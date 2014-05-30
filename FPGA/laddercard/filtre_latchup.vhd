

			--filtre_latchup--

--  surcourant ignoré au rallumage pendant une periode tck (clock JTAG)
--                              car c'est un phenomene different d'un latchup. 
--                              Il ne doit pas provoquer la coupure des alims.


-- surcourant_n : proviennent des sorties des comparateurs de la carte C2D2.
--				 =1 : consommation normal
--               =0 : courant au dessus du seuil de latchup.
--
-- pilotage_n : commandent les transistors pour bloquer les alim des hybrides.
--				=1 : hybride alimenté.
--				=0 : coupure de l'alimentation.
--
-- tck : horloge presente lors d'un dialogue JTAG.
--
-- enable_latchup_n: signal interne pour autorise la prise en compte des surcourants
--					=1 : latchup detectable.
--					=0 : surcourant ignoré. (conçu pour le redemarrage des alim)
--
-- latchup_n : signal interne au FPGA pour la detection de latchup.
--				=1 : pas de latchup
--				=0 : latchup detecté
--              = surcourant_n si (enable_latchup_n=1) sinon reste a 1.
--
--
-- Cyril, 19 juillet 2002.

-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
--     v2.01  | C.Renard | Modification  | 21 aou 2009| replaced (16 downto 1) by (15 DOWNTO 0)
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;



ENTITY filtre_latchup IS
	PORT(
--			surcourant_n	: IN    STD_LOGIC_VECTOR (16 downto 1); -- 20090821 enleve
			surcourant_n	: IN    STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 modifie
--			pilotage_n		: IN    STD_LOGIC_VECTOR (16 downto 1); -- 20090821 enleve
			pilotage_n		: IN    STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 modifie
			tck				: IN    STD_LOGIC;
--			latchup_n		:   OUT STD_LOGIC_VECTOR (16 downto 1) -- 20090821 enleve
			latchup_n		:   OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 20090821 modifie
	);
END filtre_latchup;





ARCHITECTURE ignore_courant_de_demarrage OF filtre_latchup IS
signal
--		enable_latchup_n				:  STD_LOGIC_VECTOR (16 downto 1)	; -- 20090821 enleve
		enable_latchup_n		: STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 modifie
BEGIN 

process (tck)
begin
	IF(tck'EVENT AND tck='1')THEN
						enable_latchup_n <= pilotage_n;
	END IF;
		-- pilotage(=1): declenche l'allumage de l'hybride
        -- enable_latchup : autorise la prise en compte de la detection de latchup
        --                  qu'une periode de tck apres l'allumage.
        --                 NB: Si c'est pas suffisant pour ignorer le surcourant
		--                     de demarrage, alors il faudra mettre un retard de
		--               	   2 ou 3 periodes de tck.
end process;

--filtre :for i in 1 to 16 generate -- 20090821 enleve
filtre :for i in 0 to 15 generate -- 20090821 modifie
latchup_n(i) <= not(enable_latchup_n(i)) or surcourant_n(i);
end GENERATE filtre;

END ignore_courant_de_demarrage;							   
	

