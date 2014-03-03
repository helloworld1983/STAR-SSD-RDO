--------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2014
-- Create Date:   11:55:16 11/19/2013
-- Last Edited:   Feb 10 2014
-- Design Name:   
-- Module Name:   
-- Project Name:  SSD_RDO
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- 
-- Dependencies:
-- 
-- Revisions:
-- Date        Version    Author    Description
-- 11:55:16 11/19/2013    1.0    Luis Ardila    File created
-- Additional Comments:
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.NUMERIC_STD.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.all;

ENTITY SYSTEM_TB IS
END SYSTEM_TB;
 
ARCHITECTURE SYSTEM_TB_ARCH OF SYSTEM_TB IS 

	COMPONENT M_FT2232H IS
		PORT (
			 CLK            : IN  std_logic;     -- 50MHz clock input
			 RESET          : IN  std_logic;     -- Active high reset
			 -- FT2232H signals
			 D_in           : IN  std_logic_vector(7 DOWNTO 0);   -- FIFO Data bus in
			 D_out          : OUT std_logic_vector(7 DOWNTO 0);   -- FIFO Data bus out
			 D_T            : OUT std_logic;     -- FIFO Data bus enable
			 -- "C" Port
			 RXF_n          : IN  std_logic;     -- Read enable
			 TXE_n          : IN  std_logic;     -- Write enable
			 RD_n           : OUT std_logic;     -- Read from USB FIFO
			 WR_n           : OUT std_logic;     -- Write to USB FIFO
			 SIWU           : OUT std_logic;     -- Send Immediate/Wake Up
			 CLKOUT         : IN  std_logic;     -- Sync USB FIFO clock
			 OE_n           : OUT std_logic;     -- Output enable (for sync FIFO)
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
	END COMPONENT M_FT2232H;


   COMPONENT DAQ
      PORT (
         CLK40                       : IN  STD_LOGIC;
         CLK80                       : IN  STD_LOGIC;
         RST                         : IN  STD_LOGIC;
         --GENERAL
         BoardID                     : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         Data_FormatV                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         FPGA_BuildN                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         --LC_Registers 
         LC_RST                      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         --CONFIG
         CONFIG_CMD_IN               : IN  FIBER_ARRAY_TYPE_16;
         CONFIG_DATA_IN              : IN  FIBER_ARRAY_TYPE_16;
         CONFIG_DATA_IN_WE           : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         CONFIG_BUSY                 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         CONFIG_STATUS_OUT           : OUT FIBER_ARRAY_TYPE_16;
         --JTAG
         JTAG_DATA_TDI               : IN  FIBER_ARRAY_TYPE_16;
         JTAG_DATA_WE                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         JTAG_BUSY                   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         JTAG_DATA_TDO               : OUT FIBER_ARRAY_TYPE_16;
         -- PIPE
         ADC_offset                  : IN  FIBER_ARRAY_TYPE_16;
         Zero_supr_trsh              : IN  FIBER_ARRAY_TYPE_16;
         ZST_Polarity                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         Pipe_Selector               : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         -- TCD Registers
         TCD_DELAY_Reg               : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         TCD_EN_TRGMODES_Reg         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
         Forced_Triggers_Reg         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
         Status_Counters_RST_REG     : IN  STD_LOGIC;
         TCD_Level0_RCVD_REG         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         RHIC_STROBE_LSB_REG         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         RHIC_STROBE_MSB_REG         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         N_HOLDS_REG                 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         N_TESTS_REG                 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- data packer status registers
         TCD_TRG_RCVD_REG            : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         SIU_PACKET_CNT_REG          : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- pedestal memory write port
         iPedMemWrite                : IN  PED_MEM_WRITE;
         --BUSY
         BUSY_COMBINED               : OUT STD_LOGIC;
         --LC_Trigger_Handler
         TEST2HOLD_DELAY             : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         --LC STATUS
         LC_STATUS_REG               : OUT FIBER_ARRAY_TYPE_16_8;
         LC_HYBRIDS_POWER_STATUS_REG : OUT FIBER_ARRAY_TYPE_16;
         --TCD INTERFASE
         RS                          : IN  STD_LOGIC;  -- TCD RHIC strobe
         RSx5                        : IN  STD_LOGIC;  -- TCD data clock
         TCD_DATA                    : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);  -- TCD data
         --SIU DDL LINK
         DDL_FIFO_Q                  : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface fifo data output port
         DDL_FIFO_EMPTY              : OUT STD_LOGIC;  -- interface fifo "emtpy" signal
         DDL_FIFO_RDREQ              : IN  STD_LOGIC;  -- interface fifo read request
         DDL_FIFO_RDCLK              : IN  STD_LOGIC;  -- interface fifo read clock
         -- fiber links
         Fiber_LCtoRDO               : IN  FIBER_ARRAY_TYPE;
         Fiber_RDOtoLC               : OUT FIBER_ARRAY_TYPE;
         -- test connector
         TC                          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT DAQ;

   COMPONENT USB_DECODER IS
      PORT (
         CLK40                       : IN  STD_LOGIC;
         RST                         : IN  STD_LOGIC;
--FTDI INTERFACE
         -- CMD FIFO
         CMD_FIFO_Q                  : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
         CMD_FIFO_EMPTY              : IN  STD_LOGIC;
         CMD_FIFO_RDREQ              : OUT STD_LOGIC;
         -- From FPGA to PC
         FIFO_Q                      : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface fifo data output port
         FIFO_EMPTY                  : OUT STD_LOGIC;  -- interface fifo "emtpy" signal
         FIFO_RDREQ                  : IN  STD_LOGIC;  -- interface fifo read request
         FIFO_RDCLK                  : IN  STD_LOGIC;  -- interface fifo read clock
--LC_INTERFACES
         --LC_Registers 
         LC_RST                      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         --CONFIG
         CONFIG_CMD_IN               : OUT FIBER_ARRAY_TYPE_16;
         CONFIG_DATA_IN              : OUT FIBER_ARRAY_TYPE_16;
         CONFIG_DATA_IN_WE           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         CONFIG_BUSY                 : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         CONFIG_STATUS_OUT           : IN  FIBER_ARRAY_TYPE_16;
         --JTAG
         JTAG_DATA_TDI               : OUT FIBER_ARRAY_TYPE_16;
         JTAG_DATA_WE                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         JTAG_BUSY                   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         JTAG_DATA_TDO               : IN  FIBER_ARRAY_TYPE_16;
         -- PIPE
         ADC_offset                  : OUT FIBER_ARRAY_TYPE_16;
         Zero_supr_trsh              : OUT FIBER_ARRAY_TYPE_16;
         ZST_Polarity                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         Pipe_Selector               : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
         -- TCD Registers
         TCD_DELAY_Reg               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         TCD_EN_TRGMODES_Reg         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
         Forced_Triggers_Reg         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
         Status_Counters_RST_REG     : OUT STD_LOGIC;
         TCD_Level0_RCVD_REG         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         RHIC_STROBE_LSB_REG         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         RHIC_STROBE_MSB_REG         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         N_HOLDS_REG                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         N_TESTS_REG                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- data packer status registers
         TCD_TRG_RCVD_REG            : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         SIU_PACKET_CNT_REG          : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         --BUSY_COMBINED
         BUSY_COMBINED               : IN  STD_LOGIC;
         --LC_Trigger_Handler
         TEST2HOLD_DELAY             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         --LC STATUS
         LC_STATUS_REG               : IN  FIBER_ARRAY_TYPE_16_8;
         LC_HYBRIDS_POWER_STATUS_REG : IN  FIBER_ARRAY_TYPE_16;
--GENERAL
         BoardID                     : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         Data_FormatV                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         FPGA_BuildN                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         CalLVDS                     : OUT STD_LOGIC;
         LVDS_CNT_EN                 : OUT STD_LOGIC;  -- MrAT external counter control
         -- pedestal memory write port
         oPedMemWrite                : OUT PED_MEM_WRITE
         );
   END COMPONENT USB_DECODER;

	COMPONENT MFT2232_SIMU IS
		PORT(
			---------------------------------------------------------------------------
			-- Motherboard FT2232H adapter board ("MFT")
			---------------------------------------------------------------------------
			MFT_PWREN_n       : OUT    STD_LOGIC;
			MFT_SUSPEND_n     : OUT    STD_LOGIC;
			MFT_RESET_n       : IN   STD_LOGIC;
			-- 
			MFT_EEDATA        : OUT    STD_LOGIC;
			MFT_EECS          : OUT    STD_LOGIC;
			MFT_EECLK         : OUT    STD_LOGIC;
			-- 
			MFTA_D            : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			MFTB_D            : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			-- 
			MFTA_RXF_n        : OUT    STD_LOGIC;
			MFTA_TXE_n        : OUT    STD_LOGIC;
			MFTA_RD_n         : IN   STD_LOGIC;
			MFTA_WR_n         : IN   STD_LOGIC;
			MFTA_SIWU         : IN   STD_LOGIC;
			MFTA_CLKOUT       : OUT    STD_LOGIC;
			MFTA_OE_n         : IN   STD_LOGIC;
			MFTA_C7           : OUT    STD_LOGIC;
			-- 
			MFTB_RXF_n        : OUT    STD_LOGIC;
			MFTB_TXE_n        : OUT    STD_LOGIC;
			MFTB_RD_n         : IN   STD_LOGIC;
			MFTB_WR_n         : IN   STD_LOGIC;
			MFTB_SIWU         : IN   STD_LOGIC;
			MFTB_CLKOUT       : OUT    STD_LOGIC;
			MFTB_OE_n         : IN   STD_LOGIC;
			MFTB_C7           : OUT    STD_LOGIC;
			--  
			MFT_SPARE         : OUT    STD_LOGIC_VECTOR (32 DOWNTO 1));
	END COMPONENT MFT2232_SIMU;

	COMPONENT TCD_SIMU IS
		PORT (
				Busy_Combined				: IN 	std_logic;
				oRS         				: OUT  std_logic;         -- TCD RHIC strobe
				oRSx5       				: OUT  std_logic;         -- TCD data clock
				oTCD_DATA   				: OUT  std_logic_vector (3 DOWNTO 0)   -- TCD data
			);
	END COMPONENT TCD_SIMU;


COMPONENT LC_SIMU_LA IS
	PORT (
		CLK40             : IN    STD_LOGIC;
		RST					: IN 	  STD_LOGIC;
		LC_SERIAL 			: IN    std_logic_vector (5 downto 0);
      -- Fiber 
      DES_D          : OUT    STD_LOGIC_VECTOR (23 DOWNTO 0);
      SER_D          : IN   STD_LOGIC_VECTOR (23 DOWNTO 0);
      DES_RCLK       : OUT    STD_LOGIC;
      SER_TCLK       : IN   STD_LOGIC;
      LED            : IN   STD_LOGIC_VECTOR (3 DOWNTO 0);
      SER_DEN        : IN   STD_LOGIC;
      SER_TPWDNB     : IN   STD_LOGIC;
      DES_RPWDNB     : IN   STD_LOGIC;
      DES_PASS       : OUT    STD_LOGIC;
      DES_LOCK       : OUT    STD_LOGIC;
      DES_SLEW       : IN   STD_LOGIC;
      DES_BISTM      : IN   STD_LOGIC;
      DES_BISTEN     : IN   STD_LOGIC;
      DES_REN        : IN   STD_LOGIC;
      DES_PTOSEL     : IN   STD_LOGIC;
      TX_FAULT       : OUT    STD_LOGIC;
      TX_DISABLE     : IN   STD_LOGIC;
      MOD_DEF        : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      RX_LOSS        : OUT    STD_LOGIC);
END COMPONENT LC_SIMU_LA;
	
	--GENERAL
   signal sCLK40 : std_logic := '0';
   signal sCLK80 : std_logic := '0';
   signal sRST : std_logic := '1';
	-------CONSTANTS 
   CONSTANT sData_FormatV : STD_LOGIC_VECTOR (7 DOWNTO 0)  := x"01";  --TEMPORAL
   CONSTANT sFPGA_BuildN  : STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0005";  -- RDO project number
   SIGNAL sBoardID : STD_LOGIC_VECTOR (3 DOWNTO 0) := x"0";
	
	---------------------------------------------< MB FTDI signals
   SIGNAL sMFTA_D_in         : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sMFTA_D_out        : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sMFTA_D_T          : STD_LOGIC;
   SIGNAL sMFTA_FifoQ        : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sMFTA_FifoEmpty    : STD_LOGIC;
   SIGNAL sMFTA_FifoRdreq    : STD_LOGIC;
   SIGNAL sMFTA_FifoRdClk    : STD_LOGIC;
   SIGNAL sMFTA_CmdFifoQ     : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sMFTA_CmdFifoEmpty : STD_LOGIC;
   SIGNAL sMFTA_CmdFifoRdreq : STD_LOGIC;
--   SIGNAL sMFTB_D_in         : STD_LOGIC_VECTOR (7 DOWNTO 0);
--   SIGNAL sMFTB_D_out        : STD_LOGIC_VECTOR (7 DOWNTO 0);
--   SIGNAL sMFTB_D_T          : STD_LOGIC;

   SIGNAL sMFTA_RD_n : STD_LOGIC;
   SIGNAL sMFTA_WR_n : STD_LOGIC;
   SIGNAL sMFTA_SIWU : STD_LOGIC;

	SIGNAL MFTA_RXF_n : STD_LOGIC := '0';
	SIGNAL MFTA_TXE_n : STD_LOGIC := '0';
	SIGNAL MFTA_CLKOUT : STD_LOGIC := '0';
	SIGNAL MFTA_OE_n : STD_LOGIC := '0';
	
	signal MFTA_D 				: std_logic_vector(7 downto 0) := (others => '0');
	signal MFTB_D 				: std_logic_vector(7 downto 0) := (others => '0');
   ---------------------------------------------> MB FTDI signals
	--------------------------------------<TCD
	signal TCD_BUSY_BAR : std_logic := '0';
	signal RS : std_logic := '0';
   signal RSx5 : std_logic := '0';
   signal TCD_DATA : std_logic_vector(3 downto 0) := (others => '0');
	------------------------------------>TCD
	
	   ---------------------------------------------< SIU signals
   SIGNAL sSiu_FifoQ        : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sSiu_FifoEmpty    : STD_LOGIC := '0';
   SIGNAL sSiu_FifoRdreq    : STD_LOGIC := '0';
   SIGNAL sSiu_FifoRdClk    : STD_LOGIC := '0';
   ---------------------------------------------> SIU signals
	
	---------------------------------------------< DAQ signals
   SIGNAL sLC_RST            : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sCONFIG_CMD_IN     : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");
   SIGNAL sCONFIG_DATA_IN    : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");
   SIGNAL sCONFIG_DATA_IN_WE : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sCONFIG_BUSY       : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sCONFIG_STATUS_OUT : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");
   SIGNAL sJTAG_DATA_TDI     : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");
   SIGNAL sJTAG_DATA_WE      : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sJTAG_BUSY         : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sJTAG_DATA_TDO     : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");

   SIGNAL sADC_offset     : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");
   SIGNAL sZero_supr_trsh : FIBER_ARRAY_TYPE_16           := (OTHERS => x"0000");
   SIGNAL sZST_Polarity   : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sPipe_Selector  : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');

   SIGNAL sTCD_DELAY_Reg       : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sTCD_EN_TRGMODES_Reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
   SIGNAL sForced_Triggers_Reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');  -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger

   SIGNAL sStatus_Counters_RST_REG : STD_LOGIC                      := '0';
   SIGNAL sTCD_Level0_RCVD_REG     : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sRHIC_STROBE_LSB_REG     : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sRHIC_STROBE_MSB_REG     : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sN_HOLDS_REG             : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sN_TESTS_REG             : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sTCD_TRG_RCVD_REG        : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sSIU_PACKET_CNT_REG      : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sBUSY_COMBINED           : STD_LOGIC                      := '0';

   SIGNAL sTEST2HOLD_DELAY : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

   SIGNAL sLC_STATUS_REG               : FIBER_ARRAY_TYPE_16_8 := (OTHERS => (OTHERS => x"0000"));
   SIGNAL sLC_HYBRIDS_POWER_STATUS_REG : FIBER_ARRAY_TYPE_16   := (OTHERS => x"0000");
	SIGNAL sFiber_RDOtoLC : FIBER_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
   SIGNAL sFiber_LCtoRDO : FIBER_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
	SIGNAL sLVDS_CNT_EN           : STD_LOGIC        := '0';
   ---------------------------------------------> DAQ signals
	
	   -- pedestal memory write
   SIGNAL sPedMemWrite : PED_MEM_WRITE;

 -- Clock period definitions
   constant sCLK40_period : time := 25 ns;
   constant sCLK80_period : time := 12.5 ns;
	constant sSiu_fifoRdClk_period : time := 20 ns;
	
	--OTHERS
	SIGNAL sCalLVDS : STD_LOGIC := '0';
	
 
	TYPE LC_SERIAL_ARRAY_TYPE IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (5 DOWNTO 0); 
	SIGNAL sLC_SERIAL	: LC_SERIAL_ARRAY_TYPE := (OTHERS => (OTHERS => '0')); 
BEGIN
 
	ftdi: MFT2232_SIMU
	PORT MAP(
		---------------------------------------------------------------------------
      -- Motherboard FT2232H adapter board ("MFT")
      ---------------------------------------------------------------------------
      MFT_PWREN_n       => OPEN,
      MFT_SUSPEND_n     => OPEN,
      MFT_RESET_n       => '0',
      -- 
      MFT_EEDATA        => OPEN,
      MFT_EECS          => OPEN,
      MFT_EECLK         => OPEN,
      -- 
      MFTA_D            => MFTA_D,
      MFTB_D            => MFTB_D,
      -- 
      MFTA_RXF_n        => MFTA_RXF_n,
      MFTA_TXE_n        => MFTA_TXE_n,
      MFTA_RD_n         => sMFTA_RD_n,
      MFTA_WR_n         => sMFTA_WR_n,
      MFTA_SIWU         => sMFTA_SIWU,
      MFTA_CLKOUT       => OPEN,
      MFTA_OE_n         => MFTA_OE_n,
      MFTA_C7           => OPEN,
      -- 
      MFTB_RXF_n        => OPEN,
      MFTB_TXE_n        => OPEN,
      MFTB_RD_n         => '0',
      MFTB_WR_n         => '0',
      MFTB_SIWU         => '0',
      MFTB_CLKOUT       => OPEN,
      MFTB_OE_n         => '0',
      MFTB_C7           => OPEN,
      --  
      MFT_SPARE         => OPEN
	);
	
		-- bi-directional data signals:
   mfta_bufd : FOR i IN 0 TO 7 GENERATE  -- A port
      IOBUF_mfta_di : IOBUF
         PORT MAP (
            O  => sMFTA_D_in(i),        -- Buffer output
            IO => MFTA_D(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sMFTA_D_out(i),       -- Buffer input
            T  => sMFTA_D_T   -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE mfta_bufd;
	
mft2232h_instA : M_FT2232H
      PORT MAP (
         CLK            => sClk40,
         RESET          => sRST,
			-- FT2232H sign
         D_in           => sMFTA_D_in,							-- FIFO Data bus in
         D_out          => sMFTA_D_out,                   -- FIFO Data bus out
         D_T            => sMFTA_D_T,                        -- FIFO Data bus enable
			-- "C" Port       -- "C" Port                   
         RXF_n          => MFTA_RXF_n,                   
         TXE_n          => MFTA_TXE_n,                   
         RD_n           => sMFTA_RD_n,                       -- Read from USB FIFO
         WR_n           => sMFTA_WR_n,                       -- Write to USB FIFO
         SIWU           => sMFTA_SIWU,                       -- Send Immediate/Wake Up
         CLKOUT         => MFTA_CLKOUT,                  -- Sync USB FIFO clock -- '0'
         OE_n           => MFTA_OE_n,                        -- Output enable (for sync FIFO)
			-- From FPGA to PC                              
         FIFO_Q         => sMFTA_FifoQ,                    -- interface fifo data output port
         FIFO_EMPTY     => sMFTA_FifoEmpty,  --'0';          -- interface fifo "emtpy" signal
         FIFO_RDREQ     => sMFTA_FifoRdreq,                  -- interface fifo read request
         FIFO_RDCLK     => sMFTA_FifoRdClk,                  -- interface fifo read clock
			-- From PC to FPGA                              
         CMD_FIFO_Q     => sMFTA_CmdFifoQ,                 -- interface command fifo data out port
         CMD_FIFO_EMPTY => sMFTA_CmdFifoEmpty,            -- interface command fifo "emtpy" signal
         CMD_FIFO_RDREQ => sMFTA_CmdFifoRdreq               -- interface command fifo read request
         );
	
	tcd : TCD_SIMU
		PORT MAP(
			Busy_Combined	 =>  TCD_BUSY_BAR,
			oRS      	=> RS, 
			oRSx5     => RSx5,
			oTCD_DATA => TCD_DATA
	);
	
---------------------------------------------< DAQ
   DAQ_ints : DAQ PORT MAP(
      CLK40                       => sCLK40,
      CLK80                       => sCLK80,
      RST                         => sRST,
      --GENERAL
      BoardID                     => sBoardID,
      Data_FormatV                => sData_FormatV,
      FPGA_BuildN                 => sFPGA_BuildN,
      ---
      LC_RST                      => sLC_RST,
      CONFIG_CMD_IN               => sCONFIG_CMD_IN,
      CONFIG_DATA_IN              => sCONFIG_DATA_IN,
      CONFIG_DATA_IN_WE           => sCONFIG_DATA_IN_WE,
      CONFIG_BUSY                 => sCONFIG_BUSY,
      CONFIG_STATUS_OUT           => sCONFIG_STATUS_OUT,
      JTAG_DATA_TDI               => sJTAG_DATA_TDI,
      JTAG_DATA_WE                => sJTAG_DATA_WE,
      JTAG_BUSY                   => sJTAG_BUSY,
      JTAG_DATA_TDO               => sJTAG_DATA_TDO,
      --PIPE
      ADC_offset                  => sADC_offset,
      Zero_supr_trsh              => sZero_supr_trsh,
      ZST_Polarity                => sZST_Polarity,
      Pipe_Selector               => sPipe_Selector,
      --TCD Registers
      TCD_DELAY_Reg               => sTCD_DELAY_Reg,
      TCD_EN_TRGMODES_Reg         => sTCD_EN_TRGMODES_Reg,
      Forced_Triggers_Reg         => sForced_Triggers_Reg,
      Status_Counters_RST_REG     => sStatus_Counters_RST_REG,
      TCD_Level0_RCVD_REG         => sTCD_Level0_RCVD_REG,
      RHIC_STROBE_LSB_REG         => sRHIC_STROBE_LSB_REG,
      RHIC_STROBE_MSB_REG         => sRHIC_STROBE_MSB_REG,
      N_HOLDS_REG                 => sN_HOLDS_REG,
      N_TESTS_REG                 => sN_TESTS_REG,
      -- data packer status registers
      TCD_TRG_RCVD_REG            => sTCD_TRG_RCVD_REG,
      SIU_PACKET_CNT_REG          => sSIU_PACKET_CNT_REG,
      -- pedestal memory write port
      iPedMemWrite                => sPedMemWrite,
      --BUSY_COMBINED
      BUSY_COMBINED               => sBUSY_COMBINED,
      --TEST 2 HOLD
      TEST2HOLD_DELAY             => sTEST2HOLD_DELAY,
      --LC STATUS
      LC_STATUS_REG               => sLC_STATUS_REG,
      LC_HYBRIDS_POWER_STATUS_REG => sLC_HYBRIDS_POWER_STATUS_REG,
      --TCD INTERFASE
      RS                          => RS,
      RSx5                        => RSx5,
      TCD_DATA                    => TCD_DATA,
      --SIU DDL LINK
      DDL_FIFO_Q                  => sSiu_FifoQ,
      DDL_FIFO_EMPTY              => sSiu_FifoEmpty,
      DDL_FIFO_RDREQ              => sSiu_fifoRdreq,
      DDL_FIFO_RDCLK              => sSiu_fifoRdClk,
      -- fiber links
      Fiber_LCtoRDO               => sFiber_LCtoRDO,
      Fiber_RDOtoLC               => sFiber_RDOtoLC,
      -- test connector
      TC                          => OPEN
      );
		
		 TCD_BUSY_BAR <= sBUSY_COMBINED;
---------------------------------------------> DAQ

---------------------------------------------< USB_DECODER
   USB_DECODER_inst : USB_DECODER
      PORT MAP(
         CLK40                       => sCLK40,
         RST                         => sRST,
         --FTDI INTERFACE                               
         -- CMD FIFO                                    
         CMD_FIFO_Q                  => sMFTA_CmdFifoQ,
         CMD_FIFO_EMPTY              => sMFTA_CmdFifoEmpty,
         CMD_FIFO_RDREQ              => sMFTA_CmdFifoRdreq,
         -- From FPGA to PC
         FIFO_Q                      => sMFTA_FifoQ,
         FIFO_EMPTY                  => sMFTA_FifoEmpty,
         FIFO_RDREQ                  => sMFTA_FifoRdreq,
         FIFO_RDCLK                  => sMFTA_FifoRdClk,
         --LC_INTERFACES        
         --LC_Registers                 
         LC_RST                      => sLC_RST,
         --CONFIG                       
         CONFIG_CMD_IN               => sCONFIG_CMD_IN,
         CONFIG_DATA_IN              => sCONFIG_DATA_IN,
         CONFIG_DATA_IN_WE           => sCONFIG_DATA_IN_WE,
         CONFIG_BUSY                 => sCONFIG_BUSY,
         CONFIG_STATUS_OUT           => sCONFIG_STATUS_OUT,
         --JTAG
         JTAG_DATA_TDI               => sJTAG_DATA_TDI,
         JTAG_DATA_WE                => sJTAG_DATA_WE,
         JTAG_BUSY                   => sJTAG_BUSY,
         JTAG_DATA_TDO               => sJTAG_DATA_TDO,
         --PIPE
         ADC_offset                  => sADC_offset,
         Zero_supr_trsh              => sZero_supr_trsh,
         ZST_Polarity                => sZST_Polarity,
         Pipe_Selector               => sPipe_Selector,
         --TCD Registers
         TCD_DELAY_Reg               => sTCD_DELAY_Reg,
         TCD_EN_TRGMODES_Reg         => sTCD_EN_TRGMODES_Reg,
         Forced_Triggers_Reg         => sForced_Triggers_Reg,
         Status_Counters_RST_REG     => sStatus_Counters_RST_REG,
         TCD_Level0_RCVD_REG         => sTCD_Level0_RCVD_REG,
         RHIC_STROBE_LSB_REG         => sRHIC_STROBE_LSB_REG,
         RHIC_STROBE_MSB_REG         => sRHIC_STROBE_MSB_REG,
         N_HOLDS_REG                 => sN_HOLDS_REG,
         N_TESTS_REG                 => sN_TESTS_REG,
         -- data packer status registers
         TCD_TRG_RCVD_REG            => sTCD_TRG_RCVD_REG,
         SIU_PACKET_CNT_REG          => sSIU_PACKET_CNT_REG,
         --BUSY_COMBINED
         BUSY_COMBINED               => sBUSY_COMBINED,
         --TEST 2 HOLD
         TEST2HOLD_DELAY             => sTEST2HOLD_DELAY,
         --LC STATUS
         LC_STATUS_REG               => sLC_STATUS_REG,
         LC_HYBRIDS_POWER_STATUS_REG => sLC_HYBRIDS_POWER_STATUS_REG,
         --GENERAL
         BoardID                     => sBoardID,
         Data_FormatV                => sData_FormatV,
         FPGA_BuildN                 => sFPGA_BuildN,
         CalLVDS                     => sCalLVDS,
         LVDS_CNT_EN                 => sLVDS_CNT_EN,
         -- pedestal memory write port
         oPedMemWrite                => sPedMemWrite
         );
---------------------------------------------> USB_DECODER             


LC : FOR i IN 0 TO 6 GENERATE
	sLC_SERIAL(i) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i,3)) & STD_LOGIC_VECTOR(TO_UNSIGNED(i,3));
	LC_SIMU_LA_inst : LC_SIMU_LA
	PORT MAP(
			CLK40          => sCLK40,
			RST				=> sRST,
			LC_SERIAL 		=> sLC_SERIAL(i),
			-- Fiber 
			DES_D          => sFiber_LCtoRDO(i),
			SER_D          => sFiber_RDOtoLC(i),
			DES_RCLK       => OPEN,
			SER_TCLK       => sCLK40,
			LED            => STD_LOGIC_VECTOR(TO_UNSIGNED(i,4)),
			SER_DEN        => '0',
			SER_TPWDNB     => '0',
			DES_RPWDNB     => '0',
			DES_PASS       => OPEN,
			DES_LOCK       => OPEN,
			DES_SLEW       => '0',
			DES_BISTM      => '0',
			DES_BISTEN     => '0',
			DES_REN        => '0',
			DES_PTOSEL     => '0',
			TX_FAULT       => OPEN,
			TX_DISABLE     => '0',
			MOD_DEF        => OPEN,
			RX_LOSS        => OPEN
			);
	END GENERATE;
	
   -- Clock process definitions
	sCLK40 <= NOT sCLK40 AFTER sCLK40_period/2;
	sCLK80 <= NOT sCLK80 AFTER sCLK80_period/2;
	sSiu_fifoRdClk <= NOT sSiu_fifoRdClk AFTER sSiu_fifoRdClk_period/2;
	
 

   -- Stimulus process
   stim_proc: process
   begin		
    sRST <= '1';
      -- hold reset state for 100 ns.
		sRST <= '1';
      wait for 1000 ns;	
		sRST <= '0';
	  wait for 1000 ns;	
	  sRST <= '1'; 
	  wait for 1000 ns;	
		sRST <= '0';
      wait for sCLK40_period*10;

      -- insert stimulus here 

      wait;
   end process;
	
	full : PROCESS 
  
  BEGIN 
	WAIT FOR 9000 us;
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '1';
	WHILE 1=1 LOOP
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '0';
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '1';
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '0';
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '1';
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '0';
	WAIT FOR 1300 ns;
	sSiu_fifoRdreq <= '1';
	WAIT FOR 300 ns;
	sSiu_fifoRdreq <= '1';
	END LOOP;
  WAIT;
  END PROCESS;

END;
