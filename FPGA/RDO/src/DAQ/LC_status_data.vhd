----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    09:42:11 10/08/2013 
-- Design Name: 
-- Module Name:    LC_status_data - LC_status_data_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: This module puts the LC fiber link status information into 8 words of 36 bits each for the memory
-- and 8 words of 16 bits each plus and aditional 16 bit word with the status info and the aditional for hybrids power state
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 09:42:11 10/08/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY LC_status_data IS
PORT (
		CLK40                : IN  STD_LOGIC;
		RST                  : IN  STD_LOGIC;
		LC_ADDRESS  			: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		--LC output to RDO
		LC2RDO      			: IN STD_LOGIC_VECTOR (23 DOWNTO 0);	
		--LC_Status
		LC_STATUS				: OUT FIBER_ARRAY_TYPE_36;
		LC_STATUS_REG			: OUT FIBER_ARRAY_TYPE_16;
		LC_HYBRIDS_POWER_STATUS_REG : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
END LC_status_data;

ARCHITECTURE LC_status_data_arch OF LC_status_data IS



BEGIN

LC_STATUS_PROC: PROCESS(CLK40, RST) IS

VARIABLE sLC_STATUS				: FIBER_ARRAY_TYPE_36 := (OTHERS => (OTHERS => '0'));

	BEGIN 
		IF RST = '1' THEN                 -- asynchronous reset 
			sLC_STATUS := (OTHERS => x"000000000");
			LC_HYBRIDS_POWER_STATUS_REG <= (OTHERS => '0');
			LC_STATUS <= (OTHERS => (OTHERS => '0'));
			LC_STATUS_REG <= (OTHERS => (OTHERS => '0'));
		ELSIF (rising_edge(CLK40) and LC2RDO(21) = '0') THEN
			CASE LC2RDO (20 downto 18) IS 											-- saving info in the proper variable
				WHEN b"000"=> 
					sLC_STATUS(0) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN b"001"=> 
					sLC_STATUS(1) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN b"010"=> 
					sLC_STATUS(2) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN b"011"=> 
					sLC_STATUS(3) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN b"100"=> 
					sLC_STATUS(4) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN b"101"=> 
					sLC_STATUS(5) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN b"110"=> 
					sLC_STATUS(6) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
				WHEN OTHERS => 
					sLC_STATUS(7) := x"0" & '0' & LC_ADDRESS & x"0" & LC2RDO;
			END CASE;
			
		FOR i IN 0 TO 7 LOOP
			LC_STATUS_REG (i) <= sLC_STATUS (i) (15 DOWNTO 0); 					--asigning info to 8 16 bit registers 
		END LOOP;	
			
		LC_HYBRIDS_POWER_STATUS_REG <= sLC_STATUS(7)(17 DOWNTO 16) & sLC_STATUS(6)(17 DOWNTO 16) &		-- asigning info for a 16 bit register with the 
												 sLC_STATUS(5)(17 DOWNTO 16) & sLC_STATUS(4)(17 DOWNTO 16) &		-- state of the hybrids if enabled or not
												 sLC_STATUS(3)(17 DOWNTO 16) & sLC_STATUS(2)(17 DOWNTO 16) &
												 sLC_STATUS(1)(17 DOWNTO 16) & sLC_STATUS(0)(17 DOWNTO 16);
													 
		LC_STATUS <= sLC_STATUS;	--36 bit signals for the control module to put into memory when needed
			
		END IF;
		
		
	END PROCESS LC_STATUS_PROC;

	

END LC_status_data_arch;

