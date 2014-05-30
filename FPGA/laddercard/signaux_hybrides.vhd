-------------------------------------------------------------------------
--
-- File name    :  signaux_hybrides.vhd
-- Title        :  VHDL pour gerer les signaux des hybrides dans le FPGA en bout d'echelle du SSDUpgrade de STAR
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 24 aout 2009 15:00
--              :
-- Comments     : replaces old bypass_general.vhd and bypass.vhd files that were created and modified by Cyril from 1999 to 2001
--              : 
-- Assumptions  : none
-- Limitations  : plenty
-- Known Errors : none
-- Developers   : Christophe Renard
--              : 
-- Notes        :
-- ----------------------------------------------------------------------
-- Revision History :
-- ----------------------------------------------------------------------
									-- BYPASS_GENERAL --
--concatenate les modules bypass . 
--recoit le tokenin_echelle et le tdi_echelle
--voir le module bypass pour plus de renseignements.
-- Cyril Dec2001
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
--     v2     | C.Renard | Modification  | 29 jun 2009| 0 or 1 hybrid in the JTAG line
--     v2     | C.Renard | Modification  | 20 aou 2009| 0 or 1 hybrid in the JTAG line (tms and tck)
-- ----------------------------------------------------------------------
				--							BYPASS						--
-- permet de faire passer le jeton  d'un hybride a l'autre en generant les tokenin et les TDI
-- 
-- recoit les TDO et les sigaux memorises des latchup qui se nomment: pilotage. 
-- en cas de latchup realise le bypass des tdi
-- un autre signal mis a '0' genere par le slow_control:bypass_hybride permet de realiser le bypass
-- meme si aucun latchup n'arrive(detecter par une surconsommation des alims d'hybrides) le 6/10/99
-- Cyril dec2001
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2     | C.Renard | Modification  | 09 mar 2009| adaptation from connexion board to ladder board
-- ----------------------------------------------------------------------
									-- SIGNAUX HYBRIDES --
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v0.1   | C.Renard | Creation      | 21 aou 2009
--     v0.1   | C.Renard | Modification  | 21 aou 2009| mix of old bypass_general.vhd and bypass.vhd files
--     v0.1   | C.Renard | Modification  | 24 aou 2009| debug mux
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;


ENTITY signaux_hybrides IS																	
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
END signaux_hybrides;
				

ARCHITECTURE signaux_hybrides_arch OF signaux_hybrides IS
	
--SIGNAL hybrid_on : STD_LOGIC; -- 20090824 enleve
SIGNAL jtag_on   : STD_LOGIC;

BEGIN
--hybrid_on <= '1' WHEN ((pilotage_hyb='1')AND(bypass_hyb='0'))        ELSE '0'; -- 20090824 enleve
--jtag_on   <= '1' WHEN ((hybrid_on='1')   AND(hybride_dans_jtag='1')) ELSE '0'; -- 20090824 enleve
jtag_on   <= '1' WHEN ((pilotage_hyb='1')AND(hybride_dans_jtag='1')) ELSE '0'; -- 20090824 modifie

--tokenin_hyb	<= tokenin		 WHEN (hybrid_on='1') ELSE -- normal -- 20090824 enleve
tokenin_hyb	<= tokenin		 WHEN (pilotage_hyb='1') ELSE -- normal -- 20090824 modifie
			   '0'; -- pull down the line to hybrid
--tokenout    <= tokenout_hyb	 WHEN (hybrid_on='1') ELSE -- normal  -- 20090824 enleve
tokenout	<= tokenout_hyb	 WHEN (pilotage_hyb='1') ELSE -- normal  -- 20090824 modifie
			   '0'; -- in place of the hybrid

--sc_tck_hyb 	<= ladder_fpga_sc_tck WHEN (hybrid_on='1') ELSE -- chainage normal even if hybrid bypassed -- 20090824 enleve
sc_tck_hyb 	<= ladder_fpga_sc_tck WHEN (jtag_on='1') ELSE -- chainage normal even if hybrid bypassed -- 20090824 modifie
			   '0';	-- pull down the line to hybrid
--sc_tms_hyb 	<= ladder_fpga_sc_tms WHEN (hybrid_on='1') ELSE -- chainage normal even if hybrid bypassed -- 20090824 enleve
sc_tms_hyb 	<= ladder_fpga_sc_tms WHEN (jtag_on='1') ELSE -- chainage normal even if hybrid bypassed -- 20090824 modifie
			   '0';	-- pull down the line to hybrid
--sc_tdi_hyb 	<= tdo_precedent WHEN (hybrid_on='1') ELSE -- chainage normal even if hybrid bypassed -- 20090824 enleve
sc_tdi_hyb 	<= tdo_precedent WHEN (jtag_on='1') ELSE -- chainage normal even if hybrid bypassed -- 20090824 modifie
			   '0';	-- pull down the line to hybrid
--tdi_suivant	<= sc_tdo_hyb	 WHEN (jtag_on='1') ELSE -- chainage normal -- 20090824 enleve
tdi_suivant	<= sc_tdo_hyb	 WHEN ((jtag_on='1')AND(bypass_hyb='0')) ELSE -- chainage normal -- 20090824 modifie
			   tdo_precedent;						 -- hybrid output (and only output) suppressed from jtag chain
		
END signaux_hybrides_arch;
