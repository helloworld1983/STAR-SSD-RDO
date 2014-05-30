

			--memoire_latchup_general--

-- en cas de latchup_n genere un niveau 0 sur pilotage_n,coupe les alims +2v et -2v
--lorsque le slow_control lui ordonne; pilotage_n remonte a 1 et met les alims ON
-- le slow-control est remis a 0 automatiquement dans la cellule boundary_scan														--christine le 23/04/99
--christine le 23/04/99
										
-- modif Cyril 17/7/00: chgt d'ordre du port.
--                      rajout registre extinction.
--						suppression du signal global clear.

-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;

ENTITY memoire_latchup_general IS
	PORT(
		latchup_n	: IN    STD_LOGIC_VECTOR (15 downto 0);
		extinction	: IN    STD_LOGIC_VECTOR (15 downto 0);
		rallumage	: IN    STD_LOGIC_VECTOR (15 downto 0);
		pilotage_n	:   OUT STD_LOGIC_VECTOR (15 downto 0)
	);
END memoire_latchup_general;

ARCHITECTURE a OF memoire_latchup_general IS

COMPONENT memoire_latchup
	PORT(
		 latchup_n		: IN    STD_LOGIC;
		 extinction		: IN    STD_LOGIC;
		 rallumage		: IN    STD_LOGIC;
		 pilotage_n		:   OUT STD_LOGIC
	);
END component;

BEGIN 

gen :for i in 0 to 15 generate
	latch_n: memoire_latchup
		PORT MAP (
			latchup_n(i),
			extinction(i),
			rallumage(i),
			pilotage_n(i)
		);
end GENERATE gen;

END a;							   
	

