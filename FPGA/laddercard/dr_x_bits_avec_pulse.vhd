---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
-- dr_commande_alim_16_bits_cd: REGISTRE DE DATA DE 16 BITS         
-- 
-- ceci est un registre de donnees compose d'une succession de cellules 
-- :dr_cell_set_reset_cd  pulse pour permettre de rallumer les alims
--                        Le Slow-Control n'a pas besoin de creer ce pulse, c'est automatique.
--
-- data_out:  0 pour éteindre une alim, 1 pour provoquer un rallumage.
-- pulse_out: pulse a 1 pour rallumage. 
--            le pulse durera une largeur de updateDR ou de reset_bar
													--           christine le 26/01/00
-- ------------------------------------------------------------------
-- modif cyril : rajout data_in et shiftDR, modif de dr_cell_set  3/7/2000
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| remplace type BIT par type STD_LOGIC et taille de type GENERIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system

ENTITY dr_x_bits_avec_pulse IS
	GENERIC(taille : integer:=  16);
	PORT ( 			    reset_bar,  reset_value : IN    STD_LOGIC;
		    						   data_in  : IN    STD_LOGIC_VECTOR((taille-1) downto 0);
		  clockDR, shiftDR,  updateDR, scan_in  : IN    STD_LOGIC;
   									   scan_out :   OUT STD_LOGIC;
   			        				   data_out :   OUT STD_LOGIC_VECTOR((taille-1) downto 0);
   			        				  pulse_out :   OUT STD_LOGIC_VECTOR((taille-1) downto 0));
END dr_x_bits_avec_pulse;




ARCHITECTURE structural OF dr_x_bits_avec_pulse IS

  COMPONENT dr_cell_avec_pulse
	PORT (			   reset_bar,  reset_value : IN    STD_LOGIC;	
								      data_in  : IN    STD_LOGIC;
		  clockDR, shiftDR, updateDR, scan_in  : IN    STD_LOGIC;
                   					  scan_out :   OUT STD_LOGIC;
									  data_out :   OUT STD_LOGIC;
									 pulse_out :   OUT STD_LOGIC);
  END COMPONENT;


  SIGNAL temp_scan : STD_LOGIC_VECTOR (data_out'RANGE);

BEGIN
  a : FOR i IN data_out'LOW TO data_out'HIGH GENERATE
    -- b : IF (i = data_out'HIGH) GENERATE
    b : IF (i = (taille-1)) GENERATE
      c : dr_cell_avec_pulse
		 PORT MAP (
		 	reset_bar	=>	reset_bar,
			reset_value	=>	reset_value,
		 	data_in		=>	data_in(i),
			clockDR		=>	clockDR,
			shiftDR		=>	shiftDR,
			updateDR	=>	updateDR,
			scan_in		=>	scan_in,
			scan_out	=>	temp_scan(i),  
            data_out    =>	data_out(i),
            pulse_out   =>	pulse_out(i));
    END GENERATE;
    d : IF (i < (taille-1)) GENERATE
      e :  dr_cell_avec_pulse
		 PORT MAP (
		 	reset_bar	=>	reset_bar,
			reset_value	=>	reset_value,
		 	data_in		=>	data_in(i),
			clockDR		=>	clockDR,
			shiftDR		=>	shiftDR,
			updateDR	=>	updateDR,
			scan_in		=>	temp_scan(i+1),
			scan_out	=>	temp_scan(i),  
            data_out    =>	data_out(i),
            pulse_out   =>	pulse_out(i));
    END GENERATE;
  END GENERATE;

  scan_out <= temp_scan(0);

END structural;

