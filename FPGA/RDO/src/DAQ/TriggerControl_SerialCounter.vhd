----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013
-- Create Date:    15:12:06 10/30/2013 
-- Design Name: 
-- Module Name:    TriggerControl_SerialCounter - TriggerControl_SerialCounter_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 15:12:06 10/30/2013    1.0    Luis Ardila    File created
-- 20:25		Feb/08/2014		1.1	Luis Ardila		increase sMinACQ_Time from 50 to 300 7.5 us
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY TriggerControl_SerialCounter IS
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
END TriggerControl_SerialCounter;

ARCHITECTURE TriggerControl_SerialCounter_arch OF TriggerControl_SerialCounter IS

	TYPE state_type IS (ST_IDLE, ST_FCD_TRG_RCVD, ST_TRG_RCVD, ST_DELAY, ST_TRG_HIGH);
	SIGNAL sState     : state_type;

	SIGNAL sTCD_EN_TRGMODES_Reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	
	SIGNAL sTCD_DELAY_Cnt		: INTEGER RANGE 0 TO 65535;
	SIGNAL sTC_Cnt 				: INTEGER;
	
	SIGNAL sTRIGGER_MODE			: TRIGGER_MODE_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
	CONSTANT sMinACQ_Time      : INTEGER := 300; --300 clock cycles = 7.5 us
	SIGNAL sRS_CTR     			: std_logic_vector (31 DOWNTO 0) := (OTHERS => '0');  
	SIGNAL sTRGWORD    			: std_logic_vector (19 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL sWR_SERIAL  			:  STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL sBUSY_COMBINED 		: STD_LOGIC := '0';
	SIGNAL sUSB_EVT_TRG 			: STD_LOGIC := '0';
	SIGNAL sForced_Triggers_Reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0'); 

BEGIN


	PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS CONFIG_STATES
      IF RST = '1' THEN                 				-- asynchronous global ST_RESET (active high)
			sWR_SERIAL <= (OTHERS => '0');
			sRS_CTR <= (OTHERS => '0');
			sTCD_DELAY_Cnt <= 0;
			sTC_Cnt <= 0;
			ACQUIRE <= '0';
			RScnt_TRGword_WE <= '0';
			sState <= ST_IDLE;
			sTCD_EN_TRGMODES_Reg <= (OTHERS => '0');
			RScnt_TRGword_FIFO <= (OTHERS => '0');
			sForced_Triggers_Reg <= (OTHERS => '0'); 
      ELSIF rising_edge(CLK40) THEN  					-- rising clock edge
         
         CASE sState IS
				
            WHEN ST_IDLE =>	
					sTCD_EN_TRGMODES_Reg <= TCD_EN_TRGMODES_Reg;
					sRS_CTR <= RS_CTR;
					sTRGWORD <= TRGWORD;
					sTCD_DELAY_Cnt <= to_integer(unsigned(TCD_DELAY_Reg)); -- save counter value
					sTC_Cnt <= 0;
					RScnt_TRGword_WE <= '0';
					ACQUIRE <= '0';
					sForced_Triggers_Reg <= Forced_Triggers_Reg;
					CASE sTCD_EN_TRGMODES_Reg (15 DOWNTO 8) IS 
						WHEN x"00" => 								-- USB_Trigger Only
							IF sUSB_EVT_TRG = '1' THEN 
								sState <= ST_FCD_TRG_RCVD;
								sWR_SERIAL <= STD_LOGIC_VECTOR(UNSIGNED(sWR_SERIAL) + 1); --updates the serial number of the writing procedure 
							END IF;
						WHEN OTHERS => 							--Any other combination is TCD trigger
							IF EVT_TRG = '1' AND WORKING = '1' THEN --and SiuEvt_RD_EN = '1' THEN --SiuEvt_RD_EN is a signal comming from the ddl link 0 means clear buffers and not included in run
								sState <= ST_TRG_RCVD;
								sWR_SERIAL <= STD_LOGIC_VECTOR(UNSIGNED(sWR_SERIAL) + 1); --updates the serial number of the writing procedure 
							END IF;
					END CASE;
					
				WHEN ST_FCD_TRG_RCVD => 
					sTC_Cnt <= sTC_Cnt + 1;
					RScnt_TRGword_WE <= '1';
					CASE sTC_Cnt IS 
						WHEN 0 =>
							RScnt_TRGword_FIFO <= x"000000" & sWR_SERIAL;
							FOR i IN 0 TO 7 LOOP												--Setting trigger modes
								IF sForced_Triggers_Reg(i+8) = '1' THEN
									CASE sTCD_EN_TRGMODES_Reg (7 DOWNTO 4) IS
										WHEN x"0" => 
											sTRIGGER_MODE(i) <= b"00"; --hold
										WHEN x"1" => 
											sTRIGGER_MODE(i) <= b"01"; --test+hold
										WHEN x"2" => 
											sTRIGGER_MODE(i) <= b"10";	--special test mode
										WHEN OTHERS => 
											sTRIGGER_MODE(i) <= b"11"; --no io port of hold test token but create header
									END CASE;
								ELSE
									CASE sTCD_EN_TRGMODES_Reg (3 DOWNTO 0) IS
										WHEN x"0" => 
											sTRIGGER_MODE(i) <= b"00"; --hold
										WHEN x"1" => 
											sTRIGGER_MODE(i) <= b"01"; --test+hold
										WHEN x"2" => 
											sTRIGGER_MODE(i) <= b"10";	--special test mode
										WHEN OTHERS => 
											sTRIGGER_MODE(i) <= b"11"; --no io port of hold test token but create header
									END CASE;
								END IF;
							END LOOP;
						WHEN 1 =>
							RScnt_TRGword_FIFO <= x"0111" & sTRGWORD; -- 0111 to identify a forced trigger and the sTRIGWORD that is 0000 when there is no TCD trigger
						WHEN OTHERS =>
							RScnt_TRGword_FIFO <= x"0" & sRS_CTR;
							sTC_Cnt <= 0;
							sState <= ST_TRG_HIGH;
					END CASE;
					
				WHEN ST_TRG_RCVD =>
					sTC_Cnt <= sTC_Cnt + 1;
					RScnt_TRGword_WE <= '1';
					CASE sTC_Cnt IS 
						WHEN 0 =>
							RScnt_TRGword_FIFO <= x"000000" & sWR_SERIAL;
							FOR i IN 0 TO 7 LOOP
								IF sTCD_EN_TRGMODES_Reg(i+8) = '1' THEN
									CASE sTCD_EN_TRGMODES_Reg (3 DOWNTO 0) IS
										WHEN x"0" => 
											sTRIGGER_MODE(i) <= b"00"; --hold
										WHEN x"1" => 
											sTRIGGER_MODE(i) <= b"01"; --test+hold
										WHEN OTHERS => 
											sTRIGGER_MODE(i) <= b"11"; --no io port of hold test token but create header
									END CASE;
								ELSE
									sTRIGGER_MODE(i) <= b"11"; --no io port of hold test token but create header
								END IF;
							END LOOP;
						WHEN 1 =>
							RScnt_TRGword_FIFO <= x"0000" & sTRGWORD;
						WHEN OTHERS =>
							RScnt_TRGword_FIFO <= x"0" & sRS_CTR;
							sTC_Cnt <= 0;
							sState <= ST_DELAY;
					END CASE;
				
				WHEN ST_DELAY =>
					RScnt_TRGword_WE <= '0';
					IF sTCD_DELAY_Cnt > 0 THEN 
						sState <= ST_DELAY;						-- still counting down
						sTCD_DELAY_Cnt <= sTCD_DELAY_Cnt - 1;
					ELSE
						sState 	<= ST_TRG_HIGH;				-- counter finished, go to hold
					END IF;
				
				WHEN ST_TRG_HIGH =>
					RScnt_TRGword_WE <= '0';
					ACQUIRE <= '1';
					IF sTC_Cnt < (sMinACQ_Time + 1) THEN
					sTC_Cnt <= sTC_Cnt + 1;
					END IF;
					IF (sTC_Cnt > sMinACQ_Time AND sBUSY_COMBINED = '0' AND sUSB_EVT_TRG = '0' AND EVT_TRG = '0') THEN
						sState <= ST_IDLE;
						sTC_Cnt <= 0;
					END IF;
					
				WHEN OTHERS =>
					sState <= ST_IDLE;
					
			END CASE;
		END IF;
	END PROCESS;
					
	WR_SERIAL <= sWR_SERIAL;
	TRIGGER_MODE <= sTRIGGER_MODE;
				
	sUSB_EVT_TRG <= Forced_Triggers_Reg(7) OR Forced_Triggers_Reg(6) OR Forced_Triggers_Reg(5) OR Forced_Triggers_Reg(4) OR 
						 Forced_Triggers_Reg(3) OR Forced_Triggers_Reg(2) OR Forced_Triggers_Reg(1) OR Forced_Triggers_Reg(0);
	
	sBUSY_COMBINED <= BUSY_8_FIBERS(7) OR BUSY_8_FIBERS(6) OR BUSY_8_FIBERS(5) OR BUSY_8_FIBERS(4) OR 
						   BUSY_8_FIBERS(3) OR BUSY_8_FIBERS(2) OR BUSY_8_FIBERS(1) OR BUSY_8_FIBERS(0) OR RScnt_TRGword_FULL;
	
	BUSY_COMBINED <= sBUSY_COMBINED;

END TriggerControl_SerialCounter_arch;

