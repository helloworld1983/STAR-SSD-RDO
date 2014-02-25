----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    13:22:23 10/04/2013 
-- Design Name: 
-- Module Name:    LC2RDODataSorter - LC2RDODataSorter_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: takes the 24 bits of the fiber link from LC to RDO and checks for pattern in bit 20, then sincronizes with the first pattern saw. 
--              every 8 clock cycles there is the value of one strip of each of the 16 hybrids. 
-- 				 every 8 clock cycles the output with the data descrambled is updated with a flag that says that the data is valid.
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 13:22:23 10/04/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY LC2RDODataSorter IS
PORT (
		CLK40				: IN STD_LOGIC;
		LC2RDO      	: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		LC2RDO_Hybrids : OUT HYBRIDS_ARRAY_TYPE;
		Strip_Cnt		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0); 
		DataValid 		: OUT STD_LOGIC
		);
				
END LC2RDODataSorter;

ARCHITECTURE LC2RDODataSorter_arch OF LC2RDODataSorter IS

COMPONENT Descrambler IS
PORT (
		LC2RDO  			: IN FIBER_ARRAY_TYPE;
		LC2RDO_Hybrids : OUT HYBRIDS_ARRAY_TYPE
		);
END COMPONENT Descrambler;


SIGNAL sLC2RDO : FIBER_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
SIGNAL sLC2RDO_Hybrids : HYBRIDS_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
SIGNAL sCnt : integer := 0;
SIGNAL sStrip_Cnt : STD_LOGIC_VECTOR (9 DOWNTO 0) := "1111111111";


BEGIN

Descrambler_inst : Descrambler 
PORT MAP(
	LC2RDO   			=> sLC2RDO,
	LC2RDO_Hybrids		=> sLC2RDO_Hybrids
	);

	PROCESS (CLK40) IS
	--VARIABLE TO BE REMOVED ONCE LC VHDL CODE UPDATES
	VARIABLE sFirstADC_OUT : STD_LOGIC := '0';
	BEGIN
	
		IF rising_edge(CLK40)THEN
			
				-- Shifting 8 words
				sLC2RDO(7) <= LC2RDO;
				FOR i IN 1 TO 7 LOOP 
					sLC2RDO(i-1) <= sLC2RDO(i);
				END LOOP;
				-- increment counter
				
			IF sLC2RDO(0)(21) = '1' OR sLC2RDO(7)(21) = '1' THEN --Checks for ADC data mode in Fiber link
				sCnt <= sCnt + 1;			
				-- check for pattern in Analog data mode bit 20 is 1-0-0-0-1-0-0-0
				IF (sLC2RDO(0)(20) = '1' and sLC2RDO(1)(20) = '0' and sLC2RDO(2)(20) = '0' and sLC2RDO(3)(20) = '0' and
					 sLC2RDO(4)(20) = '1' and sLC2RDO(5)(20) = '0' and sLC2RDO(6)(20) = '0' and sLC2RDO(7)(20) = '0' and sLC2RDO(7)(21) = '1' and sCnt > 5) THEN 
					sFirstADC_OUT := '1'; --first adc reading not transmited.
					sCnt <= 0;
					LC2RDO_Hybrids <= sLC2RDO_Hybrids;  --update unscrambled values to output
					IF sFirstADC_OUT = '1' THEN				-- IF TO BE REMOVED ONCE THE LC VHDL CODE IS UPDATED TO NOT TRANSMIT UNDESIRED ADC DATA
						
						DataValid <= '1';							--flag that data is valid only in first clock cycle of 8
						sStrip_Cnt <= std_logic_vector(unsigned(sStrip_Cnt) + 1);  --each data is updated with its corresponding strip number
					END IF;
				ELSE 
					DataValid <= '0';
				END IF;
			
			ELSE
			LC2RDO_Hybrids <= (OTHERS => (OTHERS => '0'));
			sCnt <= 0;
			sStrip_Cnt <= "1111111111";
			DataValid <= '0';
			-- SIGNAL TO BE EITHER REMOVED OR ASSERTED TO '1' IN THIS SECTION (REMEMBER TO REMOVE THE IF IN LINE 82
			sFirstADC_OUT := '0';    -- Change this to '1'if the Code in the LC is updated to not transmit the reading before the real strip 0
		
			END IF;
		END IF; 
	
		
	END PROCESS;
	
	Strip_Cnt <= sStrip_Cnt;

END LC2RDODataSorter_arch;