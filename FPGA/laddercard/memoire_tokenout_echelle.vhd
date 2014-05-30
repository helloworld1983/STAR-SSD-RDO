---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

-----------------------------------------------------------------------------------------------
--                                MEMOIRE DU TOKENOUT_ECHELLE
--
--  mémorise dans une bascule RS le tokenOut de l'échelle.
--  remise a zero automatique par tokenIn_echelle ou par JTAG
------------------------------------------------------------------christine le 4 fevrier 2000
-- extension a 16 memoires (une par hybride)                      Cyril le 21 nov 2001

-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;



ENTITY memoire_tokenOut_echelle IS
	PORT (
		tokenIn_echelle				: IN	STD_LOGIC;
		tokenout_echelle			: IN 	STD_LOGIC_VECTOR (15 downto 0);

		memoire_tokenout			:   OUT	STD_LOGIC_VECTOR (15 downto 0)
	);
END memoire_tokenOut_echelle;											  




ARCHITECTURE bascule_16_RS_asynchrone of memoire_tokenOut_echelle IS

BEGIN

--PROCESS (tokenIn_echelle, tokenout_echelle)	
--BEGIN
--pour_chaque_hybride: FOR i IN 0 to 15 LOOP
--	IF (tokenIn_echelle='1') then			memoire_tokenout(i)<='0';
--	ELSIF (tokenout_echelle(i) ='1') then	memoire_tokenout(i)<='1'; -- memorise le retour
--	END IF;
--END LOOP pour_chaque_hybride;
--END process;
	memoire_tokenout( 0) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 0) ='1'); -- memorise le retour
	memoire_tokenout( 1) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 1) ='1'); -- memorise le retour
	memoire_tokenout( 2) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 2) ='1'); -- memorise le retour
	memoire_tokenout( 3) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 3) ='1'); -- memorise le retour
	memoire_tokenout( 4) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 4) ='1'); -- memorise le retour
	memoire_tokenout( 5) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 5) ='1'); -- memorise le retour
	memoire_tokenout( 6) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 6) ='1'); -- memorise le retour
	memoire_tokenout( 7) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 7) ='1'); -- memorise le retour
	memoire_tokenout( 8) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 8) ='1'); -- memorise le retour
	memoire_tokenout( 9) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle( 9) ='1'); -- memorise le retour
	memoire_tokenout(10) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle(10) ='1'); -- memorise le retour
	memoire_tokenout(11) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle(11) ='1'); -- memorise le retour
	memoire_tokenout(12) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle(12) ='1'); -- memorise le retour
	memoire_tokenout(13) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle(13) ='1'); -- memorise le retour
	memoire_tokenout(14) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle(14) ='1'); -- memorise le retour
	memoire_tokenout(15) <= '0' WHEN (tokenIn_echelle='1') ELSE -- met a zero au depart
							'1' WHEN (tokenout_echelle(15) ='1'); -- memorise le retour
END bascule_16_RS_asynchrone;
