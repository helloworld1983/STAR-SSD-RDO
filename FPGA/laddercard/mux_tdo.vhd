---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

-- multiplexeur des sorties des registres data JTAG du fpga de la carte connexion
--
-- modif cyril 17/7/00   chgt de nom (commande_alim_scan_out, etat_alim_scan_out)
--
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v2.0   | C.Renard | Modification  | 03 jan 2000 | sorti dr_scan_out de process inutile
--     v2.1   | C.Renard | Modification  | 02 fev 2001 | remplace type BIT par type STD_LOGIC
--     v2.3   | C.Renard | Modification  | 16 fev 2001 | sorties specifiques a la carte READOUT
--     v2.2   | C.Renard | Modification  | 19 mar 2001 | ajout temperature fall
--     v2.3   | C.Renard | Modification  | 17 avr 2001 | modif reunion interfaces
--     v2.4   | C.Renard | Modification  | 09 aou 2001 | ajout txo
--     v2.5   | C.Renard | Modification  | 06 nov 2001 | adder pedestal
--     v2.6   | C.Renard | Modification  | 08 avr 2002 | compteur nombre event_start
--     v2.7   | C.Renard | Modification  | 03 fev 2003 | ajout daq_status
--     v2.7   | C.Renard | Modification  | 21 mai 2003 | sortie daq_tx_nb_err vers slow-cont
--     v2.8   | C.Renard | Modification  | 09 oct 2003 | sc_adjust (sc_trg_pos_mot et sc_fe_nb_pre_clk) modifiable par slow-control 
--     v .    | C.Renard | Modification  | 10 jun 2006 | suppression sc_num_config_scan_out pour regagner en frequence
--     v2.a   | C.Renard | Modification  | 12 sep 2006 | retour à v2.8 (readout_fpga64q)
--     v2.b   | C.Renard | Modification  | 10 dec 2008 | multiplexeur generique
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;
ENTITY mux_tdo IS
	PORT (
		entree_0x00, entree_0x01, entree_0x02, entree_0x03, entree_0x04, entree_0x05, entree_0x06, entree_0x07,
		entree_0x08, entree_0x09, entree_0x0a, entree_0x0b, entree_0x0c, entree_0x0d, entree_0x0e, entree_0x0f,
		entree_0x10, entree_0x11, entree_0x12, entree_0x13, entree_0x14, entree_0x15, entree_0x16, entree_0x17,
		entree_0x18, entree_0x19, entree_0x1a, entree_0x1b, entree_0x1c, entree_0x1d, entree_0x1e,
		entree_bypass : IN STD_LOGIC;	-- registre bypass JTAG IEEE 1149.1
		ir_data_out   : IN STD_LOGIC_VECTOR (4 DOWNTO 0); --registre instruction
		dr_scan_out   : OUT STD_LOGIC);	-- registre data JTAG sélectionné.
END mux_tdo ;

ARCHITECTURE behavioral OF mux_tdo IS
BEGIN
  dr_scan_out <=
    entree_0x00   WHEN ir_data_out="00000" ELSE
    entree_0x01   WHEN ir_data_out="00001" ELSE
    entree_0x02   WHEN ir_data_out="00010" ELSE
    entree_0x03   WHEN ir_data_out="00011" ELSE
    entree_0x04   WHEN ir_data_out="00100" ELSE
    entree_0x05   WHEN ir_data_out="00101" ELSE
    entree_0x06   WHEN ir_data_out="00110" ELSE
    entree_0x07   WHEN ir_data_out="00111" ELSE
    entree_0x08   WHEN ir_data_out="01000" ELSE
    entree_0x09   WHEN ir_data_out="01001" ELSE
    entree_0x0a   WHEN ir_data_out="01010" ELSE
    entree_0x0b   WHEN ir_data_out="01011" ELSE
    entree_0x0c   WHEN ir_data_out="01100" ELSE
    entree_0x0d   WHEN ir_data_out="01101" ELSE
    entree_0x0e   WHEN ir_data_out="01110" ELSE
    entree_0x0f   WHEN ir_data_out="01111" ELSE
    entree_0x10   WHEN ir_data_out="10000" ELSE
    entree_0x11   WHEN ir_data_out="10001" ELSE
    entree_0x12   WHEN ir_data_out="10010" ELSE
    entree_0x13   WHEN ir_data_out="10011" ELSE
    entree_0x14   WHEN ir_data_out="10100" ELSE
    entree_0x15   WHEN ir_data_out="10101" ELSE
    entree_0x16   WHEN ir_data_out="10110" ELSE
    entree_0x17   WHEN ir_data_out="10111" ELSE
    entree_0x18   WHEN ir_data_out="11000" ELSE
    entree_0x19   WHEN ir_data_out="11001" ELSE
    entree_0x1a   WHEN ir_data_out="11010" ELSE
    entree_0x1b   WHEN ir_data_out="11011" ELSE
    entree_0x1c   WHEN ir_data_out="11100" ELSE
    entree_0x1d   WHEN ir_data_out="11101" ELSE
    entree_0x1e   WHEN ir_data_out="11110" ELSE
    entree_bypass;
END behavioral;
