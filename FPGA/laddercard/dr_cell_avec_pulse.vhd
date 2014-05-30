---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
--  cette cellule est specifique pour l'ecriture et la remise a 0 du set de memoire latchup 
-- 																Christine le 27/01/00
--  elle va me permettre de construire le registre rallumage 
--
----------------------------------------------------------------
-- modif cyril lecture jtag sur front montant de clockDR (=tck)
--             sortie jtag sur front descendant   (3juillet2000)
-- modif christine: reset par passage de parametre (10/07/00)
-- modif Cyril : etat reset du pulse.(17/07/00)
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system


ENTITY dr_cell_avec_pulse IS 
	PORT (			   reset_bar,  reset_value : IN    STD_LOGIC;	
								      data_in  : IN    STD_LOGIC;
		  clockDR, shiftDR, updateDR, scan_in  : IN    STD_LOGIC;
                   					  scan_out :   OUT STD_LOGIC;
									  data_out :   OUT STD_LOGIC;
									 pulse_out :   OUT STD_LOGIC);
END dr_cell_avec_pulse;

ARCHITECTURE behavioral OF dr_cell_avec_pulse IS
  SIGNAL ff1, ff2, pulse_a_l_ecriture, pulse_au_reset : STD_LOGIC;
BEGIN

dff1 : PROCESS (clockDR)
  BEGIN
	IF (clockDR'event and (clockDR = '1')) THEN
   		IF shiftDR = '0' THEN
			ff1 <= data_in;  -- lecture registre
   		ELSE
			ff1 <= scan_in;  -- chargement TDin
   		END IF;			
 	END IF;
  END PROCESS dff1;

TDout: PROCESS (clockDR)
  BEGIN
    IF (clockDR'EVENT AND clockDR = '0') THEN
 		 scan_out <= ff1;						-- sortie TDout sur front descendant
    END IF;										
  END PROCESS TDout;							


  dff2 : PROCESS (reset_value, updateDR,reset_bar)
  BEGIN
    IF (reset_bar = '0') 					   THEN
		ff2 <= reset_value;
    ELSIF (updateDR'EVENT AND updateDR = '1' ) THEN
		ff2 <= ff1;
    END IF;
  END PROCESS dff2;
		

data_out  <=ff2;										-- = sortie registre extinction

pulse_a_l_ecriture <=    updateDR   and ff2;			-- pulse si ecriture d'un 1
pulse_au_reset <= (not (reset_bar)) and reset_value;	-- pulse si reset_value=1

pulse_out <= pulse_a_l_ecriture or pulse_au_reset ;		-- = sortie registre rallumage
														-- le pulse sera de la largeur
														-- du signal update ou de reset_bar

-- quand ff2 passera de 1 a 0 => pulse parasite: non génant car à ce moment extinction=0.

END behavioral;


