--pilotage : signal envoyé aux grilles des transistors MOS pour couper ou non les alims -2v,
--																    et 0v de chaque hybride.
--
-- pilotage = 0 : transistor bloqué  => alimentation coupée.
-- pilotage = 1 : transistor passant => hybride alimenté.
--
--
--
--
--
-- pilotage = 0     si (latchup=0) ou si (extinction=0). modif 28/8/00
--
-- pilotage = 1     si (rallumage=1). En fait ce sera si rallumage passe de 1 a 0
--                                    en sachant que rallumage est toujours de type pulse
--                                    par construction (largeur trstb ou tck).
--
-- latchup = sorties electroniques des comparateurs.
--         = entrées du FPGA.
--
--extinction ou rallumage peuvent etre positionné a l'initialisation (reset_bar du JTAG)
--                                                cf: cellule "dr_cell_set_reset_cd.vhd"
--
-- commentaire christine : au RESET JTAG ON NE CHANGE AUCUN "etat_des_alims"
-- au demarrage de la carte tts les alims sont coupees
-- modif Cyril 17/7/00: chgt d'ordre du port.
--                      rajout registre extinction.
--						suppression du signal global clear.
--                      réecriture de toute la cellule.

-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;


--------------------------------------------------------------------------------------------
ENTITY memoire_latchup IS								
	
PORT(
	 latchup_n		: IN    STD_LOGIC;
	 extinction		: IN    STD_LOGIC;
	 rallumage		: IN    STD_LOGIC;
	 pilotage_n		:   OUT STD_LOGIC
);
END memoire_latchup;
--------------------------------------------------------------------------------------------





ARCHITECTURE pilotage_alim OF memoire_latchup IS

SIGNAL LatchupouExtinction :STD_LOGIC;	

BEGIN

	LatchupouExtinction <= ( (not(latchup_n)) or (not(extinction)) );
							-- latchup_n  		= detection electronique de surcourant
							-- extinction 		= commande par registre JTAG.
    						--                    ( 0 pour vouloir éteindre une alim )
--------------------------------------------------------------------------------------------

	bascule: PROCESS (LatchupouExtinction,rallumage)
	BEGIN
	if (LatchupouExtinction ='1')								--RESET:
	   then 									-- test de la sortie du comparateur ou appel
		    pilotage_n<='0';					-- du slow-control .  --je coupe les alims --
	elsif  (rallumage'event and rallumage ='0')					--SET:
	   then	    								-- a l'appel du slow-control 
		    pilotage_n<='1';				    --                    --j'allume les alims --

	end if;
	END PROCESS bascule;
--------------------------------------------------------------------------------------------

-- le RESET est prioritaire :  
--                            1)  Ca permet la détection de latchup prioritaire devant tout.
--                            2)  Si le registre extinction au reset_bar prend "000000...000"
--                                alors cette valeur sera prise en compte devant le SET.
-- le SET est sur front :
--                            1)  Ca permet d'autoriser un RESET (en cas de latchup) 
--                                immédiatement après le SET sans effet d'oscillation.
--          				  2)  Front descendant: Le SET ou rallumage des alims s'effectue
--                                une fois la commande terminé. C'est le seul moyen pour 
--								  rallumer les alims au demarrage si l'on souhaite qu'un
--                                reset JTAG rallume les alims.
--
-- NB: le signal "latchup" est par construction temporaire. Mise à 0 par détection
--     électronique de surcourant, il sera remis à 1 car on coupe l'alim et donc le 
--     comparateur va forcement rebasculer sa sortie à 0.

END pilotage_alim;

