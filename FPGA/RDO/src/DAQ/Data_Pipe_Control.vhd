----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    13:20:25 10/15/2013 
-- Design Name: 
-- Module Name:    Data_Pipe_Control - Data_Pipe_Control_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: This module controls the flow of the data pipe to write into memory the status and header as soon as the trigger 
-- command is received and sent to the LC, then it waits for the LC to start sending data and writes the wanted values into the memory
-- 
-- there are 3 flags defined to mark up the data if an error occured:
-- CONSTANT sNO_DATA 			: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0001"; --NO DATA coming from fiber in less than 5 us  
-- CONSTANT sOVERFLOW			: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0002"; --too many strips over threshold in compress mode CHANGE TO 4102
-- CONSTANT sEARLYEND			: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0003"; --one strip have passed that was not valid and strip count is less than 768 = fiber glitch
--
-- the flags gets updated in the second position after the start marker
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 13:20:25 10/15/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY Data_Pipe_Control IS
PORT (
		CLK80                : IN  STD_LOGIC;
		RST                  : IN  STD_LOGIC;
		-- Control flags
		LC_Trigger_Busy		: IN  STD_LOGIC;
		DataValid				: IN  STD_LOGIC;
		--LC Address Number
		LC_ADDRESS  			: IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		-- LC_STATUS
		LC_STATUS				: IN  FIBER_ARRAY_TYPE_36;
		-- Pipe data
		PAYLOAD_MEM_IN_TTE	: IN  STD_LOGIC_VECTOR (35 DOWNTO 0);
		PAYLOAD_MEM_WE_TTE	: IN  STD_LOGIC;
		PAYLOAD_MEM_IN_CPS	: IN  STD_LOGIC_VECTOR (35 DOWNTO 0);
		PAYLOAD_MEM_WE_CPS	: IN  STD_LOGIC;
		Strip_Cnt				: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		-- Configuration registers
		ADC_offset_IN 			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		Zero_supr_trsh_IN		: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		ADC_offset_OUT  		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		Zero_supr_trsh_OUT 	: OUT  STD_LOGIC_VECTOR (9 DOWNTO 0);
		-- Operation mode register
		Pipe_Selector			: IN  STD_LOGIC_VECTOR (3 DOWNTO 0);	-- x"0" to RAW and x"1" to COMPRESS
		-- Data Pipe state machine busy
		PIPE_ST_BUSY			: OUT STD_LOGIC;
		-- Memory interface
		PAYLOAD_MEM_WADDR 	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0);	
		PAYLOAD_MEM_IN			: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);  -- Payload Memory data IN
		PAYLOAD_MEM_WE 		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		PAYLOAD_MEM_RADDR		: IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
		PAYLOAD_MEM_OUT 		: IN 	STD_LOGIC_VECTOR (35 DOWNTO 0);
		WR_SERIAL 				: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		RD_SERIAL				: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		PAYLOAD_MEM_GT_ONE	: OUT STD_LOGIC;  -- Greater than one flag	
		--TEST CONNECTOR
		TC			 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		
		);
END Data_Pipe_Control;

ARCHITECTURE Data_Pipe_Control_arch OF Data_Pipe_Control IS

--CS
SIGNAL sCounting	: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0000"; --Counter
SIGNAL sAddress 	: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0000";

SIGNAL sPAYLOAD_MEM_WE 		: STD_LOGIC_VECTOR (0 DOWNTO 0) := "0";
SIGNAL sPAYLOAD_MEM_GT_ONE	: STD_LOGIC := '0';
SIGNAL sPIPE_ST_BUSY	: STD_LOGIC := '0';


TYPE PIPE_STATE_TYPE IS (ST_IDLE, ST_HEADER, ST_STATUS, ST_WT_DATA_READY, ST_DATA, ST_END, ST_END_MARKER, ST_UPDATE_HEADER, ST_CHECK_SPACE, ST_WT_BUSY_LOW);
SIGNAL sPIPE_STATE    	: PIPE_STATE_TYPE := ST_IDLE;

TYPE GT_ONE_STATE_TYPE IS (ST_ZERO, ST_ONE);
SIGNAL GT_ONE_STATE : GT_ONE_STATE_TYPE;

-- ST_IDLE
SIGNAL sPM_INFO_0			 	: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0'); --flags, lenght and format
SIGNAL sPM_INFO_1				: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0'); -- offset and zero supression threshold
SIGNAL sSTART_ADDRESS 		: STD_LOGIC_VECTOR (14 DOWNTO 0) := (OTHERS => '0');
SIGNAL sPipe_Selector 		: STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
SIGNAL sLC_STATUS				: FIBER_ARRAY_TYPE_36 := (OTHERS => (OTHERS => '0'));
SIGNAL sPAYLOAD_MEM_WADDR 	: STD_LOGIC_VECTOR (14 DOWNTO 0) := (OTHERS => '0');

-- ST_HEADER


SIGNAL sEND_ADDRESS 			: STD_LOGIC_VECTOR (14 DOWNTO 0) := (OTHERS => '0');

SIGNAL sPipe_Cnt 				: INTEGER := 0;

-- General
SIGNAL sPM_START_MARKER 	: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0'); --start marker
SIGNAL sPM_END_MARKER 		: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0'); --start marker
SIGNAL sFlags					: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0'); --start marker

SIGNAL sClock_Cnt				: INTEGER RANGE 0 to 16000 := 0;

--CONSTANTS
CONSTANT sMEMSIZE				: INTEGER := 32767; --Payload memory size used in calculation of available space
CONSTANT sMinSpace			: INTEGER := 4200; --minimun space in memory required to clear the busy line and be able to acept a new trigger
CONSTANT sNO_DATA 			: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0001"; --flag
CONSTANT sOVERFLOW			: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0002"; --flag
CONSTANT sEARLYEND			: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0003"; --flag
CONSTANT sWRONG_PIPE_SEL	: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0004"; --flag
CONSTANT sMinClockCycles   : INTEGER := 12287;
CONSTANT sWORD_LIMIT   		: INTEGER := 4105; --4095 data + 10 header -- if this value is reached then the sequence puts the end marker and uptates the lenght with flag x"0002"

BEGIN

PIPE_PROCESS : PROCESS (CLK80, RST) IS

VARIABLE sClock_Cnt_EN 		: STD_LOGIC := '0'; 

BEGIN
	IF RST = '1' THEN 
		sPIPE_STATE <= ST_IDLE;
		ADC_offset_OUT 		<= (OTHERS => '0');			-- OFFSET Value
		Zero_supr_trsh_OUT	<= (OTHERS => '0');			-- Threshold Value
		sPAYLOAD_MEM_WE <= "0";
		PAYLOAD_MEM_IN <= (OTHERS => '0');
		sFlags <= (OTHERS => '0');
		sPAYLOAD_MEM_GT_ONE <= '0';
		sClock_Cnt_EN := '0';
	ELSIF RISING_EDGE(CLK80) THEN 
		
			CASE sPIPE_STATE IS
			
				
				WHEN ST_IDLE =>
					sClock_Cnt_EN := '0';
					sPAYLOAD_MEM_WE <= "0";
					ADC_offset_OUT 		<= ADC_offset_IN;			-- OFFSET Value
					Zero_supr_trsh_OUT	<= Zero_supr_trsh_IN;		-- Threshold Value
					sPM_INFO_0 				<= x"00000000" & Pipe_Selector;
					sSTART_ADDRESS    	<= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1); 
					sPipe_Selector			<= Pipe_Selector;			-- Selects between RAW=0 or COMPRESS=1 mode
					sLC_STATUS 				<= LC_STATUS;
					sFlags 					<= x"0000";
					sPM_START_MARKER 		<= x"15354" & WR_SERIAL & '0' & LC_ADDRESS;    -- 1 (high nibble marker for Fiber data) + ascii(ST) + serial number 12 bits to check for greater than one + #f
					sPM_END_MARKER 		<= x"1454E440" & '0' & LC_ADDRESS;                -- 1 (high nibble marker for Fiber data) + ascii(END) + #f

					IF LC_Trigger_Busy = '1' THEN 
						sPIPE_STATE 		<= ST_HEADER;
						sPipe_Cnt 			<= 0;
					END IF;
					
				WHEN ST_HEADER => --writes the header information, we can add as many or as little words 
					sPipe_Cnt <= sPipe_Cnt + 1;
					sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1); --memory address increase
					sPAYLOAD_MEM_WE <= "1";
					CASE sPipe_Cnt IS 
						WHEN 0 =>
							PAYLOAD_MEM_IN <= sPM_START_MARKER;  --see end of file for more detail
						WHEN 1 =>
							PAYLOAD_MEM_IN <= sPM_INFO_0;
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_STATUS;
						WHEN OTHERS =>
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_STATUS;
					END CASE;
					
				WHEN ST_STATUS => -- writes the 8 words of the LC status to memory
					sPipe_Cnt <= sPipe_Cnt + 1;
					sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1); --memory address increase
					sPAYLOAD_MEM_WE <= "1";
					CASE sPipe_Cnt IS 
						WHEN 0 | 1 | 2 | 3 | 4 | 5 | 6 =>
							PAYLOAD_MEM_IN <= sLC_STATUS(sPipe_Cnt);
						WHEN 7 =>
							PAYLOAD_MEM_IN <= sLC_STATUS(sPipe_Cnt);
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_WT_DATA_READY;
						WHEN OTHERS =>
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_WT_DATA_READY;
					END CASE;
					
				WHEN ST_WT_DATA_READY =>	-- waits for the data from LC to be valid and starts the data writing engine.
					sPAYLOAD_MEM_WE <= "0";
					sPipe_Cnt <= sPipe_Cnt + 1;
					IF sPipe_Cnt > 800 THEN					-- If it takes 10 us for valid data to arrive
						sPipe_Cnt <= 0;
						sFlags <= sNO_DATA; -- NO DATA coming from fiber in less than 5 us
						sPIPE_STATE <= ST_END_MARKER;
					ELSE
						IF DataValid = '1' THEN			-- checking if data is valid
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_DATA;
						END IF;
					END IF;
					
					
				WHEN ST_DATA =>
					sClock_Cnt_EN := '1';  --enables the clock cycles counter to know if we can go back to IDLE
					sPipe_Cnt <= sPipe_Cnt + 1;
					IF sPipe_Selector = x"0" THEN	-- data pipe selector 0 for the RAW mode and 1 to the COMPRESS mode
						PAYLOAD_MEM_IN <= PAYLOAD_MEM_IN_TTE;
						IF TO_INTEGER(UNSIGNED(sPAYLOAD_MEM_WADDR) - UNSIGNED(sSTART_ADDRESS)) > sWORD_LIMIT THEN --too many strips over threshold in compress mode
							sPipe_Cnt <= 0;
							sFlags <= sOVERFLOW; --OVERFLOW FLAG 
							sPIPE_STATE <= ST_END_MARKER;
							sPAYLOAD_MEM_WE <= "0";
						ELSE
							IF PAYLOAD_MEM_WE_TTE = '1' THEN 
								sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1);  --memory address increase
								sPAYLOAD_MEM_WE <= "1";
							END IF;
						END IF;
					ELSIF sPipe_Selector = x"1" THEN
						PAYLOAD_MEM_IN <= PAYLOAD_MEM_IN_CPS;
						IF TO_INTEGER(UNSIGNED(sPAYLOAD_MEM_WADDR) - UNSIGNED(sSTART_ADDRESS)) >= sWORD_LIMIT THEN --too many strips over threshold in compress mode
							sPipe_Cnt <= 0;
							sFlags <= sOVERFLOW; --OVERFLOW FLAG 
							sPIPE_STATE <= ST_END_MARKER;
							sPAYLOAD_MEM_WE <= "0";
						ELSE
							IF PAYLOAD_MEM_WE_CPS = '1' THEN
								sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1); --memory address increase
								sPAYLOAD_MEM_WE <= "1";
							END IF;
						END IF;
					ELSE 
						sFlags <= sWRONG_PIPE_SEL; --PIPE SELECTOR IS NOT 0 (RAW) OR 1 (COMPRESS) 
					END IF;
					
					IF DataValid = '1' THEN 
						sPipe_Cnt <= 0;
					ELSE
						IF (TO_INTEGER(UNSIGNED(Strip_Cnt)) >= 767 AND sPipe_Cnt > 18) THEN -- end of event
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_END_MARKER;
						ELSE
							IF sPipe_Cnt > 18 THEN	-- one strip have passed that was not valid and strip count is less than 768 = fiber glitch 
								sPipe_Cnt <= 0;
								sFlags <= sEARLYEND; --EARLY END FLAG
								sPIPE_STATE <= ST_END_MARKER;
							END IF;
						END IF;
					END IF;
					
				WHEN ST_END_MARKER =>					
					sPipe_Cnt <= sPipe_Cnt + 1;
					sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1); --memory address increase
					sPAYLOAD_MEM_WE <= "1";
					CASE sPipe_Cnt IS 
						WHEN 0 =>
							PAYLOAD_MEM_IN <= sPM_END_MARKER; 
							sEND_ADDRESS    <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_WADDR) + 1); --end adress storage
						WHEN 1 =>
							PAYLOAD_MEM_IN <= x"000000000"; --clear the next space to avoid previous data to cause mal functioning
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_UPDATE_HEADER;
						WHEN OTHERS =>
							sPipe_Cnt <= 0;
							sPIPE_STATE <= ST_UPDATE_HEADER;
					END CASE;
					
				WHEN ST_UPDATE_HEADER => --goes back to the second position and updates the number of words written into memory in this event
					sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sSTART_ADDRESS) + 1); -- updating this memory
					sPAYLOAD_MEM_WE <= "1";
					PAYLOAD_MEM_IN <= sFlags & '0' & STD_LOGIC_VECTOR(UNSIGNED(sEND_ADDRESS)-UNSIGNED(sSTART_ADDRESS)) & sPM_INFO_0 (3 DOWNTO 0);
					sPipe_Cnt <= 0;
					sPIPE_STATE <= ST_CHECK_SPACE;
			
				WHEN ST_CHECK_SPACE =>
					CASE sPipe_Cnt IS 
						WHEN 0 =>
							sPAYLOAD_MEM_WADDR <= STD_LOGIC_VECTOR(UNSIGNED(sEND_ADDRESS) + 1); -- ONE empty space between readings
							sPAYLOAD_MEM_WE <= "0";
							sPipe_Cnt <= 1;
						WHEN 1 =>
							IF	(((sMEMSIZE - TO_INTEGER(UNSIGNED(sEND_ADDRESS) - UNSIGNED(PAYLOAD_MEM_RADDR) + 1)) > sMinSpace) AND ((sClock_Cnt > sMinClockCycles) OR (sFlags = sNO_DATA))) THEN    --checking minimum space available
								sPipe_Cnt <= 0;
								sPIPE_STATE <= ST_WT_BUSY_LOW; 
							END IF;
						WHEN OTHERS =>
							sPipe_Cnt <= 1;
					END CASE;
				
				WHEN ST_WT_BUSY_LOW =>
					sClock_Cnt_EN := '0';
					IF LC_Trigger_Busy = '0' THEN 
						-- waiting for trigger busy line to go low
						sPIPE_STATE 		<= ST_IDLE;		
						sPipe_Cnt 			<= 0;				
					END IF;
					
				WHEN OTHERS =>
					sPAYLOAD_MEM_WE <= "0";
					sPIPE_STATE <= ST_IDLE;
			
			END CASE;
					
			------------------------------------------------------------------------------------------------
			-- Greater than one reading in the buffer signal, when this signal goes high a reading can be issue from the memory
			CASE GT_ONE_STATE IS
				WHEN ST_ZERO =>
					sPAYLOAD_MEM_GT_ONE <= '0';
					IF ((TO_INTEGER(UNSIGNED(WR_SERIAL) - UNSIGNED(RD_SERIAL)) > 1) OR 
						((TO_INTEGER(UNSIGNED(WR_SERIAL) - UNSIGNED(RD_SERIAL)) = 1) AND (UNSIGNED(sPAYLOAD_MEM_WADDR) > (UNSIGNED(PAYLOAD_MEM_RADDR) + 7)))) THEN
						GT_ONE_STATE <= ST_ONE; --when event starts serials are equal, if we got an only header event, then check for at least 7 in lenght
					END IF;
				WHEN ST_ONE => 
					sPAYLOAD_MEM_GT_ONE <= '1';
					IF (TO_INTEGER(UNSIGNED(WR_SERIAL) - UNSIGNED(RD_SERIAL)) = 0) OR (UNSIGNED(PAYLOAD_MEM_RADDR) >= UNSIGNED(sPAYLOAD_MEM_WADDR) - 7) THEN
						GT_ONE_STATE <= ST_ZERO; --go to 0 when reading address is reaching writing address, this indicates no more events in memory
					END IF;					
				WHEN OTHERS =>
					GT_ONE_STATE <= ST_ZERO;
			END CASE;
			
			IF sClock_Cnt_EN = '0' THEN				--counter to keep track of the 12288 clock cycles at 80 Mhz needed to let the LC finish the transmision
				sClock_Cnt <= 0;
			ELSIF sClock_Cnt_EN = '1' THEN			-- Enable signal is 0 when idle and starts counting on state ST_DATA
				IF sClock_Cnt < 14000 THEN
					sClock_Cnt <= sClock_Cnt + 1;
				END IF;
			END IF;
		
	END IF;
END PROCESS;	

 
sPIPE_ST_BUSY <= '0' WHEN ((sPIPE_STATE = ST_IDLE) OR (sPIPE_STATE = ST_WT_BUSY_LOW)) ELSE '1';
PIPE_ST_BUSY <= sPIPE_ST_BUSY;
PAYLOAD_MEM_WADDR <= sPAYLOAD_MEM_WADDR;

sCounting <= STD_LOGIC_VECTOR(TO_UNSIGNED(sClock_Cnt,16));

PAYLOAD_MEM_WE <= sPAYLOAD_MEM_WE;
PAYLOAD_MEM_GT_ONE <= sPAYLOAD_MEM_GT_ONE;

TC (0) <= LC_Trigger_Busy;
TC (1) <= DataValid;
TC (2) <= PAYLOAD_MEM_WE_TTE;
TC (3) <= PAYLOAD_MEM_WE_CPS;
TC (7 DOWNTO 4) <= Pipe_Selector;
TC (8) <= sPIPE_ST_BUSY;
TC (9) <= sPAYLOAD_MEM_WE (0);
TC (10) <= sPAYLOAD_MEM_GT_ONE;
TC (11) <= sCounting(0); --bit 0
TC (15 DOWNTO 12) <= sFlags (3 DOWNTO 0);
TC (31 DOWNTO 16) <= sAddress;

sAddress <= STD_LOGIC_VECTOR(TO_UNSIGNED(sMEMSIZE - TO_INTEGER(UNSIGNED(sEND_ADDRESS) - UNSIGNED(PAYLOAD_MEM_RADDR) + 1), 16));

END Data_Pipe_Control_arch;