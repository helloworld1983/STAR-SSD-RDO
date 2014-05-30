---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
-- +++    Cyril & Christine le 17 juillet 2000    +++    FPGA carte_connexion STAR    +++ --
---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---

----------------------------------------------------------------
--  Bypass Register Cell      P.M.Campbell         Nov. 17, 1991
--
--  This is a bypass register cell.
--
--  The schematic for this cell is on page 9-1, fig. 9-1,
--  of IEEE Std 1149.1-1990.
--  modifiee le 25/02/00 christine
----------------------------------------------------------------
-- modif Cyril  sortie sur front descendant et mémorisation du reset dans ff1.
-- v2.0 | C.Renard | 01 fev  2001 | remplace type BIT par type STD_LOGIC
------------------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
Library IEEE;
Use     IEEE.STD_Logic_1164.all; -- Reference the Std_logic_1164 system
--Use     IEEE.numeric_std.all;
Use     IEEE.std_logic_arith.all;
Use     IEEE.std_logic_signed.all;

ENTITY br_cell_1clk IS
			PORT (       reset_bar 			 :  IN STD_LOGIC;  -- rajout
				  clockDR, shiftDR, scan_in  :  IN STD_LOGIC;
                       				 dbg_ff1 : OUT STD_LOGIC; -- 20020620 ajoute pour verifier si ff1ne disparait pas
                       				scan_out : OUT STD_LOGIC);
END br_cell_1clk;

ARCHITECTURE behavioral OF br_cell_1clk IS
  SIGNAL temp,ff1 : STD_LOGIC;
BEGIN
  temp <= (shiftDR AND scan_in);

  dff : PROCESS (clockDR, reset_bar, temp)
  BEGIN
	IF (reset_bar ='0') THEN ff1 <='0';			--modif ligne rajoutee
    ELSIF (clockDR = '1') THEN ff1 <= temp; END IF;	--elsif au lieu de if
  END PROCESS dff;
  dbg_ff1 <= ff1; -- 20020620 ajoute pour verifier si ff1ne disparait pas

TDout: PROCESS (reset_bar, clockDR)
  BEGIN
	IF (reset_bar ='0') THEN scan_out <='0';			--modif ligne rajoutee
    ELSIF (clockDR'EVENT AND clockDR = '0') THEN
		IF (shiftDR='1') THEN
 		 scan_out <= scan_in;   -- sortie TDout sur front descendant
		END IF;
    END IF;					-- ?? est_ce qu'il manque le dernier
  END PROCESS TDout;		-- front descendant (lors de exit1_IR)

END behavioral;
