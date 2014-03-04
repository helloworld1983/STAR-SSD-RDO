-------------------------------------------------------------------------------
-- Title      : HFT SSD RDO board Top Module
-- Project    : STAR HFT SSD
-------------------------------------------------------------------------------
-- File       : SSD_RDO_TOP.vhd
-- Author     : Thorsten Stezelberger & Luis Ardila based on PXL_RDO_Top by Joachim Schambach (jschamba@physics.utexas.edu)
-- Company    : Lawrence Berkeley National Laboratory
-- Created    : 2012-02-16
-- Last update: 2014-Feb-13
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top Level design for Virtex-6 RDO board
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-02-16  1.0      jschamba        Created
-- 2013-08-22  2.0      Luis Ardila     SSD version
-- 2013-09-17  2.1      Luis Ardila     Quick Hack for using L2F board with ODD1_EVEN0 signal "Sept17"
-- 2014-02-21	3.0		Luis Ardila		 Clean version without Pedestal Memory
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.NUMERIC_STD.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY SSD_RDO_TOP IS
   PORT (
      ---------------------------------------------------------------------------
      -- Board clock
      ---------------------------------------------------------------------------
      OSC_50MHZ         : IN    STD_LOGIC;
      -- 
      ---------------------------------------------------------------------------
      -- SIU
      ---------------------------------------------------------------------------
      SIU_FIBEN_n       : IN    STD_LOGIC;
      SIU_FOBSY_n       : OUT   STD_LOGIC;
      SIU_FBD           : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      SIU_FBCTRL_n      : INOUT STD_LOGIC;
      SIU_FOCLK         : OUT   STD_LOGIC;
      SIU_FILF_n        : IN    STD_LOGIC;
      SIU_FIDIR         : IN    STD_LOGIC;
      SIU_FBTEN_n       : INOUT STD_LOGIC;
      -- these signals are not used
      SIU_TAP_TDI       : IN    STD_LOGIC;
      SIU_TAP_TCK       : IN    STD_LOGIC;
      SIU_TAP_TMS       : IN    STD_LOGIC;
      SIU_TAP_TDO       : IN    STD_LOGIC;
      SIU_TAP_TRST      : IN    STD_LOGIC;
      SIU_BUSMODE1_n    : IN    STD_LOGIC;
      SIU_BUSMODE2_n    : IN    STD_LOGIC;
      SIU_BUSMODE3_n    : IN    STD_LOGIC;
      SIU_BUSMODE4_n    : IN    STD_LOGIC;
      -- 
      ---------------------------------------------------------------------------
      -- TCD
      ---------------------------------------------------------------------------
      TCD_D             : IN    STD_LOGIC_VECTOR (3 DOWNTO 0);
      TCD_RS            : IN    STD_LOGIC;
      TCD_5xRS          : IN    STD_LOGIC;
      TCD_BUSY_BAR      : OUT   STD_LOGIC;
      TCD_BUSY_BAR2     : IN    STD_LOGIC;  -- was a mistake in the schematic
      -- 
      ---------------------------------------------------------------------------
      -- MTB ADC AD7997
      ---------------------------------------------------------------------------
      --SDA               : INOUT std_logic;
      --ALERT_BUSY        : IN    std_logic;
      --N_CONVST          : OUT   std_logic;
      --SCL               : OUT   std_logic;
      -- 
      ---------------------------------------------------------------------------
      -- Motherboard FT2232H adapter board ("MFT")
      ---------------------------------------------------------------------------
      MFT_PWREN_n       : IN    STD_LOGIC;
      MFT_SUSPEND_n     : IN    STD_LOGIC;
      MFT_RESET_n       : OUT   STD_LOGIC;
      -- 
      MFT_EEDATA        : IN    STD_LOGIC;
      MFT_EECS          : IN    STD_LOGIC;
      MFT_EECLK         : IN    STD_LOGIC;
      -- 
      MFTA_D            : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      MFTB_D            : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      -- 
      MFTA_RXF_n        : IN    STD_LOGIC;
      MFTA_TXE_n        : IN    STD_LOGIC;
      MFTA_RD_n         : OUT   STD_LOGIC;
      MFTA_WR_n         : OUT   STD_LOGIC;
      MFTA_SIWU         : OUT   STD_LOGIC;
      MFTA_CLKOUT       : IN    STD_LOGIC;
      MFTA_OE_n         : OUT   STD_LOGIC;
      MFTA_C7           : IN    STD_LOGIC;
      -- 
      MFTB_RXF_n        : IN    STD_LOGIC;
      MFTB_TXE_n        : IN    STD_LOGIC;
      MFTB_RD_n         : OUT   STD_LOGIC;
      MFTB_WR_n         : OUT   STD_LOGIC;
      MFTB_SIWU         : OUT   STD_LOGIC;
      MFTB_CLKOUT       : IN    STD_LOGIC;
      MFTB_OE_n         : OUT   STD_LOGIC;
      MFTB_C7           : IN    STD_LOGIC;
      --  
      MFT_SPARE         : IN    STD_LOGIC_VECTOR (32 DOWNTO 1);
      ---------------------------------------------------------------------------
      -- GTX MGT112 transceivers & clocks
      -- Don't know yet how to use them, so they are commented for now
      ---------------------------------------------------------------------------
--    MGT112REFCLK0N     : IN    std_logic;
--    MGT112REFCLK0P     : IN    std_logic;
--    MGT112REFCLK1N     : IN    std_logic;
--    MGT112REFCLK1P     : IN    std_logic;
--    MGT112RXN          : IN    std_logic_vector (3 DOWNTO 0);
--    MGT112RXP          : IN    std_logic_vector (3 DOWNTO 0);
--    MGT112TXN          : OUT   std_logic_vector (3 DOWNTO 0);
--    MGT112TXP          : OUT   std_logic_vector (3 DOWNTO 0);
      --
      ---------------------------------------------------------------------------
      -- Configuration pins for daughter card connections
      ---------------------------------------------------------------------------
      DC_NOT_ADD_EN_BAR : OUT   STD_LOGIC;
      FLASH_ADD_EN_BAR  : OUT   STD_LOGIC;
      -- 
      ---------------------------------------------------------------------------
      -- Expansion daughter board 
      ---------------------------------------------------------------------------
-- This section causes a weird error message, so it has been replaced with just
-- an input instead. See below in daughter card section for further details.
--    DC_A_P             : INOUT std_logic_vector (20 DOWNTO 1);
--    DC_A_N             : INOUT std_logic_vector (20 DOWNTO 1);
      DC_A_P            : IN    STD_LOGIC_VECTOR (20 DOWNTO 1);
      DC_A_N            : IN    STD_LOGIC_VECTOR (20 DOWNTO 1);
      DC_A              : INOUT STD_LOGIC_VECTOR (100 DOWNTO 41);
      DC_B              : INOUT STD_LOGIC_VECTOR (100 DOWNTO 1);
      --
      ---------------------------------------------------------------------------
      -- Ladder signals
      ---------------------------------------------------------------------------
      -- Latchup monitoring
      LU_MTB            : INOUT STD_LOGIC;
      -- sensor outputs (array of 4 ladders, 10 sensors, 2 outputs) 
--      L_SENSOR_OUT_N    : IN    ladderArray_type;
--      L_SENSOR_OUT_P    : IN    ladderArray_type;
      L_SENSOR_OUT_N    : IN    LVDS_IN_ARRAY_TYPE;
      L_SENSOR_OUT_P    : IN    LVDS_IN_ARRAY_TYPE;
      L_SENSOR_IN_N     : OUT   LVDS_OUT_ARRAY_TYPE;
      L_SENSOR_IN_P     : OUT   LVDS_OUT_ARRAY_TYPE;
      -- Ladder control signals
      L_START_N         : OUT   STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_START_P         : OUT   STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_MARKER_N        : IN    STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_MARKER_P        : IN    STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_RSTB            : OUT   STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_JTAG_TDO        : IN    STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_JTAG_TDI        : OUT   STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_JTAG_TMS        : OUT   STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_JTAG_TCK        : OUT   STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_LU_analog       : INOUT STD_LOGIC_VECTOR(4 DOWNTO 1);
      L_LU_digital      : INOUT STD_LOGIC_VECTOR(4 DOWNTO 1);
      -- Ladder 1
      L1_PM_clk_N       : OUT   STD_LOGIC;
      L1_PM_clk_P       : OUT   STD_LOGIC
      );
END SSD_RDO_TOP;

ARCHITECTURE SSD_RDO_TOP_Arch OF SSD_RDO_TOP IS

   COMPONENT GlobalReset IS
      PORT (
         CLK        : IN  STD_LOGIC;
         DCM_LOCKED : IN  STD_LOGIC;
         CLK_RST    : OUT STD_LOGIC;
         GLOBAL_RST : OUT STD_LOGIC
         );
   END COMPONENT GlobalReset;

   COMPONENT Clock_generator
      PORT (
         CLK_IN1  : IN  STD_LOGIC;
         CLK_OUT1 : OUT STD_LOGIC;
         CLK_OUT2 : OUT STD_LOGIC;
         CLK_OUT3 : OUT STD_LOGIC;
         CLK_OUT4 : OUT STD_LOGIC;
         CLK_OUT5 : OUT STD_LOGIC;
         CLK_OUT6 : OUT STD_LOGIC;
         CLK_BUFG : OUT STD_LOGIC;      -- input clock buffered
         RESET    : IN  STD_LOGIC;
         LOCKED   : OUT STD_LOGIC
         );
   END COMPONENT;

   COMPONENT ddl
      PORT (
         RESET          : IN  STD_LOGIC;
         CLK            : IN  STD_LOGIC;  -- system clock
         -- DDL signals
         FICLK          : IN  STD_LOGIC;  -- DDL clock
         FITEN_n        : IN  STD_LOGIC;
         FIDIR          : IN  STD_LOGIC;
         FIBEN_n        : IN  STD_LOGIC;
         FILF_n         : IN  STD_LOGIC;
         FICTRL_n       : IN  STD_LOGIC;
         FID            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
         FOD            : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         FOBSY_n        : OUT STD_LOGIC;
         FOCTRL_n       : OUT STD_LOGIC;
         FOTEN_n        : OUT STD_LOGIC;
         SIU_T          : OUT STD_LOGIC;  -- BiDir signal direction
         -- control signals
         FEE_RESET      : OUT STD_LOGIC;
         EVT_RD_ENABLE  : OUT STD_LOGIC;  --Clear buffers and lower bussy when 0
         -- From FPGA to PC
         FIFO_Q         : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface fifo data output port
         FIFO_EMPTY     : IN  STD_LOGIC;  -- interface fifo "emtpy" signal
         FIFO_RDREQ     : OUT STD_LOGIC;  -- interface fifo read request
         FIFO_RDCLK     : OUT STD_LOGIC;  -- interface fifo read clock
         -- From PC to FPGA
         CMD_FIFO_Q     : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface command fifo data out port
         CMD_FIFO_EMPTY : OUT STD_LOGIC;  -- interface command fifo "emtpy" signal
         CMD_FIFO_RDREQ : IN  STD_LOGIC  -- interface command fifo read request
         );
   END COMPONENT;

   COMPONENT LVDS2Fiber_interface IS
      PORT (
         iCLK40          : IN  STD_LOGIC;
         iCLK200         : IN  STD_LOGIC;
         iRST            : IN  STD_LOGIC;
         iClkLocked      : IN  STD_LOGIC;
         -- control
         iManual_CalLine : IN  STD_LOGIC;
         oLinkStatus     : OUT FIBER8_STATUS;
         iLinkCtrl       : IN  FIBER8_CTRL;
         oL2Fversion     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         oL2Flocked      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         iLVDS_CNT_EN    : IN  STD_LOGIC;
         -- fiber links
         iFiber_RDOtoLC  : IN  FIBER_ARRAY_TYPE;
         oFiber_LCtoRDO  : OUT FIBER_ARRAY_TYPE;
         -- LVDS links
         oL_START        : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
         iL_Marker       : IN  STD_LOGIC_VECTOR (4 DOWNTO 1);
         oL_SENSOR_OUT   : OUT LVDS_OUT_ARRAY_TYPE;
         iL_SENSOR_IN    : IN  LVDS_IN_ARRAY_TYPE;
         oL_RSTB         : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
         iL_LU_digital_1 : IN  STD_LOGIC;  -- L2F done signal
         iL_LU_analog_2  : IN  STD_LOGIC;  -- L2F done signal
         oL_LU_analog_1  : OUT STD_LOGIC;  -- L2F FPGA PROGRAMM_B
         oL_LU_digital_2 : OUT STD_LOGIC;  -- L2F FPGA PROGRAMM_B
         oL_JTAG_TCK     : OUT STD_LOGIC_VECTOR (4 DOWNTO 3);  -- iodel cal mode bit 0
         oL_JTAG_TMS     : OUT STD_LOGIC_VECTOR (4 DOWNTO 3);  -- iodel cal mode bit 1
         -- test connector
         oTC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT LVDS2Fiber_interface;

   SIGNAL sLVDSsync : STD_LOGIC_VECTOR (7 DOWNTO 0);

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

   ---------------------------------------------< Reset signals
   SIGNAL sClkRST    : STD_LOGIC;
   SIGNAL sGlobalRST : STD_LOGIC;
   ---------------------------------------------> Reset signals


   ---------------------------------------------< MB FTDI signals
   SIGNAL sMFTA_rst          : STD_LOGIC;
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
   SIGNAL sMFTB_D_in         : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sMFTB_D_out        : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sMFTB_D_T          : STD_LOGIC;

   SIGNAL sMFTA_RD_n : STD_LOGIC;
   SIGNAL sMFTA_WR_n : STD_LOGIC;
   SIGNAL sMFTA_SIWU : STD_LOGIC;

   ---------------------------------------------> MB FTDI signals

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
	SIGNAL sLVDS_CNT_EN  	: STD_LOGIC := '0';
   ---------------------------------------------> DAQ signals

   ---------------------------------------------< SIU signals
   SIGNAL sSiu_rst          : STD_LOGIC := '0';
   SIGNAL sSiuFeeReset      : STD_LOGIC := '0';
   SIGNAL sSiu_T            : STD_LOGIC := '0';
   SIGNAL sSiu_fiTEN_n      : STD_LOGIC := '0';
   SIGNAL sSiu_foTEN_n      : STD_LOGIC := '0';
   SIGNAL sSiu_fiCTRL_n     : STD_LOGIC := '0';
   SIGNAL sSiu_foCTRL_n     : STD_LOGIC := '0';
   SIGNAL sSiu_fiD          : STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL sSiu_foD          : STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL sSiu_FifoQ        : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sSiu_FifoEmpty    : STD_LOGIC := '0';
   SIGNAL sSiu_FifoRdreq    : STD_LOGIC := '0';
   SIGNAL sSiu_FifoRdClk    : STD_LOGIC := '0';
   SIGNAL sSiu_CmdFifoQ     : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sSiu_CmdFifoEmpty : STD_LOGIC := '0';
   SIGNAL sSiu_CmdFifoRdreq : STD_LOGIC := '0';
   SIGNAL sSiuEvt_RD_EN     : STD_LOGIC := '0';  --used to know that we are or not part of the run --Clear buffers and lower bussy when 0
   ---------------------------------------------> SIU signals

   ---------------------------------------------< Clock signals
   SIGNAL sClk320    : STD_LOGIC := '0';
   SIGNAL sClk200    : STD_LOGIC := '0';
   SIGNAL sClk160    : STD_LOGIC := '0';
   SIGNAL sClk100    : STD_LOGIC := '0';
   SIGNAL sClk80     : STD_LOGIC := '0';
   SIGNAL sClk40     : STD_LOGIC := '0';
   SIGNAL sClk50     : STD_LOGIC := '0';
   SIGNAL sClkLocked : STD_LOGIC := '0';
   ---------------------------------------------> Clock signals

   ---------------------------------------------< Expansion board signals
   SIGNAL sDcA_T   : STD_LOGIC_VECTOR (100 DOWNTO 1);
   SIGNAL sDcB_T   : STD_LOGIC_VECTOR (100 DOWNTO 1);
   SIGNAL sDcA_in  : STD_LOGIC_VECTOR (100 DOWNTO 1);
   SIGNAL sDcA_out : STD_LOGIC_VECTOR (100 DOWNTO 1);
   SIGNAL sDcB_in  : STD_LOGIC_VECTOR (100 DOWNTO 1);
   SIGNAL sDcB_out : STD_LOGIC_VECTOR (100 DOWNTO 1);
   ---------------------------------------------> Expansion board signals

   ---------------------------------------------< D.C. FTDI signals
   SIGNAL sFtdiAC_in  : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiAC_out : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiAC_T   : STD_LOGIC_VECTOR (7 DOWNTO 0);

   SIGNAL sFtdiAD_in  : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiAD_out : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiAD_T   : STD_LOGIC_VECTOR (7 DOWNTO 0);

   SIGNAL sFtdiBC_in  : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiBC_out : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiBC_T   : STD_LOGIC_VECTOR (7 DOWNTO 0);

   SIGNAL sFtdiBD_in  : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiBD_out : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL sFtdiBD_T   : STD_LOGIC_VECTOR (7 DOWNTO 0);

   SIGNAL sFtdiSUSPEND_n : STD_LOGIC;
   SIGNAL sFtdiCS        : STD_LOGIC;   -- EEPROM CS
   SIGNAL sFtdiCLK       : STD_LOGIC;   -- EEPROM clock
   SIGNAL sFtdiDATA      : STD_LOGIC;   -- EEPROM data
   SIGNAL sFtdiPWREN_n   : STD_LOGIC;
   SIGNAL sFtdiRESET_n   : STD_LOGIC;

   SIGNAL sFtdiA_rst          : STD_LOGIC;
   SIGNAL sFtdiA_FifoQ        : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sFtdiA_FifoEmpty    : STD_LOGIC;
   SIGNAL sFtdiA_FifoRdreq    : STD_LOGIC;
   SIGNAL sFtdiA_FifoRdClk    : STD_LOGIC;
   SIGNAL sFtdiA_CmdFifoQ     : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sFtdiA_CmdFifoEmpty : STD_LOGIC;
   SIGNAL sFtdiA_CmdFifoRdreq : STD_LOGIC;

   SIGNAL sFtdiB_rst          : STD_LOGIC;
   SIGNAL sFtdiB_FifoQ        : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sFtdiB_FifoEmpty    : STD_LOGIC;
   SIGNAL sFtdiB_FifoRdreq    : STD_LOGIC;
   SIGNAL sFtdiB_FifoRdClk    : STD_LOGIC;
   SIGNAL sFtdiB_CmdFifoQ     : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sFtdiB_CmdFifoEmpty : STD_LOGIC;
   SIGNAL sFtdiB_CmdFifoRdreq : STD_LOGIC;

   ---------------------------------------------> D.C. FTDI signals

   ---------------------------------------------< MTB AD7997 signals
   SIGNAL sMtbAdc_sda_in  : STD_LOGIC;
   SIGNAL sMtbAdc_sda_out : STD_LOGIC;
   SIGNAL sMtbAdc_sda_T   : STD_LOGIC;
   ---------------------------------------------> MTB AD7997 signals

   ---------------------------------------------< Sensor signals
   SIGNAL sChipStart     : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sMarkerL       : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sSensorOut     : STD_LOGIC_VECTOR (79 DOWNTO 0);
   SIGNAL sLUanalog_T    : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sLUdigital_T   : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sLUanalog_in   : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sLUdigital_in  : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sLUanalog_out  : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sLUdigital_out : STD_LOGIC_VECTOR (4 DOWNTO 1);
   SIGNAL sLUmtb_T       : STD_LOGIC;
   SIGNAL sLUmtb_in      : STD_LOGIC;
   SIGNAL sLUmtb_out     : STD_LOGIC;
   ---------------------------------------------> Sensor signals

   ---------------------------------------------< GTX MGT112 signals
   SIGNAL sMgt112RefClk0 : STD_LOGIC;
   SIGNAL sMgt112RefClk1 : STD_LOGIC;
   ---------------------------------------------> GTX MGT112 signals

   ---------------------------------------------< IODELAY signals
   SIGNAL sIdelayctrl_RDY : STD_LOGIC;
   SIGNAL sIodelayRst     : STD_LOGIC;
   ---------------------------------------------> IODELAY signals

   ---------------------------------------------< Chipscope signals
   SIGNAL sCS_control0 : STD_LOGIC_VECTOR (35 DOWNTO 0);
   SIGNAL sCS_trig0    : STD_LOGIC_VECTOR (71 DOWNTO 0);
   ---------------------------------------------> Chipscope signals

   SIGNAL TC    : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL TC_F  : STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL D_TX  : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sD_TX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sD_RX : STD_LOGIC_VECTOR (23 DOWNTO 0);

--      oL_START       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL sL_SENSOR_IN  : LVDS_OUT_ARRAY_TYPE;
   SIGNAL sL_SENSOR_OUT : LVDS_IN_ARRAY_TYPE;
   SIGNAL usb_rd_sel    : STD_LOGIC_VECTOR (1 DOWNTO 0);

   --status
   SIGNAL sLinkStatus : FIBER8_STATUS                 := (OTHERS => (OTHERS => '0'));
   SIGNAL sLinkCtrl   : FIBER8_CTRL                   := (OTHERS => (OTHERS => (OTHERS => '0')));
   SIGNAL sL2Fversion : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sL2Flocked  : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

   SIGNAL sCalLVDS : STD_LOGIC := '0';
   SIGNAL iCalLVDS : STD_LOGIC := '0';

   SIGNAL FIFO_Q_jtag        : STD_LOGIC_VECTOR (35 DOWNTO 0);
   SIGNAL FIFO_Rdreq_jtag    : STD_LOGIC;
   SIGNAL FIFO_Q_payload     : STD_LOGIC_VECTOR (35 DOWNTO 0);
   SIGNAL FIFO_Rdreq_payload : STD_LOGIC;

   --General
   SIGNAL sBoardID : STD_LOGIC_VECTOR (3 DOWNTO 0) := x"0";



   -- pedestal memory write
   SIGNAL sPedMemWrite : PED_MEM_WRITE;

-------CONSTANTS 


   CONSTANT sData_FormatV : STD_LOGIC_VECTOR (7 DOWNTO 0)  := x"01";  --TEMPORAL
   CONSTANT sFPGA_BuildN  : STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0021";  -- RDO project number

-------------------------------------------------------------------------------
-- ****************************************************************************
-- Start of the implementation ------------------------------------------------
-- ****************************************************************************
-------------------------------------------------------------------------------
BEGIN
   -- chip enable signals for the dual purpose pins
   -- that also service the flash address lines
   DC_NOT_ADD_EN_BAR <= '0';            -- use as I/O 
   FLASH_ADD_EN_BAR  <= '1';            -- not Flash Address

---------------------------------------------< Clocks
   reset_sm : GlobalReset
      PORT MAP (
         CLK        => sClk50,
         DCM_LOCKED => sClkLocked,
         CLK_RST    => sClkRST,
         GLOBAL_RST => sGlobalRST
         );

-------------------------------------------------------------------------------
-- Generate all the clocks needed for the design
-- Use global buffers for all clock lines
-------------------------------------------------------------------------------
   -- MMCM component instance
   clockg_inst : Clock_generator
      PORT MAP (
         CLK_IN1  => OSC_50MHZ,
         CLK_OUT1 => sClk320,           -- 320 MHz
         CLK_OUT2 => sClk200,           -- 200 MHz
         CLK_OUT3 => sClk160,           -- 160 MHz
         CLK_OUT4 => sClk100,           -- 100 MHz
         CLK_OUT5 => sClk80,            -- 80 MHz
         CLK_OUT6 => sClk40,            -- 40 MHz 
         CLK_BUFG => sClk50,            -- original 50 MHz, buffered
         RESET    => sClkRST,
         LOCKED   => sClkLocked
         );
---------------------------------------------> Clocks


---------------------------------------------< MB FTDI
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

   mftb_bufd : FOR i IN 0 TO 7 GENERATE  -- B port
      IOBUF_mftb_di : IOBUF
         PORT MAP (
            O  => sMFTB_D_in(i),        -- Buffer output
            IO => MFTB_D(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sMFTB_D_out(i),       -- Buffer input
            T  => sMFTB_D_T   -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE mftb_bufd;

   MFT_RESET_n <= '1';

   MFTA_RD_n <= sMFTA_RD_n;
   MFTA_WR_n <= sMFTA_WR_n;
   MFTA_SIWU <= sMFTA_SIWU;

	mft2232h_instA : M_FT2232H
      PORT MAP (
         CLK            => sClk40,
         RESET          => sMFTA_rst,
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
         CLKOUT         => MFTA_CLKOUT,                  -- Sync USB FIFO clock
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



   sMFTA_rst <= sGlobalRst;

   sMFTB_D_out <= (OTHERS => '0');
   sMFTB_D_T   <= '1';                  -- inputs
   MFTB_RD_n   <= '1';
   MFTB_WR_n   <= '1';
   MFTB_SIWU   <= '1';
   MFTB_OE_n   <= '1';

---------------------------------------------> MB FTDI
---------------------------------------------< SIU
   -- SIU clock
   SIU_FOCLK <= NOT sClk50;
--  SIU_FOCLK <= sClk50;

   -- bi-directional data signals:
   siu_bufd : FOR i IN 0 TO 31 GENERATE
      IOBUF_siu_fbdi : IOBUF
         PORT MAP (
            O  => sSiu_fiD(i),          -- Buffer output
            IO => SIU_FBD(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sSiu_foD(i),          -- Buffer input
            T  => sSiu_T       -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE siu_bufd;

   -- bi-directional control signals FBTEN_n and FBCTRL_n:
   IOBUF_siu_fbten : IOBUF
      PORT MAP (
         O  => sSiu_fiTEN_n,            -- Buffer output
         IO => SIU_FBTEN_n,  -- Buffer inout port (connect directly to top-level port)
         I  => sSiu_foTEN_n,            -- Buffer input
         T  => sSiu_T        -- 3-state enable signal, 1=input, 0=output
         );

   IOBUF_siu_fbctrl : IOBUF
      PORT MAP (
         O  => sSiu_fiCTRL_n,           -- Buffer output
         IO => SIU_FBCTRL_n,  -- Buffer inout port (connect directly to top-level port)
         I  => sSiu_foCTRL_n,           -- Buffer input
         T  => sSiu_T         -- 3-state enable signal, 1=input, 0=output
         );

   -- an example implementation:
   ddl_inst : ddl
      PORT MAP (
         CLK            => sClk80,      --reading clock for input fifo
         RESET          => sSiu_rst,
         FID            => sSiu_fiD,
         FOD            => sSiu_foD,
         FOBSY_n        => SIU_FOBSY_n,
         FICLK          => sClk50,
         FIDIR          => SIU_FIDIR,
         FIBEN_n        => SIU_FIBEN_n,
         FILF_n         => SIU_FILF_n,
         FICTRL_n       => sSiu_fiCTRL_n,
         FOCTRL_n       => sSiu_foCTRL_n,
         FITEN_n        => sSiu_fiTEN_n,
         FOTEN_n        => sSiu_foTEN_n,
         SIU_T          => sSiu_T,
         FEE_RESET      => sSiuFeeReset,
         EVT_RD_ENABLE  => sSiuEvt_RD_EN,  --Clear buffers and lower bussy when 0
         FIFO_Q         => sSiu_FifoQ,
         FIFO_EMPTY     => sSiu_FifoEmpty,
         FIFO_RDREQ     => sSiu_fifoRdreq,
         FIFO_RDCLK     => sSiu_fifoRdClk,
         CMD_FIFO_Q     => sSiu_CmdFifoQ,
         CMD_FIFO_EMPTY => sSiu_CmdFifoEmpty,
         CMD_FIFO_RDREQ => sSiu_CmdFifoRdreq
         );

   -- defaults for now:
   sSiu_rst <= sGlobalRst;



--  sSiu_FifoQ        <= (OTHERS => '0');
--  sSiu_FifoEmpty    <= '1';
--  sSiu_CmdFifoRdreq <= '0';


-- clearing ddl link fifo to nowhere for now.
   PROCESS (sClk80) IS
   BEGIN
      IF RISING_EDGE(sClk80) THEN
         IF sSiu_CmdFifoEmpty = '0' THEN
            sSiu_CmdFifoRdreq <= '1';
         ELSE
            sSiu_CmdFifoRdreq <= '0';
         END IF;
      END IF;
   END PROCESS;
---------------------------------------------> SIU

---------------------------------------------< DAQ
   DAQ_ints : DAQ PORT MAP(
      CLK40                       => sCLK40,
      CLK80                       => sCLK80,
      RST                         => sGlobalRst,
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
      RS                          => TCD_RS,
      RSx5                        => TCD_5xRS,
      TCD_DATA                    => TCD_D,
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
         RST                         => sGlobalRst,
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


---------------------------------------------< Expansion board
   -- I/O buffers on all bi-directional daughter card pins

   -- "A" Connector single ended pins
   dca_bufs1 : FOR i IN 41 TO 100 GENERATE
      IOBUF_dcasi : IOBUF
         PORT MAP (
            O  => sDcA_in(i),           -- Buffer output
            IO => DC_A(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sDcA_out(i),          -- Buffer input
            T  => sDcA_T(i)     -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE dca_bufs1;

   dca_bufd1 : FOR i IN 1 TO 20 GENERATE
      IOBUF_dcadni : IBUFDS
         GENERIC MAP (
            DIFF_TERM  => TRUE,         -- Differential Termination
            IOSTANDARD => "LVDS_25"
            )
         PORT MAP (
            O  => sDcA_in(i),           -- Buffer output
            I  => DC_A_P(i),  -- Diff_p inout (connect directly to top-level port)
            IB => DC_A_N(i)  -- Diff_n inout (connect directly to top-level port)
            );
   END GENERATE dca_bufd1;


   -- "B" Connector
   dcb_bufs : FOR i IN 1 TO 100 GENERATE
      IOBUF_dcbi : IOBUF
         PORT MAP (
            O  => sDcB_in(i),           -- Buffer output
            IO => DC_B(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sDcB_out(i),          -- Buffer input
            T  => sDcB_T(i)     -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE dcb_bufs;

   -- J63 header:
   sDcA_T(100 DOWNTO 41)   <= (OTHERS => '1');  -- inputs
   sDcA_out(100 DOWNTO 41) <= (OTHERS => '0');

   -- J65 header
   sDcB_T(100 DOWNTO 1)   <= (OTHERS => '1');  -- inputs
   sDcB_out(100 DOWNTO 1) <= (OTHERS => '0');

   sBoardID <= sDcB_in(38 DOWNTO 37) & sDcB_in(39) & sDcB_in(36);

---------------------------------------------> Expansion board

   LVDS2Fiber_interface_inst : LVDS2Fiber_interface
      PORT MAP (
         iCLK40          => sClk40,
         iCLK200         => sClk200,
         iRST            => sGlobalRst,
         iClkLocked      => sClkLocked,
         -- control
         iManual_CalLine => iCalLVDS,
         oLinkStatus     => sLinkStatus,
         iLinkCtrl       => sLinkCtrl,
         oL2Fversion     => sL2Fversion,
         oL2Flocked      => sL2Flocked,
         iLVDS_CNT_EN    => sLVDS_CNT_EN,
         -- fiber links
         iFiber_RDOtoLC  => sFiber_RDOtoLC,
         oFiber_LCtoRDO  => sFiber_LCtoRDO,
         -- LVDS links
         oL_START        => sChipStart,
         iL_Marker       => sMarkerL,
         oL_SENSOR_OUT   => sL_SENSOR_IN,
         iL_SENSOR_IN    => sL_SENSOR_OUT,
         -- 
         oL_RSTB         => L_RSTB,
         iL_LU_digital_1 => sLUdigital_in (1),
         iL_LU_analog_2  => sLUanalog_in (2),
         oL_LU_analog_1  => sLUanalog_out (1),
         oL_LU_digital_2 => sLUdigital_out (2),
         oL_JTAG_TCK     => L_JTAG_TCK (4 DOWNTO 3),
         oL_JTAG_TMS     => L_JTAG_TMS (4 DOWNTO 3),
         -- test connector
         oTC             => OPEN
         );

   iCalLVDS <= NOT TCD_BUSY_BAR2 OR sCalLVDS;




---------------------------------------------< Latchup
-----------------------------------------------------------------------------
-- defaults for now:
   sLUanalog_T    <= (OTHERS => '1');   -- all inputs
   sLUdigital_T   <= (OTHERS => '1');   -- all inputs
   sLUmtb_T       <= '1';               -- input
   sLUanalog_out  <= (OTHERS => '0');
   sLUdigital_out <= (OTHERS => '0');
   sLUmtb_out     <= '0';
-----------------------------------------------------------------------------

-- I/O buffers on pins for latchup
   IOBUF_mtb : IOBUF
      PORT MAP (
         O  => sLUmtb_in,               -- Buffer output
         IO => LU_MTB,  -- Buffer inout port (connect directly to top-level port)
         I  => sLUmtb_out,              -- Buffer input
         T  => sLUmtb_T     -- 3-state enable signal, 1=input, 0=output
         );


   lu_a : FOR i IN 1 TO 4 GENERATE
      IOBUF_lu_a : IOBUF
         PORT MAP (
            O  => sLUanalog_in(i),      -- Buffer output
            IO => L_LU_analog(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sLUanalog_out(i),     -- Buffer input
            T  => sLUanalog_T(i)   -- 3-state enable signal, 1=input, 0=output
            );

      IOBUF_lu_d : IOBUF
         PORT MAP (
            O  => sLUdigital_in(i),     -- Buffer output
            IO => L_LU_digital(i),  -- Buffer inout port (connect directly to top-level port)
            I  => sLUdigital_out(i),    -- Buffer input
            T  => sLUdigital_T(i)   -- 3-state enable signal, 1=input, 0=output
            );

   END GENERATE lu_a;





---------------------------------------------< IODELAY
   sIodelayRst <= NOT sClkLocked;
   IDELAYCTRL_inst_1 : IDELAYCTRL
      PORT MAP (
         RDY    => sIdelayctrl_RDY,
         REFCLK => sClk200,             -- 32 taps, each tap = 78.125ps
         RST    => sIodelayRst
         );
---------------------------------------------> IODELAY



-----------------------------------------------------------------------------
-------------------- Sensor Control & I/O Buffers ---------------------------
-----------------------------------------------------------------------------
   -- clock to first ladder
   clk_buff1 : OBUFDS
      GENERIC MAP (
         IOSTANDARD => "LVDS_25")
      PORT MAP (
         O  => L1_PM_CLK_P,
         OB => L1_PM_CLK_N,
         I  => sClk160
         );

   ladder_l : FOR l IN 1 TO 4 GENERATE  -- 4 Ladders
      -- START signal
      start_ladder1 : OBUFDS
         GENERIC MAP (
            IOSTANDARD => "LVDS_25")
         PORT MAP (
            O  => L_START_P(l),
            OB => L_START_N(l),
            I  => sChipStart(l)
            );

      -- MARKER signal
      in_marker_L : IBUFDS
         GENERIC MAP (
            IOSTANDARD => "LVDS_25")
         PORT MAP (
            O  => sMarkerL(l),
            I  => L_MARKER_P(l),
            IB => L_MARKER_N(l)
            );

      sensor_lo : FOR s IN 1 TO 12 GENERATE  -- TO 8 Sept17
         output_lo : FOR o IN 1 TO 2 GENERATE
            in_L_S_O : IBUFDS
               GENERIC MAP (
                  IOSTANDARD => "LVDS_25")
               PORT MAP (
                  O  => sL_SENSOR_OUT (l, s, o),
                  I  => L_SENSOR_OUT_P (l, s, o),
                  IB => L_SENSOR_OUT_N (l, s, o)
                  );
         END GENERATE output_lo;
      END GENERATE sensor_lo;

      sensor_li : FOR s IN 3 TO 10 GENERATE
         output_li : FOR o IN 3 TO 4 GENERATE
            out_L_S_O : OBUFDS
               GENERIC MAP (
                  IOSTANDARD => "LVDS_25")
               PORT MAP (
                  I  => sL_SENSOR_IN (l, s, o),
                  O  => L_SENSOR_IN_P (l, s, o),
                  OB => L_SENSOR_IN_N (l, s, o)
                  );
         END GENERATE output_li;
      END GENERATE sensor_li;

   END GENERATE ladder_l;

   -----------------------------------------------------------------------------
   -- defaults for now:
   --sChipStart <= (OTHERS => '0');

   def_1 : FOR i IN 1 TO 2 GENERATE
      --L_RSTB(i)     <= '1';
      L_JTAG_TDI(i) <= '0';
      L_JTAG_TMS(i) <= '0';
      L_JTAG_TCK(i) <= '0';
   END GENERATE def_1;
   L_JTAG_TDI (4 DOWNTO 3) <= "00";

END SSD_RDO_TOP_Arch;

