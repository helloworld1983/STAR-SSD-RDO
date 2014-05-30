--
-- File name    :  header_star_ssdU.vhd
-- Title        :  entete "package" VHDL pour les simulations du SSD Upgrade de STAR
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 15 decembre 2008 10:12
--              :
-- Comments     : 
--              : 
-- Assumptions  : none
-- Limitations  : none
-- Known Errors : none
-- Developers   : Christophe Renard
--              : 
-- Notes        :
-- ----------------------------------------------------------------------
-- Revision History :
-- ----------------------------------------------------------------------
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v0.1   | C.Renard | Creation      | 15 dec 2008
--     v0.1   | C.Renard | Modification  | 15 dec 2008| 
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- pour utiliser cet entete, inserer la ligne : use work.header_star_ssdU.all;

package header_star_ssdU is
CONSTANT K_sc_comm_bypass                : std_logic_vector(4 downto 0) :="11111"; -- (0x1f, data_w:  1 bits) commande jtag_sc identification
CONSTANT K_sc_comm_ssdU_bypass9          : std_logic_vector(57 downto 0) :="1111111111111111111111111111111111111111111111001000001000"; -- (0x1f, 9, data_r:9*1 bits) commande jtag_sc identification
CONSTANT K_sc_comm_ident                 : std_logic_vector(4 downto 0) :="11011"; -- (0x1b, data_r:  8 bits) commande jtag_sc identification
CONSTANT K_sc_comm_alice128_test_pattern : std_logic_vector(4 downto 0) :="10001"; -- (0x11, data_w:128 bits) commande jtag_sc alice128_test_pattern
CONSTANT K_sc_comm_costar_value          : std_logic_vector(4 downto 0) :="11000"; -- (0x18, data_w: 32 bits) commande jtag_sc alice128_test_value
CONSTANT K_sc_comm_version               : std_logic_vector(4 downto 0) :="01100"; -- (0x0c, data_r: 32 bits) commande jtag_sc version
CONSTANT K_sc_comm_config                : std_logic_vector(4 downto 0) :="00111"; -- (0x07, data_w: 16 bits) commande jtag_sc config
CONSTANT K_sc_comm_status                : std_logic_vector(4 downto 0) :="01010"; -- (0x0a, data_r:  6 bits) commande jtag_sc status
CONSTANT K_sc_comm_alice128_bias         : std_logic_vector(4 downto 0) :="01001"; -- (0x09, data_w: 56 bits) commande jtag_sc alice128_bias
CONSTANT K_sc_comm_alice128_test_value   : std_logic_vector(4 downto 0) :="01000"; -- (0x08, data_w:  8 bits) commande jtag_sc alice128_test_value
CONSTANT K_sc_comm_ladder_fpga_sc_roboclock_phase : std_logic_vector(4 downto 0) :="00001"; -- (0x01, data_rw:24 bits) commande jtag_sc ladder_fpga_sc_roboclock_phase
CONSTANT K_sc_long_bypass                : UNSIGNED(8 downto 0) :="000000001"; -- (data_w: 1 bits) commande jtag_sc identification
CONSTANT K_sc_long_ident                 : UNSIGNED(8 downto 0) :="000001000"; -- (data_r: 8 bits) commande jtag_sc identification
CONSTANT K_sc_long_version               : UNSIGNED(8 downto 0) :="000100000"; -- (data_r:32 bits) commande jtag_sc version
CONSTANT K_sc_long_config                : UNSIGNED(8 downto 0) :="000010000"; -- (data_w:16 bits) commande jtag_sc config
CONSTANT K_sc_long_status                : UNSIGNED(8 downto 0) :="000000110"; -- (data_r: 6 bits) commande jtag_sc status
CONSTANT K_sc_comm_idle                  : std_logic_vector(13 downto 0) :="HHHHHLLLLLLLLH"; -- (0x1f, data_rw:1 bit) commande jtag_sc idle
CONSTANT K_sc_comm_module_bypass6        : std_logic_vector(13 downto 0) :="HHHHHLLLLLLHHL"; -- (0x1f, data_rw:6 bit) commande jtag_sc idle
CONSTANT K_sc_comm_ident08               : std_logic_vector(13 downto 0) :="11011000000111"; -- (0x1b, data_r:8 bits) commande jtag_sc identification (0x1b, data_r:8 bits)
-- 45bit commande (9*5), 4bit nombre de composants (ladder_fpga or ladder_fpga + 6*alice128 + costar) et 9bit taille des donnees slow-control
CONSTANT K_sc_comm_module_ident56        : std_logic_vector(57 downto 0) :="ZZZZZZZZZZ110111101111011110111101111011110110111000110111"; -- (0x1b, 7, data_r:7*8 bits) commande jtag_sc identification
CONSTANT K_sc_comm_ssdU_ident64          : std_logic_vector(57 downto 0) :="ZZZZZ11011110111101111011110111101111011110111000000111111"; -- (0x1b, 8, data_r:8*8 bits) commande jtag_sc identification
CONSTANT K_sc_comm_ident72               : std_logic_vector(57 downto 0) :="1101111011110111101111011110111101111011110111001000100111"; -- (0x1b, 9, data_r:9*8 bits) commande jtag_sc identification
CONSTANT K_sc_comm_module_bypass337      : std_logic_vector(57 downto 0) :="ZZZZZZZZZZ110111101111011110111101111011HHHHH0111101010000"; -- (0x1b, 7, data_r:(6*56)+1 bits) commande jtag_sc bypass
CONSTANT K_sc_comm_ssdU_version32        : std_logic_vector(57 downto 0) :="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ011000001000011111"; -- (0x0c, 1, data_r:32 bits) commande jtag_sc version
CONSTANT K_sc_comm_ssdU_version39        : std_logic_vector(57 downto 0) :="ZZZZZ11111111111111111111111111111111111011001000000100110"; -- (0x0c, 8, data_r:32 bits) commande jtag_sc version
CONSTANT K_sc_comm_ssdU_status22         : std_logic_vector(57 downto 0) :="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ000100001000010101"; -- (0x02, 1, data_r:(1*22)) commande jtag_sc status
CONSTANT K_sc_comm_ssdU_config16         : std_logic_vector(57 downto 0) :="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ000110001000001111"; -- (0x03, 1, data_r:1*16 bits) commande jtag_sc config
CONSTANT K_sc_comm_ssdU_config23         : std_logic_vector(57 downto 0) :="ZZZZZ11111111111111111111111111111111111000111000000010110"; -- (0x03, 8, data_r:(1*16)+7 bits) commande jtag_sc config
CONSTANT K_sc_comm_ssdU_etat_alim16      : std_logic_vector(57 downto 0) :="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ001110001000001111"; -- (0x07, 1, data_r:1*16 bits) commande jtag_sc etat_alim
CONSTANT K_sc_comm_ssdU_etat_alim23      : std_logic_vector(57 downto 0) :="ZZZZZ11111111111111111111111111111111111001111000000010110"; -- (0x07, 8, data_r:(1*16)+7 bits) commande jtag_sc etat_alim
CONSTANT K_sc_comm_ssdU_rallumage16      : std_logic_vector(57 downto 0) :="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ010010001000001111"; -- (0x09, 1, data_r:1*16 bits) commande jtag_sc rallumage
CONSTANT K_sc_comm_ssdU_rallumage23      : std_logic_vector(57 downto 0) :="ZZZZZ11111111111111111111111111111111111010011000000010110"; -- (0x09, 8, data_r:(1*16)+7 bits) commande jtag_sc rallumage
CONSTANT K_sc_comm_status06              : std_logic_vector(13 downto 0) :="01001000000101"; -- (0x09, data_r: 6 bits) commande jtag_sc status
CONSTANT K_sc_comm_alice128_test_value49 : std_logic_vector(57 downto 0) :="ZZZZZZZZZZ010000100001000010000100001000111110111000110000"; -- (0x08, 7, data_r:6*8+1 bits) commande jtag_sc test_value
CONSTANT K_sc_comm_alice128_test_value50 : std_logic_vector(57 downto 0) :="ZZZZZ11111010000100001000010000100001000111110111000110001"; -- (0x08, 8, data_r:1+6*8+1 bits) commande jtag_sc test_value
CONSTANT K_sc_comm_high_z                : std_logic_vector(13 downto 0) :="ZZZZZZZZZZZZZZ"; -- () commande jtag_sc high-Z
CONSTANT K_sc_comm_high_zz               : std_logic_vector(57 downto 0) :="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"; -- () commande jtag_sc high-Z
CONSTANT K_sc_ident_ssd_rdo              : std_logic_vector(3 downto 0) :="0110";
CONSTANT K_sc_ident_ssd_rdoU             : std_logic_vector(3 downto 0) :="0111";
CONSTANT K_sc_ident_alice128             : std_logic_vector(3 downto 0) :="1000"; -- ATTENTION : pas de registre identite dans vrai alice128
CONSTANT K_sc_ident_ssd_connexion        : std_logic_vector(3 downto 0) :="1001";
CONSTANT K_sc_ident_ssd_costar           : std_logic_vector(3 downto 0) :="1010";
CONSTANT K_sc_ident_ssd_ladder_fpga      : std_logic_vector(3 downto 0) :="1011";
CONSTANT K_sc_reset_value_a_0 : STD_LOGIC := '0';
CONSTANT K_sc_reset_value_a_1 : STD_LOGIC := '1';
end package header_star_ssdU;
