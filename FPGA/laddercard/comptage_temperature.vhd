---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++   Cyril et Romain le 13 fevrier 2002   +++      FPGA carte_connexion STAR      +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

--==========================================================================================
-- Fonction de comptage
-- 
-- Mesure le temps entre les fronts descendant de start et de stop
-- un signal enable permet de ne prendre en compte que le stop
-- se trouvant dans la plage a mesurer (approximativement 0 - 100°-C)
--
-- reset    __|----------------------------------------------------------------|___________________
-- signal	-----|______|---------|______|----------|______|----------|______|---------------------
-- enable	--------------|____________________|---------------------------------------------------
-- comptage	_____|----------------------------------------------------|____________________________
--
--==========================================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY comptage_temperature IS
	PORT
    (
		clk_degre    	: IN    STD_LOGIC;
		reset			: IN    STD_LOGIC;
		signal_temp		: IN    STD_LOGIC;
		enable			: IN    STD_LOGIC;
		valeur		  	:   OUT INTEGER RANGE 0 TO 3720
	);
END comptage_temperature;
														
ARCHITECTURE un_MAX6575H OF comptage_temperature IS 
SIGNAL comptage		         : STD_LOGIC;
SIGNAL compte, valeur_kelvin : INTEGER RANGE 0 TO 3720;  -- 273,0+99,0    (273°K=0°C)

BEGIN
detection:	PROCESS (reset,enable,signal_temp)   -- fabrication du signal comptage. comptage = 1 : Il faudra mesurer le temps
	BEGIN
		IF reset='0' THEN 
			comptage <= '0';
		ELSIF((signal_temp'EVENT AND signal_temp='0')) THEN -- declenchement sur passage a 0 du signal 1-wire
			IF (enable='1') THEN comptage <= not comptage; -- si le masque l'autorise, mise en/hors fonction du comptage
			END IF;
		END IF;
	END PROCESS detection;		

mesure:		PROCESS (comptage,clk_degre) -- process de la mesure
	BEGIN
		IF (clk_degre'EVENT AND clk_degre='1') THEN 
			IF comptage='0' THEN 
				compte 		  <= 0;
			ELSE
				compte 		  <= compte + 1;
				valeur_kelvin <= compte;
			END IF;
		END IF;
	END PROCESS mesure;

valeur <= valeur_kelvin;


END un_MAX6575H;
