---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
--  REGISTRE D'INSTRUCTIONS 5 BITS 
--
--  Il est compose d'une succession de cellules elementaires ir_cell
--  Les 2 derniers etages contiennent la valeur binaire "01".
--  
--  Ceci permet a l'instruction BYPASS ou IDCODE d'etre chargee quand
--  l'etat 'Test-Logic-Reset' est entre

-- les differentes instructions sont chargees en serie par tdi et sont shiftees au fur
-- et a mesure 
--
------------------------------------------------------------------Christine le 3/2/00
-- v2.0 | C.Renard | 01 fev  2001 | remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY ir_5_bits IS
  PORT (
    reset_bar			 :  IN STD_LOGIC;
    data_in  :  IN STD_LOGIC_VECTOR (4 downto 0);
    clockIR, shiftIR,  updateIR,  scan_in  :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR (4 downto 0));
END ir_5_bits ;

ARCHITECTURE structural OF ir_5_bits IS

  COMPONENT ir_cell
    PORT (
      reset_bar,  reset_value  :  IN STD_LOGIC;
      data_in  :  IN STD_LOGIC;
      clockIR, shiftIR, updateIR, scan_in  :  IN STD_LOGIC;
      scan_out : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL temp_scan : STD_LOGIC_VECTOR (data_out'RANGE);
  SIGNAL vdd : STD_LOGIC := '1';
  SIGNAL gnd : STD_LOGIC := '0';

BEGIN
  a : FOR i IN data_out'LOW TO data_out'HIGH GENERATE
    b : IF (i = 4) GENERATE
      c : ir_cell
        PORT MAP (
          reset_bar,
          vdd ,        -- instruction bypass
          data_in(i) , -- au demarrage
          clockIR, shiftIR, updateIR, scan_in,
          temp_scan(i) ,
          data_out (i)
          );
    END GENERATE;
    d : IF (i < 4)  GENERATE
      e : ir_cell
        PORT MAP (
          reset_bar,
          vdd       , -- instruction bypass
          data_in(i)     , -- au demarrage
          clockIR, shiftIR, updateIR,   temp_scan(i+1) ,
          temp_scan(i)   ,
          data_out (i)
          );
    END GENERATE;
  END GENERATE ;

  scan_out <= temp_scan(0);
  gnd <= '0';
  vdd <= '1';

END structural;

