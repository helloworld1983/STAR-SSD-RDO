---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

				--identificateur_8bits--

--ce registre JTAG  8 bits a pour MSB en interne 1001 et pour LSB 4 bits permettant
-- d'identifier les cartes connexion
--.qd je veux lire l'identite de ma carte je lance un  coup de clk sur front montant et
--je recupere l'identite sur un mot de 8 bits =data_out
--si je veux la lire par JTAG il me faut 8 fronts
--montants de clk avec un shift DR a '1' et la je le recupere sur le TDO=scan_out.

--christine le 25/01/99
-- modif cyril de dr_cell (TDout sort sur front descendant) 3 juillet 2000.
 -- v2.0 | C.Renard | 01 fev  2001 | remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY identificateur_8bits IS
  PORT (
    reset_bar,  reset_value :  IN STD_LOGIC;
    data_in  : IN STD_LOGIC_VECTOR(7 downto 0);
    clockDR, shiftDR, updateDR, scan_in  : IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END identificateur_8bits;


ARCHITECTURE structural OF identificateur_8bits  IS

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

--  a : FOR i IN data_in'HIGH TO data_in'LOW  GENERATE
  a : FOR i IN data_in'LOW  TO data_in'HIGH GENERATE
    b : IF (i = 7) GENERATE
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
    d : IF (i < 7) GENERATE
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
