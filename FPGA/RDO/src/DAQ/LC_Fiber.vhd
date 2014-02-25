----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    16:25:12 08/22/2013 
-- Design Name: 
-- Module Name:    LC_Fiber - LC_Fiber_Arch 
-- Project Name:         STAR HFT SSD
-- Target Devices: XILINX Virtex 6 (XC6VLX240T-FF1759)
-- Tool versions:  ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Date              Version         Author          Description
-- 08/22/2013        1.0             Luis Ardila     File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY LC_Fiber IS
   PORT (
      CLK40                       : IN  STD_LOGIC;
      CLK80                       : IN  STD_LOGIC;
      RST                         : IN  STD_LOGIC;
      --LadderCard RESET
      LC_RST                      : IN  STD_LOGIC;
      --LC_FPGA_Configuration
      CONFIG_CMD_IN               : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  --    This 16 bits are a control register that contains two signals, from 15 to 8 is the ST_RESET request -8 is fiber 0
      CONFIG_DATA_IN              : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- This is the data to be configured
      CONFIG_DATA_IN_WE           : IN  STD_LOGIC;  -- Data write enable
      CONFIG_BUSY                 : OUT STD_LOGIC;
      CONFIG_STATUS_OUT           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  --       Puts status of the CONFIG
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
      LC2RDO                      : IN  STD_LOGIC_VECTOR (23 DOWNTO 0)
      );
END LC_Fiber;

ARCHITECTURE LC_Fiber_Arch OF LC_Fiber IS

   COMPONENT LC_FPGA_Configuration IS
      PORT (
         CLK40             : IN  STD_LOGIC;
         RST               : IN  STD_LOGIC;
         -- Command Interface
         CONFIG_CMD_IN     : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- This 16 bits are a control register that contains two signals, from 15 to 8 is the ST_RESET request -8 is fiber 0
         CONFIG_DATA_IN    : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);  -- This is the data to be configured
         CONFIG_DATA_IN_WE : IN  STD_LOGIC;  -- Data write enable
         CONFIG_BUSY       : OUT STD_LOGIC;
         CONFIG_STATUS_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  --    Puts status of the CONFIG
         -- Altera Configuration Interfase 
         LC_DATA           : OUT STD_LOGIC;
         LC_NCONFIG        : OUT STD_LOGIC;
         LC_DCLK           : OUT STD_LOGIC;
         LC_INIT_SWITCH    : OUT STD_LOGIC;
         LC_NSTATUS        : IN  STD_LOGIC;
         LC_CONF_DONE      : IN  STD_LOGIC;
         -- Test Connector
         TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END COMPONENT LC_FPGA_Configuration;

   COMPONENT LC_JTAG_Master IS
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
   END COMPONENT LC_JTAG_Master;

   COMPONENT LC_Trigger_Handler IS
      PORT (
         CLK40           : IN  STD_LOGIC;
         RST             : IN  STD_LOGIC;
         -- command interface
         ACQUIRE         : IN  STD_LOGIC;  --acquire signal coming from TCD or USB triggers this signal must remain high during the entire transmision or the LC will abort
         TRIGGER_MODE    : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
         TEST2HOLD_DELAY : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
         -- TO LC
         LC_MODE         : OUT STD_LOGIC;
         LC_HOLD         : OUT STD_LOGIC;
         LC_TEST         : OUT STD_LOGIC;
         LC_TOKEN        : OUT STD_LOGIC;
         --Busy line
         LC_Trigger_Busy : OUT STD_LOGIC;
         --Test connector
         TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT LC_Trigger_Handler;

   COMPONENT DataPipe IS
      PORT (
         CLK40                       : IN  STD_LOGIC;
         CLK80                       : IN  STD_LOGIC;
         RST                         : IN  STD_LOGIC;
         --
         ADC_offset                  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         Zero_supr_trsh              : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         ZST_Polarity                : IN  STD_LOGIC;
         Pipe_Selector               : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         --LC Address Number
         LC_ADDRESS                  : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
         -- pedestal memory write port
         iPedMemWrite                : IN  PED_MEM_WRITE;
         --LC output to RDO
         LC2RDO                      : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
         -- Trigger State machine busy line
         LC_Trigger_Busy             : IN  STD_LOGIC;
         -- Data Pipe state machine busy
         PIPE_ST_BUSY                : OUT STD_LOGIC;
         --Payload Memory    
         PAYLOAD_MEM_RADDR           : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
         PAYLOAD_MEM_RDCLK           : IN  STD_LOGIC;
         PAYLOAD_MEM_GT_ONE          : OUT STD_LOGIC;  -- Greater than one flag
         PAYLOAD_MEM_OUT             : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
         WR_SERIAL                   : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
         RD_SERIAL                   : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
         --LC_Status REGISTERS          
         LC_STATUS_REG               : OUT FIBER_ARRAY_TYPE_16;
         LC_HYBRIDS_POWER_STATUS_REG : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
         );
   END COMPONENT DataPipe;

   COMPONENT fifo36x4096 IS
      PORT (
         WR_CLK : IN  STD_LOGIC;
         RD_CLK : IN  STD_LOGIC;
         RST    : IN  STD_LOGIC;
         WR_EN  : IN  STD_LOGIC;
         RD_EN  : IN  STD_LOGIC;
         DIN    : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
         DOUT   : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
         FULL   : OUT STD_LOGIC;
         EMPTY  : OUT STD_LOGIC
         );
   END COMPONENT fifo36x4096;

   SIGNAL sPAYLOAD_FIFO_DIN : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sJTAG_FIFO_DIN    : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sJTAG_DATA_TDO    : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sDATA_TDO_WE      : STD_LOGIC                      := '0';
   SIGNAL sLC_CONF_DONE     : STD_LOGIC                      := '0';
   SIGNAL sTDO              : STD_LOGIC                      := '0';
   SIGNAL sLC_INIT_SWITCH   : STD_LOGIC                      := '0';
   SIGNAL sLC_Trigger_Busy  : STD_LOGIC                      := '0';


BEGIN

   LC_FPGA_Configuration_inst : LC_FPGA_Configuration
      PORT MAP(
         CLK40             => CLK40,
         RST               => RST,
         -- Command Interface                               
         CONFIG_CMD_IN     => CONFIG_CMD_IN,
         CONFIG_DATA_IN    => CONFIG_DATA_IN,
         CONFIG_DATA_IN_WE => CONFIG_DATA_IN_WE,
         CONFIG_BUSY       => CONFIG_BUSY,
         CONFIG_STATUS_OUT => CONFIG_STATUS_OUT,
         -- Altera Configuration                             
         LC_DATA           => RDO2LC(21),
         LC_NCONFIG        => RDO2LC(22),
         LC_DCLK           => RDO2LC(23),
         LC_INIT_SWITCH    => sLC_INIT_SWITCH,
         LC_NSTATUS        => LC2RDO(23),
         LC_CONF_DONE      => sLC_CONF_DONE,
         -- Test Connector                                           
         TC                => OPEN
         );

   LC_JTAG_Master_inst : LC_JTAG_Master
      PORT MAP(
         CLK40       => CLK40,
         RST         => RST,
         -- command interface                                  
         DATA_TDI    => JTAG_DATA_TDI,
         DATA_WE     => JTAG_DATA_WE,
         BUSY_JTAG   => JTAG_BUSY,
         DATA_TDO    => sJTAG_DATA_TDO,
         DATA_TDO_WE => sDATA_TDO_WE,
         -- JTAG                                       
         TCK         => RDO2LC(3),
         TMS         => RDO2LC(2),
         TDI         => RDO2LC(0),
         TDO         => sTDO,
         -- test connector                            
         TC          => OPEN
         );

   LC_Trigger_Handler_inst : LC_Trigger_Handler
      PORT MAP(
         CLK40           => CLK40,
         RST             => RST,
         -- command interface 
         ACQUIRE         => ACQUIRE,
         TRIGGER_MODE    => TRIGGER_MODE,
         TEST2HOLD_DELAY => TEST2HOLD_DELAY,
         -- TO LC                                      
         LC_MODE         => RDO2LC(10),
         LC_HOLD         => RDO2LC(4),
         LC_TEST         => RDO2LC(5),
         LC_TOKEN        => RDO2LC(6),
         --Busy line
         LC_Trigger_Busy => sLC_Trigger_Busy,
         --Test connector
         TC              => OPEN
         );

   DataPipe_inst : DataPipe
      PORT MAP(
         CLK40                       => CLK40,
         CLK80                       => CLK80,
         RST                         => RST,
         ADC_offset                  => ADC_offset,
         Zero_supr_trsh              => Zero_supr_trsh,
         ZST_Polarity                => ZST_Polarity,
         Pipe_Selector               => Pipe_Selector,
         LC_ADDRESS                  => LC_ADDRESS,
         iPedMemWrite                => iPedMemWrite,
         LC2RDO                      => LC2RDO,
         LC_Trigger_Busy             => sLC_Trigger_Busy,
         PIPE_ST_BUSY                => PIPE_ST_BUSY,
         PAYLOAD_MEM_RADDR           => PAYLOAD_MEM_RADDR,
         PAYLOAD_MEM_RDCLK           => PAYLOAD_MEM_RDCLK,
         PAYLOAD_MEM_GT_ONE          => PAYLOAD_MEM_GT_ONE,
         PAYLOAD_MEM_OUT             => PAYLOAD_MEM_OUT,
         WR_SERIAL                   => WR_SERIAL,
         RD_SERIAL                   => RD_SERIAL,
         LC_STATUS_REG               => LC_STATUS_REG,
         LC_HYBRIDS_POWER_STATUS_REG => LC_HYBRIDS_POWER_STATUS_REG
         );

--       sJTAG_FIFO_DIN <=  x"0" & '0' & LC_ADDRESS & x"000" & sDATA_TDO;               

--       JTAG_FIFO_MEM : fifo36x4096
--      PORT MAP (
--         WR_CLK       => CLK40, 
--         RD_CLK       => JTAG_FIFO_RDCLK,
--         RST          => RST,
--         WR_EN        => sDATA_TDO_WE,
--         RD_EN        => JTAG_FIFO_RDREQ,
--         DIN          => sJTAG_FIFO_DIN,
--         DOUT         => JTAG_FIFO,
--         FULL         => OPEN,
--         EMPTY        => JTAG_FIFO_EMPTY
--         );

   PROCESS (CLK40, RST) IS              --LA JAN-08-2014
   BEGIN
      IF RST = '1' THEN
         JTAG_DATA_TDO <= (OTHERS => '0');
      ELSIF falling_edge(CLK40) THEN  -- sDATA_TDO_WE is generated with a falling edge of the 40 MHz clock
         IF sDATA_TDO_WE = '1' THEN
            JTAG_DATA_TDO <= sJTAG_DATA_TDO;
         END IF;
      END IF;
   END PROCESS;

   RDO2LC(20)    <= sLC_INIT_SWITCH;
   sTDO          <= LC2RDO(22) WHEN sLC_INIT_SWITCH = '1' ELSE sTDO;
   sLC_CONF_DONE <= LC2RDO(22) WHEN sLC_INIT_SWITCH = '0' ELSE sLC_CONF_DONE;


   RDO2LC (9 DOWNTO 7)   <= LC_ADDRESS;
   RDO2LC (1)            <= LC_RST;
   RDO2LC (19 DOWNTO 11) <= (OTHERS => '0');

END LC_Fiber_Arch;
