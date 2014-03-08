-- $Id: tcd_interface.vhd 531 2014-02-11 17:47:51Z jschamba $
-------------------------------------------------------------------------------
-- Title      : TCD Interface
-- Project    : HFT PXL
-------------------------------------------------------------------------------
-- File       : tcd_interface.vhd
-- Author     : Joachim Schambach
-- Company    : University of Texas 
-- Created    : 2012-07-25
-- Last update: 2014-02-10
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
    CLK50      : IN  std_logic;         -- 50 MHz clock
    CLK200     : IN  std_logic;         -- 200 MHz clock
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
    FIFO_RST   : IN  std_logic;         -- Reset TCD FIFO
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


  TYPE rsState_type IS (R_INIT, R1, R2, R3, R4, R5, R6);
  SIGNAL rsState : rsState_type;

  SIGNAL s_reg1     : std_logic_vector (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_reg2     : std_logic_vector (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_reg3     : std_logic_vector (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_reg4     : std_logic_vector (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_reg20    : std_logic_vector (19 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_trgwrd   : std_logic_vector (19 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sTrg       : std_logic := '0';
  SIGNAL sTrg_buf   : std_logic := '0';
  SIGNAL s_lstage1  : std_logic := '0';
  SIGNAL s_lstage2  : std_logic := '0';
  SIGNAL s_mstage1  : std_logic := '0';
  SIGNAL s_mstage2  : std_logic := '0';
  SIGNAL s_L0like   : std_logic := '0';
  SIGNAL s_reset    : std_logic := '0';
  SIGNAL s_clear    : std_logic := '0';
  SIGNAL s_mstr_rst : std_logic := '0';
  SIGNAL sFifoWrEn  : std_logic := '0';
  SIGNAL sFifoRst   : std_logic := '0';
  SIGNAL sRSCtr     : unsigned (31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sRS        : std_logic := '0';
  SIGNAL sRS_buf    : std_logic := '0';
  SIGNAL sRSx5      : std_logic := '0';
  SIGNAL sRSx5_buf  : std_logic := '0';
  SIGNAL sTCD_DATA  : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');

  
BEGIN  -- ARCHITECTURE



-- reset the state machine on external reset
  s_reset <= RST;

  -- capture the trigger data in a cascade of five 4-bit registers
  -- with the tcd data clock on trailing clock edge.
  Main : PROCESS (CLK200, s_reset) IS
  BEGIN  -- PROCESS Main
    IF s_reset = '1' THEN               -- asynchronous reset (active high)
      -- Reset everything
      s_reg20   <= (OTHERS => '0');
      s_reg1    <= (OTHERS => '0');
      s_reg2    <= (OTHERS => '0');
      s_reg3    <= (OTHERS => '0');
      s_reg4    <= (OTHERS => '0');
      sRSCtr    <= (OTHERS => '0');
      sRS       <= '0';
      sRS_buf   <= '0';
      sRSx5     <= '0';
      sRSx5_buf <= '0';
      WORKING   <= '0';

      rsState <= R_INIT;
      
    ELSIF rising_edge(CLK200) THEN      -- rising clock edge
      -- defaults:
      WORKING <= '1';

      -- sync'd RHIC strobe
      sRS_buf <= sRS;
      sRS     <= RS;

      -- sync'd TCD DATA Clock
      sRSx5_buf <= sRSx5;
      sRSx5     <= RSx5;

      -- sync'd TCD DATA
      sTCD_DATA <= TCD_DATA;

      IF (s_clear = '1') OR (s_mstr_rst = '1') THEN
        sRSCtr <= (OTHERS => '0');
      END IF;

      CASE rsState IS
--      //// Initialize everything
        WHEN R_INIT =>
          -- Reset everything
          s_reg20 <= (OTHERS => '0');
          s_reg1  <= (OTHERS => '0');
          s_reg2  <= (OTHERS => '0');
          s_reg3  <= (OTHERS => '0');
          s_reg4  <= (OTHERS => '0');
          sRSCtr  <= (OTHERS => '0');

          WORKING <= '0';
          -- wait for rising edge of sync'd RHIC strobe
          IF (sRS = '1') AND (sRS_buf = '0') THEN
            rsState <= R1;
          END IF;

--      //// First nibble
        WHEN R1 =>
          -- wait for falling edge of sync'd RSx5
          -- but make sure RHIC strobe is high
          IF sRS = '0' THEN
            -- RHIC strobe should be high here
            rsState <= R_INIT;
          ELSIF (sRSx5 = '0') AND (sRSx5_buf = '1') THEN
            s_reg1  <= sTCD_DATA;
            -- count RHIC strobes here
            sRSCtr  <= sRSCtr + 1;
            rsState <= R2;
          END IF;
          
--      //// Second nibble
        WHEN R2 =>
          -- wait for falling edge of sync'd RSx5
          IF (sRSx5 = '0') AND (sRSx5_buf = '1') THEN
            s_reg2  <= sTCD_DATA;
            rsState <= R3;
          END IF;
          
--      //// Third nibble
        WHEN R3 =>
          -- wait for falling edge of sync'd RSx5
          IF (sRSx5 = '0') AND (sRSx5_buf = '1') THEN
            s_reg3  <= sTCD_DATA;
            rsState <= R4;
          END IF;
          
--      //// Fourth nibble
        WHEN R4 =>
          -- wait for falling edge of sync'd RSx5
          IF (sRSx5 = '0') AND (sRSx5_buf = '1') THEN
            s_reg4  <= sTCD_DATA;
            rsState <= R5;
          END IF;
          
--      //// Fifth nibble
        WHEN R5 =>
          -- wait for falling edge of sync'd RSx5
          IF sRS = '1' THEN
            -- RHIC strobe should be low here
            rsState <= R_INIT;
          ELSIF (sRSx5 = '0') AND (sRSx5_buf = '1') THEN
            -- latch 20bit word
            s_reg20(19 DOWNTO 16) <= s_reg1;
            s_reg20(15 DOWNTO 12) <= s_reg2;
            s_reg20(11 DOWNTO 8)  <= s_reg3;
            s_reg20(7 DOWNTO 4)   <= s_reg4;
            s_reg20(3 DOWNTO 0)   <= sTCD_DATA;
            rsState <= R6;
          END IF;

--      //// Next RHIC strobe
        WHEN R6 =>
          -- wait for next leading edge of RHIC strobe
          IF (sRS = '1') AND (sRS_buf = '0') THEN
            rsState <= R1;
          END IF;
          
--      //// Shouldn't happen
        WHEN OTHERS =>
          rsState <= R_INIT;
      END CASE;
      
    END IF;
  END PROCESS Main;

  -- Check the trigger word
  Trigger : PROCESS (CLK50, s_reset) IS
  BEGIN
    IF s_reset = '1' THEN               -- asynchronous reset (active high)
      sTrg       <= '0';
      sTrg_buf   <= '0';
      s_L0like   <= '0';
      s_mstr_rst <= '0';
      s_clear    <= '0';
      s_trgwrd   <= (OTHERS => '0');
      
    ELSIF rising_edge(CLK50) THEN       -- rising clock edge
      sTrg       <= '0';
      s_L0like   <= '0';
      s_mstr_rst <= '0';
      s_clear    <= '0';

      s_trgwrd <= s_reg20;

      -- check what kind of trigger
      CASE s_trgwrd(19 DOWNTO 16) IS
        WHEN x"4" =>                    -- "4" (trigger0)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"5" =>                    -- "5" (trigger1)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"6" =>                    -- "6" (trigger2)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"7" =>                    -- "7" (trigger3)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"8" =>                    -- "8" (pulser0)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"9" =>                    -- "9" (pulser1)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"A" =>                    -- "10" (pulser2)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"B" =>                    -- "11" (pulser3)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"C" =>                    -- "12" (config)
          sTrg     <= '1';
          s_L0like <= '1';
        WHEN x"D" =>                    -- "13" (abort)
          sTrg     <= '1';
          s_L0like <= '0';
        WHEN x"E" =>                    -- "14" (L1accept)
          sTrg     <= '1';
          s_L0like <= '0';
        WHEN x"F" =>                    -- "15" (L2accept)
          sTrg     <= '1';
          s_L0like <= '0';
        WHEN OTHERS =>                  -- all others are not recorded
          sTrg     <= '0';
          s_L0like <= '0';
      END CASE;

      -- Trigger command "2" (Master Reset)
      IF s_trgwrd(19 DOWNTO 16) = x"2" THEN
        s_mstr_rst <= '1';
      ELSE
        s_mstr_rst <= '0';
      END IF;

      -- Trigger command "1" (Clear)
      IF s_trgwrd(19 DOWNTO 16) = x"1" THEN
        s_clear <= '1';
      ELSE
        s_clear <= '0';
      END IF;
      
      -- for FIFO Write enable:
      sTrg_buf  <= sTrg;
    END IF;
  END PROCESS Trigger;

  -- store the triggerwords in a FIFO for later inclusion in the data stream
  sFifoRst <= RST OR FIFO_RST;
  sFifoWrEn <= sTrg AND (NOT sTrg_buf);
  fifo_inst : fifo20x512                -- 20bit wide x 512 deep
    PORT MAP (
      rst    => sFifoRst,
      wr_clk => CLK50,
      rd_clk => CLK50,
      din    => s_trgwrd,
      wr_en  => sFifoWrEn,
      rd_en  => FIFO_RDREQ,
      dout   => FIFO_Q,
      full   => OPEN,
      empty  => FIFO_EMPTY
      );


  -- when a valid trigger command is found, synchronize the resulting trigger
  -- to the 50MHz clock with a 2 stage DFF cascade and make the signal
  -- exactly 1 clock wide
  shorten : PROCESS (CLK50) IS
  BEGIN
    IF rising_edge(CLK50) THEN
      s_lstage1 <= s_L0like;
      s_lstage2 <= s_lstage1;

      s_mstage1 <= s_mstr_rst;
      s_mstage2 <= s_mstage1;

      -- output Trigger word and RHIC strobe counter with 50MHz clock
      TRGWORD <= s_trgwrd;
      RS_CTR  <= std_logic_vector(sRSCtr);
    END IF;
  END PROCESS shorten;

  EVT_TRG    <= s_lstage1 AND (NOT s_lstage2);
  MASTER_RST <= s_mstage2 AND (NOT s_mstage1);


END ARCHITECTURE impl;
