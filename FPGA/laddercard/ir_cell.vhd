---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
--  Instruction Register Cell      P.M.Campbell     Dec. 6, 1991
--
--  This is an instruction register cell.
--
--  The schematic for this cell is on page 6-4, fig. 6-1,
--  of IEEE Std 1149.1-1990.
--
--									modif Cyril le 26 Juin 2000
----------------------------------------------------------------
-- v2.0 | C.Renard | 01 fev  2001 | remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY ir_cell IS
  PORT (
    reset_bar,  reset_value  :  IN STD_LOGIC;
    data_in  :  IN STD_LOGIC;
    clockIR, shiftIR, updateIR, scan_in  :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC);
END ir_cell;

ARCHITECTURE behavioral OF ir_cell IS
  SIGNAL ff1 : STD_LOGIC;
BEGIN
  dff1 : PROCESS (clockIR)
  BEGIN
    IF (clockIR'EVENT AND clockIR = '1') THEN
      IF shiftIR = '0' THEN
        ff1 <= data_in;
      ELSE
        ff1 <= scan_in;						    -- lecture TDin sur front montant
      END IF;
    END IF;
  END PROCESS dff1;

  TDout: PROCESS (clockIR)
  BEGIN
    IF (clockIR'EVENT AND clockIR = '0') THEN
      scan_out <= ff1;						-- sortie TDout sur front descendant
    END IF;
  END PROCESS TDout;

  dffr : PROCESS (updateIR, reset_bar, reset_value)
  BEGIN
    IF (reset_bar = '0') THEN
      data_out <= reset_value;
    ELSIF (updateIR'EVENT AND (updateIR = '1') ) THEN
      data_out <= ff1;
    END IF;
  END PROCESS dffr;
END behavioral;


-- NB: Cette cellule est en fait identique à dr_cell.
