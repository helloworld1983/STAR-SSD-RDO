----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    14:34:41 10/08/2013 
-- Design Name: 
-- Module Name:    TwoTimesEng - TwoTimesEng_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: This module takes care of the RAW data mode
-- every 8 clock cycles there is a change in the 16 hybrids ADC value and the data valid signal. 
-- Here I use a register with 32 positions to store the current and the last ADC value to be able
-- to pack 3 hybrids in one word for the memory
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 14:34:41 10/08/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY TwoTimesEng IS
PORT (
		CLK80          		: IN  STD_LOGIC;
		LC2RDO      			: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		LC2RDO_Hybrids			: IN HYBRIDS_ARRAY_TYPE;
		DataValid 				: IN STD_LOGIC;
		PAYLOAD_MEM_IN			: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
		PAYLOAD_MEM_WE			: OUT STD_LOGIC
		);
END TwoTimesEng;

ARCHITECTURE TwoTimesEng_arch OF TwoTimesEng IS


SIGNAL sOffsetOut_EXT			: HYBRIDS_ARRAY_TYPE_EXT := (OTHERS => (OTHERS => '0'));

SIGNAL sTTE_Selector				: STD_LOGIC := '0'; 

TYPE TTE_STATE_TYPE IS (ST_IDLE, ST_WRITE, ST_PRE_END, ST_END);
SIGNAL sTTE_STATE    : TTE_STATE_TYPE := ST_IDLE;

SIGNAL sTTE_Cnt 					: INTEGER := 0;
SIGNAL sST_WRITE_Cnt				: INTEGER := 0;
SIGNAL sNum0	 					: INTEGER := 0;
SIGNAL sNum1 						: INTEGER := 1;
SIGNAL sNum2 						: INTEGER := 2;
SIGNAL sWt_Cnt						: INTEGER RANGE 0 to 7 := 0;
SIGNAL sDataValid 				: STD_LOGIC := '0'; 
SIGNAL sEvt_flag 					: STD_LOGIC := '0';

BEGIN
Two_Times_Engine : Process (CLK80) IS
BEGIN

	IF rising_edge(CLK80) THEN
		sDataValid <= DataValid;
		CASE sTTE_STATE IS
			WHEN ST_IDLE =>
				IF sDataValid = '1' and DataValid = '0' THEN --waits for falling edge of datavalid
					IF sTTE_Selector = '0' THEN  -- internal selector to create the double time engine
						FOR i IN 0 TO 15 LOOP
							sOffsetOut_EXT(i)<= LC2RDO_Hybrids(i); --save input to lower part of the 32 spaces register
						END LOOP;
						sTTE_Selector <= '1';
					ELSE
						FOR i IN 0 TO 15 LOOP
							sOffsetOut_EXT(i+16) <= LC2RDO_Hybrids(i);  --save input to he upper part of the 32 spaces register
						END LOOP;
						sTTE_Selector <= '0';
					END IF;
					
					IF sTTE_Cnt = 2 THEN    --counter used to know if last data needs an extra write enable
						sTTE_Cnt <= 0;
					ELSE
						sTTE_Cnt <= sTTE_Cnt + 1; --increment counter
					END IF;
					sEvt_flag <= '1';
					sTTE_STATE <= ST_WRITE;
					sWt_Cnt <= 0;
				ELSIF LC2RDO(21) = '0' AND sEvt_flag = '1' AND sWt_Cnt > 4 THEN
					sTTE_STATE <= ST_PRE_END;					--extra write enable when data finishes and I still have ADCs from prev readings.
					sEvt_flag <= '0';
					sWt_Cnt <= 0;
				ELSIF sWt_Cnt < 5 AND LC2RDO(21) = '0' THEN
					sWt_Cnt <= sWt_Cnt + 1;
				ELSE
					sTTE_STATE <= ST_IDLE;
				END IF;
				
				
			
			WHEN ST_WRITE =>
				CASE sNum0 IS			-- cases to wrap the counter
					WHEN 29 =>
						sNum0 <= 0;
					WHEN 30 =>
						sNum0 <= 1;
					WHEN 31 =>
						sNum0 <= 2;
					WHEN OTHERS =>
						sNum0 <= sNum0 + 3;
				END CASE;
				
				CASE sNum1 IS			-- cases to wrap the counter
					WHEN 29 =>
						sNum1 <= 0;
					WHEN 30 =>
						sNum1 <= 1;
					WHEN 31 =>
						sNum1 <= 2;
					WHEN OTHERS =>
						sNum1 <= sNum1 + 3;
				END CASE;
				
				CASE sNum2 IS			-- cases to wrap the counter
					WHEN 29 =>
						sNum2 <= 0;
					WHEN 30 =>
						sNum2 <= 1;
					WHEN 31 =>
						sNum2 <= 2;
					WHEN OTHERS =>
						sNum2 <= sNum2 + 3;
				END CASE;
				
				
				sST_WRITE_Cnt <= sST_WRITE_Cnt + 1; --number of 36 bit words written to memory -goes from 0 to 4 or 5
				
				IF ((sTTE_Cnt = 1 OR sTTE_Cnt = 2) AND sST_WRITE_Cnt = 4) THEN	
					sTTE_STATE <= ST_IDLE;
					sST_WRITE_Cnt <= 0;
				ELSIF (sTTE_Cnt = 0 AND sST_WRITE_Cnt = 5) THEN
					sTTE_STATE <= ST_IDLE;
					sST_WRITE_Cnt <= 0;
				ELSE
					sTTE_STATE <= ST_WRITE;
				END IF;
			
			WHEN ST_PRE_END =>
				IF sTTE_Cnt = 1 OR sTTE_Cnt = 2 THEN 
					IF sTTE_Selector = '0' THEN
						FOR i IN 0 TO 15 LOOP
							sOffsetOut_EXT(i)<= (OTHERS => '0');		--clear this half prior to write the last data
						END LOOP;
					ELSE
						FOR i IN 0 TO 15 LOOP
							sOffsetOut_EXT(i+16) <= (OTHERS => '0'); --clear this half prior to write the last data
						END LOOP;
					END IF;
					sTTE_STATE <= ST_END;
				ELSE  --sTTE_Cnt = 0
					sTTE_STATE <= ST_IDLE;
					sTTE_Selector <= '0';
					sST_WRITE_Cnt <= 0;
					sTTE_Cnt <= 0;
					sNum0 <= 0;
					sNum1 <= 1;
					sNum2 <= 2;
				END IF;
			
			WHEN ST_END =>
				sTTE_STATE <= ST_IDLE;
				sTTE_Selector <= '0';	
				sST_WRITE_Cnt <= 0;
				sTTE_Cnt <= 0;
				sNum0 <= 0;
				sNum1 <= 1;
				sNum2 <= 2;
				
			WHEN OTHERS =>
				sTTE_STATE <= ST_IDLE;
		END CASE;
		
		IF (sTTE_STATE = ST_WRITE OR sTTE_STATE = ST_END) THEN		-- memory write enable
			PAYLOAD_MEM_WE <= '1';
		ELSE 
			PAYLOAD_MEM_WE <= '0';
		END IF;
		
		PAYLOAD_MEM_IN <= x"0" & b"00" & sOffsetOut_EXT (sNum2) & sOffsetOut_EXT (sNum1) & sOffsetOut_EXT (sNum0);	-- memory data
	
	END IF;
	

END PROCESS Two_Times_Engine;

END TwoTimesEng_arch;

