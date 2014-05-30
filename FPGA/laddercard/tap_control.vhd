---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

------------------------------------------------------------------------------
--							TAP_CONTROL
--  IEEE 1149.1 TAP Controller state machine
--		  ********************************************************************
--		  * Controleur JTAG (TAP) pour le fpga de la carte de connexion STAR *
--		  ********************************************************************
--
-- modifier/compiler le 5/10/99 christine
-- modif Cyril le 23 juin 2000 : pas de chgt theorique, remise en forme du texte.
--                26 juin 2000 : modif glitch clockIR et clockDR
--                               modif bascule "current"
--                13 juillet 2000: affectation synchrone et asynchrone de "reset_bar"

--     v2.0   | C.Renard | Modification  | 03 jan 2001 | sorti clockIR et clockDR de process inutile
--     v2.1   | C.Renard | Modification  | 01 fev 2001 | remplace type BIT par type STD_LOGIC
--     v2.2   | C.Renard | Modification  | 06 fev 2001 | sorties specifiques a la carte READOUT
--     v2.3   | C.Renard | Modification  | 10 aou 2001 | modif reunion interfaces
--     v2.4   | C.Renard | Modification  | 06 nov 2001 | adder pedestal
--     v2.5   | C.Renard | Modification  | 09 oct 2003 | sc_adjust (sc_trg_pos_mot et sc_fe_nb_pre_clk) modifiable par slow-control 
--     v2.6   | C.Renard | Modification  | 12 sep 2006 | syn_encoding "safe,onehot"
--     v2.7   | C.Renard | Modification  | 10 dec 2008 | adaptation pour star ssd Upgrade
--     v2.8   | C.Renard | Modification  | 10 dec 2008 | tap_control generique
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;
--Library synplify; -- 200600912 ajoute
--Use     synplify.attributes.all; -- 200600912 ajoute


ENTITY tap_control IS
  PORT (tms, tck, trstb 			: IN STD_LOGIC;
	reset_bar, enable, shiftIR, clockIR,
	updateIR, shiftDR, clockDR	: OUT STD_LOGIC;
	sc_updateDR_0x00, sc_updateDR_0x01, sc_updateDR_0x02, sc_updateDR_0x03,
	sc_updateDR_0x04, sc_updateDR_0x05, sc_updateDR_0x06, sc_updateDR_0x07,
	sc_updateDR_0x08, sc_updateDR_0x09, sc_updateDR_0x0a, sc_updateDR_0x0b,
	sc_updateDR_0x0c, sc_updateDR_0x0d, sc_updateDR_0x0e, sc_updateDR_0x0f,
	sc_updateDR_0x10, sc_updateDR_0x11, sc_updateDR_0x12, sc_updateDR_0x13,
	sc_updateDR_0x14, sc_updateDR_0x15, sc_updateDR_0x16, sc_updateDR_0x17,
	sc_updateDR_0x18, sc_updateDR_0x19, sc_updateDR_0x1a, sc_updateDR_0x1b,
	sc_updateDR_0x1c, sc_updateDR_0x1d, sc_updateDR_0x1e, sc_updateDR_bypass : OUT STD_LOGIC;
	dbg_etat_present			: OUT STD_LOGIC_VECTOR (15 downto 0);
	Instruction_Register			: IN STD_LOGIC_VECTOR (4 downto 0)
	);
END tap_control ;


--==========================================================================================
--==========================================================================================
--==========================================================================================

ARCHITECTURE a OF tap_control IS
  TYPE state IS (test_logic_reset, run_test_idle, select_DR_scan,
                 capture_DR, shift_DR, exit1_DR, pause_DR, exit2_DR, 
                 update_DR, select_IR_scan, capture_IR, shift_IR,
                 exit1_IR, pause_IR, exit2_IR, update_IR);

  SIGNAL clockDR_in : std_logic; -- 20060912 ajoute
  SIGNAL etat_present,etat_futur : state := test_logic_reset;
--  attribute syn_encoding of etat_present : signal is "safe,onehot"; -- 200600912 ajoute

BEGIN

--==========================================================================================
  bascule: PROCESS  (tck,trstb)
  BEGIN
    if trstb='0' then
      etat_present <= test_logic_reset;
    elsif (tck'event and (tck = '1')) then	
      etat_present <=etat_futur;
    end if;
  END PROCESS bascule;
--==========================================================================================


--==========================================================================================
  calculcombinatoire: process(etat_present, tms)
  begin 
	CASE etat_present IS
	WHEN test_logic_reset =>
	  IF tms = '0' THEN
            etat_futur <= run_test_idle;
	  ELSE
            etat_futur <= test_logic_reset;
	  END IF;
	  dbg_etat_present <= "0000000000000001";
	WHEN run_test_idle =>
	  IF tms = '1' THEN
            etat_futur <= select_DR_scan;
	  ELSE
            etat_futur <= run_test_idle;
	  END IF;
	  dbg_etat_present <= "0000000000000010";
	WHEN select_DR_scan =>
	  IF tms = '0' THEN
            etat_futur <= capture_DR;
	  ELSE
            etat_futur <= select_IR_scan;
	  END IF;
	  dbg_etat_present <= "0000000000000100";
	WHEN capture_DR =>
	  IF tms = '0' THEN
            etat_futur <= shift_DR;
	  ELSE
            etat_futur <= exit1_DR;
	  END IF;
	  dbg_etat_present <= "0000000000001000";
	WHEN shift_DR =>
	  IF tms = '1' THEN
            etat_futur <= exit1_DR;
	  ELSE
            etat_futur <= shift_DR;
	  END IF;
	  dbg_etat_present <= "0000000000010000";
	WHEN exit1_DR =>
	  IF tms = '0' THEN
            etat_futur <= pause_DR;
	  ELSE
            etat_futur <= update_DR;
	  END IF;
	  dbg_etat_present <= "0000000000100000";
	WHEN pause_DR =>
	  IF tms = '1' THEN
            etat_futur <= exit2_DR;
	  ELSE
            etat_futur <= pause_DR;
	  END IF;
	  dbg_etat_present <= "0000000001000000";
	WHEN exit2_DR =>
	  IF tms = '1' THEN
            etat_futur <= update_DR;
	  ELSE
            etat_futur <= shift_DR;
	  END IF;
	  dbg_etat_present <= "0000000010000000";
	WHEN update_DR =>
	  IF tms = '0' THEN
            etat_futur <= run_test_idle;
	  ELSE
            etat_futur <= select_DR_scan;
	  END IF;
	  dbg_etat_present <= "0000000100000000";
	WHEN select_IR_scan =>
	  IF tms = '0' THEN
            etat_futur <= capture_IR;
	  ELSE
            etat_futur <= test_logic_reset;
	  END IF;
	  dbg_etat_present <= "0000001000000000";
	WHEN capture_IR =>
	  IF tms = '0' THEN
            etat_futur <= shift_IR;
	  ELSE
            etat_futur <= exit1_IR;
	  END IF;
	  dbg_etat_present <= "0000010000000000";
	WHEN shift_IR =>
	  IF tms = '1' THEN
            etat_futur <= exit1_IR;
	  ELSE
            etat_futur <= shift_IR;
	  END IF;
	  dbg_etat_present <= "0000100000000000";
	WHEN exit1_IR =>
	  IF tms = '0' THEN
            etat_futur <= pause_IR;
	  ELSE
            etat_futur <= update_IR;
	  END IF;
	  dbg_etat_present <= "0001000000000000";
	WHEN pause_IR =>
	  IF tms = '1' THEN
            etat_futur <= exit2_IR;
	  ELSE
            etat_futur <= pause_IR;
	  END IF;
	  dbg_etat_present <= "0010000000000000";
	WHEN exit2_IR =>
	  IF tms = '1' THEN
            etat_futur <= update_IR;
	  ELSE
            etat_futur <= shift_IR;
	  END IF;
	  dbg_etat_present <= "0100000000000000";
	WHEN update_IR =>
	  IF tms = '0' THEN
            etat_futur <= run_test_idle;
	  ELSE
            etat_futur <= select_DR_scan;
	  END IF;
	  dbg_etat_present <= "1000000000000000";
	WHEN OTHERS =>
	  IF tms = '0' THEN
            etat_futur <= test_logic_reset;
	  ELSE
            etat_futur <= test_logic_reset;
	  END IF;
	  dbg_etat_present <= "1111111111111111";
	END CASE;
  END PROCESS calculcombinatoire;
 --==========================================================================================



--==========================================================================================
sortiessynchrones: PROCESS (tck)
BEGIN
  IF (tck = '0' AND tck'EVENT) THEN
    -----------------------------------------------------------
    IF (etat_present = shift_IR OR etat_present = shift_DR) THEN
      enable <= '1';
    ELSE
      enable <= '0';
    END IF;
    -----------------------------------------------------------
    IF etat_present = shift_IR THEN
      shiftIR <= '1';
    ELSE
      shiftIR <= '0';
    END IF;
    -----------------------------------------------------------
    IF etat_present = shift_DR THEN
      shiftDR <= '1';
    ELSE
      shiftDR <= '0';
    END IF;
    -----------------------------------------------------------
    IF etat_present = update_IR	THEN
      updateIR <= '1';
    ELSE
      updateIR <= '0'; 
    END IF;
    -----------------------------------------------------------
    IF etat_present = update_DR THEN
      -- permet de generer un enable par registre accessible en ecriture
      -- en decodant l'instruction
      case Instruction_Register is
        when "00000" => sc_updateDR_0x00	<='1' ;
        when "00001" => sc_updateDR_0x01	<='1' ;
        when "00010" => sc_updateDR_0x02	<='1' ;
        when "00011" => sc_updateDR_0x03	<='1' ;
        when "00100" => sc_updateDR_0x04	<='1' ;
        when "00101" => sc_updateDR_0x05	<='1' ;
        when "00110" => sc_updateDR_0x06	<='1' ;
        when "00111" => sc_updateDR_0x07	<='1' ;
        when "01000" => sc_updateDR_0x08	<='1' ;
        when "01001" => sc_updateDR_0x09	<='1' ;
        when "01010" => sc_updateDR_0x0a	<='1' ;
        when "01011" => sc_updateDR_0x0b	<='1' ;
        when "01100" => sc_updateDR_0x0c	<='1' ;
        when "01101" => sc_updateDR_0x0d	<='1' ;
        when "01110" => sc_updateDR_0x0e	<='1' ;
        when "01111" => sc_updateDR_0x0f	<='1' ;
        when "10000" => sc_updateDR_0x10	<='1' ;
        when "10001" => sc_updateDR_0x11	<='1' ;
        when "10010" => sc_updateDR_0x12	<='1' ;
        when "10011" => sc_updateDR_0x13	<='1' ;
        when "10100" => sc_updateDR_0x14	<='1' ;
        when "10101" => sc_updateDR_0x15	<='1' ;
        when "10110" => sc_updateDR_0x16	<='1' ;
        when "10111" => sc_updateDR_0x17	<='1' ;
        when "11000" => sc_updateDR_0x18	<='1' ;
        when "11001" => sc_updateDR_0x19	<='1' ;
        when "11010" => sc_updateDR_0x1a	<='1' ;
        when "11011" => sc_updateDR_0x1b	<='1' ;
        when "11100" => sc_updateDR_0x1c	<='1' ;
        when "11101" => sc_updateDR_0x1d	<='1' ;
        when "11110" => sc_updateDR_0x1e	<='1' ;
        when others  => sc_updateDR_bypass	<='1' ;
      end case ;
    ELSE
      sc_updateDR_0x00	<='0' ;
      sc_updateDR_0x01	<='0' ;
      sc_updateDR_0x02	<='0' ;
      sc_updateDR_0x03	<='0' ;
      sc_updateDR_0x04	<='0' ;
      sc_updateDR_0x05	<='0' ;
      sc_updateDR_0x06	<='0' ;
      sc_updateDR_0x07	<='0' ;
      sc_updateDR_0x08	<='0' ;
      sc_updateDR_0x09	<='0' ;
      sc_updateDR_0x0a	<='0' ;
      sc_updateDR_0x0b	<='0' ;
      sc_updateDR_0x0c	<='0' ;
      sc_updateDR_0x0d	<='0' ;
      sc_updateDR_0x0e	<='0' ;
      sc_updateDR_0x0f	<='0' ;
      sc_updateDR_0x10	<='0' ;
      sc_updateDR_0x11	<='0' ;
      sc_updateDR_0x12	<='0' ;
      sc_updateDR_0x13	<='0' ;
      sc_updateDR_0x14	<='0' ;
      sc_updateDR_0x15	<='0' ;
      sc_updateDR_0x16	<='0' ;
      sc_updateDR_0x17	<='0' ;
      sc_updateDR_0x18	<='0' ;
      sc_updateDR_0x19	<='0' ;
      sc_updateDR_0x1a	<='0' ;
      sc_updateDR_0x1b	<='0' ;
      sc_updateDR_0x1c	<='0' ;
      sc_updateDR_0x1d	<='0' ;
      sc_updateDR_0x1e	<='0' ;
      sc_updateDR_bypass	<='0' ;
    END IF;
    -----------------------------------------------------------
  END IF;
END PROCESS sortiessynchrones;
--==========================================================================================



--==========================================================================================
--sortiescombinatoires : process
--begin
--	-----------------------------------------------------------------
--  	IF (etat_present = capture_IR OR etat_present = shift_IR)
--		THEN									clockIR<=tck;
--		ELSE									clockIR<='1';
--	END IF;
--	-----------------------------------------------------------------
--	IF (etat_present = capture_DR OR etat_present = shift_DR)
--		THEN									clockDR<=tck;
--		ELSE									clockDR<='1';
--	END IF;
--	-----------------------------------------------------------------
--end process sortiescombinatoires;
clockIR <= tck when(etat_present = capture_IR OR etat_present = shift_IR) else
           '1';
--  clockDR <= tck when(etat_present = capture_DR OR etat_present = shift_DR) else -- 20060912 enleve
clockDR_in <= tck when(etat_present = capture_DR OR etat_present = shift_DR) else -- 20060912 modifie
              '1';
clockDR    <= clockDR_in; -- 20060912 ajoute
--==========================================================================================


--==========================================================================================
sortieRESET: PROCESS  (tck,trstb)
BEGIN														  -- reset par "trstb" asynchrone
  if trstb='0' then 						reset_bar <= '0';
  elsif (tck'event and (tck = '0')) then	
    IF etat_present = test_logic_reset 					  -- reset par "tms" synchrone
    THEN 								reset_bar <= '0';
    ELSE 								reset_bar <= '1'; 
    END IF;
  end if;
end process sortieRESET;
--==========================================================================================


END a ;

