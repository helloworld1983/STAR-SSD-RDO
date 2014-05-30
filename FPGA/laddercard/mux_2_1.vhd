---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
--
-- multiplexeur de sortie JTAG du FPGA: aiguillage instruction_register ou data_register
--
-- v2.0 | C.Renard | 01 fev  2001 | remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY mux_2_1 IS
  PORT (a, b, g1 : IN STD_LOGIC; z : OUT STD_LOGIC);
END mux_2_1;

ARCHITECTURE behavioral OF mux_2_1 IS
BEGIN
  PROCESS (a, b, g1)
  BEGIN
    IF (g1 = '0') THEN z <= a;
    ELSIF (g1 = '1') THEN z <= b;
    END IF;
  END PROCESS;
END behavioral;
