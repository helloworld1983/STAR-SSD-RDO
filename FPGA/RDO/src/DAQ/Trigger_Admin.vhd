----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013
-- Create Date:    17:03:47 10/28/2013 
-- Design Name: 
-- Module Name:    Trigger_Admin - Trigger_Admin_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 17:03:47 10/28/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY Trigger_Admin IS
PORT (
		CLK40						: IN  STD_LOGIC;
		CLK80						: IN  STD_LOGIC;
		CLK200					: IN  STD_LOGIC;
		RST						: IN  STD_LOGIC;
		--to fibers
		BUSY_8_FIBERS			: IN  STD_LOGIC_VECTOR (7 DOWNTO 0); --each bit is the busy line of the pipe of each fiber
		BUSY_COMBINED 			: OUT STD_LOGIC;								--general busy OR with each fiber busy 
		WR_SERIAL 				: OUT STD_LOGIC_VECTOR (11 DOWNTO 0); --serial number 12 bits to check for greater than one flag
		TRIGGER_MODE 			: OUT TRIGGER_MODE_ARRAY_TYPE;
		ACQUIRE					: OUT STD_LOGIC;
		-- Registers
		TCD_DELAY_Reg  		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		TCD_EN_TRGMODES_Reg 	: IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
		Forced_Triggers_Reg 	: IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
		Status_Counters_RST_REG : IN STD_LOGIC;
		TCD_Level0_RCVD_REG		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		RHIC_STROBE_LSB_REG 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		RHIC_STROBE_MSB_REG 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		N_HOLDS_REG 				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		N_TESTS_REG 				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		DATA_BUFF_RST				: IN STD_LOGIC;
		-- TCD signals
		RS         						: IN  std_logic;         -- TCD RHIC strobe
		RSx5       						: IN  std_logic;         -- TCD data clock
		TCD_DATA   						: IN  std_logic_vector (3 DOWNTO 0);   -- TCD data
		TCD_FIFO_Q     				: OUT std_logic_vector (19 DOWNTO 0);  -- Triggerwords for inclusion in data
		TCD_FIFO_EMPTY 				: OUT std_logic;         -- Triggerwords FIFO emtpy
		TCD_FIFO_RDREQ 				: IN  std_logic;         -- Read Request for Triggerwords FIFO
		RScnt_TRGword_FIFO_OUT 		: OUT std_logic_vector (35 DOWNTO 0);
		RScnt_TRGword_FIFO_EMPTY 	: OUT std_logic; 
		RScnt_TRGword_FIFO_RDREQ 	: IN std_logic
		);
END Trigger_Admin;


ARCHITECTURE Trigger_Admin_arch OF Trigger_Admin IS

COMPONENT tcd_interface IS	 
	 PORT (
    CLK50      : IN  std_logic;         -- 80 MHz clock  NOTE THE CHANGE IN CLK SOURCE from 50 to 80 MHz - this clock is use to get the data out of the fifo
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
END COMPONENT tcd_interface;

COMPONENT TriggerControl_SerialCounter IS
PORT (
		CLK40						: IN  STD_LOGIC;
		RST						: IN  STD_LOGIC;
		BUSY_8_FIBERS			: IN  STD_LOGIC_VECTOR (7 DOWNTO 0); --each bit is the busy line of the pipe of each fiber
		BUSY_COMBINED 			: OUT STD_LOGIC;								--general busy OR with each fiber busy 
		WR_SERIAL 				: OUT STD_LOGIC_VECTOR (11 DOWNTO 0); --serial number 12 bits to check for greater than one flag
		-- Registers
		TCD_DELAY_Reg  		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		TCD_EN_TRGMODES_Reg 	: IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
		Forced_Triggers_Reg 	: IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
		--TCD
		WORKING    				: IN std_logic;         -- TCD interface is working
		RS_CTR     				: IN std_logic_vector (31 DOWNTO 0);  -- RHICstrobe counter
		TRGWORD    				: IN std_logic_vector (19 DOWNTO 0);  -- captured 20bit trigger word
		MASTER_RST 				: IN std_logic;         -- indicates master reset command										--DOING NOTHING AT THE MOMENT
		RScnt_TRGword_FIFO 	: OUT std_logic_vector (35 DOWNTO 0);  -- FIFO of triggers L0 received
		RScnt_TRGword_FULL 	: IN std_logic;         -- -- FIFO of triggers L0 received
		RScnt_TRGword_WE   	: OUT  std_logic;         -- -- FIFO of triggers L0 received
		EVT_TRG    				:  IN std_logic;   -- this signal indicates an event to read
		-- Modes of operation for fibers
		TRIGGER_MODE 			: OUT TRIGGER_MODE_ARRAY_TYPE;
		ACQUIRE 					: OUT STD_LOGIC
		);
END COMPONENT TriggerControl_SerialCounter;

	COMPONENT fifo36x512_TCD
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
  
  COMPONENT Status_Counters_TA IS
PORT(
		CLK40							: IN STD_LOGIC;
		--
		RS_CTR     					: IN std_logic_vector (31 DOWNTO 0);  -- RHICstrobe counter
		EVT_TRG_TCD					: IN STD_LOGIC;
		TRIGGER_MODE 				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);  -- ONLY USING ONE OF THE 8 TRIGGER MODES (CHANNEL 0)
		ACQUIRE 						: IN STD_LOGIC;
		--Registers
		Status_Counters_RST_REG : IN STD_LOGIC;
		TCD_Level0_RCVD_REG		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		RHIC_STROBE_LSB_REG 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		RHIC_STROBE_MSB_REG 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		N_HOLDS_REG 				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		N_TESTS_REG 				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
END COMPONENT Status_Counters_TA;

SIGNAL sRS_CTR  : std_logic_vector (31 DOWNTO 0) := (OTHERS => '0');
SIGNAL sTRGWORD : std_logic_vector (19 DOWNTO 0) := (OTHERS => '0');

SIGNAL sEVT_TRG : std_logic := '0';
SIGNAL sEVT_TRG_TCD : std_logic := '0';
SIGNAL sEVT_TRG_TCD_Buff : std_logic := '0';

SIGNAL sMASTER_RST : std_logic := '0';
SIGNAL sMASTER_RST_TCD : std_logic := '0';
SIGNAL sMASTER_RST_TCD_Buff : std_logic := '0';

SIGNAL sWORKING : std_logic := '0';
SIGNAL sWORKING_TCD : std_logic := '0';
SIGNAL sWORKING_TCD_Buff : std_logic := '0';

SIGNAL sRScnt_TRGword_FIFO_IN : std_logic_vector (35 DOWNTO 0) := (OTHERS => '0');
SIGNAL sRScnt_TRGword_FULL : std_logic := '0';	
SIGNAL sRScnt_TRGword_WE : std_logic := '0';

SIGNAL sTRIGGER_MODE 		: TRIGGER_MODE_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
SIGNAL sACQUIRE 			: STD_LOGIC := '0';
SIGNAL sRScnt_TRGword_FIFO_EMPTY : STD_LOGIC := '0';

TYPE state_type IS (ST_EMPTY, ST_NOT_EMPTY);
SIGNAL sFE_State     : state_type := ST_EMPTY;

		 
BEGIN  

tcd_interface_inst : tcd_interface  
  PORT MAP(
    CLK50       => CLK80,  -- 80 MHz clock  NOTE THE CHANGE IN CLK SOUCE from 50 to 80 MHz - this clock is use to get the data out of the fifo
    CLK200		 => CLK200,
	 RST         => RST,
	 -- TCD signals
    RS          => RS,        
    RSx5        => RSx5,      
    TCD_DATA    => TCD_DATA, 
	 -- Interface signals	 
    WORKING     => sWORKING_TCD, 		
    RS_CTR      => sRS_CTR,    
    TRGWORD     => sTRGWORD,   
    MASTER_RST  => sMASTER_RST_TCD,    --DONT KNOW WHAT TO DO WITH THIS SIGNAL
    FIFO_Q      => TCD_FIFO_Q,    
    FIFO_EMPTY  => TCD_FIFO_EMPTY,
	 FIFO_RST    => DATA_BUFF_RST,        	-- Reset TCD FIFO
    FIFO_RDREQ  => TCD_FIFO_RDREQ,
    EVT_TRG     => sEVT_TRG_TCD 
    );
	 
TriggerControl_SerialCounter_inst : TriggerControl_SerialCounter
PORT MAP(
		CLK40						=> CLK40,						
		RST						=> RST,						
		BUSY_8_FIBERS			=> BUSY_8_FIBERS,			
		BUSY_COMBINED 			=> BUSY_COMBINED, 			
		WR_SERIAL 				=> WR_SERIAL, 				
		-- Registers       
		TCD_DELAY_Reg  		=> TCD_DELAY_Reg,  		
		TCD_EN_TRGMODES_Reg 	=> TCD_EN_TRGMODES_Reg, 	
		Forced_Triggers_Reg 	=> Forced_Triggers_Reg, 	
		--TCD            
		WORKING    				=> sWORKING,    				
		RS_CTR     				=> sRS_CTR,     				
		TRGWORD    				=> sTRGWORD,    				
		MASTER_RST 				=> sMASTER_RST, 				--doing nothing
		RScnt_TRGword_FIFO 	=> sRScnt_TRGword_FIFO_IN,	
		RScnt_TRGword_FULL 	=> sRScnt_TRGword_FULL, 	
		RScnt_TRGword_WE   	=> sRScnt_TRGword_WE,   	
		EVT_TRG    				=> sEVT_TRG,    				
		-- to fibers      
		TRIGGER_MODE 			=> sTRIGGER_MODE, 			
		ACQUIRE 					=> sACQUIRE 					
		);	 
	 
RScnt_TRGword_FIFO: fifo36x512_TCD
    PORT MAP (
      rst    => RST,
      wr_clk => CLK40,
      rd_clk => CLK80,
      din    => sRScnt_TRGword_FIFO_IN,
      wr_en  => sRScnt_TRGword_WE,
      rd_en  => RScnt_TRGword_FIFO_RDREQ,
      dout   => RScnt_TRGword_FIFO_OUT,
      full   => sRScnt_TRGword_FULL,
      empty  => sRScnt_TRGword_FIFO_EMPTY
      );
		
Status_Counters_TA_inst : Status_Counters_TA
	PORT MAP(
		CLK40							=> CLK40,							
		--                      
		RS_CTR     					=> sRS_CTR,     					 -- RHICstrobe counter
		EVT_TRG_TCD					=> sEVT_TRG,					
		TRIGGER_MODE 				=> sTRIGGER_MODE(0), 				-- ONLY USING ONE OF THE 8 TRIGGER MODES (CHANNEL 0)
		ACQUIRE 						=> sACQUIRE, 						
		--Registers             
		Status_Counters_RST_REG => Status_Counters_RST_REG, 
		TCD_Level0_RCVD_REG		=> TCD_Level0_RCVD_REG,			
		RHIC_STROBE_LSB_REG 		=> RHIC_STROBE_LSB_REG, 		
		RHIC_STROBE_MSB_REG 		=> RHIC_STROBE_MSB_REG, 		
		N_HOLDS_REG 				=> N_HOLDS_REG, 				
		N_TESTS_REG 				=> N_TESTS_REG 				
		);

------------------------------------------------------------------------
--signals crossing clock domain from 80 to 40 MHz
------------------------------------------------------------------------

PROCESS (CLK80) IS
BEGIN
	IF rising_edge(CLK80) THEN
		sEVT_TRG_TCD_Buff <= sEVT_TRG_TCD;
		sMASTER_RST_TCD_Buff <= sMASTER_RST_TCD;
		sWORKING_TCD_Buff <= sWORKING_TCD;
	END IF;
END PROCESS;

--SIGNALS from 80 MHz to 40 MHz clock domain
sEVT_TRG <= sEVT_TRG_TCD OR sEVT_TRG_TCD_Buff;
sMASTER_RST <= sMASTER_RST_TCD OR sMASTER_RST_TCD_Buff;
sWORKING <= sWORKING_TCD OR sWORKING_TCD_Buff;

----------------------------------------------------------------------------
--RScnt_TRGword_FIFO_EMPTY flag, proper implementation to be not empty only 
--after we have written the 3 values on it
----------------------------------------------------------------------------

sRScnt_TRGword_FIFO_EMPTY_PROCESS : PROCESS (CLK80) IS
BEGIN
	IF rising_edge(CLK80) THEN
		CASE sFE_State IS
			WHEN ST_EMPTY =>
				RScnt_TRGword_FIFO_EMPTY <= '1';
				IF sRScnt_TRGword_FIFO_EMPTY = '0' and sACQUIRE = '1' THEN
					sFE_State <= ST_NOT_EMPTY;
				END IF;
			WHEN ST_NOT_EMPTY =>
				RScnt_TRGword_FIFO_EMPTY <= '0';
				IF sRScnt_TRGword_FIFO_EMPTY = '1' THEN
					sFE_State <= ST_EMPTY;
				END IF;
			WHEN OTHERS =>
				sFE_State <= ST_EMPTY;
		END CASE;
	END IF;
END PROCESS;

TRIGGER_MODE <= sTRIGGER_MODE;
ACQUIRE <= sACQUIRE;


END Trigger_Admin_arch;

