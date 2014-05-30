---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
--  Data Register Cell        P.M.Campbell         Nov. 17, 1991
--
--  This is a boundary-scan/data register cell.
--
--  The schematic for this cell is on page 10-18, fig. 10-16,
--  of IEEE Std 1149.1-1990.
-- j'enleve le mode      christine le 25/01/00
----------------------------------------------------------------
-- modif cyril lecture jtag sur front montant de clockDR (=tck)
--             sortie jtag sur front descendant   (3juillet2000)
-- 17/7/00
-- v2.0 | C.Renard | 02 fev  2001 | remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY dr_cell IS 
  PORT (
    reset_bar,  reset_value :  IN STD_LOGIC;
    data_in  :  IN STD_LOGIC;
    clockDR, shiftDR, updateDR, scan_in  :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC
    );
END dr_cell;

ARCHITECTURE behavioral OF dr_cell IS
  SIGNAL ff1 : STD_LOGIC;
BEGIN

  dff1 : PROCESS (clockDR)
  BEGIN
    IF (clockDR'event and (clockDR = '1')) THEN
      IF shiftDR = '0' THEN
        ff1 <= data_in;  -- lecture registre
      ELSE
        ff1 <= scan_in;  -- chargement TDin
      END IF;			
    END IF;
  END PROCESS dff1;


  TDout: PROCESS (clockDR)
  BEGIN
    IF (clockDR'EVENT AND clockDR = '0') THEN
      scan_out <= ff1;						-- sortie TDout sur front descendant
    END IF;
  END PROCESS TDout;


  dff2 : PROCESS (updateDR, reset_bar, reset_value)
  BEGIN
    IF (reset_bar = '0') THEN
      data_out <= reset_value;
    ELSIF (updateDR'EVENT AND (updateDR = '1')) THEN
      data_out <= ff1; -- ecriture registre
    END IF;
  END PROCESS dff2;

END behavioral;

