-------------------------------------------------------------------------------
-- Title      : LC JTAG Master
-- Project    : STAR HFT SSD
-------------------------------------------------------------------------------
-- File       : LC_JTAG_master.vhd
-- Author     :   <thorsten@TSTEZELBERG-S25>
-- Company    : LBNL
-- Created    : 2013-03-06
-- Last update: 2013-03-18
-- Platform   : XILINX Virtex 6
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: JTAG master to control Ladder-cards and ladder
--              INPUT DATA:
--                bits 15-8: control
--                bits 7-0 : TDI data
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-03-06  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY LC_JTAG_Master IS
   PORT (
      CLK40       : IN  STD_LOGIC;
      RST         : IN  STD_LOGIC;
      -- command interface
      DATA_TDI    : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      DATA_WE     : IN  STD_LOGIC;
      BUSY_JTAG   : OUT STD_LOGIC;
      DATA_TDO    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      DATA_TDO_WE : OUT STD_LOGIC;
      -- JTAG
      TCK         : OUT STD_LOGIC;
      TMS         : OUT STD_LOGIC;
      TDI         : OUT STD_LOGIC;
      TDO         : IN  STD_LOGIC;
      -- test connector
      TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
END ENTITY LC_JTAG_Master;

ARCHITECTURE LC_JTAG_Master_arch OF LC_JTAG_Master IS

   TYPE state_type IS (IDLE, WRITE_FIRST, SHIFT_R, WAIT_DONE);
   SIGNAL sState     : state_type;
   TYPE state_tck_type IS (IDLE, TCK_LOW, TCK_HIGH);
   SIGNAL sState_tck : state_tck_type;


   -- JTAG macro commands
   CONSTANT TLR_IDLE      : STD_LOGIC_VECTOR (2 DOWNTO 0) := "001";
   CONSTANT GOTO_SHIFT_IR : STD_LOGIC_VECTOR (2 DOWNTO 0) := "010";
   CONSTANT GOTO_SHIFT_DR : STD_LOGIC_VECTOR (2 DOWNTO 0) := "011";
   CONSTANT SHIFT_REG     : STD_LOGIC_VECTOR (2 DOWNTO 0) := "100";
   CONSTANT LAST_SHIFT    : STD_LOGIC_VECTOR (2 DOWNTO 0) := "101";
   CONSTANT MARKER        : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";

   CONSTANT TCK_DIVIDER : INTEGER := 1023; --31;  -- half of the TCK clock cycle
   SIGNAL sCnt_tck       : INTEGER RANGE -2 TO TCK_DIVIDER;
   SIGNAL sTCK_LH_edge   : STD_LOGIC;
   SIGNAL sTCK_HL_edge   : STD_LOGIC;

   SIGNAL sJTAG_commad : STD_LOGIC_VECTOR (2 DOWNTO 0);
   SIGNAL sJTAG_cmd    : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sJTAG_length : STD_LOGIC_VECTOR (2 DOWNTO 0);

   SIGNAL sSrg_tdi       : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sSrg_tdo       : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sSrg_tdo_latch : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sSrg_tms       : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sCnt_srg       : INTEGER RANGE -1 TO 7;

   SIGNAL sReturn_to_idle : STD_LOGIC;
   SIGNAL sTdo_latch_flag : STD_LOGIC;

BEGIN  -- ARCHITECTURE JTAG_maser_arch

   sJTAG_commad <= DATA_TDI(10 DOWNTO 8);
   sJTAG_length <= DATA_TDI (14 DOWNTO 12);

   -- This sState machine implements JTAG sState machine macros
   -- TLR_IDLE      : Go to TestLogicReset and then to IDLE
   -- GOTO_SHIFT_IR : Go to the Shift-IR sState
   -- GOTO_SHIFT_DR : Go to the Shift-DR sState
   -- SHIFT_REG     : Shift IR or DR register
   -- LAST_SHIFT    : Do the last IR or DR shift and go to IDLE
   -- MARKER        : places a marker in the JTAG read back
   JTAG_STATES : PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS JTAG_STATES
      IF RST = '1' THEN                 -- asynchronous reset (active high)
			TDI <= '0';								-- Luis Ardila Nov 6 2013
			TMS <= '0';								-- Luis Ardila Nov 6 2013
         sSrg_tdo_latch <= (OTHERS => '0');
         sState         <= IDLE;
      ELSIF rising_edge(CLK40) THEN  -- rising clock edge
         --BUSY_JTAG <= '0';
         CASE sState IS
            WHEN IDLE =>
               sSrg_tdi        <= DATA_TDI (7 DOWNTO 0);
               sReturn_to_idle <= '0';
               sTdo_latch_flag <= '0';
               IF DATA_WE = '1' THEN
                  --             sState <= SHIFT_R;
                  sState <= WRITE_FIRST;
                  IF sJTAG_commad = TLR_IDLE THEN
                     sCnt_srg <= 7;
                     sSrg_tms <= x"7F";
                  ELSIF sJTAG_commad = GOTO_SHIFT_IR THEN
                     sCnt_srg <= 4; --3;
                     sSrg_tms <= x"06"; --x"03";
                  ELSIF sJTAG_commad = GOTO_SHIFT_DR THEN
                     sCnt_srg <= 3; --2;
                     sSrg_tms <= x"02"; --x"01";
                  ELSIF sJTAG_commad = SHIFT_REG THEN
                     sTdo_latch_flag <= '1';
                     sCnt_srg        <= TO_INTEGER(UNSIGNED(sJTAG_length));
                     sSrg_tms        <= x"00";
                  ELSIF sJTAG_commad = LAST_SHIFT THEN
                     sReturn_to_idle <= '1';
                     sTdo_latch_flag <= '1';
                     sCnt_srg        <= TO_INTEGER(UNSIGNED(sJTAG_length));
                     sSrg_tms        <= x"00";
                  ELSE
                     sState <= IDLE;
                  END IF;
               END IF;
            WHEN WRITE_FIRST =>
               --BUSY_JTAG <= '1';
               -- update TMS and TDI
               TDI     <= sSrg_tdi (0);
               sSrg_tdi <= '0' & sSrg_tdi (7 DOWNTO 1);
               TMS     <= sSrg_tms (0);
               sSrg_tms <= '0' & sSrg_tms (7 DOWNTO 1);
               sCnt_srg <= sCnt_srg - 1;

               sState <= SHIFT_R;
            WHEN SHIFT_R =>
               --BUSY_JTAG <= '1';
               IF sTCK_LH_edge = '1' THEN
                  -- read TDO
                  sSrg_tdo <= TDO & sSrg_tdo (7 DOWNTO 1);
               END IF;
               IF sTCK_HL_edge = '1' THEN
                  -- update TMS and TDI
                  TDI     <= sSrg_tdi (0);
                  sSrg_tdi <= '0' & sSrg_tdi (7 DOWNTO 1);
                  TMS     <= sSrg_tms (0);
                  sSrg_tms <= '0' & sSrg_tms (7 DOWNTO 1);
               END IF;
               IF sTCK_HL_edge = '1' THEN
                  IF sCnt_srg > 0 THEN
                     -- still shifting
                     sSrg_tdo_latch <= sSrg_tdo_latch (6 DOWNTO 0) & '0';
                     sCnt_srg       <= sCnt_srg - 1;
                  ELSE
                     -- end of shift initiate data latch from srg
                     sSrg_tdo_latch  <= sSrg_tdo_latch (6 DOWNTO 0) & sTdo_latch_flag;
                     sTdo_latch_flag <= '0';
                     sJTAG_cmd       <= "00000" & sJTAG_commad;

                     IF sReturn_to_idle = '1' THEN
                        -- we want to go back to idle
                        -- setup the sequence
                        sReturn_to_idle <= '0';
                        sCnt_srg        <= 1;
                        sSrg_tms        <= x"01";
                        TMS            <= '1';
                        sState          <= SHIFT_R;
                     ELSE
                        sState <= WAIT_DONE;
                     END IF;
                  END IF;
               ELSE
                  sState <= SHIFT_R;
               END IF;
            WHEN WAIT_DONE =>
               -- wait for the last TCK to finish
               --BUSY_JTAG <= '1';
               IF sTCK_LH_edge = '1' THEN
                  -- read TDO
                  sSrg_tdo <= TDO & sSrg_tdo (7 DOWNTO 1);
               END IF;
               IF sTCK_HL_edge = '1' THEN
                  sSrg_tdo_latch <= sSrg_tdo_latch (6 DOWNTO 0) & '0';
                  sState         <= IDLE;
               ELSE
                  sState <= WAIT_DONE;
               END IF;
            WHEN OTHERS =>
               sState <= IDLE;
         END CASE;
      END IF;
   END PROCESS JTAG_STATES;

   BUSY_JTAG <= '0' WHEN sState = IDLE ELSE '1';

   PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS
      IF RST = '1' THEN                 -- asynchronous reset (active high)
         DATA_TDO_WE <= '0';
      ELSIF falling_edge (CLK40) THEN  -- rising clock edge
         DATA_TDO_WE <= '0';
         -- place JTAG TDO data
         IF sTCK_LH_edge = '1' THEN
            IF sSrg_tdo_latch (1) = '1' THEN
               DATA_TDO    <= x"00" & sSrg_tdo;
               DATA_TDO    <= sJTAG_cmd & sSrg_tdo;
               DATA_TDO_WE <= '1';
            END IF;
         END IF;
         -- place marker
         IF (sJTAG_commad = MARKER OR sJTAG_commad = TLR_IDLE OR sJTAG_commad = GOTO_SHIFT_IR OR sJTAG_commad = GOTO_SHIFT_DR) AND DATA_WE = '1' THEN
            DATA_TDO    <= DATA_TDI;
            DATA_TDO_WE <= '1';
         END IF;
      END IF;
   END PROCESS;



   -- This process generated the JTAG TCK signal when the JTAG sState machine is
   -- not in IDLE
   -- It uses the CLK_DIVIDER constant to slow down the clock
   -- sTCK_LH_edge and sTCK_HL_edge are clock edge flags for the JTAG sState machine
   TCK_GEN : PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS TCK_GEN
      IF RST = '1' THEN                 	-- asynchronous reset (active high)
			TCK     <= '0';						-- Luis Ardila Nov 6 2013
         sState_tck <= IDLE;
      ELSIF rising_edge(CLK40) THEN  -- rising clock edge
         sTCK_LH_edge <= '0';
         sTCK_HL_edge <= '0';
         CASE sState_tck IS
            WHEN IDLE =>
               TCK     <= '0';
               sCnt_tck <= TCK_DIVIDER;
               IF sState = IDLE OR sState = WAIT_DONE THEN
                  sState_tck <= IDLE;
               ELSE
                  sState_tck <= TCK_LOW;
               END IF;
            WHEN TCK_LOW =>
               TCK     <= '0';
               sCnt_tck <= sCnt_tck - 1;
               IF sCnt_tck >= 0 THEN
                  sState_tck <= TCK_LOW;
               ELSE
                  sTCK_LH_edge <= '1';
                  sCnt_tck     <= TCK_DIVIDER;
                  sState_tck   <= TCK_HIGH;
               END IF;
            WHEN TCK_HIGH =>
               TCK     <= '1';
               sCnt_tck <= sCnt_tck - 1;
               IF sCnt_tck >= 0 THEN
                  sState_tck <= TCK_HIGH;
               ELSE
                  sTCK_HL_edge <= '1';
                  sState_tck   <= IDLE;
               END IF;
            WHEN OTHERS =>
               sState_tck <= IDLE;
         END CASE;
      END IF;
   END PROCESS TCK_GEN;

END ARCHITECTURE LC_JTAG_Master_arch;
