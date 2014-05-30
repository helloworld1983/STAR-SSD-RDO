---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
--  REGISTRE DE DATA DE 16 BITS         CHRISTINE				LE 3/05/99
--  Copie presque conforme de modeles fait par PM CAMBELL trouves sur le WEB
-- ceci est un registre de donnees compose d'une succession de cellules 
-- boundary-scan/registre de donnees.  ---accessible en lecture /ecriture
-- -- REMARQUE: le shift-register charge la data dans le registre MSB 
-- et la decale en la sortant du LSB .,le mode est supprime.
--		CHAQUE REGISTRE EST POURVU D'UN RESET 7/7/00
-- la valeur prise au reset sera commune pour tous les bits.
------------------------------------------------------------------
-- v2.0 | C.Renard | 02 fev  2001 | remplace type BIT par type STD_LOGIC
-- v3.0 | C.Renard | 09 mars 2009 | taille de type GENERIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY dr_x_bits IS
  GENERIC(taille : integer:=  16);
  PORT (
    reset_bar, reset_value  :  IN STD_LOGIC;
    data_in  :  IN STD_LOGIC_VECTOR((taille-1) downto 0);
    clockDR, shiftDR,  updateDR, scan_in  :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR((taille-1) downto 0)
    );
END dr_x_bits;



ARCHITECTURE structural OF dr_x_bits IS

  COMPONENT dr_cell
    PORT (

      reset_bar, reset_value  :  IN STD_LOGIC;
      data_in  :  IN STD_LOGIC;
      clockDR, shiftDR, updateDR, scan_in  :  IN STD_LOGIC;
      scan_out : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC
      ); --dr_cell
  END COMPONENT;

  SIGNAL temp_scan : STD_LOGIC_VECTOR (data_in'RANGE);

BEGIN

  a : FOR i IN data_in'LOW  TO data_in'HIGH GENERATE
    b : IF (i = (taille-1)) GENERATE
      c : dr_cell
        PORT MAP (
          reset_bar	=>	reset_bar,
          reset_value	=>	reset_value,
          data_in	=>	data_in(i),
          clockDR	=>	clockDR,
          shiftDR	=>	shiftDR,
          updateDR	=>	updateDR,
          scan_in	=>	scan_in,
          scan_out	=>	temp_scan(i),
          data_out	=>	data_out(i)); --dr_cell
    END GENERATE;
    d : IF (i < (taille-1)) GENERATE
      e : dr_cell
        PORT MAP (
          reset_bar	=>	reset_bar,
          reset_value	=>	reset_value,
          data_in	=>	data_in(i),
          clockDR	=>	clockDR,
          shiftDR	=>	shiftDR,
          updateDR	=>	updateDR,
          scan_in	=>	temp_scan(i+1),
          scan_out	=>	temp_scan(i),
          data_out	=>	data_out(i)); --dr_cell
    END GENERATE;
  END GENERATE;

  scan_out <= temp_scan(0);

END structural;

