-- $Id: ddl_top.vhd 428 2013-10-29 21:15:53Z jschamba $
-------------------------------------------------------------------------------
-- Title      : DDL top level design
-- Project    : HFT PXL
-------------------------------------------------------------------------------
-- File       : ddl_top.vhd
-- Author     : Joachim Schambach
-- Company    : University of Texas at Austin
-- Created    : 2012-02-16
-- Last update: 2014-03-04
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top Level Component for the DDL interface.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-02-16  1.0      jschamba        Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--  Entity Declaration
ENTITY ddl IS
  PORT (
    RESET          : IN  std_logic;
    CLK            : IN  std_logic;     -- system clock
    -- DDL signals
    FICLK          : IN  std_logic;     -- DDL clock
    FITEN_n        : IN  std_logic;
    FIDIR          : IN  std_logic;
    FIBEN_n        : IN  std_logic;
    FILF_n         : IN  std_logic;
    FICTRL_n       : IN  std_logic;
    FID            : IN  std_logic_vector(31 DOWNTO 0);
    FOD            : OUT std_logic_vector(31 DOWNTO 0);
    FOBSY_n        : OUT std_logic;
    FOCTRL_n       : OUT std_logic;
    FOTEN_n        : OUT std_logic;
    SIU_T          : OUT std_logic;     -- BiDir signal direction
    -- control signals
    FEE_RESET      : OUT std_logic;
    EVT_RD_ENABLE  : OUT std_logic;
    -- From FPGA to PC
    FIFO_Q         : IN  std_logic_vector(35 DOWNTO 0);  -- interface fifo data output port
    FIFO_EMPTY     : IN  std_logic;     -- interface fifo "emtpy" signal
    FIFO_RDREQ     : OUT std_logic;     -- interface fifo read request
    FIFO_RDCLK     : OUT std_logic;     -- interface fifo read clock
    -- From PC to FPGA
    CMD_FIFO_Q     : OUT std_logic_vector(35 DOWNTO 0);  -- interface command fifo data out port
    CMD_FIFO_EMPTY : OUT std_logic;  -- interface command fifo "emtpy" signal
    CMD_FIFO_RDREQ : IN  std_logic      -- interface command fifo read request


    );
END ddl;

-- Architecture body
ARCHITECTURE a OF ddl IS
  CONSTANT CMD_FECTRL : std_logic_vector := "11000100";  -- 0xC4
  CONSTANT CMD_FESTRD : std_logic_vector := "01000100";  -- 0x44
  CONSTANT CMD_STBWR  : std_logic_vector := "11010100";  -- 0xD4
  CONSTANT CMD_STBRD  : std_logic_vector := "01010100";  -- 0x54
  CONSTANT CMD_RDYRX  : std_logic_vector := "00010100";  -- 0x14
  CONSTANT FESTW      : std_logic_vector := "01000100";  -- 0x44
  CONSTANT FESTW_EODB : std_logic_vector := "01100100";  -- 0x64

  COMPONENT fifo36x512_DDL
    PORT (
      rst    : IN  std_logic;
      wr_clk : IN  std_logic;
      rd_clk : IN  std_logic;
      din    : IN  std_logic_vector(35 DOWNTO 0);
      wr_en  : IN  std_logic;
      rd_en  : IN  std_logic;
      dout   : OUT std_logic_vector(35 DOWNTO 0);
      full   : OUT std_logic;
      empty  : OUT std_logic
      );
  END COMPONENT;

  TYPE inputState_type IS (
    IS_IDLE,
    IS_EVAL,
    IS_STBWR,
    IS_EVDATA
    );

  TYPE outputState_type IS (
    OS_IDLE,
    OS_WAITOUT,
    OS_TXDATA,
    OS_TXEMPTY,
    OS_TXGETDATA,
    OS_TXLF,
    OS_TXEODB,
    OS_TXINGAP,
    OS_WAITIN
    );

  TYPE feebusState_type IS (
    FB_INPUT,
    FB_FLOAT,
    FB_OUTPUT,
    FB_RESET
    );

  SIGNAL outputState   : outputState_type;
  SIGNAL inputState    : inputState_type;
  SIGNAL feebusState   : feebusState_type;
  SIGNAL s_areset      : std_logic;
  SIGNAL sCmdFifoD     : std_logic_vector (35 DOWNTO 0);
  SIGNAL sCmdFifoWrreq : std_logic;
  SIGNAL sCmdFifoFull  : std_logic;
  SIGNAL dout_val      : std_logic;
  SIGNAL event_read    : boolean;
  SIGNAL sDataEnd      : std_logic;
  SIGNAL sFifoRdreq    : std_logic;
  SIGNAL gap_timer     : integer RANGE 0 TO 15;
  SIGNAL fidir_d1      : std_logic := '0';
  SIGNAL fidir_d2      : std_logic := '0';
  SIGNAL sFiBen_n      : std_logic := '0';

  -- signals to delay inputs and outputs
  SIGNAL sDataIn    : std_logic_vector(31 DOWNTO 0);
  SIGNAL sDataReq   : std_logic;
  SIGNAL sFifoEmpty : std_logic;
  SIGNAL sFiD1      : std_logic_vector(31 DOWNTO 0);
  SIGNAL sFiD2      : std_logic_vector(31 DOWNTO 0);
  SIGNAL sFiTEN_n   : std_logic;
  
BEGIN
  -- direction of DDL signals
  SIU_T <= FIBEN_n OR (NOT FIDIR);

  FIFO_RDREQ <= sFifoRdreq AND FILF_n;
  FIFO_RDCLK <= FICLK;

  FEE_RESET <= s_areset;

  -- cmd FIFO
  FOBSY_n   <= NOT sCmdFifoFull;
  sCmdFifoD <= x"0" & sFiD2;
  cmd_fifo : fifo36x512_DDL
    PORT MAP (
      rst    => RESET,
      wr_clk => FICLK,
      rd_clk => CLK,
      din    => sCmdFifoD,
      wr_en  => sCmdFifoWrreq,
      rd_en  => CMD_FIFO_RDREQ,
      dout   => CMD_FIFO_Q,
      full   => sCmdFifoFull,
      empty  => CMD_FIFO_EMPTY
      );

  -- Generate FEE reset:
  -- The SIU can initiate a FEE reset by activating fiBEN_n and THEN
  -- switching FIDIR from '1' to '0'
  PROCESS (FICLK)
  BEGIN
    IF rising_edge(FICLK) THEN
      fidir_d2 <= fidir_d1;
      fidir_d1 <= FIDIR;
      sFiBen_n <= FIBEN_n;
      IF ((fidir_d2 = '1') AND (fidir_d1 = '0') AND (sFiBen_n = '0')) THEN
        s_areset <= '1';
      ELSE
        s_areset <= RESET;
      END IF;
    END IF;
  END PROCESS;

  -- Main Process
  main : PROCESS (FICLK, s_areset) IS
    VARIABLE b_rxdat       : boolean;
    VARIABLE b_rxcmd       : boolean;
    VARIABLE command_code  : std_logic_vector (7 DOWNTO 0);
    VARIABLE command_tid   : std_logic_vector (3 DOWNTO 0);
    VARIABLE command_param : std_logic_vector (18 DOWNTO 0);

  BEGIN
    IF s_areset = '1' THEN              -- asynchronous reset (active high)
      inputState  <= IS_IDLE;
      feebusState <= FB_INPUT;
      outputState <= OS_IDLE;

      b_rxdat       := false;
      b_rxcmd       := false;
      command_param := (OTHERS => '0');
      command_code  := (OTHERS => '0');
      command_tid   := (OTHERS => '0');
      sCmdFifoWrreq <= '0';
      event_read    <= false;
      EVT_RD_ENABLE <= '0';

      gap_timer <= 0;

      FOD        <= (OTHERS => '0');
      FOTEN_n    <= '1';
      FOCTRL_n   <= '1';
      sFifoRdreq <= '0';
      sDataIn    <= (OTHERS => '0');

      sFiD1    <= (OTHERS => '0');
      sFiD2    <= (OTHERS => '0');
      sFiTEN_n <= '1';

    ELSIF rising_edge(FICLK) THEN       -- rising clock edge

      sDataIn <= FIFO_Q(31 DOWNTO 0);

      sFifoEmpty <= FIFO_EMPTY;

      -- delay inputs for Block Write
      sFiD1    <= FID;
      sFiD2    <= sFiD1;
      sFiTEN_n <= FITEN_n OR NOT FICTRL_n;

      -------------------------------------------------------------------------
      -- INPUT State Machine
      -------------------------------------------------------------------------
      CASE inputState IS
        WHEN IS_IDLE =>
          IF (b_rxcmd) THEN
            inputState <= IS_EVAL;
          ELSE
            inputState <= IS_IDLE;
          END IF;

        WHEN IS_EVAL =>
          IF (command_code = CMD_STBWR) THEN
            inputState <= IS_STBWR;
          ELSIF (command_code = CMD_RDYRX) THEN
            inputState <= IS_EVDATA;
          ELSE
            inputState <= IS_IDLE;
          END IF;

        WHEN IS_STBWR =>
          IF (b_rxcmd) THEN
            inputState <= IS_IDLE;
          ELSE
            inputState <= IS_STBWR;
          END IF;

        WHEN IS_EVDATA =>
          IF (b_rxcmd OR feebusState = FB_RESET) THEN
            inputState <= IS_IDLE;
          ELSE
            inputState <= IS_EVDATA;
          END IF;

      END CASE;

      -- decode input
      b_rxdat := (FIDIR = '0') AND (FITEN_n = '0') AND (FICTRL_n = '1');
      b_rxcmd := (FIDIR = '0') AND (FITEN_n = '0') AND (FICTRL_n = '0');
      IF (b_rxcmd) THEN
        command_code  := FID(7 DOWNTO 0);
        command_tid   := FID(11 DOWNTO 8);
        command_param := FID(30 DOWNTO 12);
      END IF;

      -- Block Write
      IF (inputState = IS_STBWR) THEN
        sCmdFifoWrreq <= NOT sFiTEN_n;
      ELSE
        sCmdFifoWrreq <= '0';
      END IF;

      -- event read
      IF (inputState = IS_EVDATA) THEN
        EVT_RD_ENABLE <= '1';
        event_read    <= true;
      ELSE
        EVT_RD_ENABLE <= '0';
        event_read    <= false;
      END IF;


      -------------------------------------------------------------------------
      -- OUTPUT State Machine
      -------------------------------------------------------------------------
      CASE outputState IS
        WHEN OS_IDLE =>
          FOD        <= (OTHERS => '0');
          FOTEN_n    <= '1';
          FOCTRL_n   <= '1';
          sFifoRdreq <= '0';

          IF (feebusState = FB_FLOAT) THEN
            outputState <= OS_WAITOUT;
          ELSE
            outputState <= OS_IDLE;
          END IF;

        WHEN OS_WAITOUT =>
          FOD        <= (OTHERS => '0');
          FOTEN_n    <= '1';
          FOCTRL_n   <= '1';
          sFifoRdreq <= '0';

          IF (feebusState = FB_OUTPUT) THEN
            IF event_read THEN
              gap_timer   <= 0;
              outputState <= OS_TXEMPTY;
            ELSE
              outputState <= OS_WAITIN;
            END IF;
          ELSIF (feebusState = FB_INPUT) THEN
            outputState <= OS_IDLE;
          ELSE
            outputState <= OS_WAITOUT;
          END IF;

        WHEN OS_TXEMPTY =>
          FOD      <= (OTHERS => '0');
          FOTEN_n  <= '1';
          FOCTRL_n <= '1';

          IF (feebusState = FB_FLOAT OR feebusState = FB_RESET) THEN
            sFifoRdreq  <= '0';
            outputState <= OS_WAITIN;
          ELSIF (FIFO_EMPTY = '1') THEN
            sFifoRdreq  <= '0';
            outputState <= OS_TXEMPTY;
          ELSE
            sFifoRdreq  <= '1';
            outputState <= OS_TXGETDATA;
          END IF;

        WHEN OS_TXGETDATA =>
          sFifoRdreq  <= '1';
          outputState <= OS_TXDATA;
          
        WHEN OS_TXDATA =>
          FOD      <= FIFO_Q(31 DOWNTO 0);
          FOTEN_n  <= sFifoEmpty;
          foCTRL_N <= '1';

          IF (feebusState = FB_FLOAT OR feebusState = FB_RESET) THEN
            sFifoRdreq  <= '0';
            outputState <= OS_WAITIN;
          ELSIF FILF_n = '0' THEN
            FOTEN_n     <= '1';
            outputState <= OS_TXLF;
          ELSIF FIFO_Q(32) = '1' THEN
            sFifoRdreq  <= '0';
            gap_timer   <= 0;
            outputState <= OS_TXEODB;
          ELSIF FIFO_EMPTY = '1' THEN
            sFifoRdreq  <= '0';
            outputState <= OS_TXEMPTY;
          ELSE
            sFifoRdreq  <= '1';
            outputState <= OS_TXDATA;
          END IF;

        WHEN OS_TXLF =>
          FOD        <= (OTHERS => '0');
          FOTEN_n    <= '1';
          FOCTRL_n   <= '1';
          sFifoRdreq <= (NOT FIFO_EMPTY) AND FILF_n;

          IF (feebusState = FB_FLOAT OR feebusState = FB_RESET) THEN
            sFifoRdreq  <= '0';
            outputState <= OS_WAITIN;
          ELSIF (FILF_n = '0') THEN
            sFifoRdreq  <= '0';
            outputState <= OS_TXLF;
          ELSE
            -- re-transmit previous data word
            FOD         <= sDataIn;
            -- make sure FOTEN_n is asserted at least once
            -- if FIFO is empty at this point
            -- otherwise, FOTEN_n is asserted in OS_TXDATA
            FOTEN_n     <= NOT FIFO_EMPTY;
            outputState <= OS_TXDATA;
          END IF;

        WHEN OS_TXEODB =>
          IF (feebusState = FB_FLOAT OR feebusState = FB_RESET) THEN
            FOD        <= (OTHERS => '0');
            FOTEN_n    <= '1';
            FOCTRL_n   <= '1';
            sFifoRdreq <= '0';

            outputState <= OS_WAITIN;
          ELSIF (gap_timer = 1) THEN
            gap_timer  <= 0;
            FOD        <= x"000000" & FESTW_EODB;
            FOTEN_n    <= '0';
            foCTRL_N   <= '0';
            sFifoRdreq <= '0';

            outputState <= OS_TXINGAP;
          ELSE
            FOD        <= (OTHERS => '0');
            FOTEN_n    <= '1';
            FOCTRL_n   <= '1';
            sFifoRdreq <= '0';
            gap_timer  <= gap_timer + 1;

            outputState <= OS_TXEODB;
          END IF;

        WHEN OS_TXINGAP =>
          FOD        <= (OTHERS => '0');
          FOTEN_n    <= '1';
          FOCTRL_n   <= '1';
          sFifoRdreq <= '0';

          IF (feebusState = FB_FLOAT OR feebusState = FB_RESET) THEN
            outputState <= OS_WAITIN;
          ELSIF (gap_timer = 15) AND ((FIFO_EMPTY = '1') OR (FIFO_Q(32) = '1')) THEN
            outputState <= OS_TXEMPTY;
          ELSIF gap_timer = 15 THEN
            outputState <= OS_TXGETDATA;
          ELSE
            gap_timer   <= gap_timer + 1;
            outputState <= OS_TXINGAP;
          END IF;

        WHEN OS_WAITIN =>
          FOD        <= (OTHERS => '0');
          FOTEN_n    <= '1';
          FOCTRL_n   <= '1';
          sFifoRdreq <= '0';

          IF (feebusState = FB_INPUT) THEN
            outputState <= OS_IDLE;
          ELSE
            outputState <= OS_WAITIN;
          END IF;
      END CASE;


      -------------------------------------------------------------------------
      -- FEEBUS State Machine
      -------------------------------------------------------------------------
      CASE feebusState IS
        WHEN FB_INPUT =>
          IF (fiBEN_N = '1') THEN
            feebusState <= FB_FLOAT;
          ELSE
            feebusState <= FB_INPUT;
          END IF;

        WHEN FB_FLOAT =>
          IF (fiBEN_N = '0') THEN
            IF (fiDIR = '0') THEN
              feebusState <= FB_INPUT;
            ELSE
              feebusState <= FB_OUTPUT;
            END IF;
          ELSE
            feebusState <= FB_FLOAT;
          END IF;

        WHEN FB_OUTPUT =>
          IF (fiBEN_N = '1') THEN
            feebusState <= FB_FLOAT;
          ELSIF (fiDIR = '0') THEN
            feebusState <= FB_RESET;
          ELSE
            feebusState <= FB_OUTPUT;
          END IF;

        WHEN FB_RESET =>
          feebusState <= FB_INPUT;

      END CASE;

    END IF;
  END PROCESS main;

END a;
