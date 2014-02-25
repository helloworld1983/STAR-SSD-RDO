----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    13:43:28 10/04/2013 
-- Design Name: 
-- Module Name:    Descrambler - Descrambler_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: takes the 8 words with 20 bits of data from the ladder card and  
--               sorts its values into 16 hybrids with 10 bit of data each
--	              please follow table 56 in the STAR-SSD-Upgrade-technical implementation 
--					  document.
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 13:43:28 10/04/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY Descrambler IS
PORT (
		LC2RDO  : IN FIBER_ARRAY_TYPE;
		LC2RDO_Hybrids  : OUT HYBRIDS_ARRAY_TYPE
		);
END Descrambler;

ARCHITECTURE Descrambler_arch OF Descrambler IS

BEGIN

	bit9 : FOR i IN 0 TO 15 GENERATE
		LC2RDO_Hybrids(i)(9) <= LC2RDO(0)(i);  	--Bit 9
	END GENERATE bit9;
	
	bit8_a : FOR i IN 16 TO 19 GENERATE
		LC2RDO_Hybrids(i-16)(8) <= LC2RDO(0)(i);	--Bit 8
	END GENERATE bit8_a;
	
	bit8_b : FOR i IN 0 TO 11 GENERATE
		LC2RDO_Hybrids(i+4)(8) <= LC2RDO(1)(i);   --Bit 8
	END GENERATE bit8_b;
	
	bit7_a : FOR i IN 12 TO 19 GENERATE
		LC2RDO_Hybrids(i-12)(7) <= LC2RDO(1)(i);  --Bit 7
	END GENERATE bit7_a;
	
	bit7_b : FOR i IN 0 TO 7 GENERATE
		LC2RDO_Hybrids(i+8)(7) <= LC2RDO(2)(i);   --Bit 7
	END GENERATE bit7_b;
	
	bit6_a : FOR i IN 8 TO 19 GENERATE
		LC2RDO_Hybrids(i-8)(6) <= LC2RDO(2)(i);   --Bit 6
	END GENERATE bit6_a;
	
	bit6_b : FOR i IN 0 TO 3 GENERATE
		LC2RDO_Hybrids(i+12)(6) <= LC2RDO(3)(i);  --Bit 6
	END GENERATE bit6_b;
	
	bit5 : FOR i IN 4 TO 19 GENERATE
		LC2RDO_Hybrids(i-4)(5) <= LC2RDO(3)(i);   --Bit 5
	END GENERATE bit5;
	
	bit4 : FOR i IN 0 TO 15 GENERATE
		LC2RDO_Hybrids(i)(4) <= LC2RDO(4)(i);     --Bit 4
	END GENERATE bit4;
	
	bit3_a : FOR i IN 16 TO 19 GENERATE
		LC2RDO_Hybrids(i-16)(3) <= LC2RDO(4)(i);  --Bit 3
	END GENERATE bit3_a;
	
	bit3_b : FOR i IN 0 TO 11 GENERATE
		LC2RDO_Hybrids(i+4)(3) <= LC2RDO(5)(i);   --Bit 3
	END GENERATE bit3_b;
	
	bit2_a : FOR i IN 12 TO 19 GENERATE
		LC2RDO_Hybrids(i-12)(2) <= LC2RDO(5)(i);  --Bit 2
	END GENERATE bit2_a;
	
	bit2_b : FOR i IN 0 TO 7 GENERATE
		LC2RDO_Hybrids(i+8)(2) <= LC2RDO(6)(i);   --Bit 2
	END GENERATE bit2_b;
	
	bit1_a : FOR i IN 8 TO 19 GENERATE
		LC2RDO_Hybrids(i-8)(1) <= LC2RDO(6)(i);   --Bit 1
	END GENERATE bit1_a;
	
	bit1_b : FOR i IN 0 TO 3 GENERATE
		LC2RDO_Hybrids(i+12)(1) <= LC2RDO(7)(i);  --Bit 1
	END GENERATE bit1_b;
	
	bit0 : FOR i IN 4 TO 19 GENERATE
		LC2RDO_Hybrids(i-4)(0) <= LC2RDO(7)(i);   --Bit 0
	END GENERATE bit0;

END Descrambler_arch;

