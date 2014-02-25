----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    14:51:14 06/27/2013 
-- Design Name: 
-- Module Name:    LC_Trigger_Handler - LC_Trigger_Handler_Arch 
-- Project Name: 	 STAR HFT SSD
-- Target Devices: XILINX Virtex 6 (XC6VLX240T-FF1759)
-- Tool versions:  ISE 13.4
-- Description: This module receive a signal call acquire to iniciate the state machine to send out the proper 
-- sequence of test, hold and token to the ladder card
-- acquire must remain high for the entire time when the LC is acquiring the data, otherwise the LC will go to abort
-- tigger mode is to select wich mode of operations we are
-- mode 0 = normal operation = hold + token
-- mode 1 = test mode 1 = test pulse + hold + token
-- mode 2 = test mode 2 = hold + token + test + no test
-- mode 3 = test mode 3 = no hold, no token, no test, just the header in the pipe line, the LC doesnt see the reading request
--
-- Dependencies: 
--
-- Revision: 
-- Date              Version         Author          Description
-- 06/27/2013        1.0             Luis Ardila     File Created
-- 10/09/2013			1.1				 Luis Ardila	  Add Busy line to indicate that we are not in IDLE state
-- 10/28/2013			1.2				 Luis Ardila	  add acquire port comming from the TCD or USB trigger 
--  																  add mode 3 where nothing goes to LC but busy line is asserted
-- Additional Comments: 
--
---------------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 

Use IEEE.NUMERIC_STD.ALL; 

--library UNISIM;
--use UNISIM.VComponents.all;

entity LC_Trigger_Handler is
	PORT (
		CLK40       		: IN  STD_LOGIC;
      RST         		: IN  STD_LOGIC;
      -- command interface
		ACQUIRE				: IN  STD_LOGIC;  --acquire signal coming from TCD or USB triggers this signal must remain high during the entire transmision or the LC will abort
		TRIGGER_MODE		: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		TEST2HOLD_DELAY	: IN  STD_LOGIC_VECTOR(7 downto 0);
      -- TO LC
		LC_MODE				: OUT STD_LOGIC;
      LC_HOLD        	: OUT STD_LOGIC;
      LC_TEST        	: OUT STD_LOGIC;
      LC_TOKEN       	: OUT STD_LOGIC;
		--Busy line
		LC_Trigger_Busy	: OUT STD_LOGIC;
		--Test connector
		TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
			
end LC_Trigger_Handler;

architecture LC_Trigger_Handler_Arch of LC_Trigger_Handler is

	TYPE state_type IS (ST_IDLE, ST_TEST, ST_HOLD, ST_TOKEN, ST_N_TOKEN, ST_N_TEST);
	
	SIGNAL sState     			: state_type;
	SIGNAL sCurr_mode 			: STD_LOGIC_VECTOR (1 downto 0) := b"00";
	
	CONSTANT WT_BEFORE_TEST		: INTEGER := 3600;				--45 us			--time for the second TEST Mode to see the LC_TEST pulse with the LC ADCs
	CONSTANT WT_TIME_TEST		: INTEGER := 400;					--5  us 			--time for the second TEST Mode to see the LC_TEST pulse with the LC ADCs
	
	SIGNAL sCnt						: INTEGER RANGE 0 TO WT_BEFORE_TEST;
	
 
BEGIN

	PROCESS (RST, CLK40)
	BEGIN 

		IF RST = '1' THEN                 -- asynchronous reset 
			LC_MODE		<= '0';
			LC_HOLD     <= '0';
			LC_TEST     <= '0';
			LC_TOKEN    <= '0';
			sState      <= ST_IDLE;
					
		ELSIF rising_edge(CLK40) THEN  
			CASE sState IS
					
					WHEN ST_IDLE =>
						LC_MODE		<= '0';
						LC_HOLD     <= '0';
						LC_TEST     <= '0';
						LC_TOKEN    <= '0';
						sCnt <= 0;
						IF ACQUIRE = '1' THEN					-- trigger command has been issued, the sequence starts 
							sCurr_mode <= TRIGGER_MODE;					-- current mode of operation is saved in a signal for the rest of the process
							IF TRIGGER_MODE = b"01" then 			-- mode 1 indicates Test pulses
								sState 	<= ST_TEST;
								sCnt <= to_integer(unsigned(TEST2HOLD_DELAY)); -- save counter value
							ElSIF TRIGGER_MODE = b"10" then			-- mode 2 indicates special mode yet not implemented in LC
								LC_MODE <= '1';					-- mode sigal goes high			
								sState <= ST_HOLD;
							ELSIF TRIGGER_MODE = b"11" then
								sState <= ST_N_TOKEN;		--mode 3 NO TEST, HOLD OR TOKEN TO Ladder card but the pipe will generate the HEADER and END MARKER with a flag
							ELSE
								sState <= ST_HOLD;			-- mode 0 or 3 is normal operation mode
							END IF;
							
						ELSE
							sState <= ST_IDLE;
							sCnt <= 0;							
						END IF;
						
					WHEN ST_TEST =>
						LC_TEST        <= '1';					--test signal goes high
						
						IF ACQUIRE = '1' THEN
							IF sCurr_mode = b"01" then 			-- mode 1
								
								IF sCnt > 1 THEN 
									sState <= ST_TEST;				-- still counting down
									sCnt <= sCnt - 1;					-- counter
								ELSE
									sState 	<= ST_HOLD;				-- counter finished, go to hold
								END IF;
								
							ELSIF sCurr_mode = b"10" then			-- mode 2 coming from no token state
							
								
								IF sCnt > 1 THEN 
									sState <= ST_TEST;				-- still counting down
									sCnt <= sCnt - 1;							-- count
								ELSE 
									sState <= ST_N_TEST;				-- go to no test state 
								END IF;
								
							END IF;
						ELSE
							sState <= ST_IDLE;
							sCnt <= 0;
						END IF;	
						
					WHEN ST_HOLD =>
						LC_HOLD        <= '1';				-- hold goes high
						
						IF ACQUIRE = '1' THEN				
							sState 	<= ST_TOKEN;				
						ELSE
							sState <= ST_IDLE;
							sCnt <= 0;
						END IF;
						
					WHEN ST_TOKEN =>
						LC_TOKEN       <= '1';				-- token goes high
						
						IF ACQUIRE = '1' THEN
							sState 	<= ST_N_TOKEN;
							sCnt <= WT_BEFORE_TEST; 			-- constant 
						ELSE
							sState <= ST_IDLE;
							sCnt <= 0;
						END IF;
						
					WHEN ST_N_TOKEN =>
						LC_TOKEN       <= '0';
						
						IF ACQUIRE = '1' THEN 
							IF sCurr_mode = b"10" THEN			-- mode 2
								
								IF sCnt > 1 THEN
									sState <= ST_N_TOKEN;
									sCnt <= sCnt - 1; 				-- count
								ELSE
									sState <= ST_TEST;			-- go to test 
									sCnt <= WT_TIME_TEST;		-- load counter
								END IF;
								
							ELSE
								sState <= ST_N_TOKEN;			-- modes 0, 1, 3
							END IF;
						ELSE
							sState <= ST_IDLE;					-- end
							sCnt <= 0;
						END IF;
						
					WHEN ST_N_TEST =>
						LC_TEST <= '0';
						
						IF ACQUIRE = '1' THEN 
							sState <= ST_N_TEST;					--mode 2
						ELSE
							sState <= ST_IDLE;					-- end
							sCnt <= 0;
						END IF;
						
					WHEN OTHERS =>
						sState <= ST_IDLE;
						sCnt <= 0;
						
			END CASE;
			
--			IF sState = ST_IDLE THEN							-- busy
--				LC_Trigger_Busy <= '0';
--			ELSE
--				LC_Trigger_Busy <= '1';
--			END IF;
			
		END IF;
		
		

	END PROCESS;	
					
	LC_Trigger_Busy <= '0' WHEN sState = ST_IDLE ELSE '1';				
					

end LC_Trigger_Handler_Arch;

