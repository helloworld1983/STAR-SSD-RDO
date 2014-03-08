----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    11:02:15 08/26/2013 
-- Design Name: 
-- Module Name:    DAQ - DAQ_Arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author         Description
-- 08/26/2013  1.0        Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;
USE ieee.std_logic_misc.ALL;
ENTITY DAQ IS
   PORT (
      CLK40                       : IN  STD_LOGIC;
      CLK80                       : IN  STD_LOGIC;
		CLK200 							 : IN  STD_LOGIC;
      RST                         : IN  STD_LOGIC;
      --GENERAL
      BoardID                     : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
      Data_FormatV                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      FPGA_BuildN                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
		DATA_BUFF_RST				 	 : IN STD_LOGIC;
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
      -- trigger admin status Registers
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
END DAQ;

ARCHITECTURE DAQ_Arch OF DAQ IS
   --------------------------------------------------------------------
   COMPONENT LC_Fiber IS
      PORT (
         CLK40                       : IN  STD_LOGIC;
         CLK80                       : IN  STD_LOGIC;
         RST                         : IN  STD_LOGIC;
         --LadderCard RESET
         LC_RST                      : IN  STD_LOGIC;
         --LC_FPGA_Configuration
         CONFIG_CMD_IN               : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- This 16 bits are a control register that contains two signals, from 15 to 8 is the ST_RESET request -8 is fiber 0
         CONFIG_DATA_IN              : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- This is the data to be configured
         CONFIG_DATA_IN_WE           : IN  STD_LOGIC;  -- Data write enable
         CONFIG_BUSY                 : OUT STD_LOGIC;
         CONFIG_STATUS_OUT           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  --    Puts status of the CONFIG
         --LC_JTAG_Master
         JTAG_DATA_TDI               : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         JTAG_DATA_WE                : IN  STD_LOGIC;
         JTAG_BUSY                   : OUT STD_LOGIC;
         JTAG_DATA_TDO               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         --LC_Trigger_Handler
         ACQUIRE                     : IN  STD_LOGIC;  --signal meaning that a trigger came either through TCD or USB needs to remain high
         TRIGGER_MODE                : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
         TEST2HOLD_DELAY             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
         -- PIPE
         ADC_offset                  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         Zero_supr_trsh              : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         ZST_Polarity                : IN  STD_LOGIC;
         Pipe_Selector               : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         PIPE_ST_BUSY                : OUT STD_LOGIC;
         --LC Address Number
         LC_ADDRESS                  : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
         -- pedestal memory write port
         iPedMemWrite                : IN  PED_MEM_WRITE;
         --Payload Memory    
         PAYLOAD_MEM_RADDR           : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
         PAYLOAD_MEM_RDCLK           : IN  STD_LOGIC;
         PAYLOAD_MEM_GT_ONE          : OUT STD_LOGIC;  -- Greater than one flag
         PAYLOAD_MEM_OUT             : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
         WR_SERIAL                   : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
         RD_SERIAL                   : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
         --LC_Status
         LC_STATUS_REG               : OUT FIBER_ARRAY_TYPE_16;
         LC_HYBRIDS_POWER_STATUS_REG : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         --LADDER_CARD_FIBER
         RDO2LC                      : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
         LC2RDO                      : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
			--TestConnector
			TC									 : OUT STD_LOGIC_VECTOR (68 DOWNTO 0)
         );
   END COMPONENT LC_Fiber;

   COMPONENT Trigger_Admin IS
      PORT (
         CLK40                    : IN  STD_LOGIC;
         CLK80                    : IN  STD_LOGIC;
			CLK200					: IN  STD_LOGIC;
         RST                      : IN  STD_LOGIC;
         --to fibers
         BUSY_8_FIBERS            : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);  --each bit is the busy line of the pipe of each fiber
         BUSY_COMBINED            : OUT STD_LOGIC;  --general busy OR with each fiber busy 
         WR_SERIAL                : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);  --serial number 12 bits to check for greater than one flag
         TRIGGER_MODE             : OUT TRIGGER_MODE_ARRAY_TYPE;
         ACQUIRE                  : OUT STD_LOGIC;
         -- Registers
         TCD_DELAY_Reg            : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         TCD_EN_TRGMODES_Reg      : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
         Forced_Triggers_Reg      : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
         Status_Counters_RST_REG  : IN  STD_LOGIC;
         TCD_Level0_RCVD_REG      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         RHIC_STROBE_LSB_REG      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         RHIC_STROBE_MSB_REG      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         N_HOLDS_REG              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         N_TESTS_REG              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			DATA_BUFF_RST				 : IN STD_LOGIC;
         -- TCD signals
         RS                       : IN  STD_LOGIC;  -- TCD RHIC strobe
         RSx5                     : IN  STD_LOGIC;  -- TCD data clock
         TCD_DATA                 : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);  -- TCD data
         TCD_FIFO_Q               : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);  -- Triggerwords for inclusion in data
         TCD_FIFO_EMPTY           : OUT STD_LOGIC;  -- Triggerwords FIFO emtpy
         TCD_FIFO_RDREQ           : IN  STD_LOGIC;  -- Read Request for Triggerwords FIFO
         RScnt_TRGword_FIFO_OUT   : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
         RScnt_TRGword_FIFO_EMPTY : OUT STD_LOGIC;
         RScnt_TRGword_FIFO_RDREQ : IN  STD_LOGIC
         );
   END COMPONENT Trigger_Admin;


   COMPONENT Data_Packer IS
      PORT (
         CLK80                    : IN  STD_LOGIC;
         RST                      : IN  STD_LOGIC;
         --GENERAL
         BoardID                  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         Data_FormatV             : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         FPGA_BuildN              : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         --PAYLOAD MEMORIES FROM 8 FIBER PIPES
         RD_SERIAL                : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
         PAYLOAD_MEM_GT_ONE       : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         PAYLOAD_MEM_RADDR        : OUT PAYLOAD_MEM_RADDR_ARRAY_TYPE;  --14 downto 0 (15 bits)
         PAYLOAD_MEM_OUT          : IN  PAYLOAD_MEM_OUT_ARRAY_TYPE;  --35 downto 0 (36 bits)
         --Trigger Admin module
         TCD_FIFO_Q               : IN  STD_LOGIC_VECTOR (19 DOWNTO 0);  -- Triggerwords for inclusion in data
         TCD_FIFO_EMPTY           : IN  STD_LOGIC;  -- Triggerwords FIFO emtpy
         TCD_FIFO_RDREQ           : OUT STD_LOGIC;  -- Read Request for Triggerwords FIFO
         RScnt_TRGword_FIFO_OUT   : IN  STD_LOGIC_VECTOR (35 DOWNTO 0);
         RScnt_TRGword_FIFO_EMPTY : IN  STD_LOGIC;
         RScnt_TRGword_FIFO_RDREQ : OUT STD_LOGIC;
         -- REGISTERS COUNTERS
         Status_Counters_RST_REG  : IN  STD_LOGIC;
         TCD_TRG_RCVD_REG         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         SIU_PACKET_CNT_REG       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         --SIU DDL LINK
         DDL_FIFO_Q               : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface fifo data output port
         DDL_FIFO_EMPTY           : OUT STD_LOGIC;  -- interface fifo "emtpy" signal
         DDL_FIFO_RDREQ           : IN  STD_LOGIC;  -- interface fifo read request
         DDL_FIFO_RDCLK           : IN  STD_LOGIC  -- interface fifo read clock
         );

   END COMPONENT Data_Packer;
	
component chipscope_icon_daq
  PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	 );
end component;

component chipscope_ila_daq
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CLK : IN STD_LOGIC;
    TRIG0 : IN STD_LOGIC_VECTOR(68 DOWNTO 0)
	 );
end component;
	
signal CONTROL0 : STD_LOGIC_VECTOR(35 DOWNTO 0);
signal TRIG0 : STD_LOGIC_VECTOR(68 DOWNTO 0);

   SIGNAL sTRIGGER_MODE  : TRIGGER_MODE_ARRAY_TYPE        := (OTHERS => (OTHERS => '0'));
   SIGNAL sACQUIRE       : STD_LOGIC                      := '0';
   SIGNAL sWR_SERIAL     : STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sRD_SERIAL     : STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sBUSY_8_FIBERS : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');

--PAYLOAD
   SIGNAL sPAYLOAD_MEM_RADDR  : PAYLOAD_MEM_RADDR_ARRAY_TYPE  := (OTHERS => (OTHERS => '0'));
   SIGNAL sPAYLOAD_MEM_OUT    : PAYLOAD_MEM_OUT_ARRAY_TYPE    := (OTHERS => (OTHERS => '0'));
   SIGNAL sPAYLOAD_MEM_GT_ONE : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

--TCD FIFOS
   SIGNAL sTCD_FIFO_Q               : STD_LOGIC_VECTOR (19 DOWNTO 0) := (OTHERS => '0');  -- Triggerwords for inclusion in data
   SIGNAL sTCD_FIFO_EMPTY           : STD_LOGIC                      := '0';  -- Triggerwords FIFO emtpy
   SIGNAL sTCD_FIFO_RDREQ           : STD_LOGIC                      := '0';  -- Read Request for Triggerwords FIFO
   SIGNAL sRScnt_TRGword_FIFO_OUT   : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sRScnt_TRGword_FIFO_EMPTY : STD_LOGIC                      := '0';
   SIGNAL sRScnt_TRGword_FIFO_RDREQ : STD_LOGIC                      := '0';
	
	--TEST CONNECTOR
	TYPE TC_ARRAY_TYPE IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (68 DOWNTO 0);
	
	SIGNAL sTC : TC_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));

BEGIN

   FIBERS : FOR i IN 0 TO 7 GENERATE
      LC_Inst : LC_Fiber
         PORT MAP(
            CLK40                       => CLK40,
            CLK80                       => CLK80,
            RST                         => RST,
            --LadderCard RESET
            LC_RST                      => LC_RST (i),
            --LC_FPGA_Configuration
            CONFIG_CMD_IN               => CONFIG_CMD_IN (i),
            CONFIG_DATA_IN              => CONFIG_DATA_IN (i),
            CONFIG_DATA_IN_WE           => CONFIG_DATA_IN_WE (i),
            CONFIG_BUSY                 => CONFIG_BUSY (i),
            CONFIG_STATUS_OUT           => CONFIG_STATUS_OUT (i),
            --LC_JTAG_Master
            JTAG_DATA_TDI               => JTAG_DATA_TDI (i),
            JTAG_DATA_WE                => JTAG_DATA_WE (i),
            JTAG_BUSY                   => JTAG_BUSY (i),
            JTAG_DATA_TDO               => JTAG_DATA_TDO (i),  --ALL NEW FROM HERE DOWN
            --LC_Trigger_Handler
            ACQUIRE                     => sACQUIRE,  --ACQUIRE goes to all fibers so they can put the Header at least
            TRIGGER_MODE                => sTRIGGER_MODE (i),
            TEST2HOLD_DELAY             => TEST2HOLD_DELAY,
            -- PIPE                             
            ADC_offset                  => ADC_offset (i)(9 DOWNTO 0),
            Zero_supr_trsh              => Zero_supr_trsh (i)(9 DOWNTO 0),
            ZST_Polarity                => ZST_Polarity (i),
            Pipe_Selector               => Pipe_Selector,  --ONLY ONE PIPE SELECTOR FOR ALL 8 FIBERS
            PIPE_ST_BUSY                => sBUSY_8_FIBERS (i),
            --LC Address Number
            LC_ADDRESS                  => STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3)),
            -- pedestal memory write port
            iPedMemWrite                => iPedMemWrite,
            --Payload Memory                  
            PAYLOAD_MEM_RADDR           => sPAYLOAD_MEM_RADDR (i),
            PAYLOAD_MEM_RDCLK           => CLK80,  --CLOCK to read data fifo              
            PAYLOAD_MEM_GT_ONE          => sPAYLOAD_MEM_GT_ONE (i),
            PAYLOAD_MEM_OUT             => sPAYLOAD_MEM_OUT (i),
            WR_SERIAL                   => sWR_SERIAL,
            RD_SERIAL                   => sRD_SERIAL,
            --LC_Status                                                         
            LC_STATUS_REG               => LC_STATUS_REG (i),
            LC_HYBRIDS_POWER_STATUS_REG => LC_HYBRIDS_POWER_STATUS_REG (i),
            --LADDER_CARD_FIBER
            RDO2LC                      => Fiber_RDOtoLC (i),
            LC2RDO                      => Fiber_LCtoRDO (i),
				--TestConnector
				TC									 => sTC (i)
            );
   END GENERATE FIBERS;

   Trigger_Admin_inst : Trigger_Admin
      PORT MAP(
         CLK40                    => CLK40,
         CLK80                    => CLK80,
			CLK200						 => CLK200,
         RST                      => RST,
         --to fibers              
         BUSY_8_FIBERS            => sBUSY_8_FIBERS,
         BUSY_COMBINED            => BUSY_COMBINED,
         WR_SERIAL                => sWR_SERIAL,
         TRIGGER_MODE             => sTRIGGER_MODE,
         ACQUIRE                  => sACQUIRE,
         -- Registers                 
         TCD_DELAY_Reg            => TCD_DELAY_Reg,
         TCD_EN_TRGMODES_Reg      => TCD_EN_TRGMODES_Reg,
         Forced_Triggers_Reg      => Forced_Triggers_Reg,
         Status_Counters_RST_REG  => Status_Counters_RST_REG,
         TCD_Level0_RCVD_REG      => TCD_Level0_RCVD_REG,
         RHIC_STROBE_LSB_REG      => RHIC_STROBE_LSB_REG,
         RHIC_STROBE_MSB_REG      => RHIC_STROBE_MSB_REG,
         N_HOLDS_REG              => N_HOLDS_REG,
         N_TESTS_REG              => N_TESTS_REG,
			DATA_BUFF_RST				 => DATA_BUFF_RST,
         -- TCD signals             
         RS                       => RS,
         RSx5                     => RSx5,
         TCD_DATA                 => TCD_DATA,
         TCD_FIFO_Q               => sTCD_FIFO_Q,
         TCD_FIFO_EMPTY           => sTCD_FIFO_EMPTY,
         TCD_FIFO_RDREQ           => sTCD_FIFO_RDREQ,
         RScnt_TRGword_FIFO_OUT   => sRScnt_TRGword_FIFO_OUT,
         RScnt_TRGword_FIFO_EMPTY => sRScnt_TRGword_FIFO_EMPTY,
         RScnt_TRGword_FIFO_RDREQ => sRScnt_TRGword_FIFO_RDREQ
         );


   Data_Packer_Inst : Data_Packer
      PORT MAP(
         CLK80                    => CLK80,
         RST                      => RST,
         --GENERAL
         BoardID                  => BoardID,
         Data_FormatV             => Data_FormatV,
         FPGA_BuildN              => FPGA_BuildN,
         --PAYLOAD MEMORIES FROM 8 FIBERS
         RD_SERIAL                => sRD_SERIAL,
         PAYLOAD_MEM_GT_ONE       => sPAYLOAD_MEM_GT_ONE,
         PAYLOAD_MEM_RADDR        => sPAYLOAD_MEM_RADDR,
         PAYLOAD_MEM_OUT          => sPAYLOAD_MEM_OUT,
         --Trigger Admin module  
         TCD_FIFO_Q               => sTCD_FIFO_Q,
         TCD_FIFO_EMPTY           => sTCD_FIFO_EMPTY,
         TCD_FIFO_RDREQ           => sTCD_FIFO_RDREQ,
         RScnt_TRGword_FIFO_OUT   => sRScnt_TRGword_FIFO_OUT,
         RScnt_TRGword_FIFO_EMPTY => sRScnt_TRGword_FIFO_EMPTY,
         RScnt_TRGword_FIFO_RDREQ => sRScnt_TRGword_FIFO_RDREQ,
         -- REGISTERS COUNTERS
         Status_Counters_RST_REG  => Status_Counters_RST_REG,
         TCD_TRG_RCVD_REG         => TCD_TRG_RCVD_REG,
         SIU_PACKET_CNT_REG       => SIU_PACKET_CNT_REG,
         --SIU DDL LINK             
         DDL_FIFO_Q               => DDL_FIFO_Q,
         DDL_FIFO_EMPTY           => DDL_FIFO_EMPTY,
         DDL_FIFO_RDREQ           => DDL_FIFO_RDREQ,
         DDL_FIFO_RDCLK           => DDL_FIFO_RDCLK
         );
				 
chipscope_icon_daq_inst : chipscope_icon_daq
  PORT map (
    CONTROL0 => CONTROL0
	 );

chipscope_ila_daq_inst : chipscope_ila_daq
  PORT map (
    CONTROL => CONTROL0,
    CLK => CLK80,
    TRIG0 => TRIG0
	 );
	 
TRIG0 (68 DOWNTO 0) <= sTC(0);

END DAQ_Arch;

