----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    13:58:55 10/10/2013 
-- Design Name: 
-- Module Name:    Demux16Pos - Demux16Pos_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: Simply a 16 position demultiplexer, each clock cycle it chooses the next value 
-- when it gets to the first position also checks that datavalid is 1 before proceding
-- adds a clock cycle delay for the dataValid signal to be in sync with the output data
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 13:58:55 10/10/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;


ENTITY Demux16Pos IS
PORT (
		CLK80          		: IN  STD_LOGIC;
		LC2RDO_Hybrids			: IN HYBRIDS_ARRAY_TYPE;
		DataValid_In 			: IN STD_LOGIC;
		Strip_Cnt				: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		DataValid_Out			: OUT STD_LOGIC;
		StripAddress 			: OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
		LC2RDO_1Hybrid			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
END Demux16Pos;

ARCHITECTURE Demux16Pos_arch OF Demux16Pos IS

SIGNAL sCnt : INTEGER := 0;

BEGIN

PROCESS (CLK80) IS
BEGIN
	IF RISING_EDGE(CLK80) THEN
		
		CASE sCnt IS
			
			WHEN 0 => 
				IF DataValid_In = '1' THEN
					sCnt <= sCnt + 1;
				END IF;
			
			WHEN 15 =>
				sCnt <= 0;
			
			WHEN OTHERS =>
				sCnt <= sCnt + 1;
		
		END CASE;
		DataValid_Out <= DataValid_In;
		LC2RDO_1Hybrid <= LC2RDO_Hybrids(sCnt);
		StripAddress <= Strip_Cnt & STD_LOGIC_VECTOR(TO_UNSIGNED(sCnt,4));
	END IF;

END PROCESS;

END Demux16Pos_arch;

