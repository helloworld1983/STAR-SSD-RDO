-------                                 GESTION DES hybrides (BYPASS,memoire token , ...)                           -------------


--- a partir de tous les modules generer les bypass des tokenin en cas de latchup ou non
--- avertir le slow-control des latchup par les sigaux pilotages.
--- generer le codage des multiplexeurs pour permettre la lecture des donnees par l'ADC.


--modifs 16bits le 12/05/99			--christine le 23/04/99
--modifs le 31 mai1999(j'ai enleve des sorties tests)
--enlever le commande mux il n'est plus necessaire a cause des 16 voies sur la meme carte connexion
--integrer le nouvel encodeur  avec 7 fils d'adresse,le busy(latchup SRC)est integre dans cet encodeur
--christine le 4/06/99
-- en dehors d'un latchup ,nous pouvons souhaiter faire un bypass d'hybride 
--christine le 24/01/00
-- modif Cyril dec2001

-- modif Romain 29janv2002
-- rajout du registre de commande de 160 bits pour la commande des mux analogique

-- modif Cyril 19 juillet 2002: surcourant ignoré au rallumage pendant une periode tck (clock JTAG)
--                              car c'est un phenomene different d'un latchup. 
--                              Il ne doit pas provoquer la coupure des alims.

-- Version No:| Author   | Changes Made: | Mod. Date:
--     v4     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
--     v4     | C.Renard | Modification  | 29 jun 2009| 0 or 1 hybrid in the JTAG line
--     v4.01  | C.Renard | Modification  | 20 aou 2009| 0 or 1 hybrid in the JTAG line (tms and tck)
--     v4.02  | C.Renard | Modification  | 21 aou 2009| signaux_hybrides in place of bypass_general
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;
Use     IEEE.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;

ENTITY gestion_hybrides_v4 IS

	PORT (
		surcourant			:  IN STD_LOGIC_VECTOR (15 downto 0);
		latchup_memoire		: OUT STD_LOGIC;
		latchup_pulse		: OUT STD_LOGIC;

		pilotage			: OUT STD_LOGIC_VECTOR (15 downto 0);
		tck					:  IN STD_LOGIC;

		extinction			:  IN STD_LOGIC_VECTOR (15 downto 0);
		rallumage			:  IN STD_LOGIC_VECTOR (15 downto 0);
		bypass_hybride		:  IN STD_LOGIC_VECTOR (15 downto 0);

		tokenin_echelle		:  IN STD_LOGIC;
		tokenin				: OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090818 enleve -- 20090821 remis
		tokenout			:  IN STD_LOGIC_VECTOR (15 downto 0);
		tokenout_memoire	: OUT STD_LOGIC_VECTOR (15 downto 0);

		tdi_echelle			:  IN STD_LOGIC;
		tdi					: OUT STD_LOGIC_VECTOR (15 downto 0);
		tdo					:  IN STD_LOGIC_VECTOR (15 downto 0);
		tdo_echelle			: OUT STD_LOGIC;
		num_hybride_dans_jtag  : IN STD_LOGIC_VECTOR(3 downto 0); -- 20090629 ajoute
		jtag_avec_hybride      : IN STD_LOGIC; -- 20090629 ajoute
		ladder_fpga_sc_tms        : IN    STD_LOGIC; -- 20090820 ajoute
		sc_tck_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090820 ajoute
		sc_tms_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090820 ajoute

--		rclk				:  IN STD_LOGIC; -- 20090824 enleve
--		ck_mux				:  IN STD_LOGIC; -- 20090309 enleve

--		adresse_mux_readout			:OUT STD_LOGIC_vector (1 downto 0); -- 20090309 enleve
--		adresse_mux_reference		:OUT STD_LOGIC_vector (1 downto 0); -- 20090309 enleve
--		enable_mux_entreeADC_plus	:OUT STD_LOGIC_vector (4 downto 0); -- 20090309 enleve
--		enable_mux_entreeADC_moins	:OUT STD_LOGIC_vector (4 downto 0); -- 20090309 enleve
--		jtag_mux 					: IN STD_LOGIC_vector (159 downto 0); -- registre de c -- 20090309 enleveommande JTAG pour les mux analogiques
		tst_gestion_hybrides		:OUT STD_LOGIC_vector (15 downto 0)
	);


END gestion_hybrides_v4;

--======================================================================

ARCHITECTURE gestion_hybrides_v4_arch of gestion_hybrides_v4 IS
	SIGNAL 		latchup,
				latchup_memorise,
				tokenin_test
--			    tokenin_par_comptage	: STD_LOGIC_VECTOR (16 downto 1); -- 20090821 enleve
			    	: STD_LOGIC_VECTOR(15 downto 0); -- 20090821 modifie
--	SIGNAL		numero_du_connecteur	: STD_LOGIC_VECTOR (3 downto 0); -- 20090821 enleve
	SIGNAL		tokenout_hybrid			: STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 ajoute
	SIGNAL		hybride_dans_jtag		: STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 ajoute
	SIGNAL		tdi_suivant				: STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 ajoute

------------------------------------------------------------------------------------

	component filtre_latchup	
		PORT(
--			surcourant_n	: IN    STD_LOGIC_VECTOR (16 downto 1); -- 20090821 enleve
			surcourant_n	: IN    STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 modifie
--			pilotage_n		: IN    STD_LOGIC_VECTOR (16 downto 1); -- 20090821 enleve
			pilotage_n		: IN    STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090821 modifie
			tck				: IN    STD_LOGIC;
--			latchup_n		:   OUT STD_LOGIC_VECTOR (16 downto 1) -- 20090821 enleve
			latchup_n		:   OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 20090821 modifie
		);
		END component;

------------------------------------------------------------------------------------

	component memoire_latchup_general
		PORT(
			latchup_n	: IN    STD_LOGIC_VECTOR (15 downto 0);
			extinction	: IN    STD_LOGIC_VECTOR (15 downto 0);
			rallumage	: IN    STD_LOGIC_VECTOR (15 downto 0);
			pilotage_n	:   OUT STD_LOGIC_VECTOR (15 downto 0)
		);
	END component;

------------------------------------------------------------------------------------

--	component ou_pilotage -- 20090821 enleve
--		PORT ( -- 20090821 enleve
--			pilotage		: IN    STD_LOGIC_VECTOR (15 downto 0); -- 20090821 enleve
--			latchup_echelle	:   OUT STD_LOGIC -- 20090821 enleve
--		); -- 20090821 enleve
--	end component; -- 20090821 enleve

------------------------------------------------------------------------------------

--	component bypass_general -- 20090821 enleve
--		PORT( -- 20090821 enleve
--			bypass_hybride	: IN    STD_LOGIC_VECTOR(15 downto 0); -- 20090821 enleve
--			pilotage		: IN    STD_LOGIC_VECTOR(15 downto 0); -- 20090821 enleve
--			tdi_echelle		: IN    STD_LOGIC; -- 20090821 enleve
--			tdi				:   OUT STD_LOGIC_VECTOR(15 downto 0); -- 20090821 enleve
--			tdo				: IN    STD_LOGIC_VECTOR(15 downto 0); -- 20090821 enleve
--			tdo_echelle		:   OUT STD_LOGIC; -- 20090821 enleve
--			num_hybride_dans_jtag  : IN STD_LOGIC_VECTOR(3 downto 0); -- 20090629 ajoute -- 20090821 enleve
--			jtag_avec_hybride      : IN STD_LOGIC; -- 20090629 ajoute -- 20090821 enleve
--		ladder_fpga_sc_tck        : IN    STD_LOGIC; -- 20090820 ajoute -- 20090821 enleve
--		ladder_fpga_sc_tms        : IN    STD_LOGIC; -- 20090820 ajoute -- 20090821 enleve
--		sc_tck_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090820 ajoute -- 20090821 enleve
--		sc_tms_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090820 ajoute -- 20090821 enleve
--			tokenin_auto	: IN    STD_LOGIC_VECTOR(15 downto 0); -- 20090821 enleve
--			tokenin			:   OUT STD_LOGIC_VECTOR(15 downto 0) -- 20090821 enleve
--		); -- 20090821 enleve
--	end component; -- 20090821 enleve

component signaux_hybrides
	PORT (
			bypass_hyb			: IN    STD_LOGIC; -- from fpga slow-control
			pilotage_hyb		: IN    STD_LOGIC; -- from fpga slow-control
			tdo_precedent		: IN    STD_LOGIC; -- from fpga slow-control
			sc_tdi_hyb			:   OUT STD_LOGIC; -- to   hybrid
			sc_tdo_hyb			: IN    STD_LOGIC; -- from hybrid
			tdi_suivant			:   OUT STD_LOGIC; -- to   fpga slow-control
			tokenin		 		: IN    STD_LOGIC; -- from event controller
			tokenout			:   OUT STD_LOGIC; -- to   event controller
			hybride_dans_jtag	: IN    STD_LOGIC; -- from fpga slow-control
			ladder_fpga_sc_tck	: IN    STD_LOGIC; -- from slow-control
			ladder_fpga_sc_tms	: IN    STD_LOGIC; -- from slow-control
			sc_tck_hyb			:   OUT STD_LOGIC; -- to   hybrid
			sc_tms_hyb			:   OUT STD_LOGIC; -- to   hybrid
			tokenin_hyb			:   OUT STD_LOGIC; -- to   hybrid
			tokenout_hyb		: IN    STD_LOGIC  -- from hybrid
	);
END component;--signaux_hybrides;

------------------------------------------------------------------------------------

--	component compteur_hybride -- 20090821 enleve
--		PORT( -- 20090821 enleve
--			tokenin_echelle : IN	STD_LOGIC; -- 20090821 enleve
--			clk				: IN    STD_LOGIC; -- 20090821 enleve
--			numero_hybride	:   OUT STD_LOGIC_VECTOR (3 downto 0); -- 20090821 enleve
--			tokenin_auto	:   OUT	STD_LOGIC_VECTOR(15 downto 0) -- 20090821 enleve
--		); -- 20090821 enleve
--	end component; -- 20090821 enleve

------------------------------------------------------------------------------------

--		component commande_mux_v2 -- 20090309 enleve
--		PORT( -- 20090309 enleve
--		bypass_hybride					: IN 	STD_LOGIC_VECTOR(16 downto 1)	; -- 20090309 enleve
--		pilotage						: IN 	STD_LOGIC_VECTOR(16 downto 1)	; -- 20090309 enleve
--		numero_hybride					: IN    STD_LOGIC_VECTOR (3 downto 0) ; -- 20090309 enleve
--		clk								: IN 	STD_LOGIC						; -- 20090309 enleve
--		adresse_mux_readout				:OUT 	STD_LOGIC_vector (1 downto 0) ; -- 20090309 enleve
--		adresse_mux_reference			:OUT 	STD_LOGIC_vector (1 downto 0) ; -- 20090309 enleve
--		enable_mux_entreeADC_plus		:OUT 	STD_LOGIC_vector (4 downto 0) ; -- 20090309 enleve
--		enable_mux_entreeADC_moins		:OUT 	STD_LOGIC_vector (4 downto 0) ; -- 20090309 enleve
--		jtag_mux						:IN 	STD_LOGIC_vector (159 downto 0) ); -- 20090309 enleve
--		END component; -- 20090309 enleve

------------------------------------------------------------------------------------
  COMPONENT memoire_tokenOut_echelle
	PORT (
		tokenIn_echelle				: IN	STD_LOGIC;
		tokenout_echelle			: IN 	STD_LOGIC_VECTOR (15 downto 0);

		memoire_tokenout			:   OUT	STD_LOGIC_VECTOR (15 downto 0)
	);
  END COMPONENT;					
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


		
BEGIN
	control_latchup : filtre_latchup	
	PORT MAP(
		surcourant_n	=>	surcourant,
		pilotage_n		=>	latchup_memorise,
		tck				=>	tck,
		latchup_n		=>	latchup
	);

	control_alim : memoire_latchup_general
		PORT MAP (
			latchup_n	=>	latchup,
			extinction	=>	extinction,
			rallumage	=>	rallumage,
			pilotage_n	=>	latchup_memorise
		);
	---------------------------
	pilotage<=latchup_memorise;
	---------------------------

--	mem_pour_jtag : ou_pilotage -- 20090821 enleve
--	PORT MAP ( -- 20090821 enleve
--		pilotage		=>	latchup_memorise, -- 20090821 enleve
--		latchup_echelle	=>	latchup_memoire -- 20090821 enleve
--	); -- 20090821 enleve
--latchup_memoire <= (	(not latchup_memorise(15)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(14)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(13)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(12)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(11)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(10)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(9) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(8) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(7) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(6) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(5) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(4) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(3) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(2) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(1) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup_memorise(0) ) ); -- 20090821 ajoute -- 20090821 enleve
latchup_memoire <= '0' WHEN (latchup_memorise=x"FFFF") ELSE '1'; -- 20090821 ajoute -- 20090821 modifie

--	pulse_pour_cpt_readout : ou_pilotage -- 20090821 enleve
--	PORT MAP ( -- 20090821 enleve
--		pilotage		=>	latchup, -- 20090821 enleve
--		latchup_echelle	=>	latchup_pulse -- 20090821 enleve
--	); -- 20090821 enleve
--latchup_pulse 	<= (	(not latchup(15)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(14)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(13)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(12)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(11)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(10)) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(9) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(8) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(7) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(6) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(5) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(4) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(3) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(2) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(1) ) -- 20090821 ajoute -- 20090821 enleve
--					 or (not latchup(0) ) ); -- 20090821 ajoute -- 20090821 enleve
latchup_pulse   <= '0' WHEN (latchup=x"FFFF") ELSE '1'; -- 20090821 ajoute -- 20090821 modifie

--	comptage768: compteur_hybride -- 20090821 enleve
--		PORT MAP ( -- 20090821 enleve
--			tokenin_echelle	=>	tokenin_echelle, -- 20090821 enleve
--			clk	=>	rclk, -- 20090821 enleve
--			numero_hybride	=>	numero_du_connecteur, -- 20090821 enleve
--			tokenin_auto	=>	tokenin_par_comptage -- 20090821 enleve
--		); -- 20090821 enleve

  tokenin_test <= x"0000"; -- 20090821 ajouter --A_PREVOIR: supprimer 
--	chainage : bypass_general -- 20090821 enleve
--		PORT MAP ( -- 20090821 enleve
--			bypass_hybride	=>	bypass_hybride, -- 20090821 enleve
--			pilotage		=>	latchup_memorise, -- 20090821 enleve
--			tdi_echelle		=>	tdi_echelle, -- 20090821 enleve
--			tdi				=>	tdi, -- 20090821 enleve
--			tdo				=>	tdo, -- 20090821 enleve
--			tdo_echelle		=>	tdo_echelle, -- 20090821 enleve
--			num_hybride_dans_jtag => num_hybride_dans_jtag, -- 20090629 ajoute -- 20090821 enleve
--			jtag_avec_hybride     => jtag_avec_hybride, -- 20090629 ajoute -- 20090821 enleve
--		ladder_fpga_sc_tck        => tck, -- 20090820 ajoute -- 20090821 enleve
--		ladder_fpga_sc_tms        => ladder_fpga_sc_tms, -- 20090820 ajoute -- 20090821 enleve
--		sc_tck_hybride            => sc_tck_hybride, -- 20090820 ajoute -- 20090821 enleve
--		sc_tms_hybride            => sc_tms_hybride, -- 20090820 ajoute -- 20090821 enleve
--			tokenin_auto	=>	tokenin_par_comptage, -- 20090821 enleve
--			tokenin			=>	tokenin_test -- 20090821 enleve
--		); -- 20090821 enleve

	gen_hybride_dans_jtag :FOR i IN 0 TO 15 GENERATE
--		hybride_dans_jtag(i) <= '0' WHEN (jtag_avec_hybride='0') ELSE '1' WHEN (CONV_INTEGER(num_hybride_dans_jtag)=i) ELSE '0'; -- 20090820 ajoute
		hybride_dans_jtag(i) <= '0' WHEN (jtag_avec_hybride='0') ELSE '1' WHEN (num_hybride_dans_jtag=CONV_STD_LOGIC_VECTOR(i,4)) ELSE '0'; -- 20090820 ajoute
	end GENERATE gen_hybride_dans_jtag;

	tdo_echelle <= tdi_suivant(CONV_INTEGER(num_hybride_dans_jtag)); -- 20090821 ajoute

	gen_chainage :FOR i IN 0 TO 15 GENERATE
		comp_chainage_i: signaux_hybrides -- 20090821 ajoute
		PORT MAP ( -- 20090821 ajoute
			bypass_hyb			=>	bypass_hybride(i),--: IN    STD_LOGIC; -- from fpga slow-control -- 20090821 ajoute
			pilotage_hyb		=>	latchup_memorise(i),--: IN    STD_LOGIC; -- from fpga slow-control -- 20090821 ajoute
			tdo_precedent		=>	tdi_echelle,--: IN    STD_LOGIC; -- from fpga slow-control -- 20090821 ajoute
			sc_tdi_hyb			=>	tdi(i),--:   OUT STD_LOGIC; -- to   hybrid -- 20090821 ajoute
			sc_tdo_hyb			=>	tdo(i),--: IN    STD_LOGIC; -- from hybrid -- 20090821 ajoute
			tdi_suivant			=>	tdi_suivant(i),--:   OUT STD_LOGIC; -- to   fpga slow-control -- 20090821 ajoute
			tokenin		 		=>	tokenin_echelle,--: IN    STD_LOGIC; -- from event controller -- 20090821 ajoute
			tokenout			=>	tokenout_hybrid(i),--:   OUT STD_LOGIC; -- to   event controller -- 20090821 ajoute
			hybride_dans_jtag	=>	hybride_dans_jtag(i),--: IN    STD_LOGIC; -- from fpga slow-control -- 20090821 ajoute
			ladder_fpga_sc_tck	=>	tck,--: IN    STD_LOGIC; -- from slow-control -- 20090821 ajoute
			ladder_fpga_sc_tms	=>	ladder_fpga_sc_tms,--: IN    STD_LOGIC; -- from slow-control -- 20090821 ajoute
			sc_tck_hyb			=>	sc_tck_hybride(i),--:   OUT STD_LOGIC; -- to   hybrid -- 20090821 ajoute
			sc_tms_hyb			=>	sc_tms_hybride(i),--:   OUT STD_LOGIC; -- to   hybrid -- 20090821 ajoute
			tokenin_hyb			=>	tokenin(i),--:   OUT STD_LOGIC; -- to   hybrid -- 20090821 ajoute
			tokenout_hyb		=>	tokenout(i)--: IN    STD_LOGIC  -- from hybrid -- 20090821 ajoute
		); -- 20090821 ajoute
--		END component;--signaux_hybrides; -- 20090821 ajoute
	end GENERATE gen_chainage;
	------------------------
--	tokenin <= tokenin_test; -- 20090818 enleve
	------------------------

--	mux_analogique : commande_mux_v2		 -- 20090309 enleve
--			 PORT MAP (	bypass_hybride		 		, -- 20090309 enleve
--						latchup_memorise	 		, -- 20090309 enleve
--					 	numero_du_connecteur		, -- 20090309 enleve
--						ck_mux						, -- 20090309 enleve
--						adresse_mux_readout			, -- 20090309 enleve
--						adresse_mux_reference		, -- 20090309 enleve
--						enable_mux_entreeADC_plus	, -- 20090309 enleve
--						enable_mux_entreeADC_moins, -- 20090309 enleve
--						jtag_mux	); -- 20090309 enleve

------------------------------------------------------------------------------------
-- memoire pour garder le tokenOut_echelle					-- au reset la memoire est mise a 0
   stokage_token: memoire_tokenOut_echelle
	    PORT MAP (
		tokenIn_echelle		=>	tokenIn_echelle ,
--		tokenout_echelle	=>	tokenout , -- 20090821 enleve
		tokenout_echelle	=>	tokenout_hybrid , -- 20090821 modifie
		memoire_tokenout	=>	tokenout_memoire );
															
																

------------------------------------------------------------------------------------



-- signaux tests:
-----------------

tst_gestion_hybrides(0)		<= tokenin_echelle  ;
--tst_gestion_hybrides(1)	 	<= ck_mux 	        ; -- 20090309 enleve
tst_gestion_hybrides(1)	 	<= '0' 	        ; -- 20090309 modifie
tst_gestion_hybrides(2)		<= tokenin_test(1)  ;
tst_gestion_hybrides(3) 	<= tokenin_test(2)  ;
tst_gestion_hybrides(4)		<= tokenin_test(3)  ;
tst_gestion_hybrides(5)		<= tokenin_test(4)  ;
tst_gestion_hybrides(6)		<= tokenin_test(5)  ;
tst_gestion_hybrides(7)		<= tokenin_test(6)  ;
tst_gestion_hybrides(8)		<= '1' 		        ;
tst_gestion_hybrides(9)		<= '1' 				;
tst_gestion_hybrides(10)	<= '1' 				;
tst_gestion_hybrides(11)	<= '1' 				;
tst_gestion_hybrides(12)	<= '1' 				;
tst_gestion_hybrides(13)	<= '1' 				;
tst_gestion_hybrides(14)	<= '1' 				;
tst_gestion_hybrides(15)	<= '1' 				;

end gestion_hybrides_v4_arch;
