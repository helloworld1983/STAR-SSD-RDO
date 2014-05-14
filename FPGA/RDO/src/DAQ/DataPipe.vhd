----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    11:19:04 10/04/2013 
-- Design Name: 
-- Module Name:    DataPipe - DataPipe_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 10/04/2013    1.0    Luis Ardila    File created
-- Feb 21 2014   1.1		Luis Ardila		Changed fiber memory from true dual port to simple dual port
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY DataPipe IS
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
      LC_HYBRIDS_POWER_STATUS_REG : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		TC									 : OUT STD_LOGIC_VECTOR (68 DOWNTO 0)
      );	
END DataPipe;

ARCHITECTURE DataPipe_arch OF DataPipe IS

   COMPONENT LC2RDODataSorter IS
      PORT (
         CLK40          : IN  STD_LOGIC;
         LC2RDO         : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
         LC2RDO_Hybrids : OUT HYBRIDS_ARRAY_TYPE;  -- 16 words of 10 bits with Hybrids ADC
         Strip_Cnt      : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
         DataValid      : OUT STD_LOGIC
         );

   END COMPONENT LC2RDODataSorter;


   COMPONENT TwoTimesEng IS
      PORT (
         CLK80          : IN  STD_LOGIC;
         LC2RDO         : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
         LC2RDO_Hybrids : IN  HYBRIDS_ARRAY_TYPE;
         DataValid      : IN  STD_LOGIC;
         PAYLOAD_MEM_IN : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
         PAYLOAD_MEM_WE : OUT STD_LOGIC
         );
   END COMPONENT TwoTimesEng;

   COMPONENT Demux16Pos IS
      PORT (
         CLK80          : IN  STD_LOGIC;
         LC2RDO_Hybrids : IN  HYBRIDS_ARRAY_TYPE;
         DataValid_In   : IN  STD_LOGIC;
         Strip_Cnt      : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         DataValid_Out  : OUT STD_LOGIC;
         StripAddress   : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
         LC2RDO_1Hybrid : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
         );
   END COMPONENT Demux16Pos;

   COMPONENT Ped_substration IS
      PORT (
         CLK80            : IN  STD_LOGIC;
         DataValid        : IN  STD_LOGIC;
         ADC_offset       : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         Zero_supr_trsh   : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         ZST_Polarity     : IN  STD_LOGIC;
         LC2RDO_1Hybrid   : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         StripAddress     : IN  STD_LOGIC_VECTOR (13 DOWNTO 0);
         PED_MEM_DATA_OUT : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         PAYLOAD_MEM_IN   : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
         PAYLOAD_MEM_WE   : OUT STD_LOGIC;
			--TEST CONNECTOR
			TC						: OUT STD_LOGIC_VECTOR(36 DOWNTO 0)
         );
   END COMPONENT Ped_substration;

   COMPONENT LC_status_data IS
      PORT (
         CLK40                       : IN  STD_LOGIC;
         RST                         : IN  STD_LOGIC;
         LC_ADDRESS                  : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
         LC2RDO                      : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
         LC_STATUS                   : OUT FIBER_ARRAY_TYPE_36;
         LC_STATUS_REG               : OUT FIBER_ARRAY_TYPE_16;
         LC_HYBRIDS_POWER_STATUS_REG : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT Data_Pipe_Control IS
      PORT (
         CLK80              : IN  STD_LOGIC;
         RST                : IN  STD_LOGIC;
         -- Control flags
         LC_Trigger_Busy    : IN  STD_LOGIC;
         DataValid          : IN  STD_LOGIC;
         --LC Address Number
         LC_ADDRESS         : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
         -- LC_STATUS
         LC_STATUS          : IN  FIBER_ARRAY_TYPE_36;
         -- Pipe data
         PAYLOAD_MEM_IN_TTE : IN  STD_LOGIC_VECTOR (35 DOWNTO 0);
         PAYLOAD_MEM_WE_TTE : IN  STD_LOGIC;
         PAYLOAD_MEM_IN_CPS : IN  STD_LOGIC_VECTOR (35 DOWNTO 0);
         PAYLOAD_MEM_WE_CPS : IN  STD_LOGIC;
         Strip_Cnt          : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         -- Configuration registers
         ADC_offset_IN      : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         Zero_supr_trsh_IN  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         ADC_offset_OUT     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
         Zero_supr_trsh_OUT : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
         -- Operation mode register
         Pipe_Selector      : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
         -- Data Pipe state machine busy
         PIPE_ST_BUSY       : OUT STD_LOGIC;
         -- Memory interface
         PAYLOAD_MEM_WADDR  : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
         PAYLOAD_MEM_IN     : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);  -- Payload Memory data IN
         PAYLOAD_MEM_WE     : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         PAYLOAD_MEM_RADDR  : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
         PAYLOAD_MEM_OUT    : IN  STD_LOGIC_VECTOR (35 DOWNTO 0);
         WR_SERIAL          : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
         RD_SERIAL          : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
         PAYLOAD_MEM_GT_ONE : OUT STD_LOGIC;  -- Greater than one flag  
			--TEST CONNECTOR
			TC			 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)        
         );
   END COMPONENT Data_Pipe_Control;

   COMPONENT mem_12288_9
      PORT (
         clka  : IN  STD_LOGIC;
         wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
         addra : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
         dina  : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
         clkb  : IN  STD_LOGIC;
         addrb : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
         doutb : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
         );
   END COMPONENT mem_12288_9;

	COMPONENT mem_32k_36
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
		 clkb : IN STD_LOGIC;
		 addrb : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		 doutb : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	  );
	END COMPONENT;

-- LC2RDODataSorter_inst
   SIGNAL sLC2RDO_Hybrids : HYBRIDS_ARRAY_TYPE            := (OTHERS => (OTHERS => '0'));
   SIGNAL sStrip_Cnt      : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sDataValid      : STD_LOGIC                     := '0';

-- TwoTimesEng_inst
   SIGNAL sPAYLOAD_MEM_IN_TTE : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');  -- Two Times Engine
   SIGNAL sPAYLOAD_MEM_WE_TTE : STD_LOGIC                      := '0';

-- Demux16Pos_inst
   SIGNAL sDataValid_Out : STD_LOGIC                     := '0';
	SIGNAL sDataValid_Out_buff : STD_LOGIC                     := '0';
   SIGNAL sLC2RDO_1Hybrid : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sLC2RDO_1Hybrid_buff : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');

-- Ped_substration_inst
   SIGNAL sADC_offset         : STD_LOGIC_VECTOR (9 DOWNTO 0)  := (OTHERS => '0');
   SIGNAL sZero_supr_trsh     : STD_LOGIC_VECTOR (9 DOWNTO 0)  := (OTHERS => '0');
   SIGNAL sStripAddress       : STD_LOGIC_VECTOR (13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sStripAddress_buff       : STD_LOGIC_VECTOR (13 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sPED_MEM_DATA_OUT   : STD_LOGIC_VECTOR (9 DOWNTO 0)  := (OTHERS => '0');  -- Pedestal memory output
   SIGNAL sPED_MEM_WE         : STD_LOGIC_VECTOR (0 DOWNTO 0) := "0";
   SIGNAL sPAYLOAD_MEM_IN_CPS : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');  -- Compress
   SIGNAL sPAYLOAD_MEM_WE_CPS : STD_LOGIC                      := '0';

-- LC_status_data_ints
   SIGNAL sLC_STATUS : FIBER_ARRAY_TYPE_36 := (OTHERS => (OTHERS => '0'));

-- Payload_mem_inst             
   SIGNAL sPAYLOAD_MEM_WE    : STD_LOGIC_VECTOR (0 DOWNTO 0)  := (OTHERS => '0');
   SIGNAL sPAYLOAD_MEM_WADDR : STD_LOGIC_VECTOR (14 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sPAYLOAD_MEM_IN    : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');  -- Payload Memory data IN       
   SIGNAL sPAYLOAD_MEM_OUT   : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');  -- Payload Memory data IN      

-- 
   SIGNAL sStrip_Cnt_buff : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
	
	--Test connector
	SIGNAL sTC_PS	: STD_LOGIC_VECTOR (36 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sTC_PC	: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

BEGIN

   LC2RDODataSorter_inst : LC2RDODataSorter
      PORT MAP(
         CLK40          => CLK40,
         LC2RDO         => LC2RDO,
         LC2RDO_Hybrids => sLC2RDO_Hybrids,
         Strip_Cnt      => sStrip_Cnt,
         DataValid      => sDataValid
         );

   TwoTimesEng_inst : TwoTimesEng
      PORT MAP (
         CLK80          => CLK80,
         LC2RDO         => LC2RDO,
         LC2RDO_Hybrids => sLC2RDO_Hybrids,
         DataValid      => sDataValid,
         PAYLOAD_MEM_IN => sPAYLOAD_MEM_IN_TTE,
         PAYLOAD_MEM_WE => sPAYLOAD_MEM_WE_TTE
         );

   Demux16Pos_inst : Demux16Pos
      PORT MAP(
         CLK80          => CLK80,
         LC2RDO_Hybrids => sLC2RDO_Hybrids,
         DataValid_in   => sDataValid,
         Strip_Cnt      => sStrip_Cnt,
         DataValid_Out  => sDataValid_Out,
         StripAddress   => sStripAddress,
         LC2RDO_1Hybrid => sLC2RDO_1Hybrid
         );

   Ped_substration_inst : Ped_substration
      PORT MAP(
         CLK80            => CLK80,
         DataValid        => sDataValid_Out_buff,
         ADC_offset       => sADC_offset,
         Zero_supr_trsh   => sZero_supr_trsh,
         ZST_Polarity     => ZST_Polarity,
         LC2RDO_1Hybrid   => sLC2RDO_1Hybrid_buff,
         StripAddress     => sStripAddress_buff,
         PED_MEM_DATA_OUT => sPED_MEM_DATA_OUT,
         PAYLOAD_MEM_IN   => sPAYLOAD_MEM_IN_CPS,
         PAYLOAD_MEM_WE   => sPAYLOAD_MEM_WE_CPS,
			TC					  => sTC_PS
         );

   LC_status_data_ints : LC_status_data
      PORT MAP (
         CLK40                       => CLK40,
         RST                         => RST,
         LC_ADDRESS                  => LC_ADDRESS,
         LC2RDO                      => LC2RDO,
         LC_STATUS                   => sLC_STATUS,
         LC_STATUS_REG               => LC_STATUS_REG,
         LC_HYBRIDS_POWER_STATUS_REG => LC_HYBRIDS_POWER_STATUS_REG
         );

   Data_Pipe_Control_inst : Data_Pipe_Control
      PORT MAP(
         CLK80              => CLK80,
         RST                => RST,
         LC_Trigger_Busy    => LC_Trigger_Busy,
         DataValid          => sDataValid_Out,
         LC_ADDRESS         => LC_ADDRESS,
         LC_STATUS          => sLC_STATUS,
         PAYLOAD_MEM_IN_TTE => sPAYLOAD_MEM_IN_TTE,
         PAYLOAD_MEM_WE_TTE => sPAYLOAD_MEM_WE_TTE,
         PAYLOAD_MEM_IN_CPS => sPAYLOAD_MEM_IN_CPS,
         PAYLOAD_MEM_WE_CPS => sPAYLOAD_MEM_WE_CPS,
         Strip_Cnt          => sStrip_Cnt,
         ADC_offset_IN      => ADC_offset,
         Zero_supr_trsh_IN  => Zero_supr_trsh,
         ADC_offset_OUT     => sADC_offset,
         Zero_supr_trsh_OUT => sZero_supr_trsh,
         Pipe_Selector      => Pipe_Selector,
         PIPE_ST_BUSY       => PIPE_ST_BUSY,
         PAYLOAD_MEM_WADDR  => sPAYLOAD_MEM_WADDR,
         PAYLOAD_MEM_IN     => sPAYLOAD_MEM_IN,
         PAYLOAD_MEM_WE     => sPAYLOAD_MEM_WE,
         PAYLOAD_MEM_RADDR  => PAYLOAD_MEM_RADDR,
         PAYLOAD_MEM_OUT    => sPAYLOAD_MEM_OUT,
         WR_SERIAL          => WR_SERIAL,
         RD_SERIAL          => RD_SERIAL,
         PAYLOAD_MEM_GT_ONE => PAYLOAD_MEM_GT_ONE,
			TC 					 => sTC_PC
         );
 
   Payload_mem_inst : mem_32k_36
      PORT MAP (
         clka  => CLK80,
         wea   => sPAYLOAD_MEM_WE,
         addra => sPAYLOAD_MEM_WADDR,
         dina  => sPAYLOAD_MEM_IN,
         clkb  => PAYLOAD_MEM_RDCLK,
         addrb => PAYLOAD_MEM_RADDR,
         doutb => sPAYLOAD_MEM_OUT
         );

   PAYLOAD_MEM_OUT <= sPAYLOAD_MEM_OUT;
	
--   sPED_MEM_DATA_OUT <= b"00" & x"00";  --constant value for the PEDESTAL MEMORY, this needs to be updated with the memory and be sure it is syncronized with the rest of the logic

   -- the core uses std_logic_vector
   sPED_MEM_WE (0) <= iPedMemWrite.WE (TO_INTEGER (UNSIGNED (LC_ADDRESS)));

   mem_12288_9_inst : mem_12288_9
      PORT MAP (
         clka  => iPedMemWrite.CLK,
         wea   => sPED_MEM_WE,
         addra => iPedMemWrite.ADDR,
         dina  => iPedMemWrite.DATA,
         clkb  => CLK80,
         addrb => sStripAddress,
         doutb => sPED_MEM_DATA_OUT (9 DOWNTO 0)
         );
   --sPED_MEM_DATA_OUT (9) <= '0';

	--one clock cycle delay to compensate for pedestal memory response. 
	PROCESS (CLK80) IS
	BEGIN
		IF RISING_EDGE(CLK80) THEN
			sStripAddress_buff <= sStripAddress;
			sDataValid_Out_buff <= sDataValid_Out;
			sLC2RDO_1Hybrid_buff <= sLC2RDO_1Hybrid;
		END IF;
	END PROCESS;
	
	TC (9 downto 0) <= iPedMemWrite.DATA;
	TC (14 downto 10) <= iPedMemWrite.ADDR(4 downto 0);
	TC (15) <= sPED_MEM_WE (0);
	TC (25 downto 16) <= sPED_MEM_DATA_OUT (9 downto 0);
	TC (31 downto 26) <= sStripAddress(5 downto 0);
	TC (63 downto 32) <= sTC_PS(31 downto 0);
	
	--TC <= sTC_PC (31 DOWNTO 16) & sTC_PS & sTC_PC (15 DOWNTO 0);
	
END DataPipe_arch;

