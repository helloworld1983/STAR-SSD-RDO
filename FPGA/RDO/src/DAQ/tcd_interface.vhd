-- $Id$
-------------------------------------------------------------------------------
-- Title      : TCD Interface
-- Project    : HFT PXL
-------------------------------------------------------------------------------
-- File       : tcd_interface.vhd
-- Author     : Joachim Schambach
-- Company    : University of Texas 
-- Created    : 2012-07-25
-- Last update: 2013-10-07
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Interface to TCD triggers
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-07-25  1.0      jschamba        Created
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tcd_interface IS
  
  PORT (
    CLK        : IN  std_logic;         -- 50 MHz clock
    RST        : IN  std_logic;         -- Async. reset
    -- TCD signals
    RS         : IN  std_logic;         -- TCD RHIC strobe
    RSx5       : IN  std_logic;         -- TCD data clock
    TCD_DATA   : IN  std_logic_vector (3 DOWNTO 0);   -- TCD data
    -- Interface signals
    WORKING    : OUT std_logic;         -- TCD interface is working
    RS_CTR     : OUT std_logic_vector (31 DOWNTO 0);  -- RHICstrobe counter
    TRGWORD    : OUT std_logic_vector (19 DOWNTO 0);  -- captured 20bit trigger word
    MASTER_RST : OUT std_logic;         -- indicates master reset command
    FIFO_Q     : OUT std_logic_vector (19 DOWNTO 0);  -- Triggerwords for inclusion in data
    FIFO_EMPTY : OUT std_logic;         -- Triggerwords FIFO emtpy
    FIFO_RDREQ : IN  std_logic;         -- Read Request for Triggerwords FIFO
    EVT_TRG    : OUT std_logic   -- this signal indicates an event to read
    );

END ENTITY tcd_interface;

ARCHITECTURE impl OF tcd_interface IS
  COMPONENT fifo20x512
    PORT (
      rst    : IN  std_logic;
      wr_clk : IN  std_logic;
      rd_clk : IN  std_logic;
      din    : IN  std_logic_vector(19 DOWNTO 0);
      wr_en  : IN  std_logic;
      rd_en  : IN  std_logic;
      dout   : OUT std_logic_vector(19 DOWNTO 0);
      full   : OUT std_logic;
      empty  : OUT std_logic
      );
  END COMPONENT;

  TYPE rsState_type IS (R0l, R0h, R1, R2, R3, R4, R5);
  SIGNAL rsState : rsState_type;

  SIGNAL s_reg1       : std_logic_vector (3 DOWNTO 0);
  SIGNAL s_reg2       : std_logic_vector (3 DOWNTO 0);
  SIGNAL s_reg3       : std_logic_vector (3 DOWNTO 0);
  SIGNAL s_reg4       : std_logic_vector (3 DOWNTO 0);
  SIGNAL s_reg5       : std_logic_vector (3 DOWNTO 0);
  SIGNAL s_reg20      : std_logic_vector (19 DOWNTO 0);
  SIGNAL s_trgwrd     : std_logic_vector (19 DOWNTO 0);
  SIGNAL s_trg_unsync : std_logic;
  SIGNAL s_lstage1    : std_logic;
  SIGNAL s_lstage2    : std_logic;
  SIGNAL s_mstage1    : std_logic;
  SIGNAL s_mstage2    : std_logic;
  SIGNAL s_L0like     : std_logic;
  SIGNAL s_trigger    : std_logic;
  SIGNAL s_reset      : std_logic;
  SIGNAL s_clear      : std_logic;
  SIGNAL s_mstr_rst   : std_logic;
  SIGNAL sFifoWrEn    : std_logic;
  SIGNAL sFifoWrClk   : std_logic;
  SIGNAL sRSCtrRst    : std_logic;
  SIGNAL sRSCtr       : unsigned (31 DOWNTO 0);
  SIGNAL sRSCtrSynced : std_logic_vector (31 DOWNTO 0);
  SIGNAL s_counter    : integer RANGE 0 TO 63;

  
BEGIN  -- ARCHITECTURE

  -- reset the state machine on external reset
  s_reset <= RST;

  -- capture the trigger data in a cascade of five 4-bit registers
  -- with the tcd data clock on trailing clock edge.
  Main : PROCESS (RSx5, s_reset, s_reg20) IS
    VARIABLE vRS_reg1 : std_logic := '0';
    VARIABLE vRS_reg2 : std_logic := '0';
    VARIABLE vRS_edge : std_logic := '0';
  BEGIN
    IF s_reset = '1' THEN               -- asynchronous reset (active high)
      s_reg1   <= (OTHERS => '0');
      s_reg2   <= (OTHERS => '0');
      s_reg3   <= (OTHERS => '0');
      s_reg4   <= (OTHERS => '0');
      s_reg5   <= (OTHERS => '0');
      s_reg20  <= (OTHERS => '0');
      s_trgwrd <= (OTHERS => '0');
      WORKING  <= '0';                  -- trigger doesn't work (yet)

      s_trg_unsync <= '0';
      s_L0like     <= '0';
      s_mstr_rst   <= '0';
      s_clear      <= '0';

      rsState <= R0l;
      
    ELSIF falling_edge(RSx5) THEN
      WORKING <= '1';                   -- default: "it works"

      -- defaults:
      sFifoWrEn <= '0';

      -- find rising edge of RHICstrobe
      vRS_edge := vRS_reg1 AND NOT vRS_reg2;
      vRS_reg2 := vRS_reg1;
      vRS_reg1 := RS;

      CASE rsState IS
        WHEN R0l =>
          WORKING <= '0';               -- not "working right" (yet)

          -- Reset everything
          s_trgwrd <= (OTHERS => '0');
          s_reg20  <= (OTHERS => '0');

          s_reg1 <= (OTHERS => '0');
          s_reg2 <= (OTHERS => '0');
          s_reg3 <= (OTHERS => '0');
          s_reg4 <= (OTHERS => '0');
          s_reg5 <= (OTHERS => '0');

          -- wait for RHICstrobe to be low
          IF RS = '0' THEN
            rsState <= R0h;
          END IF;

        WHEN R0h =>
          WORKING <= '0';               -- not "working right" (yet)

          s_trgwrd <= s_trgwrd;
          s_reg20  <= s_reg20;

          s_reg1 <= TCD_DATA;           -- latch current nibble as 1st nibble

          -- wait for rising edge of RHICstrobe
          IF vRS_edge = '1' THEN
            rsState <= R3;              -- next state
          END IF;

        -- now the state machine should be aligned to the RHICstrobe
        WHEN R1 =>
          s_trgwrd <= s_trgwrd;

          -- make sure we see RHICstrobe being high during this nibble
          IF RS = '1' THEN
            -- latch current nibbles into 20bit register
            s_reg20(19 DOWNTO 16) <= s_reg1;
            s_reg20(15 DOWNTO 12) <= s_reg2;
            s_reg20(11 DOWNTO 8)  <= s_reg3;
            s_reg20(7 DOWNTO 4)   <= s_reg4;
            s_reg20(3 DOWNTO 0)   <= s_reg5;

            s_reg1 <= TCD_DATA;         -- 1st nibble

            rsState <= R2;              -- next state
            
          ELSE
            s_reg20 <= (OTHERS => '0');
            -- try new sync, if not at proper edge
            rsState <= R0l;             -- next state
          END IF;
          
        WHEN R2 =>
          -- trigger word stays latched
          s_trgwrd <= s_trgwrd;
          s_reg20  <= s_reg20;

          s_reg2 <= TCD_DATA;           -- 2nd nibble

          rsState <= R3;                -- next state
          
        WHEN R3 =>
          -- latch current 20bits for output
          s_trgwrd <= s_reg20;
          s_reg20  <= s_reg20;

          -- latch triggerword into FIFO
          sFifoWrEn <= s_trg_unsync;

          s_reg3 <= TCD_DATA;           -- 3rd nibble

          rsState <= R4;                -- next state
          
        WHEN R4 =>
          -- trigger word stays latched
          s_trgwrd <= s_trgwrd;
          s_reg20  <= s_reg20;

          s_reg4 <= TCD_DATA;           -- 4th nibble

          rsState <= R5;                -- next state
          
        WHEN R5 =>
          -- trigger word stays latched
          s_trgwrd <= s_trgwrd;
          s_reg20  <= s_reg20;

          s_reg5 <= TCD_DATA;           -- 5th nibble

          rsState <= R1;                -- next state
      END CASE;
    END IF;

    -- check what kind of trigger
    CASE s_reg20(19 DOWNTO 16) IS
      WHEN x"4" =>                      -- "4" (trigger0)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"5" =>                      -- "5" (trigger1)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"6" =>                      -- "6" (trigger2)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"7" =>                      -- "7" (trigger3)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"8" =>                      -- "8" (pulser0)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"9" =>                      -- "9" (pulser1)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"A" =>                      -- "10" (pulser2)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"B" =>                      -- "11" (pulser3)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"C" =>                      -- "12" (config)
        s_trg_unsync <= '1';
        s_L0like     <= '1';
      WHEN x"D" =>                      -- "13" (abort)
        s_trg_unsync <= '1';
        s_L0like     <= '0';
      WHEN x"E" =>                      -- "14" (L1accept)
        s_trg_unsync <= '1';
        s_L0like     <= '0';
      WHEN x"F" =>                      -- "15" (L2accept)
        s_trg_unsync <= '1';
        s_L0like     <= '0';
      WHEN OTHERS =>                    -- all others are not recorded
        s_trg_unsync <= '0';
        s_L0like     <= '0';
    END CASE;

    IF s_reg20(19 DOWNTO 16) = x"2" THEN  -- "2" (Master Reset)
      s_mstr_rst <= '1';
    ELSE
      s_mstr_rst <= '0';
    END IF;

    IF s_reg20(19 DOWNTO 16) = x"1" THEN  -- "1" (Clear)
      s_clear <= '1';
    ELSE
      s_clear <= '0';
    END IF;
    

  END PROCESS Main;

  -- when a valid trigger command is found, synchronize the resulting trigger
  -- to the 50MHz clock with a 3 stage DFF cascade and make the signal
  -- exactly 1 clock wide
  syncit : PROCESS (CLK) IS
  BEGIN
    IF rising_edge(CLK) THEN
      s_lstage1 <= s_L0like;
      s_lstage2 <= s_lstage1;

      s_mstage1 <= s_mstr_rst;
      s_mstage2 <= s_mstage1;

      TRGWORD <= s_trgwrd;
    END IF;
  END PROCESS syncit;

  EVT_TRG    <= s_lstage2 AND (NOT s_lstage1);
  MASTER_RST <= s_mstage2 AND (NOT s_mstage1);


  -- store the triggerwords in a FIFO for later inclusion in the data stream
  sFifoWrClk <= NOT RSx5;
  fifo_inst : fifo20x512                -- 20bit wide x 512 deep
    PORT MAP (
      rst    => RST,
      wr_clk => sFifoWrClk,
      rd_clk => CLK,
      din    => s_trgwrd,
      wr_en  => sFifoWrEn,
      rd_en  => FIFO_RDREQ,
      dout   => FIFO_Q,
      full   => OPEN,
      empty  => FIFO_EMPTY
      );


  -- Count RHICstrobes
  sRSCtrRst <= RST OR s_mstr_rst OR s_clear;
  rsctr : PROCESS (RS, sRSCtrRST) IS
  BEGIN
    IF sRSCtrRst = '1' THEN             -- asynchronous reset (active high)
      sRSCtr <= (OTHERS => '0');
    ELSIF rising_edge(RS) THEN          -- rising clock edge
      sRSCtr <= sRSCtr + 1;
    END IF;
  END PROCESS rsctr;

  -- sync RHICstrobe counter to 50MHz clock
  rsctr_sync : PROCESS (CLK, RST) IS
  BEGIN
    IF RST = '1' THEN                   -- asynchronous reset (active high)
      RS_CTR <= (OTHERS => '0');
    ELSIF rising_edge(CLK) THEN         -- rising clock edge
      sRSCtrSynced <= std_logic_vector(sRSCtr);
      RS_CTR       <= sRSCtrSynced;
    END IF;
  END PROCESS rsctr_sync;

END ARCHITECTURE impl;