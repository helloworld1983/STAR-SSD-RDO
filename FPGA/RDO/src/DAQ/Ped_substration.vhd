----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    16:21:28 10/07/2013 
-- Design Name: 
-- Module Name:    Ped_substration - Ped_substration_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: This module is intended to add the offset, substract the pedestal memory value off, suppress all values below or avobe threshold,
--					 associate each reading with a strip number and then prepare the memory data (36 bits) and an write enable signal
--
-- 				 The imputs must be sincronized to properly operate the module. The pedestal memory has to be sincronized with the ADC value comming from
--	             the ongoing reading and the stripAddress so at the end each strip gets substrated its equivalent memory and properly labled with the strip number
--
--					 ZST_Polarity		: IN STD_LOGIC; --Zero suppersion threshold polarity 0=allow values less than (Negative pulses) 1=allow values over than (Positive pulses)
--						 
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 16:21:28 10/07/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Ped_substration IS
PORT (
		CLK80					: IN STD_LOGIC;
		DataValid			: IN STD_LOGIC;
		--OFFSET
		ADC_offset		 	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		--Zero suppresion threshold 
		Zero_supr_trsh 	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		ZST_Polarity		: IN STD_LOGIC; --Zero suppersion threshold polarity 0=allow values less than (Negative pulses) 1=allow values over than (Positive pulses)
		--ADC data and (strip + hybrid) address 
		LC2RDO_1Hybrid		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		StripAddress 		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		--Pedestal memory data
		PED_MEM_DATA_OUT 	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		-- Output to demux		
		PAYLOAD_MEM_IN		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
		PAYLOAD_MEM_WE		: OUT STD_LOGIC;
		--TEST CONNECTOR
		TC						: OUT STD_LOGIC_VECTOR(36 DOWNTO 0)	
		);
END Ped_substration;

ARCHITECTURE Ped_substration_arch OF Ped_substration IS

SIGNAL sCnt 				: INTEGER := 0;
SIGNAL sDATA_MEM			: STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
SIGNAL sStripAddress  	: STD_LOGIC_VECTOR (13 DOWNTO 0) := (OTHERS => '0');
SIGNAL sPAYLOAD_MEM_WE	: STD_LOGIC := '0';


BEGIN

PROCESS (CLK80) IS

VARIABLE sDATA_PED_SUBST 	: STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');

BEGIN
	IF RISING_EDGE(CLK80) THEN

		sStripAddress <= StripAddress;
		
		--sDATA_PED_SUBST := STD_LOGIC_VECTOR(UNSIGNED(LC2RDO_1Hybrid) + UNSIGNED(ADC_offset) - UNSIGNED(PED_MEM_DATA_OUT));   
		sDATA_PED_SUBST := STD_LOGIC_VECTOR(UNSIGNED(LC2RDO_1Hybrid) - UNSIGNED(PED_MEM_DATA_OUT));   
		sDATA_MEM <= STD_LOGIC_VECTOR(UNSIGNED(LC2RDO_1Hybrid) - UNSIGNED(PED_MEM_DATA_OUT));			 
		
		CASE sCnt IS
		
			WHEN 0 =>
				IF DataValid = '1' THEN 
					sCnt <= sCnt + 1;
					IF ZST_Polarity = '1' THEN								-- POSITIVE pulse
						IF sDATA_PED_SUBST > Zero_supr_trsh AND PED_MEM_DATA_OUT /= "1111111111" THEN 
							sPAYLOAD_MEM_WE <= '1';
						ELSE 
							sPAYLOAD_MEM_WE <= '0';
						END IF;
					ELSE															-- NEGATIVE pulse
						IF sDATA_PED_SUBST < Zero_supr_trsh AND PED_MEM_DATA_OUT /= "1111111111" THEN 
							sPAYLOAD_MEM_WE <= '1';
						ELSE 
							sPAYLOAD_MEM_WE <= '0';
						END IF;
					END IF;
				ELSE 
					sPAYLOAD_MEM_WE <= '0';	
				END IF;			
			WHEN 15 =>
				sCnt <= 0;
			
				IF ZST_Polarity = '1' THEN								-- POSITIVE pulse
					IF sDATA_PED_SUBST > Zero_supr_trsh AND PED_MEM_DATA_OUT /= "1111111111" THEN 
						sPAYLOAD_MEM_WE <= '1';
					ELSE 
						sPAYLOAD_MEM_WE <= '0';
					END IF;
				ELSE															-- NEGATIVE pulse
					IF sDATA_PED_SUBST < Zero_supr_trsh AND PED_MEM_DATA_OUT /= "1111111111" THEN 
						sPAYLOAD_MEM_WE <= '1';
					ELSE 
						sPAYLOAD_MEM_WE <= '0';
					END IF;
				END IF;
				
			
			WHEN OTHERS =>
				sCnt <= sCnt + 1;
				
				IF ZST_Polarity = '1' THEN								-- POSITIVE pulse
					IF sDATA_PED_SUBST > Zero_supr_trsh AND PED_MEM_DATA_OUT /= "1111111111" THEN 
						sPAYLOAD_MEM_WE <= '1';
					ELSE 
						sPAYLOAD_MEM_WE <= '0';
					END IF;
				ELSE															-- NEGATIVE pulse
					IF sDATA_PED_SUBST < Zero_supr_trsh AND PED_MEM_DATA_OUT /= "1111111111" THEN 
						sPAYLOAD_MEM_WE <= '1';
					ELSE 
						sPAYLOAD_MEM_WE <= '0';
					END IF;
				END IF;
				
			
		END CASE;
		
	END IF;
	
END PROCESS; 

PAYLOAD_MEM_IN <= x"000" & sStripAddress & sDATA_MEM;  

TC (0) 				<= DataValid;
TC (1) 				<= ZST_Polarity;
TC (11 DOWNTO 2) 	<= LC2RDO_1Hybrid;
TC (25 DOWNTO 12) <= StripAddress;
TC (35 DOWNTO 26) <= PED_MEM_DATA_OUT;
TC (36) 				<= sPAYLOAD_MEM_WE;

PAYLOAD_MEM_WE <= sPAYLOAD_MEM_WE;
	
END Ped_substration_arch;

