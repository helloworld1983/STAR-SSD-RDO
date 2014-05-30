-------------------------------------------------------------------------
--
-- File name    :  ladder_fpga.vhd
-- Title        :  VHDL pour decrire le fonctionnement du FPGA en bout d'echelle du SSDUpgrade de STAR
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 03 fevrier 2009 10:50
--              :
-- Comments     : 
--              : 
-- Assumptions  : none
-- Limitations  : plenty
-- Known Errors : none
-- Developers   : Christophe Renard
--              : 
-- Notes        :
-- ----------------------------------------------------------------------
-- Revision History :
-- ----------------------------------------------------------------------
-- Version No:| Author   | Changes Made: | Mod. Date:
--     v0.1   | C.Renard | Creation      | 03 fev 2009
--     v0.1   | C.Renard | Modification  | 03 fev 2009| 
--     v0.2   | C.Renard | Modification  | 05 mar 2009| add I/O for ser, des, fiber and usb
--     v0.2   | C.Renard | Modification  | 06 mar 2009| add I/O for ser, des, fiber and usb
--     v0.2   | C.Renard | Modification  | 09 mar 2009| add I/O for hybrides
--     v0.2   | C.Renard | Modification  | 29 jun 2009| extracted signal names (ladder_addr(2 downto 0), tokenin_echelle, testin_echelle, holdin_echelle, ladder_fpga_sc_tck, ladder_fpga_sc_tms, ladder_fpga_sc_trstb, ladder_fpga_sc_tdi) from rdo_to_ladder
--     v0.3   | C.Renard | Modification  | 12 aou 2009| flux compactor and new data packer
--     v0.3   | C.Renard | Modification  | 13 aou 2009| flux compactor and new data packer
--     v0.3   | C.Renard | Modification  | 14 aou 2009| event controller
--     v0.3   | C.Renard | Modification  | 17 aou 2009| event controller
--     v0.3   | C.Renard | Modification  | 18 aou 2009| event controller
--     v0.3   | C.Renard | Modification  | 19 aou 2009| event controller
--     v0.3   | C.Renard | Modification  | 20 aou 2009| event controller (abort) and 0 or 1 hybrid in the JTAG line (tms and tck)
--     v0.3   | C.Renard | Modification  | 24 aou 2009| ladder_fpga_mux_datain and ladder_fpga_nbr_abort
--     v0.4   | C.Renard | Modification  | 24 aou 2009| ladder_fpga_usb_fifo
--     v0.4   | C.Renard | Modification  | 25 aou 2009| usb_present
--     v0.4   | C.Renard | Modification  | 26 aou 2009| suppressed st_ev_ctrl_test added 4MHz and 1MHz outputs to switchover
--     v0.4   | C.Renard | Modification  | 27 aou 2009| replaced addr_mux_h_neg and addr_mux_l_neg by level_shifter_mux( 1 downto 0)
-- ladder_fpga_v02
--     v0.5   | C.Renard | Modification  | 30 nov 2009| replaced level_shifter_mux by level_shifter_dac
--     v0.5   | C.Renard | Modification  | 01 dec 2009| replaced level_shifter_mux by level_shifter_dac
-- ladder_fpga_v03
--     v0.5   | C.Renard | Modification  |            | pin swap in quartus for pcb layout
-- ladder_fpga_v04
--     v0.5   | C.Renard | Modification  |            | pin swap in quartus for pcb layout
-- ladder_fpga_v05
--     v0.5   | C.Renard | Modification  |            | pin swap in quartus for pcb layout
-- ladder_fpga_v06
--     v0.6   | C.Renard | Modification  | 08 jan 2010| hv_side
--     v0.6   | C.Renard | Modification  | 10 mar 2010| modif origine hv_side
--     v0.6   | C.Renard | Modification  | 11 mar 2010| ajout CRC_ERROR
--     v0.6   | C.Renard | Modification  | 01 avr 2010| crc_error dans status et ajout debug_present_n, xtal_en, sc_serdes_ou_connec, fpga_serdes_ou_connec, spare_switch
-- ladder_fpga_v07
--     v0.7   | C.Renard | Modification  | 05 mai 2010| configuration par PS (Passive Serial)
--     v0.7   | C.Renard | Modification  | 26 jan 2011| included automatic time stamp generator developped by Micheal LeVine
--     v0.7   | C.Renard | Modification  | 26 jan 2011| connected usb debug fifos together
-- ladder_fpga_v08
--      16-jun-2011 mjl changed the sense of usb_write_n
--                      changed fifo to usb wrclk to not(80MHz)
--      17-jun-2011 mjl many mods to usb section following simulation
-- ----------------------------------------------------------------------
--      08-jul-2011 mjl cannibalized version for testing ADC function
--                      take command bytes from USB, convert one sample,
--                      send outputs to USB along with DAC register value and
--                      selector switch value (input from USB)
--      23-jul-2011 mjl change adc process and USB fifo to 40 MHz clock
--                      (was 80 MHz)
--                      n_preamble reaches 0,2,4,6,8 (status register!)
--                      removed usb_write_int assignment from clocked process
-- ----------------------------------------------------------------------
-- A_PREVOIR: Ce commentaire est place la ou il reste des modifications a faire
library ieee;
use     ieee.std_logic_1164.all;
Use     IEEE.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     work.all;
use work.header_star_ssdU.all;
Library synplify; -- 20090814 ajoute
Use     synplify.attributes.all; -- 20090814 ajoute
use work.date_stamp.all; -- 20110126 ajoute

entity ladder_fpga is
    port (    
	reset_n                   : IN    STD_LOGIC;
	card_ser_num              : IN    STD_LOGIC_VECTOR (5 DOWNTO 0); -- 20090309 ajoute
--	hv_side                   : IN    STD_LOGIC; -- 20100108 ajoute -- 20100310 enleve
	crc_error                 : INOUT STD_LOGIC; -- 20100311 ajoute
	-- CLOCKS --
	clock40mhz_fpga           : IN    STD_LOGIC;
	clock40mhz_xtal           : IN    STD_LOGIC; -- 20090812 ajoute
	clock80mhz_adc            :   OUT STD_LOGIC; -- 20090814 ajoute
	roboclock_horloge40_phase :   OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	roboclock_adc_phase       :   OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	-- ADC --
	adc_cs_n                  :   OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	data_serial               : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
	-- MULTIPLEXEURS --
	level_shifter_dac_ld_cs_n :   OUT STD_LOGIC; -- 20091130 ajoute
	level_shifter_dac_sdi     :   OUT STD_LOGIC; -- 20091130 ajoute
	level_shifter_dac_sck     :   OUT STD_LOGIC; -- 20091130 ajoute
	pilotage_magnd_hybride	  :   OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
	pilotage_mvdd_hybride	  :   OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
	-- DESERIALISEUR --
	des_lock                  : IN    STD_LOGIC;
--	rdo_to_ladder             : IN    STD_LOGIC_VECTOR (20 DOWNTO  0); -- 20090629 enleve
	rdo_to_ladder             : IN    STD_LOGIC_VECTOR (20 DOWNTO 10); -- 20090629 modifie
	ladder_addr               : IN    STD_LOGIC_VECTOR ( 2 DOWNTO  0); -- 20090629 modifie
	tokenin_echelle           : IN    STD_LOGIC; -- 20090629 modifie -- token injection for acquisition
	testin_echelle            : IN    STD_LOGIC; -- 20090629 modifie -- pulse test (calibration electronique du front-end)
	holdin_echelle            : IN    STD_LOGIC; -- 20090629 modifie -- fige (hold) les donnees du front-end
	ladder_fpga_sc_tck        : IN    STD_LOGIC; -- 20090629 modifie -- slow-control clock
	ladder_fpga_sc_tms        : IN    STD_LOGIC; -- 20090629 modifie
	ladder_fpga_sc_trstb      : IN    STD_LOGIC; -- 20090629 modifie
	ladder_fpga_sc_tdi        : IN    STD_LOGIC; -- 20090629 modifie
    des_bist_pass             : IN    STD_LOGIC; -- 20090305 ajoute
	-- SERIALISEUR --
	ladder_to_rdo             :   OUT STD_LOGIC_VECTOR (21 DOWNTO 0); -- 20090814 modifie
	ladder_fpga_sc_tdo        :   OUT STD_LOGIC; -- 20090629 ajoute -- 20090814 modifie
	-- FIBRE OPTIQUE --
    fibre_mod_absent          : IN    STD_LOGIC; -- 20090305 ajoute -- 20090818 modifie
    fibre_mod_scl             : INOUT STD_LOGIC; -- 20090305 ajoute
    fibre_mod_sda             : INOUT STD_LOGIC; -- 20090305 ajoute
    fibre_rx_loss             : IN    STD_LOGIC; -- 20090305 ajoute
    fibre_tx_disable          :   OUT STD_LOGIC; -- must be '0' -- 20090305 ajoute
    fibre_tx_fault            : IN    STD_LOGIC; -- 20090305 ajoute
	-- SECURITE ALICE128 (LATCHUP) --
	latchup_hybride           : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
	mux_ref_latchup           :   OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
	-- ACQUISITION --
	test_16hybrides           :   OUT STD_LOGIC;
	hold_16hybrides           :   OUT STD_LOGIC;
--	rclk_echelle			  : IN   STD_LOGIC; -- 20090309 ajoute -- 20090814 enleve
--	rclk_16hybrides			  :   OUT STD_LOGIC; -- 20090309 ajoute -- 20090814 enleve
	ladder_fpga_rclk_16hybrides :   OUT STD_LOGIC; -- 20090309 ajoute -- 20090814 modifie
	tokenin_hybride           :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090309 ajoute
	tokenout_hybride          : IN    STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090309 ajoute
	-- SLOW-CONTROL --
	temperature               : INOUT STD_LOGIC;
	sc_tck_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
	sc_tms_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
	sc_trstb_hybride          :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
	sc_tdi_hybride               :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
	sc_tdo_hybride               : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
	-- USB DEBUG --
    usb_data                  : INOUT STD_LOGIC_VECTOR(7 downto 0); -- 20090305 ajoute
    usb_present               : IN    STD_LOGIC; -- 20090825 ajoute
    usb_ready_n               : IN    STD_LOGIC; -- 20090305 ajoute
    usb_read_n                : OUT   STD_LOGIC; -- 20090305 ajoute
    usb_reset_n               : INOUT STD_LOGIC; -- ATTENTION : open-colector -- 20090305 ajoute
    usb_rx_empty              : IN    STD_LOGIC; -- 20090305 ajoute
    usb_tx_full               : IN    STD_LOGIC; -- 20090305 ajoute
    usb_write                 : OUT   STD_LOGIC; -- 16-jun-2011 mjl
    debug_present_n           : IN    STD_LOGIC; -- 20100401 ajoute
    xtal_en                   : IN    STD_LOGIC; -- 20100401 ajoute
    sc_serdes_ou_connec       : IN    STD_LOGIC; -- 20100401 ajoute
    fpga_serdes_ou_connec     : IN    STD_LOGIC; -- 20100401 ajoute
    spare_switch              : IN    STD_LOGIC; -- 20100401 ajoute
    -- DEBUG --
    dbg_ladder_fpga_adc_bit_count_cs_integer :  OUT STD_LOGIC_VECTOR(3 downto 0); -- 20090819 ajoute
	dbg_ladder_fpga_sc_bypass :   OUT STD_LOGIC -- doit etre modifiable par sc -- 20090629 ajoute
	);
end ladder_fpga;

ARCHITECTURE ladder_fpga_arch OF ladder_fpga IS

--  CONSTANT ladder_fpga_sc_reg_version : STD_LOGIC_VECTOR(31 downto 0) := x"05052010"; -- 20110126 enleve
  SIGNAL ladder_fpga_sc_reg_version : STD_LOGIC_VECTOR(31 downto 0); -- 20110126 enleve

  CONSTANT level_shifter_dac_b_code           : STD_LOGIC_VECTOR( 3 DOWNTO  0) := "1010"; -- 20091130 ajoute
  CONSTANT level_shifter_dac_a_code           : STD_LOGIC_VECTOR( 3 DOWNTO  0) := "1001"; -- 20091130 ajoute

-- define type for adc result array
  type bit_result is array (INTEGER range <>) of std_logic_vector(9 downto 0);
  signal adc_results : bit_result(0 to 15); -- 

  TYPE state_event_controller IS (st_ev_ctrl_wait4hold, st_ev_ctrl_wait4token, st_ev_ctrl_tokenin_pulse, st_ev_ctrl_acquisition, st_ev_ctrl_event_end, st_ev_ctrl_abort); -- 20090826 modifie
  SIGNAL ladder_fpga_event_controller_state : state_event_controller;
  attribute syn_encoding of ladder_fpga_event_controller_state : signal is "safe"; -- 20090814 ajoute

  TYPE state_level_shifter_dac IS (st_lev_shft_pre_cs, st_lev_shft_load_a, st_lev_shft_pulse_cs_H, st_lev_shft_pulse_cs_L, st_lev_shft_load_b, st_lev_shft_end, st_lev_shft_wait);-- 20091130 ajoute
  SIGNAL ladder_fpga_level_shifter_dac_state : state_level_shifter_dac; -- 20091130 ajoute
  attribute syn_encoding of ladder_fpga_level_shifter_dac_state : signal is "safe"; -- 20091130 ajoute
-- FSM to acquire one set of adc values:
  type acquire_state_type is (acq_idle,acq_wt_usb_in, acq_wt_cmd,acq_command_0,acq_command,acq_hold,acq_token,
                              acq_convert_1,acq_convert_2,acq_convert,acq_send_preamble,
                              acq_send_adcs_0,acq_send_adcs_1,acq_send_adcs_2,acq_send_adcs);
  signal acquire_state : acquire_state_type := acq_idle;

 -- local values for adc tests:
  signal tst_holdin_echelle, tst_tokenin_echelle : std_logic := '0'; 
  SIGNAL ladder_fpga_busy         : STD_LOGIC; -- 20090814 ajoute
  SIGNAL ladder_fpga_rclk_echelle : STD_LOGIC; -- 20090814 ajoute
  signal switch_val : std_logic_vector(7 downto 0);

  SIGNAL roboclock_horloge40_phase_in : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL roboclock_adc_phase_in       : STD_LOGIC_VECTOR (7 DOWNTO 0);

  SIGNAL ladder_fpga_clock1MHz   : STD_LOGIC; -- 20090826 ajoute
  SIGNAL ladder_fpga_clock4MHz   : STD_LOGIC; -- 20090826 ajoute
  SIGNAL ladder_fpga_clock40MHz  : STD_LOGIC;
  SIGNAL ladder_fpga_clock80MHz  : STD_LOGIC;
  SIGNAL pll_40MHz_switchover_locked : STD_LOGIC; -- 20090812 modifie
  SIGNAL ladder_fpga_switchover_rst  : STD_LOGIC; -- 20090813 ajoute
  SIGNAL ladder_fpga_switchover_xtal_sel : STD_LOGIC; -- 20090813 ajoute
  SIGNAL clock40mhz_fpga_bad         : STD_LOGIC; -- 20090813 ajoute
  SIGNAL clock40mhz_xtal_bad         : STD_LOGIC; -- 20090813 ajoute
  SIGNAL ladder_fpga_activeclock     : STD_LOGIC; -- 20090813 ajoute
  ------------------------------------------------------------------------------------
  component mega_func_pll_40MHz_switchover_cycloneIII -- 20090812 ajoute
    PORT ( -- 20090812 ajoute
      areset		: IN STD_LOGIC  := '0'; -- 20090812 ajoute
      clkswitch		: IN STD_LOGIC  := '0'; -- 20090812 ajoute
      inclk0		: IN STD_LOGIC  := '0'; -- 20090812 ajoute
      inclk1		: IN STD_LOGIC  := '0'; -- 20090812 ajoute
      activeclock		: OUT STD_LOGIC ; -- 20090812 ajoute
      c0			: OUT STD_LOGIC ; -- 20090812 ajoute
      c1			: OUT STD_LOGIC ; -- 20090812 ajoute
      c2			: OUT STD_LOGIC ; -- 20090826 ajoute
      c3			: OUT STD_LOGIC ; -- 20090826 ajoute
      clkbad0		: OUT STD_LOGIC ; -- 20090812 ajoute
      clkbad1		: OUT STD_LOGIC ; -- 20090812 ajoute
      locked		: OUT STD_LOGIC  -- 20090812 ajoute
      ); -- 20090812 ajoute
  end component; -- mega_func_pll_40MHz_switchover_cycloneIII -- 20090812 ajoute
  ------------------------------------------------------------------------------------

  SIGNAL crc_error_regout          : STD_LOGIC; -- 20100311 ajoute
  ------------------------------------------------------------------------------------
  component cycloneiii_crcblock -- 20100311 ajoute
    generic ( -- 20100311 ajoute
--	lpm_hint	:	string := "UNUSED"; -- 20100311 ajoute
      lpm_type	:	string := "cycloneiii_crcblock"; -- 20100311 ajoute
      oscillator_divider	:	natural := 1	); -- 20100311 ajoute
    port( -- 20100311 ajoute
      clk	:	in std_logic := '0'; -- 20100311 ajoute
      crcerror	:	out std_logic; -- 20100311 ajoute
      ldsrc	:	in std_logic := '0'; -- 20100311 ajoute
      regout	:	out std_logic; -- 20100311 ajoute
      shiftnld	:	in std_logic := '0' -- 20100311 ajoute
      ); -- 20100311 ajoute
  end component; -- comp_cycloneiii_crcblock -- 20100311 ajoute
  ------------------------------------------------------------------------------------




  -- declarations slow-control
  SIGNAL ladder_fpga_sc_ir_data_out      : STD_LOGIC_VECTOR (4 DOWNTO 0);
  SIGNAL ladder_fpga_sc_reset_bar, ladder_fpga_sc_enable    : STD_LOGIC;
  SIGNAL ladder_fpga_sc_shiftIR, ladder_fpga_sc_clockIR, ladder_fpga_sc_updateIR : STD_LOGIC;
  SIGNAL ladder_fpga_sc_shiftDR, ladder_fpga_sc_clockDR, ladder_fpga_sc_updateDR : std_logic;
  SIGNAL ladder_fpga_sc_updateDR_roboclock_phase : STD_LOGIC; -- 20090306 ajoute
  SIGNAL ladder_fpga_sc_scan_in, ladder_fpga_sc_ir_scan_out, ladder_fpga_sc_dr_scan_out, ladder_fpga_sc_scan_out : STD_LOGIC;
  SIGNAL ladder_fpga_sc_version_scan_out, ladder_fpga_sc_br_scan_out, ladder_fpga_sc_ident_scan_out : STD_LOGIC;
  SIGNAL ladder_fpga_sc_roboclock_phase_scan_out : STD_LOGIC; -- 20090306 ajoute
  SIGNAL ladder_fpga_sc_bypass               : STD_LOGIC; -- doit etre modifiable par sc
  SIGNAL ladder_fpga_sc_reg_identite         : STD_LOGIC_VECTOR( 7 downto 0);
  SIGNAL dbg_ladder_fpga_etat_present        : STD_LOGIC_VECTOR(15 downto 0);
  SIGNAL ladder_fpga_sc_nc_reg_identite      : STD_LOGIC_VECTOR( 7 downto 0); -- trou sans fond (comme si c'etait pas connecte)
  SIGNAL ladder_fpga_sc_nc_reg_version       : STD_LOGIC_VECTOR(31 downto 0); -- trou sans fond (comme si c'etait pas connecte)
  SIGNAL ladder_fpga_sc_updateDR_null        : STD_LOGIC_VECTOR(31 downto 0);
  SIGNAL ladder_fpga_sc_roboclock_phase      : STD_LOGIC_VECTOR(23 DOWNTO 0); -- 20090306 ajoute
--  SIGNAL ladder_addr : STD_LOGIC_VECTOR(2 downto 0); -- 20090629 enleve
  SIGNAL ladder_fpga_sc_dr_rallumage, ladder_fpga_sc_dr_extinction, ladder_fpga_sc_dr_bypass_hybride : STD_LOGIC_VECTOR (15 downto 0); -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_dr_mux_ref_latchup   : STD_LOGIC_VECTOR ( 1 downto 0); -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_dr_temperature       : STD_LOGIC_VECTOR (47 downto 0); -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_mux_ref_latchup_scan_out, ladder_fpga_sc_etat_alims_scan_out : STD_LOGIC; -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_rallumage_scan_out, ladder_fpga_sc_bypass_hybride_scan_out, ladder_fpga_sc_temperature_scan_out : STD_LOGIC; -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_updateDR_mux_ref_latchup : STD_LOGIC; -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_updateDR_rallumage, ladder_fpga_sc_updateDR_bypass_hybride : STD_LOGIC; -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_nc_etat_alims        : STD_LOGIC_VECTOR(15 downto 0); -- trou sans fond (comme si c'etait pas connecte) -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_nc_temperature       : STD_LOGIC_VECTOR(47 downto 0); -- trou sans fond (comme si c'etait pas connecte) -- 20090310 ajoute
  SIGNAL ladder_fpga_sc_reg_etat             : STD_LOGIC_VECTOR(21 downto 0); -- 20090316 ajoute
  SIGNAL ladder_fpga_sc_etat_scan_out        : STD_LOGIC; -- 20090316 ajoute
  SIGNAL ladder_fpga_sc_nc_reg_etat          : STD_LOGIC_VECTOR(21 downto 0); -- trou sans fond (comme si c'etait pas connecte) -- 20090316 ajoute
  SIGNAL ladder_fpga_sc_updateDR_config      : STD_LOGIC; -- 20090316 ajoute
  SIGNAL ladder_fpga_sc_config_scan_out      : STD_LOGIC; -- 20090316 ajoute
  SIGNAL ladder_fpga_sc_config               : STD_LOGIC_VECTOR(15 DOWNTO 0); -- 20090316 ajoute
  SIGNAL tokenin_pulse_ok                    : STD_LOGIC; -- 20090819 ajoute
  SIGNAL tokenin_pulse_duration              : UNSIGNED(3 DOWNTO 0); -- 20090819 ajoute
  SIGNAL ladder_fpga_abort                   : STD_LOGIC; -- 20090824 ajoute
  SIGNAL level_shifter_dac_load              : STD_LOGIC; -- 20091130 ajoute
  SIGNAL level_shifter_dac_b                 : STD_LOGIC_VECTOR(15 DOWNTO  0); -- 20091130 ajoute -- 20091201 modifie
  SIGNAL level_shifter_dac_a                 : STD_LOGIC_VECTOR(15 DOWNTO  0); -- 20091130 ajoute -- 20091201 modifie
  SIGNAL ladder_fpga_sc_level_shifter_dac    : STD_LOGIC_VECTOR(19 DOWNTO  0); -- 20091130 ajoute
  CONSTANT ladder_fpga_sc_level_shifter_dac_init : STD_LOGIC_VECTOR(19 DOWNTO  0):="10101010100101010101"; -- mid value on A and B -- 20091130 ajoute
  SIGNAL ladder_fpga_sc_updateDR_level_shifter_dac : STD_LOGIC; -- 20091130 ajoute
  SIGNAL ladder_fpga_sc_level_shifter_dac_scan_out : STD_LOGIC; -- 20091130 ajoute
  SIGNAL level_shifter_dac_load_indice       : INTEGER RANGE 0 TO 15; -- 20091130 ajoute -- 20091201 modifie
  SIGNAL level_shifter_dac_sck_en            : STD_LOGIC; -- 20091130 ajoute
  SIGNAL hv_side                             : STD_LOGIC; -- 20100310 ajoute

  ------------------------------------------------------------------------------------
COMPONENT tap_control 
  PORT 
    (tms, tck, trstb			: IN  STD_LOGIC;
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
     dbg_etat_present			: out STD_LOGIC_VECTOR (15 downto 0);
     Instruction_Register			: IN  STD_LOGIC_VECTOR (4 downto 0) );
END COMPONENT; --tap_control
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT ir_5_bits
  PORT (
    reset_bar :  IN STD_LOGIC;
    data_in :  IN STD_LOGIC_VECTOR (4 downto 0);
    clockIR,shiftIR, updateIR, scan_in :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR (4 downto 0));
END COMPONENT; --ir_5_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT br_cell_1clk
  PORT (
    reset_bar  :  IN STD_LOGIC;
    clockDR, shiftDR, scan_in  :  IN STD_LOGIC;
    dbg_ff1 : OUT STD_LOGIC; -- pour verifier si ff1 ne disparait pas
    scan_out : OUT STD_LOGIC);
END COMPONENT; --br_cell_1clk
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT identificateur_8bits
  PORT (
    reset_bar,  reset_value :  IN STD_LOGIC;
    data_in :  IN STD_LOGIC_VECTOR(7 downto 0);
    clockDR, shiftDR, updateDR, scan_in :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT dr_x_bits
  GENERIC(taille : integer:=  16);
  PORT (
    reset_bar, reset_value  :  IN STD_LOGIC;
    data_in  :  IN STD_LOGIC_VECTOR((taille-1) downto 0);
    clockDR, shiftDR,  updateDR, scan_in  :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR((taille-1) downto 0));
END COMPONENT;

------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT dr_x_bits_init
  GENERIC(taille : integer:=  160);
  PORT (
    reset_bar :  IN STD_LOGIC;
    reset_values :  IN STD_LOGIC_VECTOR((taille-1) downto 0);
    data_in :  IN STD_LOGIC_VECTOR((taille-1) downto 0);
    clockDR, shiftDR,  updateDR,  scan_in :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR((taille-1) downto 0));
END COMPONENT;

------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT dr_x_bits_avec_pulse
  GENERIC(taille : integer:=  16);
  PORT (
    reset_bar,  reset_value : IN    STD_LOGIC;
    data_in  : IN    STD_LOGIC_VECTOR((taille-1) downto 0);
    clockDR, shiftDR,  updateDR, scan_in  : IN    STD_LOGIC;
    scan_out :   OUT STD_LOGIC;
    data_out :   OUT STD_LOGIC_VECTOR((taille-1) downto 0);
    pulse_out :   OUT STD_LOGIC_VECTOR((taille-1) downto 0));
END COMPONENT;

------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT dr_cell
  PORT (
    reset_bar,  reset_value :  IN STD_LOGIC;
    data_in  :  IN STD_LOGIC;
    clockDR, shiftDR, updateDR, scan_in  :  IN STD_LOGIC;
    scan_out : OUT STD_LOGIC;
    data_out : OUT STD_LOGIC); --dr_cell
END COMPONENT;
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
COMPONENT mux_tdo	-- multiplexeur des données JTAG:
  PORT (
    entree_0x00, entree_0x01, entree_0x02, entree_0x03, entree_0x04, entree_0x05, entree_0x06, entree_0x07,
    entree_0x08, entree_0x09, entree_0x0a, entree_0x0b, entree_0x0c, entree_0x0d, entree_0x0e, entree_0x0f,
    entree_0x10, entree_0x11, entree_0x12, entree_0x13, entree_0x14, entree_0x15, entree_0x16, entree_0x17,
    entree_0x18, entree_0x19, entree_0x1a, entree_0x1b, entree_0x1c, entree_0x1d, entree_0x1e,
    entree_bypass : IN STD_LOGIC;	-- registre bypass JTAG IEEE 1149.1
    ir_data_out   : IN STD_LOGIC_VECTOR (4 DOWNTO 0); --registre instruction
    dr_scan_out   : OUT STD_LOGIC);	-- registre data JTAG sélectionné.
END COMPONENT; --mux_tdo
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
component shiftreg
  port (
    clock	: IN STD_LOGIC ;
    enable	: IN STD_LOGIC ;
    shiftin	: IN STD_LOGIC ;
    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
    );
end component;
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
  COMPONENT mux_2_1    PORT (a, b, g1 : IN STD_LOGIC; z : OUT STD_LOGIC);
  END COMPONENT; --mux_2_1
------------------------------------------------------------------------------------


  SIGNAL etat_alims_hybride		: STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
  SIGNAL rallumage_hybride		: STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
  SIGNAL extinction_hybride		: STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
  SIGNAL bypass_hybride			: STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
  SIGNAL latchup_memorise		: STD_LOGIC; -- 20090309 ajoute
  SIGNAL latchup_readout        : STD_LOGIC; -- 20090309 ajoute
  SIGNAL tokenout_memorise		: STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
  SIGNAL tst_gestion_hybrides	: STD_LOGIC_VECTOR(15 downto 0); -- 20090309 ajoute
  SIGNAL num_hybride_dans_jtag  : STD_LOGIC_VECTOR(3 downto 0); -- 20090629 ajoute
  SIGNAL jtag_avec_hybride      : STD_LOGIC; -- 20090629 ajoute
  SIGNAL tokenin_echelle_in     : STD_LOGIC; -- 20090821 ajoute
------------------------------------------------------------------------------------
  COMPONENT gestion_hybrides_v4 -- 20090309 ajoute
    PORT (
      surcourant		:  IN STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      latchup_memoire		: OUT STD_LOGIC; -- 20090309 ajoute
      latchup_pulse		: OUT STD_LOGIC; -- 20090309 ajoute

      pilotage			: OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      tck			:  IN STD_LOGIC; -- 20090309 ajoute
      
      extinction		:  IN STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      rallumage			:  IN STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      bypass_hybride		:  IN STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute

      tokenin_echelle		:  IN STD_LOGIC; -- 20090309 ajoute
      tokenin			: OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute -- 20090818 enleve -- 20090821 remis
      tokenout			:  IN STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      tokenout_memoire	        : OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute

      tdi_echelle		:  IN STD_LOGIC; -- 20090309 ajoute
      tdi			: OUT STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      tdo			:  IN STD_LOGIC_VECTOR (15 downto 0); -- 20090309 ajoute
      tdo_echelle		: OUT STD_LOGIC; -- 20090309 ajoute
      num_hybride_dans_jtag     : IN STD_LOGIC_VECTOR(3 downto 0); -- 20090629 ajoute
      jtag_avec_hybride         : IN STD_LOGIC; -- 20090629 ajoute
      ladder_fpga_sc_tms        : IN    STD_LOGIC; -- 20090820 ajoute
      sc_tck_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090820 ajoute
      sc_tms_hybride            :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 20090820 ajoute

      tst_gestion_hybrides      :OUT STD_LOGIC_VECTOR (15 downto 0)
      );  -- gestion_hybrides_v4 -- 20090309 ajoute
  END COMPONENT; --gestion_hybrides_v4 -- 20090309 ajoute
------------------------------------------------------------------------------------

SIGNAL end_of_temp_conv : STD_LOGIC; -- etat de la conversion de temperature -- 20090316 ajoute
------------------------------------------------------------------------------------
  COMPONENT mesure_temperature -- 20090312 ajoute
	PORT -- 20090312 ajoute
    ( -- 20090312 ajoute
	reset_sys		: IN    STD_LOGIC; -- reset (utilise le trstb) -- 20090312 ajoute
	clock4mhz_fpga		: IN    STD_LOGIC; -- oscillateur a 4 MHz -- 20090312 ajoute -- 20090826 modifie

	temperature_in		: IN    STD_LOGIC; -- bus 1-wire en entree -- 20090312 ajoute
	temperature_out		: OUT STD_LOGIC; -- bus 1-wire en sortie -- 20090312 ajoute

	end_of_temp_conv	: OUT STD_LOGIC; -- registre JTAG en sortie pour status -- 20090312 ajoute
	temperature_value	: OUT STD_LOGIC_VECTOR(47 downto 0) -- registre JTAG des valeurs de temperatures (4 valeurs codees sur 12 bits) -- 20090312 ajoute
	);
  END COMPONENT; --mesure_temperature -- 20090312 ajoute

--signal ladder_fpga_nbr_rclk_echelle : integer range 0 to 1023; -- 20090817 ajoute -- 20090819 enleve
signal ladder_fpga_nbr_rclk_echelle : integer range 0 to 16383; -- 20090817 ajoute -- 20090819 modifie

SIGNAL ladder_fpga_flux_compactor_status : std_logic_vector( 4 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_data_packer_0_word    : std_logic_vector(15 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_data_packer_1_word    : std_logic_vector(15 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_data_packer_2_word    : std_logic_vector(15 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_data_packer_3_word    : std_logic_vector(15 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_data_packer_4_word    : std_logic_vector(15 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_fifo21_wr             : std_logic; -- 20090812 ajoute
SIGNAL ladder_fpga_fifo21_input          : std_logic_vector(20 downto 0); -- 20090812 ajoute
SIGNAL ladder_fpga_fifo_reset          : std_logic; -- 20090813 ajoute
SIGNAL ladder_fpga_fifo21_rd             : std_logic; -- 20090813 ajoute
SIGNAL ladder_fpga_fifo21_full             : std_logic; -- 20090813 ajoute
SIGNAL ladder_fpga_fifo21_empty             : std_logic; -- 20090813 ajoute

signal ladder_fpga_packer_dataout : std_logic_vector(20 downto 0); -- 20090813 modifie
signal ladder_fpga_packer_dataready       : std_logic;
signal ladder_fpga_adc_bit_count_cs_integer : integer range 0 to 15;
signal ladder_fpga_adc_select_n : std_logic;
------------------------------------------------------------------------------------
  component mega_func_fifo21x32_cycloneIII -- 20090813 ajoute
    PORT -- 20090813 ajoute
      ( -- 20090813 ajoute
        aclr		: IN STD_LOGIC  := '0'; -- 20090813 ajoute
        data		: IN STD_LOGIC_VECTOR (20 DOWNTO 0); -- 20090813 ajoute
        rdclk		: IN STD_LOGIC ; -- 20090813 ajoute
        rdreq		: IN STD_LOGIC ; -- 20090813 ajoute
        wrclk		: IN STD_LOGIC ; -- 20090813 ajoute
        wrreq		: IN STD_LOGIC ; -- 20090813 ajoute
        q		: OUT STD_LOGIC_VECTOR (20 DOWNTO 0); -- 20090813 ajoute
        rdempty		: OUT STD_LOGIC ; -- 20090813 ajoute
        wrfull		: OUT STD_LOGIC  -- 20090813 ajoute
	); -- 20090813 ajoute
  END component; --mega_func_fifo21x32_cycloneIII -- 20090813 ajoute
------------------------------------------------------------------------------------


SIGNAL ladder_fpga_fifo8_usb_clock       : std_logic; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_to_usb_input    : STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_to_usb_wr       : STD_LOGIC; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_to_usb_wr_d       : STD_LOGIC; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_to_usb_wr_dd       : STD_LOGIC; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_to_usb_empty    : STD_LOGIC; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_to_usb_full     : STD_LOGIC;  -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_from_usb_rd     : STD_LOGIC; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_from_usb_output : STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_from_usb_empty  : STD_LOGIC; -- 20090824 ajoute
SIGNAL ladder_fpga_fifo8_from_usb_full   : STD_LOGIC;  -- 20090824 ajoute
signal usb_read_n_in            :   STD_LOGIC; -- 20110125 ajoute
signal usb_write_n_in           :   STD_LOGIC; -- 20110125 ajoute
signal usb_tx_data              : STD_LOGIC_VECTOR(7 downto 0); -- 20110128 ajoute
signal usb_write_int            : std_logic;

------------------------------------------------------------------------------------
  component mega_func_fifo8x256_cycloneIII IS -- 20090824 ajoute
    PORT -- 20090824 ajoute
      ( -- 20090824 ajoute
        aclr		: IN STD_LOGIC  := '0'; -- 20090824 ajoute
        data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
        rdclk		: IN STD_LOGIC ; -- 20090824 ajoute
        rdreq		: IN STD_LOGIC ; -- 20090824 ajoute
        wrclk		: IN STD_LOGIC ; -- 20090824 ajoute
        wrreq		: IN STD_LOGIC ; -- 20090824 ajoute
        q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
        rdempty		: OUT STD_LOGIC ; -- 20090824 ajoute
        wrfull		: OUT STD_LOGIC  -- 20090824 ajoute
	); -- 20090824 ajoute
  END component; -- mega_func_fifo8x256_cycloneIII; -- 20090824 ajoute
------------------------------------------------------------------------------------

 SIGNAL ladder_fpga_mux_dataout              : STD_LOGIC_VECTOR(21 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_mux_datain               : STD_LOGIC_VECTOR(21 DOWNTO  0); -- 20090824 ajoute
 SIGNAL ladder_fpga_mux_status_count_integer : integer range 0 to 7; -- 20090817 ajoute
 SIGNAL ladder_fpga_mux_statusout            : STD_LOGIC_VECTOR(20 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_mux_statusin             : STD_LOGIC_VECTOR(20 DOWNTO  0); -- 20090824 ajoute
 SIGNAL ladder_fpga_status_h_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_g_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_f_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_e_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_d_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_c_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_b_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_status_a_out             : STD_LOGIC_VECTOR(17 DOWNTO  0); -- 20090817 ajoute

 SIGNAL ladder_fpga_nbr_hold                 : UNSIGNED(11 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_nbr_test                 : UNSIGNED(11 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_nbr_token                : UNSIGNED(11 DOWNTO  0); -- 20090817 ajoute
 SIGNAL ladder_fpga_nbr_abort                : UNSIGNED(11 DOWNTO  0); -- 20090824 ajoute
 SIGNAL ladder_fpga_ok                       : STD_LOGIC; -- 20090817 ajoute
 SIGNAL tst_tokenin_pulse_ok                 : STD_LOGIC; -- 20090819 ajoute

  
-- signal adc_val_0,adc_val_1,adc_val_2,adc_val_3,adc_val_4,adc_val_5,adc_val_6,adc_val_7 : std_logic_vector(9 downto 0);
-- signal adc_val_8,adc_val_9,adc_val_10,adc_val_11,adc_val_12,adc_val_13,adc_val_14,adc_val_15 : std_logic_vector(9 downto 0);

BEGIN

  tst_tokenin_pulse_ok  <= '1';         -- for single ADC test only

  ladder_fpga_sc_reg_version  <= revision_date; -- date derniere modif (jjmmaaaa) -- 20110126 modifie


  comp_mega_func_pll_40MHz_switchover_cycloneIII : mega_func_pll_40MHz_switchover_cycloneIII -- 20090812 ajoute
    PORT MAP ( -- 20090812 ajoute
      areset	        => ladder_fpga_switchover_rst, -- 20090812 ajoute
      clkswitch	        => ladder_fpga_switchover_xtal_sel, -- 20090812 ajoute
      inclk0	        => clock40mhz_fpga, -- 20090812 ajoute
      inclk1	        => clock40mhz_xtal, -- 20090812 ajoute
      activeclock	=> ladder_fpga_activeclock, -- 20090812 ajoute
      c0		=> ladder_fpga_clock40MHz, -- 20090812 ajoute
      c1		=> ladder_fpga_clock80MHz, -- 20090812 ajoute
      c2		=> ladder_fpga_clock4MHz, -- 20090826 ajoute
      c3		=> ladder_fpga_clock1MHz, -- 20090826 ajoute
      clkbad0	        => clock40mhz_fpga_bad, -- 20090812 ajoute
      clkbad1	        => clock40mhz_xtal_bad, -- 20090812 ajoute
      locked	        => pll_40MHz_switchover_locked -- 20090812 ajoute
      ); -- comp_mega_func_pll_40MHz_switchover_cycloneIII -- 20090812 ajoute
  ------------------------------------------------------------------------------------


  ------------------------------------------------------------------------------------
  comp_cycloneiii_crcblock : cycloneiii_crcblock -- 20100311 ajoute
    generic map ( -- 20100311 ajoute
      lpm_type	=> "cycloneiii_crcblock", -- 20100311 ajoute
      oscillator_divider	=> 1	) -- 20100311 ajoute
    port map( -- 20100311 ajoute
      clk	=> ladder_fpga_clock40MHz, -- 20100311 ajoute
      crcerror	=> crc_error, -- 20100311 ajoute
      ldsrc	=> '1', -- 20100311 ajoute
      regout	=> crc_error_regout, -- 20100311 ajoute
      shiftnld	=> '0' -- 20100311 ajoute
      ); -- comp_cycloneiii_crcblock -- 20100311 ajoute
  ------------------------------------------------------------------------------------




ladder_fpga_sc_updateDR_null <= (OTHERS=>'L');
ladder_fpga_sc_updateDR      <= (ladder_fpga_sc_updateDR_null( 0)) OR
                    (ladder_fpga_sc_updateDR_null( 1)) OR
                    (ladder_fpga_sc_updateDR_null( 2)) OR
                    (ladder_fpga_sc_updateDR_null( 3)) OR
                    (ladder_fpga_sc_updateDR_null( 4)) OR
                    (ladder_fpga_sc_updateDR_null( 5)) OR
                    (ladder_fpga_sc_updateDR_null( 6)) OR
                    (ladder_fpga_sc_updateDR_null( 7)) OR
                    (ladder_fpga_sc_updateDR_null( 8)) OR
                    (ladder_fpga_sc_updateDR_null( 9)) OR
                    (ladder_fpga_sc_updateDR_null(10)) OR
                    (ladder_fpga_sc_updateDR_null(11)) OR
                    (ladder_fpga_sc_updateDR_null(12)) OR
                    (ladder_fpga_sc_updateDR_null(13)) OR
                    (ladder_fpga_sc_updateDR_null(14)) OR
                    (ladder_fpga_sc_updateDR_null(15)) OR
                    (ladder_fpga_sc_updateDR_null(16)) OR
                    (ladder_fpga_sc_updateDR_null(17)) OR
                    (ladder_fpga_sc_updateDR_null(18)) OR
                    (ladder_fpga_sc_updateDR_null(19)) OR
                    (ladder_fpga_sc_updateDR_null(20)) OR
                    (ladder_fpga_sc_updateDR_null(21)) OR
                    (ladder_fpga_sc_updateDR_null(22)) OR
                    (ladder_fpga_sc_updateDR_null(23)) OR
                    (ladder_fpga_sc_updateDR_null(24)) OR
                    (ladder_fpga_sc_updateDR_null(25)) OR
                    (ladder_fpga_sc_updateDR_null(26)) OR
                    (ladder_fpga_sc_updateDR_null(27)) OR
                    (ladder_fpga_sc_updateDR_null(28)) OR
                    (ladder_fpga_sc_updateDR_null(29)) OR
                    (ladder_fpga_sc_updateDR_null(30)) OR
                    (ladder_fpga_sc_updateDR_null(31));

  COMP_ladder_fpga_SC_TAP_CONTROL  : tap_control
    PORT MAP (
      tms			=> ladder_fpga_sc_tms,
      tck			=> ladder_fpga_sc_tck,
      trstb			=> ladder_fpga_sc_trstb,
      reset_bar			=> ladder_fpga_sc_reset_bar,
      enable			=> ladder_fpga_sc_enable,
      shiftIR			=> ladder_fpga_sc_shiftIR,
      clockIR			=> ladder_fpga_sc_clockIR,
      updateIR			=> ladder_fpga_sc_updateIR,
      shiftDR			=> ladder_fpga_sc_shiftDR,
      clockDR			=> ladder_fpga_sc_clockDR,
      sc_updateDR_0x00		=> ladder_fpga_sc_updateDR_null(00), 
      sc_updateDR_0x01		=> ladder_fpga_sc_updateDR_roboclock_phase, 
      sc_updateDR_0x02		=> ladder_fpga_sc_updateDR_null(02), 
      sc_updateDR_0x03		=> ladder_fpga_sc_updateDR_config, 
      sc_updateDR_0x04		=> ladder_fpga_sc_updateDR_level_shifter_dac, 
      sc_updateDR_0x05		=> ladder_fpga_sc_updateDR_null(05), 
      sc_updateDR_0x06		=> ladder_fpga_sc_updateDR_null(06), 
      sc_updateDR_0x07		=> ladder_fpga_sc_updateDR_null(07), 
      sc_updateDR_0x08		=> ladder_fpga_sc_updateDR_mux_ref_latchup, 
      sc_updateDR_0x09		=> ladder_fpga_sc_updateDR_rallumage, 
      sc_updateDR_0x0a		=> ladder_fpga_sc_updateDR_null(10), 
      sc_updateDR_0x0b		=> ladder_fpga_sc_updateDR_bypass_hybride, 
      sc_updateDR_0x0c		=> ladder_fpga_sc_updateDR_null(12), 
      sc_updateDR_0x0d		=> ladder_fpga_sc_updateDR_null(13), 
      sc_updateDR_0x0e		=> ladder_fpga_sc_updateDR_null(14), 
      sc_updateDR_0x0f		=> ladder_fpga_sc_updateDR_null(15), 
      sc_updateDR_0x10		=> ladder_fpga_sc_updateDR_null(16), 
      sc_updateDR_0x11		=> ladder_fpga_sc_updateDR_null(17), 
      sc_updateDR_0x12		=> ladder_fpga_sc_updateDR_null(18), 
      sc_updateDR_0x13		=> ladder_fpga_sc_updateDR_null(19), 
      sc_updateDR_0x14		=> ladder_fpga_sc_updateDR_null(20), 
      sc_updateDR_0x15		=> ladder_fpga_sc_updateDR_null(21), 
      sc_updateDR_0x16		=> ladder_fpga_sc_updateDR_null(22), 
      sc_updateDR_0x17		=> ladder_fpga_sc_updateDR_null(23), 
      sc_updateDR_0x18		=> ladder_fpga_sc_updateDR_null(24), 
      sc_updateDR_0x19		=> ladder_fpga_sc_updateDR_null(25), 
      sc_updateDR_0x1a		=> ladder_fpga_sc_updateDR_null(26), 
      sc_updateDR_0x1b		=> ladder_fpga_sc_updateDR_null(27), 
      sc_updateDR_0x1c		=> ladder_fpga_sc_updateDR_null(28), 
      sc_updateDR_0x1d		=> ladder_fpga_sc_updateDR_null(29), 
      sc_updateDR_0x1e		=> ladder_fpga_sc_updateDR_null(30), 
      sc_updateDR_bypass	=> ladder_fpga_sc_updateDR_null(31),
      dbg_etat_present		=> dbg_ladder_fpga_etat_present,
      Instruction_Register	=> ladder_fpga_sc_ir_data_out
      ); --tap_control

------------------------------------------------------------------------------------
--registre d'instruction -- au reset les cellules sont forcées a 1 pour valider le mode data en bypass.
  COM_LADDER_SC_INSTRUC_REG  : ir_5_bits
    PORT MAP (
      reset_bar	=> ladder_fpga_sc_reset_bar,
      data_in	=> K_sc_comm_bypass,
      clockIR	=> ladder_fpga_sc_clockIR,
      shiftIR	=> ladder_fpga_sc_shiftIR,
      updateIR	=> ladder_fpga_sc_updateIR,
      scan_in	=> ladder_fpga_sc_scan_in,
      scan_out	=> ladder_fpga_sc_ir_scan_out,
      data_out	=> ladder_fpga_sc_ir_data_out
      ); --ir_5_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--bypass register (JTAG) -- au reset la cellule est forcée a 0
  COMP_ladder_fpga_SC_BYPASS_REG  :dr_cell
--  COMP_ladder_fpga_SC_BYPASS_REG  :br_cell_1clk
    PORT MAP(
      reset_bar	        => ladder_fpga_sc_reset_bar,
      reset_value 	=> '0',		-- seulement si dr_cell
      data_in		=> ladder_fpga_sc_bypass,	-- seulement si dr_cell
      clockDR		=> ladder_fpga_sc_clockDR,
      shiftDR		=> ladder_fpga_sc_shiftDR,
      updateDR	        => ladder_fpga_sc_updateDR,	-- seulement si dr_cell
      scan_in		=> ladder_fpga_sc_scan_in,
--	dbg_ff1		=> ladder_fpga_sc_bypass,	-- seulement si br_cell_1clk
      scan_out	        => ladder_fpga_sc_br_scan_out,
      data_out	        => ladder_fpga_sc_bypass	-- seulement si dr_cell
      ); --dr_cell
--	); --br_cell_1clk
------------------------------------------------------------------------------------

  ladder_fpga_sc_reg_identite(7 downto 4) <= K_sc_ident_ssd_ladder_fpga; -- (carte connexion="1001", carte readout="0110", costar="1010", alice128="????" )
  ladder_fpga_sc_reg_identite(3)          <= '0';
  ladder_fpga_sc_reg_identite(2 downto 0) <= ladder_addr(2 downto 0);
------------------------------------------------------------------------------------
  --identificateur_8bits (JTAG)		-- lecture seule (pas de reset)
--  COMP_ladder_fpga_SC_IDENT_REG  : dr_8_bits
  COMP_ladder_fpga_SC_IDENT_REG  : dr_x_bits
    GENERIC MAP (taille => 8) 
    PORT MAP (
      reset_bar	        =>	'1', -- pas de reset,
      reset_value	=>	'1',
      data_in		=>	ladder_fpga_sc_reg_identite,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_ident_scan_out,
      data_out	        =>	ladder_fpga_sc_nc_reg_identite
      ); --dr_x_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
  --version (JTAG)		-- lecture seule (pas de reset)
--  COMP_ladder_fpga_SC_VERSION_REG  : dr_32_bits
  COMP_ladder_fpga_SC_VERSION_REG  : dr_x_bits
    GENERIC MAP (taille => 32) 
    PORT MAP (
      reset_bar	=>	'1', -- pas de reset,
      reset_value	=>	'1',
      data_in		=>	ladder_fpga_sc_reg_version,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_version_scan_out,
      data_out	        =>	ladder_fpga_sc_nc_reg_version
      ); --dr_x_bits
------------------------------------------------------------------------------------


--  ladder_fpga_sc_reg_etat(21)           <= spare_switch; -- 20100108 modifie -- 20100311 modifie -- 20100401 modifie
--  ladder_fpga_sc_reg_etat(20)           <= fpga_serdes_ou_connec; -- 20100108 modifie -- 20100311 modifie -- 20100401 modifie
--  ladder_fpga_sc_reg_etat(19)           <= sc_serdes_ou_connec; -- 20100108 modifie -- 20100311 modifie -- 20100401 modifie
--  ladder_fpga_sc_reg_etat(18)           <= xtal_en; -- 20100108 modifie -- 20100311 modifie -- 20100401 modifie
--  ladder_fpga_sc_reg_etat(17)           <= NOT(debug_present_n); -- 20100108 modifie -- 20100311 modifie -- 20100401 modifie
--  ladder_fpga_sc_reg_etat(16)           <= crc_error; -- 20100108 modifie -- 20100311 modifie
--  ladder_fpga_sc_reg_etat(15)           <= hv_side; -- 20100108 modifie
--  ladder_fpga_sc_reg_etat(14)           <= holdin_echelle; -- 20100108 modifie
--  ladder_fpga_sc_reg_etat(13)           <= testin_echelle; -- 20100108 modifie
--  ladder_fpga_sc_reg_etat(12)           <= ladder_fpga_activeclock; -- 20090813 ajoute
--  ladder_fpga_sc_reg_etat(11)           <= pll_40MHz_switchover_locked; -- 20090813 ajoute
--  ladder_fpga_sc_reg_etat(10)           <= ladder_fpga_switchover_xtal_sel; -- 20090813 ajoute
--  ladder_fpga_sc_reg_etat( 9)           <= clock40mhz_fpga_bad; -- 20090813 ajoute
--  ladder_fpga_sc_reg_etat( 8)           <= clock40mhz_xtal_bad; -- 20090813 ajoute
--  ladder_fpga_sc_reg_etat( 7)           <= latchup_readout;
--  ladder_fpga_sc_reg_etat( 6)           <= end_of_temp_conv;
--  ladder_fpga_sc_reg_etat( 5 downto  0) <= card_ser_num(5 downto 0);
------------------------------------------------------------------------------------
 --ladder_fpga_sc_reg_etat (JTAG)		-- lecture seule (pas de reset)
  COMP_ladder_fpga_SC_ETAT_REG  : dr_x_bits
		GENERIC MAP (taille => 22) 
	PORT MAP (
	reset_bar	=>	'1', -- pas de reset,
	reset_value	=>	'1',
	data_in		=>	ladder_fpga_sc_reg_etat,
	clockDR		=>	ladder_fpga_sc_clockDR,
	shiftDR		=>	ladder_fpga_sc_shiftDR,
	updateDR	=>	ladder_fpga_sc_updateDR,
	scan_in		=>	ladder_fpga_sc_scan_in,
	scan_out	=>	ladder_fpga_sc_etat_scan_out,
	data_out	=>	ladder_fpga_sc_nc_reg_etat
	); --dr_x_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--roboclock_phase:	-- initialise au reset a "101010101010101010101010"
					-- pas de dephasage
  COMP_LADDER_FPGA_SC_ROBOCLOCK_PHASE  : dr_x_bits_init -- 20090306 ajoute
		GENERIC MAP (taille => 24) 
	PORT MAP (
		reset_bar	=>	ladder_fpga_sc_reset_bar,
		reset_values	=>	"101010101010101010101010", -- 20090306 ajoute
		data_in		=>	ladder_fpga_sc_roboclock_phase,
		clockDR		=>	ladder_fpga_sc_clockDR,
		shiftDR		=>	ladder_fpga_sc_shiftDR,
		updateDR	=>	ladder_fpga_sc_updateDR_roboclock_phase,
		scan_in		=>	ladder_fpga_sc_scan_in ,
		scan_out	=>	ladder_fpga_sc_roboclock_phase_scan_out,
		data_out	=>	ladder_fpga_sc_roboclock_phase
		); -- dr_x_bits_init -- 20090306 ajoute
------------------------------------------------------------------------------------


hv_side                         <= ladder_fpga_sc_config(7); -- 20100310 ajoute
level_shifter_dac_load          <= ladder_fpga_sc_config(6); -- 20091130 ajoute
ladder_fpga_switchover_xtal_sel <= ladder_fpga_sc_config(5); -- 20090813 ajoute -- 20091130 modifie
jtag_avec_hybride               <= ladder_fpga_sc_config(4); -- 20090629 ajoute -- 20091130 modifie -- 20091201 modifie
num_hybride_dans_jtag(3)        <= ladder_fpga_sc_config(3); -- 20090629 ajoute -- 20091130 modifie -- 20091201 modifie
num_hybride_dans_jtag(2)        <= ladder_fpga_sc_config(2); -- 20090629 ajoute -- 20091130 modifie -- 20091201 modifie
num_hybride_dans_jtag(1)        <= ladder_fpga_sc_config(1); -- 20090629 ajoute -- 20091130 modifie -- 20091201 modifie
num_hybride_dans_jtag(0)        <= ladder_fpga_sc_config(0); -- 20090629 ajoute -- 20091130 modifie -- 20091201 modifie

------------------------------------------------------------------------------------
--config:	-- initialise au reset a "0000000000000000" -- 20090316 ajoute
  COMP_LADDER_FPGA_SC_CONFIG  : dr_x_bits_init -- 20090316 ajoute
    GENERIC MAP (taille => 16)  -- 20090316 ajoute
    PORT MAP ( -- 20090316 ajoute
      reset_bar		=>	ladder_fpga_sc_reset_bar, -- 20090316 ajoute
      reset_values	=>	"0000000000000000", -- 20090316 ajoute
      data_in		=>	ladder_fpga_sc_config, -- 20090316 ajoute
      clockDR		=>	ladder_fpga_sc_clockDR, -- 20090316 ajoute
      shiftDR		=>	ladder_fpga_sc_shiftDR, -- 20090316 ajoute
      updateDR		=>	ladder_fpga_sc_updateDR_config, -- 20090316 ajoute
      scan_in		=>	ladder_fpga_sc_scan_in , -- 20090316 ajoute
      scan_out		=>	ladder_fpga_sc_config_scan_out, -- 20090316 ajoute
      data_out		=>	ladder_fpga_sc_config -- 20090316 ajoute
      ); -- dr_x_bits_init -- 20090316 ajoute
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--config:	-- initialise au reset a "10000000001000000000" -- mid value on A and B -- 20091130 ajoute
  COMP_LADDER_FPGA_SC_LEVEL_SHIFTER_DAC  : dr_x_bits_init -- 20091130 ajoute
    GENERIC MAP (taille => 20)  -- 20091130 ajoute
    PORT MAP ( -- 20091130 ajoute
      reset_bar		=>	ladder_fpga_sc_reset_bar, -- 20091130 ajoute
      reset_values	=>	ladder_fpga_sc_level_shifter_dac_init, -- 20091130 ajoute
      data_in		=>	ladder_fpga_sc_level_shifter_dac, -- 20091130 ajoute
      clockDR		=>	ladder_fpga_sc_clockDR, -- 20091130 ajoute
      shiftDR		=>	ladder_fpga_sc_shiftDR, -- 20091130 ajoute
      updateDR		=>	ladder_fpga_sc_updateDR_level_shifter_dac, -- 20091130 ajoute
      scan_in		=>	ladder_fpga_sc_scan_in , -- 20091130 ajoute
      scan_out		=>	ladder_fpga_sc_level_shifter_dac_scan_out, -- 20091130 ajoute
      data_out		=>	ladder_fpga_sc_level_shifter_dac -- 20091130 ajoute
      ); -- dr_x_bits_init -- 20091130 ajoute
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--multiplexeur jtag
  COMP_ladder_fpga_SC_MUX_TDO : mux_tdo
    PORT MAP (
      entree_0x00	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x01	=> ladder_fpga_sc_roboclock_phase_scan_out,	-- registre  24 bit  en r/w roboclock phase
      entree_0x02	=> ladder_fpga_sc_etat_scan_out,			-- registre  22 bit  en r/- ladder status
      entree_0x03	=> ladder_fpga_sc_config_scan_out,			-- registre  16 bit  en r/w ladder_board configuration
      entree_0x04	=> ladder_fpga_sc_level_shifter_dac_scan_out,-- registre  20 bit  en r/w level-shifter DAC values
      entree_0x05	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x06	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x07	=> ladder_fpga_sc_etat_alims_scan_out,		-- registre  16 bit  en r/- JTAG
      entree_0x08	=> ladder_fpga_sc_mux_ref_latchup_scan_out,	-- registre   2 bits en r/w JTAG
      entree_0x09	=> ladder_fpga_sc_rallumage_scan_out,		-- registre  16 bit  en r/w commande alim hybrides
      entree_0x0a	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x0b	=> ladder_fpga_sc_bypass_hybride_scan_out,	-- registre  16 bits en r/w bypass hybrides
      entree_0x0c	=> ladder_fpga_sc_version_scan_out,			-- registre  32 bits en r/- version ladder_fpga
      entree_0x0d	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x0e	=> ladder_fpga_sc_temperature_scan_out,		-- registre  48 bit  en r/- lecture temperatures sur carte fpga
      entree_0x0f	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x10	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x11	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x12	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x13	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x14	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x15	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x16	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x17	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x18	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x19	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x1a	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x1b	=> ladder_fpga_sc_ident_scan_out,			-- registre   8 bits en r/- identite ladder_fpga
      entree_0x1c	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x1d	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_0x1e	=> ladder_fpga_sc_br_scan_out,				-- registre   1 bit  en r/w JTAG
      entree_bypass     => ladder_fpga_sc_br_scan_out,			-- registre   1 bit  en r/w JTAG
      ir_data_out	=> ladder_fpga_sc_ir_data_out,				-- registre   5 bits en r/w instruction register
      dr_scan_out	=> ladder_fpga_sc_dr_scan_out
      ); --mux_tdo
--------------------------------------------------------------------


------------------------------------------------------------------------------------
  COMP_ladder_fpga_SC_MUX_OUT : mux_2_1
    PORT MAP (
      a	        =>	ladder_fpga_sc_dr_scan_out,
      b	        =>	ladder_fpga_sc_ir_scan_out,
      g1	=>	ladder_fpga_sc_shiftIR,
      z	        =>	ladder_fpga_sc_scan_out
      ); --mux_2_1
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
--dr_commande_alim_16_bits:			-- si reset_bar => valeur au reset:
										-- si reset_value_a_O: les alims s'éteignent.
										-- si reset_value_a_1: les alims se rallument.

  allumage_hybride  : dr_x_bits_avec_pulse
    PORT MAP (
      reset_bar	        =>	'1', -- pas_de_reset,
      reset_value	=>	'1', -- reset_value_a_1,
      data_in		=>	ladder_fpga_sc_dr_extinction,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR_rallumage,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_rallumage_scan_out,
      data_out	        =>	ladder_fpga_sc_dr_extinction,
      pulse_out	        =>	ladder_fpga_sc_dr_rallumage
      );
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--bypass_hybride:						-- au reset tous les hybrides seront bypassés
-- hybride bypassés = registre a 0
  COMP_ladder_fpga_SC_BYPASS_HYBRIDE  : dr_x_bits
    GENERIC MAP (taille => 16) 
    PORT MAP (
      reset_bar	        =>	ladder_fpga_sc_reset_bar,
      reset_value	=>	'0',
      data_in		=>	ladder_fpga_sc_dr_bypass_hybride,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR_bypass_hybride,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_bypass_hybride_scan_out,
      data_out	        =>	ladder_fpga_sc_dr_bypass_hybride
      ); --dr_x_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--etats des alims:
  COMP_ladder_fpga_SC_ETAT_ALIMS  : dr_x_bits
    GENERIC MAP (taille => 16) 
    PORT MAP (
      reset_bar	        =>	'1',
      reset_value	=>	'1',
      data_in		=>	etat_alims_hybride,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_etat_alims_scan_out,
      data_out	        =>	ladder_fpga_sc_nc_etat_alims
      ); --dr_x_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--code_v_ref (seuil_latchup)
  COMP_ladder_fpga_SC_REF_LATCHUP  : dr_x_bits
    GENERIC MAP (taille => 2) 
    PORT MAP (
      reset_bar	        =>	'1',
      reset_value	=>	'1',
      data_in		=>	ladder_fpga_sc_dr_mux_ref_latchup,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR_mux_ref_latchup,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_mux_ref_latchup_scan_out,
      data_out	        =>	ladder_fpga_sc_dr_mux_ref_latchup
      ); --dr_x_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- valeur des capteurs de temperature
  COMP_ladder_fpga_SC_TEMPERATURE  : dr_x_bits
    GENERIC MAP (taille => 48) 
    PORT MAP (
      reset_bar	        =>	ladder_fpga_sc_reset_bar,
      reset_value	=>	'0',
      data_in		=>	ladder_fpga_sc_dr_temperature,
      clockDR		=>	ladder_fpga_sc_clockDR,
      shiftDR		=>	ladder_fpga_sc_shiftDR,
      updateDR	        =>	ladder_fpga_sc_updateDR,
      scan_in		=>	ladder_fpga_sc_scan_in,
      scan_out	        =>	ladder_fpga_sc_temperature_scan_out,
      data_out	        =>	ladder_fpga_sc_nc_temperature
      ); --dr_x_bits
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------

GEN_SC_TRSTB_HYBRIDE: FOR i IN 0 TO 15 GENERATE sc_trstb_hybride(i) <= ladder_fpga_sc_trstb; END GENERATE GEN_SC_TRSTB_HYBRIDE;
ladder_fpga_sc_scan_in <= ladder_fpga_sc_tdi;
  rallumage_hybride		<= ladder_fpga_sc_dr_rallumage; -- 20090310 ajoute
  extinction_hybride	<= ladder_fpga_sc_dr_extinction; -- 20090310 ajoute
  bypass_hybride		<= ladder_fpga_sc_dr_bypass_hybride; -- 20090310 ajoute
  mux_ref_latchup		<= ladder_fpga_sc_dr_mux_ref_latchup; -- 20090310 ajoute

						

--latchup:
HZ_pour_cmd_mos_canalP:
FOR i IN 0 to 15 GENERATE
	pilotage_mvdd_hybride(i)  <= '0'	when (etat_alims_hybride(i)='1') else 'Z'	 ;
	pilotage_magnd_hybride(i) <= '0'	when (etat_alims_hybride(i)='1') else 'Z'	 ;
END GENERATE;
------------------------------------------------------------------------------------
--gestion des hybrides (bypass en cas de latchup, memoire token, ...)

comp_gestion_hybrides_v4 : gestion_hybrides_v4
  PORT MAP (
    surcourant			=>	latchup_hybride,
    latchup_memoire		=>	latchup_memorise,
    latchup_pulse		=>	latchup_readout,

    pilotage			=>	etat_alims_hybride,
    tck				=>	ladder_fpga_sc_tck,

    extinction			=>	extinction_hybride,
    rallumage			=>	rallumage_hybride,
    bypass_hybride		=>	bypass_hybride,

    tokenin_echelle		=>	tokenin_echelle_in,
    tokenin			=>	tokenin_hybride, -- 20090818 enleve -- 20090821 remis
    tokenout			=>	tokenout_hybride,
    tokenout_memoire		=>	tokenout_memorise,

    tdi_echelle			=>	ladder_fpga_sc_scan_out, -- 20090629 modifie
    tdi				=>	sc_tdi_hybride,
    tdo				=>	sc_tdo_hybride,
    tdo_echelle			=>	ladder_fpga_sc_tdo,
    num_hybride_dans_jtag       => num_hybride_dans_jtag, -- 20090629 ajoute
    jtag_avec_hybride           => jtag_avec_hybride, -- 20090629 ajoute
    ladder_fpga_sc_tms          => ladder_fpga_sc_tms, -- 20090820 ajoute
    sc_tck_hybride              => sc_tck_hybride, -- 20090820 ajoute
    sc_tms_hybride              => sc_tms_hybride, -- 20090820 ajoute
    tst_gestion_hybrides	=> tst_gestion_hybrides
    );		   


GEN_ADC_RESULTS: for i in 0 to 15 generate
shift_adc_i : shiftreg PORT MAP (
  clock	        => ladder_fpga_clock80MHz,
  enable        => ladder_fpga_fifo21_wr,
  shiftin       => data_serial(i),
  q	        => adc_results(i)
  );
end generate gen_adc_results;

-------------------------------------------------------------------------------
-- if you are wondering why I don't use generate: modelsim does not accept
--      arrays of std_logic_vectors!
-------------------------------------------------------------------------------
--shift_adc_0 : shiftreg PORT MAP (
--  clock	  => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(0),
--  q	          => adc_val_0;
--  );
--shift_adc_1 : shiftreg PORT MAP (
--  clock	  => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(1),
--  q	          => adc_val_1;
--  );
--shift_adc_2 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(2),
--  q	        => adc_val_2;
--  );
--shift_adc_3 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(3),
--  q	        => adc_val_3;
--  );
--shift_adc_4 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(4),
--  q	        => adc_val_4;
--  );
--shift_adc_5 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(5),
--  q	        => adc_val_5;
--  );
--shift_adc_6 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(6),
--  q	        => adc_val_6;
--  );
--shift_adc_7 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(7),
--  q	        => adc_val_7;
--  );
--shift_adc_8 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(8),
--  q	        => adc_val_8;
--  );
--shift_adc_9 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(9),
--  q	        => adc_val_9;
--  );
--shift_adc_10 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(10),
--  q	        => adc_val_10;
--  );
--shift_adc_11 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(11),
--  q	        => adc_val_11;
--  );
--shift_adc_12 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(12),
--  q	        => adc_val_12;
--  );
--shift_adc_13 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(13),
--  q	        => adc_val_13;
--  );
--shift_adc_14 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(14),
--  q	        => adc_val_14;
--  );
--shift_adc_15 : shiftreg PORT MAP (
--  clock	        => ladder_fpga_clock80MHz,
--  enable        => ladder_fpga_fifo21_wr,
--  shiftin       => data_serial(15),
--  q	        => adc_val_15;
--  );


------------------------------------------------------------------------------------
comp_mesure_temperature: mesure_temperature -- 20090316 ajoute
  PORT MAP -- 20090316 ajoute
  ( -- 20090316 ajoute
    reset_sys			=> ladder_fpga_sc_trstb, -- : IN    STD_LOGIC; -- reset (utilise le trstb) -- 20090316 ajoute
    clock4mhz_fpga		=> ladder_fpga_clock4MHz, -- : IN    STD_LOGIC; -- oscillateur a 4 MHz -- 20090316 ajoute -- 20090826 modifie

    temperature_in		=>	temperature, -- : IN    STD_LOGIC; -- bus 1-wire en entree -- 20090316 ajoute
    temperature_out		=>	temperature, -- :   OUT STD_LOGIC; -- bus 1-wire en sortie -- 20090316 ajoute

    end_of_temp_conv	        => end_of_temp_conv, -- :   OUT STD_LOGIC; -- registre JTAG en sortie pour status -- 20090316 ajoute
    temperature_value	        => ladder_fpga_sc_dr_temperature --:   OUT STD_LOGIC_VECTOR(47 downto 0) -- registre JTAG des valeurs de temperatures (4 valeurs codees sur 12 bits) -- 20090316 ajoute
    ); --mesure_temperature -- 20090316 ajoute

-------------------------------------------------------------------------------
-- procedure to acquire one set of ADC values
--      wait for byte from USB
--      if it is 'A' wait for a second byte, else wait for 'A'
--      2nd byte contains switch value (to be echoed later to USB)
--      set holdin_echelle = '1'
--      set tokenin_echelle = '1'
--      release tokenin_echelle, holdin_echelle (prevent 2nd acquisition)
--      wait for ladder_fpga_adc_bit_count_cs_integer = 14
--      put switch value to USB (formatted)
--      put DAC value to USB (formatted)
--      put 16 ADC values to USB (formatted)
--      back to beginning
--
--      output formatting:  raw binary 
--      DAC values: 2 bits,8bits,2 bits,8bits,
--      ADC value:  2 bits,8bits for each ADC
--      input scanning: expect raw binary for switch value
-------------------------------------------------------------------------------
acquire_adcs: process (ladder_fpga_clock40MHz, reset_n)
variable n_adc : integer range 0 to 15 := 0;
variable data_to_send : std_logic_vector(9 downto 0);
variable n_convert : integer range 0 to 4;
variable n_preamble : integer range 0 to 12 := 0;
begin
  if reset_n = '0' then
    ladder_fpga_sc_reg_etat <= (others => '0');  -- for debug only
    acquire_state <= acq_idle;
--  elsif rising_edge(ladder_fpga_clock80MHz) then
  elsif falling_edge(ladder_fpga_clock40MHz) then
    case acquire_state is
      when acq_idle =>
        ladder_fpga_sc_reg_etat(0) <= '1';
        if ladder_fpga_fifo8_from_usb_empty = '0' then  -- wait for byte in USB
          ladder_fpga_fifo8_from_usb_rd <= '1';
          acquire_state <= acq_wt_cmd;
        else
          acquire_state <= acq_idle;
          ladder_fpga_fifo8_from_usb_rd <= '0';
        end if;
      when acq_wt_cmd =>
        ladder_fpga_sc_reg_etat(1) <= '1';
--        ladder_fpga_sc_reg_etat(20 downto 13) <= ladder_fpga_fifo8_from_usb_output;
         -- wait for 'A' or 'a' else back to square 1
        if ladder_fpga_fifo8_from_usb_output = x"41" or ladder_fpga_fifo8_from_usb_output = x"61" then
          acquire_state <= acq_command_0;
          ladder_fpga_fifo8_from_usb_rd <= '0';
        else
          acquire_state <= acq_idle;
        end if;
--      when acq_command_0 =>
--        if ladder_fpga_fifo8_from_usb_empty = '0' then  -- wait for byte in USB
--          ladder_fpga_fifo8_from_usb_rd <= '1';
--          acquire_state <= acq_command;
--        else
--          acquire_state <= acq_command_0;
--          ladder_fpga_fifo8_from_usb_rd <= '0';
--        end if;
      when acq_command_0 =>
        ladder_fpga_sc_reg_etat(2) <= '1';
--        ladder_fpga_sc_reg_etat(12) <= '1';
        ladder_fpga_fifo8_from_usb_rd <= '0';
        switch_val <= ladder_fpga_fifo8_from_usb_output;
--        acquire_state <= acq_hold;
--  THESE ARE FOR DEBUGGING fsm ONLY:
        acquire_state <= acq_send_preamble;
        n_preamble := 0;
        ladder_fpga_fifo8_to_usb_wr <= '1';  -- maybe not necessary?
      when acq_hold =>    -- send hold
        ladder_fpga_fifo8_from_usb_rd <= '0';
        ladder_fpga_sc_reg_etat(3) <= '1';
--        ladder_fpga_sc_reg_etat(13) <= '1';
        tst_holdin_echelle <= '1';
        if ladder_fpga_event_controller_state = st_ev_ctrl_wait4hold then
          acquire_state <= acq_hold;    -- stay here until other FSM sees hold
        else
          acquire_state <= acq_token;    
          tst_holdin_echelle <= '0';
        end if;
      when acq_token =>
        ladder_fpga_sc_reg_etat(4) <= '1';
--        ladder_fpga_sc_reg_etat(14) <= '1';
        tst_tokenin_echelle <= '1';
        if ladder_fpga_event_controller_state = st_ev_ctrl_wait4token then
          acquire_state <= acq_token;    -- stay here until other FSM sees token
        else
          acquire_state <= acq_convert;
          n_convert :=0;
          tst_tokenin_echelle <= '0';
        end if;
      when acq_convert =>
        ladder_fpga_sc_reg_etat(5) <= '1';
--        ladder_fpga_sc_reg_etat(15) <= '1';
        if n_convert < 3 then
          n_convert := n_convert + 1;  -- kill some clocks here
          acquire_state <= acq_convert;
        else
          if ladder_fpga_adc_select_n = '1' then  -- adcs finished?
            acquire_state <= acq_send_preamble;
            n_preamble := 0;
          else
            acquire_state <= acq_convert;  -- wait until conversion complete
          end if;
        end if;
       when acq_send_preamble =>
        ladder_fpga_sc_reg_etat(6) <= '1';  
        ladder_fpga_fifo8_to_usb_input <= X"68";
--        ladder_fpga_fifo8_to_usb_input <= "0000" & switch_val(3 downto 0);
        ladder_fpga_sc_reg_etat(20 downto 17) <= switch_val(3 downto 0);
        ladder_fpga_fifo8_to_usb_wr <= '1';
        acquire_state <= acq_idle;
        

--        case n_preamble is
--          when 1|3|5|7|9 =>
--            ladder_fpga_fifo8_to_usb_wr <= '0';  -- maybe this has to be
--                                                 -- asserted for 2 write clocks?
--          when 0 =>
----            ladder_fpga_fifo8_to_usb_input <= "0000" & switch_val(3 downto 0);
--            ladder_fpga_fifo8_to_usb_input <= X"68";
--            ladder_fpga_sc_reg_etat(10) <= '1';
--            ladder_fpga_fifo8_to_usb_wr <= '1';
--          when 2 => 
--            ladder_fpga_fifo8_to_usb_input <= X"65";
--            ladder_fpga_fifo8_to_usb_wr <= '1';
--            ladder_fpga_sc_reg_etat(11) <= '1';
-- --           ladder_fpga_fifo8_to_usb_input <= "000000" & ladder_fpga_sc_level_shifter_dac(19 downto 18);
--          when 4 => 
--            ladder_fpga_fifo8_to_usb_wr <= '1';
--            ladder_fpga_fifo8_to_usb_input <= X"6c";
--            ladder_fpga_sc_reg_etat(12) <= '1';
-- --           ladder_fpga_fifo8_to_usb_input <= ladder_fpga_sc_level_shifter_dac(17 downto 10);
--          when 6 =>
--            ladder_fpga_fifo8_to_usb_input <= X"6c";
--            ladder_fpga_fifo8_to_usb_wr <= '1';
--            ladder_fpga_sc_reg_etat(13) <= '1';
----            ladder_fpga_fifo8_to_usb_input <= "000000" & ladder_fpga_sc_level_shifter_dac(9 downto 8);
--          when 8 =>
--            ladder_fpga_fifo8_to_usb_input <= X"6f";
--            ladder_fpga_fifo8_to_usb_wr <= '1';
--            ladder_fpga_sc_reg_etat(14) <= '1';
----            ladder_fpga_fifo8_to_usb_input <= ladder_fpga_sc_level_shifter_dac(7 downto 0);
--          when others =>
--            ladder_fpga_fifo8_to_usb_wr <= '0';
--         end case;

--        -- this shows that we get to n_preamble = 4 !!
--        ladder_fpga_sc_reg_etat(21 downto 18) <= CONV_STD_LOGIC_VECTOR(n_preamble,4);
        
--        if n_preamble <9 then
--          n_preamble := n_preamble + 1;
--          acquire_state <= acq_send_preamble;
--        else
----          acquire_state <= acq_send_adcs_0;
----     DEBUG only
--          acquire_state <= acq_idle;
--          n_adc := 0;
--          ladder_fpga_fifo8_to_usb_wr <= '0';
--        end if;
                                                                                               
--          send adcs
      when acq_send_adcs_0 =>
        ladder_fpga_sc_reg_etat(7) <= '1';
        data_to_send := adc_results(n_adc);
        ladder_fpga_fifo8_to_usb_input <= "000000" & data_to_send(9 downto 8); 
        ladder_fpga_fifo8_to_usb_wr <= '1';
        acquire_state <= acq_send_adcs_1;
      when acq_send_adcs_1 =>
        ladder_fpga_sc_reg_etat(8) <= '1';
        ladder_fpga_fifo8_to_usb_wr <= '0';
        acquire_state <= acq_send_adcs_2;
      when acq_send_adcs_2 =>
        ladder_fpga_sc_reg_etat(9) <= '1';
        ladder_fpga_fifo8_to_usb_input <= data_to_send(7 downto 0); 
        ladder_fpga_fifo8_to_usb_wr <= '1';
        acquire_state <= acq_send_adcs;
      when acq_send_adcs =>
        ladder_fpga_sc_reg_etat(10) <= '1';
        ladder_fpga_fifo8_to_usb_wr <= '0';
        if n_adc = 15 then
          n_adc := 0;
          acquire_state <= acq_idle;
        else
          n_adc := n_adc + 1;
          acquire_state <= acq_send_adcs_0;  -- go back for next value
        end if;
      when others => null;
    end case;
  end if;
end process acquire_adcs;

                 
ladder_fpga_fifo_reset   <= NOT(reset_n); -- 20090813 ajoute
ladder_fpga_fifo21_rd    <= '1' when ((ladder_fpga_clock40MHz='0')and(ladder_fpga_fifo21_empty='0')) else '0'; -- 20090813 ajoute
------------------------------------------------------------------------------------
comp_mega_func_fifo21x32_cycloneIII: mega_func_fifo21x32_cycloneIII -- 20090813 ajoute
  PORT map -- 20090813 ajoute
  ( -- 20090813 ajoute
    aclr	=> ladder_fpga_fifo_reset, -- : IN STD_LOGIC  := '0'; -- 20090813 ajoute
    data	=> ladder_fpga_fifo21_input, -- : IN STD_LOGIC_VECTOR (20 DOWNTO 0); -- 20090813 ajoute
    rdclk	=> ladder_fpga_clock40MHz, -- : IN STD_LOGIC ; -- 20090813 ajoute
    rdreq	=> ladder_fpga_fifo21_rd, -- : IN STD_LOGIC ; -- 20090813 ajoute
    wrclk	=> ladder_fpga_clock80MHz, -- : IN STD_LOGIC ; -- 20090813 ajoute
    wrreq	=> ladder_fpga_fifo21_wr, -- : IN STD_LOGIC ; -- 20090813 ajoute
    q		=> ladder_fpga_packer_dataout, -- : OUT STD_LOGIC_VECTOR (20 DOWNTO 0); -- 20090813 ajoute
    rdempty	=> ladder_fpga_fifo21_empty, -- : OUT STD_LOGIC ; -- 20090813 ajoute
    wrfull	=> ladder_fpga_fifo21_full -- : OUT STD_LOGIC  -- 20090813 ajoute
    );-- mega_func_fifo21x32_cycloneIII; -- 20090813 ajoute
------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- delay wrreq to fifo_to_usb by 2 ticks of 40MHz clock
-------------------------------------------------------------------------------
  
--synch_wrreq_to_usb_fifo: process (ladder_fpga_clock40MHz)
--begin
--if falling_edge(ladder_fpga_clock40MHz) then
--  ladder_fpga_fifo8_to_usb_wr_d <= ladder_fpga_fifo8_to_usb_wr;
--  ladder_fpga_fifo8_to_usb_wr_dd <= ladder_fpga_fifo8_to_usb_wr_d;
--end if;
--end process synch_wrreq_to_usb_fifo;

--synch_rdreq_to_usb_fifo: process (ladder_fpga_clock1MHz)
--begin  -- 
--  if falling_edge(ladder_fpga_clock1MHz) then 
--    usb_write_int <= not usb_write_n_in;
--  end if;
--end process synch_rdreq_to_usb_fifo;

usb_write_int <= not usb_write_n_in;    -- added outside process 23-jul-2011
--usb_write    <=  usb_write_int; -- 17-jun-2011 mjl
usb_write    <=  not usb_write_n_in; -- 23-jul-2011 mjl

--ladder_fpga_fifo8_to_usb_input <= ladder_fpga_fifo8_from_usb_output; -- 20090824 ajoute -- 20110126 modifie
--ladder_fpga_fifo8_to_usb_wr    <= '0' WHEN (ladder_fpga_fifo8_to_usb_full='1') ELSE -- 20090824 ajoute -- 20110126 modifie
--                                  '0' WHEN (ladder_fpga_fifo8_from_usb_rd='0') ELSE -- 20090824 ajoute -- 20110126 modifie
--                                  '1'; -- 20090824 ajoute -- 20110126 modifie
usb_data                       <= usb_tx_data WHEN (usb_write_int='1') ELSE (OTHERS=>'Z');
------------------------------------------------------------------------------------
comp_mega_func_fifo8_to_usb: mega_func_fifo8x256_cycloneIII -- 20090824 ajoute
  PORT MAP -- 20090824 ajoute
  ( -- 20090824 ajoute
    aclr		=> ladder_fpga_fifo_reset, --: IN STD_LOGIC  := '0'; -- 20090824 ajoute
    data		=> ladder_fpga_fifo8_to_usb_input, --: IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
    rdclk		=> ladder_fpga_fifo8_usb_clock, --: IN STD_LOGIC ; -- 20090824 ajoute
--  rdreq		=> NOT(usb_write_n), --: IN STD_LOGIC ; -- 20090824 ajoute -- 20110125 enleve
    rdreq		=> NOT(usb_write_n_in), --: IN STD_LOGIC ; -- 20090824 ajoute -- 20110125 modifie
--    wrclk		=> NOT(ladder_fpga_clock80MHz), --: IN STD_LOGIC ; -- 20090824 ajoute
    wrclk		=> ladder_fpga_clock40MHz, -- mod 20-jul-2011 mjl
    wrreq		=> ladder_fpga_fifo8_to_usb_wr, --: IN STD_LOGIC ; --17-jun-2011 mjl
    q		        => usb_tx_data, --: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
    rdempty		=> ladder_fpga_fifo8_to_usb_empty, --: OUT STD_LOGIC ; -- 20090824 ajoute
    wrfull		=> ladder_fpga_fifo8_to_usb_full --: OUT STD_LOGIC  -- 20090824 ajoute
    ); -- mega_func_fifo8x256_cycloneIII; -- 20090824 ajoute
------------------------------------------------------------------------------------

usb_read_n    <= usb_read_n_in; -- 20110125 modifie
--ladder_fpga_fifo8_from_usb_rd <= '0' WHEN (ladder_fpga_fifo8_from_usb_empty='1') ELSE '1'; -- 20090824 ajoute
------------------------------------------------------------------------------------
comp_mega_func_fifo8_from_usb: mega_func_fifo8x256_cycloneIII -- 20090824 ajoute
  PORT MAP -- 20090824 ajoute
  ( -- 20090824 ajoute
    aclr		=> ladder_fpga_fifo_reset, --: IN STD_LOGIC  := '0'; -- 20090824 ajoute
    data		=> usb_data, --: IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
    rdclk		=> ladder_fpga_clock40MHz, --: IN STD_LOGIC ; -- 20090824 ajoute
    rdreq		=> ladder_fpga_fifo8_from_usb_rd, --: IN STD_LOGIC ; -- 20090824 ajoute
    wrclk		=> ladder_fpga_fifo8_usb_clock, --: IN STD_LOGIC ; -- 20090824 ajoute
    wrreq		=> NOT(usb_read_n_in), --: IN STD_LOGIC ; -- 20090824 ajoute -- 20110125 modifie
    q		        => ladder_fpga_fifo8_from_usb_output, --: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- 20090824 ajoute
    rdempty		=> ladder_fpga_fifo8_from_usb_empty, --: OUT STD_LOGIC ; -- 20090824 ajoute
    wrfull		=> ladder_fpga_fifo8_from_usb_full --: OUT STD_LOGIC  -- 20090824 ajoute
    ); -- mega_func_fifo8x256_cycloneIII; -- 20090824 ajoute
------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- ADDED condition on usb_read_n_in = '0' to kill usb_read_n_in after 1 clock
-- ADDED condition on usb_write_n_in = '0' to kill usb_write_n_in after 1 clock
-- also added mutual exclusion between read and write
--  23-jul-2011 mjl (comments):
--                      usb_read_n_in and usb_write_n_in are registered with
--                      falling edge of 1MHz clock.
--                      fifo8_to_usb rdreq is (NOT)usb_write_n_in and rdclk is
--                      1MHz clock. fifo8_from_usb wrreq is (NOT)usb_write_n_in
--                      and wrclk is 1MHz clock
-------------------------------------------------------------------------------

--proc_usb_read_write : process(reset_n, usb_present, usb_reset_n, ladder_fpga_fifo8_usb_clock, usb_ready_n, ladder_fpga_fifo8_from_usb_full, usb_rx_empty, ladder_fpga_fifo8_to_usb_empty, usb_tx_full) is -- 20110128 ajoute
proc_usb_read_write : process(ladder_fpga_fifo8_usb_clock,reset_n, usb_present, usb_reset_n, usb_ready_n) is --changed 23-jul-2011 mjl
begin -- 20110128 ajoute
  IF ((reset_n='0')OR(usb_present='0')OR(usb_ready_n='1')OR(usb_reset_n='0')) then -- 20110128 ajoute
    usb_read_n_in     <= '1'; -- 20110128 ajoute
    usb_write_n_in    <= '1'; -- 20110128 ajoute
  ELSIF falling_edge(ladder_fpga_fifo8_usb_clock) then 
    IF ((ladder_fpga_fifo8_to_usb_empty='0')AND(usb_tx_full='0') and
        (usb_write_n_in = '1') and (usb_read_n_in = '1')) THEN -- modified 17-jun-2011
      usb_read_n_in   <= '1'; -- 20110128 ajoute
      usb_write_n_in  <= '0'; -- 20110128 ajoute
    ELSIF ((ladder_fpga_fifo8_from_usb_full='0')AND(usb_rx_empty='0') and
           (usb_read_n_in = '1') and (usb_write_n_in = '1')) THEN -- modified 17-jun-2011
      usb_read_n_in   <= '0'; -- 20110128 ajoute
      usb_write_n_in  <= '1'; -- 20110128 ajoute
    ELSE -- 20110128 ajoute
      usb_read_n_in   <= '1'; -- 20110128 ajoute
      usb_write_n_in  <= '1'; -- 20110128 ajoute
    END IF; -- 20110128 ajoute
  END IF; -- 20110128 ajoute
end process proc_usb_read_write; -- 20110128 ajoute


proc_ladder_fpga_adc_cs : process(reset_n, ladder_fpga_clock80MHz, ladder_fpga_event_controller_state) is
begin
  IF (reset_n='0') then
    ladder_fpga_adc_select_n       <= '1';
    ladder_fpga_adc_bit_count_cs_integer <= 15;
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='0')) THEN
    CASE ladder_fpga_adc_bit_count_cs_integer is
      WHEN 0 => -- first leading zero
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 1;
      WHEN 1 => -- second leading zero
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 2;
      WHEN 2 => -- msb
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 3;
      WHEN 3 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 4;
      WHEN 4 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 5;
      WHEN 5 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 6;
      WHEN 6 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 7;
      WHEN 7 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 8;
      WHEN 8 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 9;
      WHEN 9 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 10;
      WHEN 10 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 11;
      WHEN 11 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 12;
      WHEN 12 => -- 
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 13;
      WHEN 13 => -- lsb
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN ladder_fpga_adc_select_n <= '0'; ELSE ladder_fpga_adc_select_n <= '1'; END IF; -- 20090817 modifie -- 20090819 modifie
        ladder_fpga_adc_bit_count_cs_integer <= 14;
      WHEN 14 => -- High Z
        ladder_fpga_adc_select_n       <= '1';
        ladder_fpga_adc_bit_count_cs_integer <= 15;
      WHEN 15 => -- High Z
        ladder_fpga_adc_select_n       <= '1';
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)OR(ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_abort)) THEN ladder_fpga_adc_bit_count_cs_integer <= 0; ELSE ladder_fpga_adc_bit_count_cs_integer <= 15; END IF; -- 20090814 modifie -- 20090817 modifie -- 20090818 modifie
      WHEN OTHERS => -- no more bit
        ladder_fpga_adc_select_n       <= '1';
        ladder_fpga_adc_bit_count_cs_integer <= 15;
    END CASE;
  END IF;
end process proc_ladder_fpga_adc_cs;
GEN_ADC_CS_N:   FOR i IN 0 TO 7 GENERATE adc_cs_n(i)   <= ladder_fpga_adc_select_n;   END GENERATE GEN_ADC_CS_N;



proc_ladder_fpga_event_controller : process(reset_n, ladder_fpga_clock80MHz, tst_holdin_echelle, tst_tokenin_echelle, ladder_fpga_busy) is -- 20090826 modifie
begin
  IF (reset_n='0') then
    ladder_fpga_event_controller_state <= st_ev_ctrl_wait4hold;
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='0')) THEN
    CASE ladder_fpga_event_controller_state is
      WHEN st_ev_ctrl_wait4hold => -- 
        IF (tst_holdin_echelle='1')   THEN ladder_fpga_event_controller_state <= st_ev_ctrl_wait4token; -- 20090826 modifie
        ELSE ladder_fpga_event_controller_state <= st_ev_ctrl_wait4hold; -- 
        END IF;
      WHEN st_ev_ctrl_wait4token => -- 
        IF (tst_holdin_echelle='0')      THEN ladder_fpga_event_controller_state <= st_ev_ctrl_abort; -- 
        ELSIF (tst_tokenin_echelle='1')  THEN ladder_fpga_event_controller_state <= st_ev_ctrl_tokenin_pulse; -- 
        ELSE ladder_fpga_event_controller_state <= st_ev_ctrl_wait4token; --
        END IF;
      WHEN st_ev_ctrl_tokenin_pulse => -- 
--        IF (tokenin_pulse_ok='0')      THEN ladder_fpga_event_controller_state <= st_ev_ctrl_tokenin_pulse; -- 20090819 modifie
        IF (tst_tokenin_pulse_ok='0')      THEN ladder_fpga_event_controller_state <= st_ev_ctrl_tokenin_pulse; -- 20090819 modifie
        ELSE ladder_fpga_event_controller_state <= st_ev_ctrl_acquisition; -- 20090818 enleve -- 20090819 remis
        END IF; -- 20090818 enleve -- 20090819 remis
      WHEN st_ev_ctrl_acquisition => -- 
        IF (tst_holdin_echelle='0')      THEN ladder_fpga_event_controller_state <= st_ev_ctrl_abort; -- 
        ELSIF (ladder_fpga_busy='0') THEN ladder_fpga_event_controller_state <= st_ev_ctrl_event_end; -- 
        ELSE ladder_fpga_event_controller_state <= st_ev_ctrl_acquisition; --
        END IF;
      WHEN st_ev_ctrl_event_end => -- 
        IF (tst_holdin_echelle='0')      THEN ladder_fpga_event_controller_state <= st_ev_ctrl_wait4hold; -- 
        ELSE ladder_fpga_event_controller_state <= st_ev_ctrl_event_end; -- 
        END IF;
      WHEN st_ev_ctrl_abort => -- 
        IF (ladder_fpga_busy='0')    THEN ladder_fpga_event_controller_state <= st_ev_ctrl_wait4hold; -- 
        ELSE ladder_fpga_event_controller_state <= st_ev_ctrl_abort; -- 
        END IF;
      WHEN OTHERS => -- error
        ladder_fpga_event_controller_state <= st_ev_ctrl_abort; -- 
    END CASE;
  END IF;
end process proc_ladder_fpga_event_controller;



proc_ladder_fpga_data_packer : process(reset_n, ladder_fpga_clock80MHz, ladder_fpga_adc_bit_count_cs_integer, ladder_fpga_event_controller_state) is -- 20090820 modifie
begin
  IF (reset_n='0') then
    ladder_fpga_flux_compactor_status      <= "00000"; -- 20090812 ajoute
    ladder_fpga_data_packer_0_word         <= x"0000"; -- 20090812 ajoute
    ladder_fpga_data_packer_1_word         <= x"0000"; -- 20090812 ajoute
    ladder_fpga_data_packer_2_word         <= x"0000"; -- 20090812 ajoute
    ladder_fpga_data_packer_3_word         <= x"0000"; -- 20090812 ajoute
    ladder_fpga_data_packer_4_word         <= x"0000"; -- 20090812 ajoute
    ladder_fpga_fifo21_input               <= (OTHERS=>'0'); -- 20090812 ajoute
    ladder_fpga_fifo21_wr                  <= '0'; -- 20091201 ajoute
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='0')) THEN
    CASE ladder_fpga_adc_bit_count_cs_integer is
      WHEN 3 => -- msb for SSD
        ladder_fpga_flux_compactor_status      <= "00001"; -- 20090812 ajoute
        ladder_fpga_data_packer_0_word         <= data_serial; --InData -- 20090812 ajoute
        ladder_fpga_fifo21_wr                  <= '0'; -- 20090812 ajoute
        ladder_fpga_fifo21_input(20)           <= '0'; -- 20090812 ajoute
      WHEN 4 => -- 
        ladder_fpga_flux_compactor_status      <= "00011"; -- 20090812 ajoute
        ladder_fpga_data_packer_1_word         <= data_serial; --InData -- 20090812 ajoute
        ladder_fpga_fifo21_wr                  <= '0'; -- 20090812 ajoute
        ladder_fpga_fifo21_input(20)           <= '0'; -- 20090812 ajoute
      WHEN 5 => -- 
        ladder_fpga_flux_compactor_status      <= "00110"; -- 20090812 ajoute
        ladder_fpga_data_packer_2_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '1'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto 16) <= ladder_fpga_data_packer_1_word( 3 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input(15 downto  0) <= ladder_fpga_data_packer_0_word(15 downto  0); -- 20090812 ajoute
      WHEN 6 => -- 
        ladder_fpga_flux_compactor_status      <= "01100"; -- 20090812 ajoute
        ladder_fpga_data_packer_3_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '0'; -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto 12) <= ladder_fpga_data_packer_2_word( 7 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input(11 downto  0) <= ladder_fpga_data_packer_1_word(15 downto  4); -- 20090812 ajoute
      WHEN 7 => -- 
        ladder_fpga_flux_compactor_status      <= "11000"; -- 20090812 ajoute
        ladder_fpga_data_packer_4_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '0'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto  8) <= ladder_fpga_data_packer_3_word(11 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input( 7 downto  0) <= ladder_fpga_data_packer_2_word(15 downto  8); -- 20090812 ajoute
      WHEN 8 => -- 
        ladder_fpga_flux_compactor_status      <= "00001"; -- 20090812 ajoute
        ladder_fpga_data_packer_0_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '0'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto  4) <= ladder_fpga_data_packer_4_word(15 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input( 3 downto  0) <= ladder_fpga_data_packer_3_word(15 downto 12); -- 20090812 ajoute
      WHEN 9 => -- 
        ladder_fpga_flux_compactor_status      <= "00011"; -- 20090812 ajoute
        ladder_fpga_data_packer_1_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '1'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto 16) <= ladder_fpga_data_packer_1_word( 3 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input(15 downto  0) <= ladder_fpga_data_packer_0_word(15 downto  0); -- 20090812 ajoute
      WHEN 10 => -- 
        ladder_fpga_flux_compactor_status      <= "00110"; -- 20090812 ajoute
        ladder_fpga_data_packer_2_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '0'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto 12) <= ladder_fpga_data_packer_2_word( 7 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input(11 downto  0) <= ladder_fpga_data_packer_1_word(15 downto  4); -- 20090812 ajoute
      WHEN 11 => -- 
        ladder_fpga_flux_compactor_status      <= "01100"; -- 20090812 ajoute
        ladder_fpga_data_packer_3_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '0'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto  8) <= ladder_fpga_data_packer_3_word(11 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input( 7 downto  0) <= ladder_fpga_data_packer_2_word(15 downto  8); -- 20090812 ajoute
      WHEN 12 => -- lsb for SSD
        ladder_fpga_flux_compactor_status      <= "11000"; -- 20090812 ajoute
        ladder_fpga_data_packer_4_word         <= data_serial; --InData -- 20090812 ajoute
        IF (ladder_fpga_event_controller_state=st_ev_ctrl_acquisition) THEN ladder_fpga_fifo21_wr <= '1'; ELSE ladder_fpga_fifo21_wr <= '0'; END IF; -- 20090820 modifie
        ladder_fpga_fifo21_input(20)           <= '0'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto  4) <= ladder_fpga_data_packer_4_word(15 downto  0); -- 20090812 ajoute
        ladder_fpga_fifo21_input( 3 downto  0) <= ladder_fpga_data_packer_3_word(15 downto 12); -- 20090812 ajoute
      WHEN OTHERS => -- no usable bit
        ladder_fpga_flux_compactor_status      <= "00000"; -- 20090812 ajoute
        ladder_fpga_fifo21_wr                  <= '0'; -- 20090812 ajoute
        ladder_fpga_fifo21_input(20)           <= '0'; -- first_word -- 20090812 ajoute
        ladder_fpga_fifo21_input(19 downto 16) <= (OTHERS=>'0'); -- 20090812 ajoute
        ladder_fpga_fifo21_input(15 downto  0) <= (OTHERS=>'0'); -- 20090812 ajoute
    END CASE;
  END IF;
end process proc_ladder_fpga_data_packer;

ladder_fpga_rclk_16hybrides <= ladder_fpga_rclk_echelle; -- 20090814 ajoute
proc_ladder_fpga_rclk_echelle : process(reset_n, ladder_fpga_clock80MHz, ladder_fpga_adc_bit_count_cs_integer, ladder_fpga_event_controller_state) is -- 20090814 ajoute
begin -- 20090814 ajoute
  IF (reset_n='0') then -- 20090814 ajoute
    ladder_fpga_rclk_echelle               <= '0'; -- 20090814 ajoute
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='0')) THEN -- 20090814 ajoute
    CASE ladder_fpga_adc_bit_count_cs_integer is -- 20090814 ajoute
      WHEN 0 => -- 20090814 ajoute
        ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
      WHEN 1 => -- 20090814 ajoute
        ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
      WHEN 2 => -- 20090814 ajoute
        ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
      WHEN 3 => -- 20090814 ajoute
        ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
      WHEN 4 => -- 20090814 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 5 => -- 20090814 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 6 => -- 20090814 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 7 => -- 20090814 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '1'; -- 20090814 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 8 => -- 20090817 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '1'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 9 => -- 20090817 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '1'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 10 => -- 20090817 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '1'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN 11 => -- 20090817 ajoute
        IF ((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse)) THEN -- 20090817 ajoute -- 20090819 modifie
          ladder_fpga_rclk_echelle           <= '0'; -- 20090817 ajoute
        ELSE -- 20090817 ajoute
          ladder_fpga_rclk_echelle           <= '1'; -- 20090817 ajoute
        END IF; -- 20090817 ajoute
      WHEN OTHERS => -- 20090814 ajoute
        ladder_fpga_rclk_echelle           <= '0'; -- 20090814 ajoute
    END CASE; -- 20090814 ajoute
  END IF; -- 20090814 ajoute
end process proc_ladder_fpga_rclk_echelle; -- 20090814 ajoute




proc_ladder_fpga_mux_statusout : process(reset_n, ladder_fpga_clock40MHz, ladder_fpga_mux_statusin) is -- 20090824 ajoute
begin -- 20090817 ajoute
  IF (reset_n='0') then -- 20090817 ajoute
    ladder_fpga_mux_statusout <= (OTHERS=>'0'); -- 20090824 ajoute -- 20090824 modifie
    ladder_fpga_mux_status_count_integer    <= 0; -- 20090824 ajoute
  ELSIF ((ladder_fpga_clock40MHz'EVENT) AND (ladder_fpga_clock40MHz='0')) THEN -- 20090824 ajoute
    ladder_fpga_mux_statusout <= ladder_fpga_mux_statusin; -- 20090824 ajoute
    IF (ladder_fpga_mux_status_count_integer=7) THEN -- 20090824 ajoute
      ladder_fpga_mux_status_count_integer <= 0; -- 20090824 ajoute
    ELSE -- 20090824 ajoute
      ladder_fpga_mux_status_count_integer    <= ladder_fpga_mux_status_count_integer + 1; -- 20090824 ajoute
    END IF; -- 20090824 ajoute
  END IF; -- 20090824 ajoute
end process proc_ladder_fpga_mux_statusout; -- 20090824 ajoute

  ladder_fpga_mux_statusin(20 DOWNTO 18) <= CONV_STD_LOGIC_VECTOR(ladder_fpga_mux_status_count_integer,3); -- 20090824 ajoute
  ladder_fpga_mux_statusin(17 DOWNTO  0) <= ladder_fpga_status_a_out WHEN (ladder_fpga_mux_status_count_integer=0) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_b_out WHEN (ladder_fpga_mux_status_count_integer=1) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_c_out WHEN (ladder_fpga_mux_status_count_integer=2) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_d_out WHEN (ladder_fpga_mux_status_count_integer=3) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_e_out WHEN (ladder_fpga_mux_status_count_integer=4) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_f_out WHEN (ladder_fpga_mux_status_count_integer=5) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_g_out WHEN (ladder_fpga_mux_status_count_integer=6) ELSE -- 20090824 ajoute
                                            ladder_fpga_status_h_out; -- 20090824 ajoute


proc_ladder_fpga_mux_dataout : process(reset_n, ladder_fpga_clock40MHz, ladder_fpga_mux_datain) is -- 20090824 ajoute
begin -- 20090817 ajoute
  IF (reset_n='0') then -- 20090817 ajoute
    ladder_fpga_mux_dataout <= (OTHERS=>'0'); -- 20090824 ajoute -- 20090824 modifie
  ELSIF ((ladder_fpga_clock40MHz'EVENT) AND (ladder_fpga_clock40MHz='0')) THEN -- 20090824 ajoute
    ladder_fpga_mux_dataout <= ladder_fpga_mux_datain; -- 20090824 ajoute
  END IF; -- 20090824 ajoute
end process proc_ladder_fpga_mux_dataout; -- 20090824 ajoute

  ladder_fpga_mux_datain(21)           <= NOT(ladder_fpga_fifo21_empty); -- 20090824 ajoute
  ladder_fpga_mux_datain(20 DOWNTO  0) <= ladder_fpga_packer_dataout WHEN (ladder_fpga_fifo21_empty='0') ELSE
                                          ladder_fpga_mux_statusout; -- 20090824 ajoute


proc_ladder_fpga_nbr_hold : process(reset_n, holdin_echelle) is -- 20090817 ajoute
begin -- 20090817 ajoute
  IF (reset_n='0') then -- 20090817 ajoute
    ladder_fpga_nbr_hold           <= (OTHERS=>'0'); -- 20090817 ajoute
  ELSIF ((holdin_echelle'EVENT) AND (holdin_echelle='1')) THEN -- 20090817 ajoute
    ladder_fpga_nbr_hold           <= ladder_fpga_nbr_hold + 1; -- 20090817 ajoute
  END IF; -- 20090817 ajoute
end process proc_ladder_fpga_nbr_hold; -- 20090817 ajoute

proc_ladder_fpga_nbr_test : process(reset_n, testin_echelle) is -- 20090817 ajoute
begin -- 20090817 ajoute
  IF (reset_n='0') then -- 20090817 ajoute
    ladder_fpga_nbr_test           <= (OTHERS=>'0'); -- 20090817 ajoute
  ELSIF ((testin_echelle'EVENT) AND (testin_echelle='1')) THEN -- 20090817 ajoute
    ladder_fpga_nbr_test           <= ladder_fpga_nbr_test + 1; -- 20090817 ajoute
  END IF; -- 20090817 ajoute
end process proc_ladder_fpga_nbr_test; -- 20090817 ajoute

proc_ladder_fpga_nbr_token : process(reset_n, tst_tokenin_echelle) is -- 20090817 ajoute
begin -- 20090817 ajoute
  IF (reset_n='0') then -- 20090817 ajoute
    ladder_fpga_nbr_token           <= (OTHERS=>'0'); -- 20090817 ajoute
  ELSIF ((tst_tokenin_echelle'EVENT) AND (tst_tokenin_echelle='1')) THEN -- 20090817 ajoute
    ladder_fpga_nbr_token           <= ladder_fpga_nbr_token + 1; -- 20090817 ajoute
  END IF; -- 20090817 ajoute
end process proc_ladder_fpga_nbr_token; -- 20090817 ajoute

proc_ladder_fpga_nbr_abort : process(reset_n, ladder_fpga_abort) is -- 20090824 ajoute
begin -- 20090824 ajoute
  IF (reset_n='0') then -- 20090824 ajoute
    ladder_fpga_nbr_abort           <= (OTHERS=>'0'); -- 20090824 ajoute
  ELSIF ((ladder_fpga_abort'EVENT) AND (ladder_fpga_abort='1')) THEN -- 20090824 ajoute
    ladder_fpga_nbr_abort           <= ladder_fpga_nbr_abort + 1; -- 20090824 ajoute
  END IF; -- 20090824 ajoute
end process proc_ladder_fpga_nbr_abort; -- 20090824 ajoute

proc_ladder_fpga_abort : process(reset_n, ladder_fpga_clock80MHz, ladder_fpga_event_controller_state) is -- 20090824 ajoute
begin -- 20090824 ajoute
  IF (reset_n='0') then -- 20090824 ajoute
    ladder_fpga_abort           <= '0'; -- 20090824 ajoute
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='0')) THEN -- 20090824 ajoute
    IF (ladder_fpga_event_controller_state=st_ev_ctrl_abort) THEN ladder_fpga_abort <= '1'; ELSE ladder_fpga_abort <= '0'; END IF; -- 20090824 ajoute
  END IF; -- 20090824 ajoute
end process proc_ladder_fpga_abort; -- 20090824 ajoute

ladder_fpga_switchover_rst <= NOT(reset_n); -- 20090813 ajoute
clock80MHz_adc             <= ladder_fpga_clock80MHz; -- 20090814 ajoute

roboclock_horloge40_phase        <= roboclock_horloge40_phase_in; -- 20090306 ajoute
roboclock_horloge40_phase_in(3)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(23 downto 22)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(23 downto 22)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_horloge40_phase_in(2)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(21 downto 20)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(21 downto 20)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_horloge40_phase_in(1)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(19 downto 18)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(19 downto 18)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_horloge40_phase_in(0)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(17 downto 16)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(17 downto 16)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase        <= roboclock_adc_phase_in; -- 20090306 ajoute
roboclock_adc_phase_in(7)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(15 downto 14)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(15 downto 14)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(6)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(13 downto 12)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(13 downto 12)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(5)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase(11 downto 10)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase(11 downto 10)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(4)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase( 9 downto  8)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase( 9 downto  8)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(3)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase( 7 downto  6)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase( 7 downto  6)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(2)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase( 5 downto  4)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase( 5 downto  4)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(1)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase( 3 downto  2)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase( 3 downto  2)="11") ELSE 'Z'; -- 20090306 ajoute
roboclock_adc_phase_in(0)  <= '0' WHEN (ladder_fpga_sc_roboclock_phase( 1 downto  0)="00") ELSE '1' WHEN (ladder_fpga_sc_roboclock_phase( 1 downto  0)="11") ELSE 'Z'; -- 20090306 ajoute


ladder_fpga_packer_dataready <= '1' WHEN (ladder_fpga_fifo21_empty='0') ELSE '0'; -- 20090817 ajoute

ladder_to_rdo(21 downto  0) <= ladder_fpga_mux_dataout; -- 20090813 modifie -- 20090817 enleve

hold_16hybrides        <= holdin_echelle; -- fige (hold) les donnees du front-end
test_16hybrides        <= testin_echelle; -- pulse test (calibration electronique du front-end)


fibre_tx_disable          <= '0'; -- must be '0' -- 20090306 ajoute

usb_reset_n               <= '0' WHEN (reset_n='0')   ELSE -- 20090306 ajoute -- 20090824 modifie
                             'Z'; -- ATTENTION : open-colector -- 20090306 ajoute -- 20090824 modifie

dbg_ladder_fpga_sc_bypass <= ladder_fpga_sc_bypass; -- 20090629 ajoute



proc_ladder_fpga_nbr_rclk_echelle : process(reset_n, ladder_fpga_clock80MHz, ladder_fpga_event_controller_state) is -- 20090817 ajoute -- 20090819 modifie
begin -- 20090817 ajoute
  IF (reset_n='0') then -- 20090817 ajoute -- 20090824 modifie
    ladder_fpga_nbr_rclk_echelle <= 0; -- 20090817 ajoute
    ladder_fpga_busy <= '0'; -- 20091201 ajoute
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='1')) THEN -- 20090817 ajoute -- 20090819 modifie
    IF (ladder_fpga_event_controller_state=st_ev_ctrl_wait4hold) then -- 20090817 ajoute -- 20090824 modifie
      ladder_fpga_nbr_rclk_echelle <= 0; -- 20090824 ajoute
    ELSIF ((ladder_fpga_nbr_rclk_echelle<12288)AND((ladder_fpga_event_controller_state=st_ev_ctrl_acquisition)OR(ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse))) THEN -- 20090817 ajoute -- 20090818 modifie -- 20090819 modifie -- 20090820 modifie -- 20090824 modifie
      ladder_fpga_nbr_rclk_echelle <= ladder_fpga_nbr_rclk_echelle + 1; -- 20090817 ajoute
    ELSIF ((ladder_fpga_nbr_rclk_echelle<12288)AND(ladder_fpga_event_controller_state=st_ev_ctrl_abort)) THEN -- 20090817 ajoute -- 20090818 modifie -- 20090819 modifie -- 20090820 modifie
      ladder_fpga_nbr_rclk_echelle <= ladder_fpga_nbr_rclk_echelle + 2; -- 20090820 ajoute
    ELSIF (ladder_fpga_event_controller_state=st_ev_ctrl_event_end) THEN -- 20090819 ajoute
      ladder_fpga_nbr_rclk_echelle <= 12304; -- 20090819 ajoute
    ELSE -- 20090820 ajoute
      ladder_fpga_nbr_rclk_echelle <= ladder_fpga_nbr_rclk_echelle + 0; -- 20090820 ajoute
    END IF; -- 20090817 ajoute
    IF (ladder_fpga_nbr_rclk_echelle=0) THEN
      ladder_fpga_busy <= '0';
    ELSIF (ladder_fpga_nbr_rclk_echelle<12288) THEN -- 20090819 modifie
      ladder_fpga_busy <= '1';
    ELSE
      ladder_fpga_busy <= '0';
    END IF;
  END IF; -- 20090817 ajoute
end process proc_ladder_fpga_nbr_rclk_echelle; -- 20090817 ajoute

  ladder_fpga_status_a_out(17 DOWNTO 16) <= etat_alims_hybride( 1 DOWNTO  0); -- 20090817 ajoute
  ladder_fpga_status_a_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_a_out(14)           <= '1'; -- fpga_configured -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_a_out(13)           <= ladder_fpga_ok; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_a_out(12)           <= NOT(ladder_fpga_activeclock); -- 1 when (active clock = serdes clock) -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_a_out(11 DOWNTO  0) <= ladder_fpga_sc_dr_temperature(11 DOWNTO  0); -- 20090817 ajoute

  ladder_fpga_status_b_out(17 DOWNTO 16) <= etat_alims_hybride( 3 DOWNTO  2); -- 20090817 ajoute
  ladder_fpga_status_b_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_b_out(14)           <= des_lock; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_b_out(13)           <= des_bist_pass; -- 20090817 ajoute -- 20090824 modifie -- 20090827 modifie
  ladder_fpga_status_b_out(12)           <= crc_error; -- 20090817 ajoute -- 20090824 modifie -- 20090827 modifie -- 20100401 modifie
  ladder_fpga_status_b_out(11 DOWNTO  0) <= ladder_fpga_sc_dr_temperature(23 DOWNTO 12); -- 20090817 ajoute

  ladder_fpga_status_c_out(17 DOWNTO 16) <= etat_alims_hybride( 5 DOWNTO  4); -- 20090817 ajoute
  ladder_fpga_status_c_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_c_out(14)           <= fibre_tx_fault; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_c_out(13)           <= fibre_mod_absent; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_c_out(12)           <= fibre_rx_loss; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_c_out(11 DOWNTO  0) <= ladder_fpga_sc_dr_temperature(35 DOWNTO 24); -- 20090817 ajoute

  ladder_fpga_status_d_out(17 DOWNTO 16) <= etat_alims_hybride( 7 DOWNTO  6); -- 20090817 ajoute
  ladder_fpga_status_d_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_d_out(14)           <= usb_present; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_d_out(13)           <= usb_ready_n; -- 20090817 ajoute -- 20090824 modifie
  ladder_fpga_status_d_out(12)           <= NOT(debug_present_n); -- 20090817 ajoute -- 20090824 modifie -- 20100401 modifie
  ladder_fpga_status_d_out(11 DOWNTO  0) <= ladder_fpga_sc_dr_temperature(47 DOWNTO 36); -- 20090817 ajoute

  ladder_fpga_status_e_out(17 DOWNTO 16) <= etat_alims_hybride( 9 DOWNTO  8); -- 20090817 ajoute
  ladder_fpga_status_e_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_e_out(14)           <= holdin_echelle; -- 20090817 ajoute -- 20090826 modifie
  ladder_fpga_status_e_out(13)           <= testin_echelle; -- 20090817 ajoute -- 20090826 modifie
  ladder_fpga_status_e_out(12)           <= hv_side; -- 20090817 ajoute -- 20090826 modifie -- 20100108 modifie
  ladder_fpga_status_e_out(11 DOWNTO  0) <= ladder_fpga_nbr_hold(11 DOWNTO  0); -- 20090817 ajoute

  ladder_fpga_status_f_out(17 DOWNTO 16) <= etat_alims_hybride(11 DOWNTO 10); -- 20090817 ajoute
  ladder_fpga_status_f_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_f_out(14 DOWNTO 12) <= card_ser_num(5 DOWNTO 3); -- 20090817 ajoute
  ladder_fpga_status_f_out(11 DOWNTO  0) <= ladder_fpga_nbr_test(11 DOWNTO  0); -- 20090817 ajoute

  ladder_fpga_status_g_out(17 DOWNTO 16) <= etat_alims_hybride(13 DOWNTO 12); -- 20090817 ajoute
  ladder_fpga_status_g_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_g_out(14 DOWNTO 12) <= card_ser_num(2 DOWNTO 0); -- 20090817 ajoute
  ladder_fpga_status_g_out(11 DOWNTO  0) <= ladder_fpga_nbr_token(11 DOWNTO  0); -- 20090817 ajoute

  ladder_fpga_status_h_out(17 DOWNTO 16) <= etat_alims_hybride(15 DOWNTO 14); -- 20090817 ajoute
  ladder_fpga_status_h_out(15)           <= ladder_fpga_busy; -- 20090817 ajoute
  ladder_fpga_status_h_out(14 DOWNTO 12) <= ladder_addr; -- 20090817 ajoute
  ladder_fpga_status_h_out(11 DOWNTO  0) <= ladder_fpga_nbr_abort(11 DOWNTO  0); -- 20090824 ajoute

  tokenin_echelle_in <= '1' WHEN (ladder_fpga_event_controller_state=st_ev_ctrl_tokenin_pulse) ELSE '0'; -- 20090818 ajoute -- 20090821 modifie

proc_ladder_fpga_tokenin_pulse_duration : process(reset_n, ladder_fpga_clock80MHz, ladder_fpga_event_controller_state) is -- 20090819 ajoute
begin -- 20090819 ajoute
  IF (reset_n='0') then -- 20090819 ajoute -- 20090824 modifie
    tokenin_pulse_ok         <= '0';
    tokenin_pulse_duration   <= (OTHERS=>'0'); -- 20090819 ajoute
  ELSIF ((ladder_fpga_clock80MHz'EVENT) AND (ladder_fpga_clock80MHz='1')) THEN -- 20090819 ajoute
    IF (ladder_fpga_event_controller_state/=st_ev_ctrl_tokenin_pulse) then -- 20090824 ajoute
      tokenin_pulse_ok         <= '0'; -- 20090824 ajoute
      tokenin_pulse_duration   <= (OTHERS=>'0'); -- 20090824 ajoute
    ELSIF (tokenin_pulse_duration=15) THEN -- 20090824 modifie
      tokenin_pulse_ok       <= '1';
    ELSE -- 20090819 ajoute
      tokenin_pulse_ok       <= '0';
      tokenin_pulse_duration <= tokenin_pulse_duration + 1;
    END IF; -- 20090819 ajoute
  END IF; -- 20090819 ajoute
end process proc_ladder_fpga_tokenin_pulse_duration; -- 20090819 ajoute


  level_shifter_dac_sck             <= (level_shifter_dac_sck_en AND ladder_fpga_clock4MHz); -- 20091130 ajoute
  level_shifter_dac_a(15 downto 12) <= level_shifter_dac_a_code( 3 downto 0); -- 20091130 ajoute -- 20091201 modifie
  level_shifter_dac_a( 1 downto  0) <= "00"; -- 20091201 ajoute
  level_shifter_dac_b(15 downto 12) <= level_shifter_dac_b_code( 3 downto 0); -- 20091130 ajoute -- 20091201 modifie
  level_shifter_dac_b( 1 downto  0) <= "00"; -- 20091201 ajoute
proc_ladder_fpga_level_shifter_dac_val : process(reset_n, level_shifter_dac_load, ladder_fpga_sc_level_shifter_dac) is -- 20091130 ajoute
begin -- 20091130 ajoute
  IF (reset_n='0') then -- 20091130 ajoute
    level_shifter_dac_a(11 downto  2) <= ladder_fpga_sc_level_shifter_dac_init( 9 DOWNTO  0); -- 20091130 ajoute -- 20091201 modifie
    level_shifter_dac_b(11 downto  2) <= ladder_fpga_sc_level_shifter_dac_init(19 DOWNTO 10); -- 20091130 ajoute -- 20091201 modifie
  ELSIF ((level_shifter_dac_load'EVENT) AND (level_shifter_dac_load='1')) THEN -- 20091130 ajoute
    level_shifter_dac_a(11 downto  2) <= ladder_fpga_sc_level_shifter_dac( 9 DOWNTO  0); -- 20091130 ajoute -- 20091201 modifie
    level_shifter_dac_b(11 downto  2) <= ladder_fpga_sc_level_shifter_dac(19 DOWNTO 10); -- 20091130 ajoute -- 20091201 modifie
  END IF; -- 20091130 ajoute
end process proc_ladder_fpga_level_shifter_dac_val; -- 20091130 ajoute

proc_ladder_fpga_level_shifter_dac : process(reset_n, ladder_fpga_clock4MHz, ladder_fpga_level_shifter_dac_state, level_shifter_dac_load) is -- 20091130 ajoute
begin -- 20091130 ajoute
  IF (reset_n='0') then -- 20091130 ajoute
    level_shifter_dac_ld_cs_n       <= '1'; -- 20091130 ajoute
    level_shifter_dac_sck_en        <= '0'; -- 20091130 ajoute
    level_shifter_dac_load_indice   <= 15; -- 20091130 ajoute -- 20091201 modifie
    ladder_fpga_level_shifter_dac_state <= st_lev_shft_pre_cs; -- 20091130 ajoute
  ELSIF ((ladder_fpga_clock4MHz'EVENT) AND (ladder_fpga_clock4MHz='1')) THEN
    CASE ladder_fpga_level_shifter_dac_state is
      WHEN st_lev_shft_pre_cs => -- pulse LD/CS_N signal
        level_shifter_dac_ld_cs_n       <= '0'; -- 20091130 ajoute
        ladder_fpga_level_shifter_dac_state <= st_lev_shft_load_a; -- 20091130 ajoute
      WHEN st_lev_shft_load_a => -- load DAC A channel
        level_shifter_dac_ld_cs_n       <= '0'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '1'; -- 20091130 ajoute
        IF (level_shifter_dac_load_indice=0) THEN -- 20091130 ajoute
          level_shifter_dac_load_indice   <= 15; -- 20091130 ajoute -- 20091201 modifie
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_pulse_cs_H; -- 20091130 ajoute
        ELSE -- 20091130 ajoute
          level_shifter_dac_load_indice   <= level_shifter_dac_load_indice - 1; -- 20091130 ajoute
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_load_a; -- 20091130 ajoute
        END IF; -- 20091130 ajoute
      WHEN st_lev_shft_pulse_cs_H => -- pulse LD/CS_N signal
        level_shifter_dac_ld_cs_n       <= '1'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '0'; -- 20091130 ajoute
        ladder_fpga_level_shifter_dac_state <= st_lev_shft_pulse_cs_L; -- 20091130 ajoute
      WHEN st_lev_shft_pulse_cs_L => -- pulse LD/CS_N signal
        level_shifter_dac_ld_cs_n       <= '0'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '0'; -- 20091130 ajoute
        level_shifter_dac_load_indice   <= 15; -- 20091201 ajoute
        ladder_fpga_level_shifter_dac_state <= st_lev_shft_load_b; -- 20091130 ajoute
      WHEN st_lev_shft_load_b => -- load DAC B channel
        level_shifter_dac_ld_cs_n       <= '0'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '1'; -- 20091130 ajoute
        IF (level_shifter_dac_load_indice=0) THEN -- 20091130 ajoute
          level_shifter_dac_load_indice   <= 15; -- 20091130 ajoute -- 20091201 modifie
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_end; -- 20091130 ajoute
        ELSE -- 20091130 ajoute
          level_shifter_dac_load_indice   <= level_shifter_dac_load_indice - 1; -- 20091130 ajoute
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_load_b; -- 20091130 ajoute
        END IF; -- 20091130 ajoute
      WHEN st_lev_shft_end => -- wait for load command
        level_shifter_dac_ld_cs_n       <= '1'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '0'; -- 20091130 ajoute
        level_shifter_dac_load_indice   <= 15; -- 20091130 ajoute -- 20091201 modifie
        IF (level_shifter_dac_load='1') THEN -- 20091130 ajoute
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_end; -- 20091130 ajoute
        ELSE -- 20091130 ajoute
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_wait; -- 20091130 ajoute
        END IF; -- 20091130 ajoute
      WHEN st_lev_shft_wait => -- wait for load command
        level_shifter_dac_ld_cs_n       <= '1'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '0'; -- 20091130 ajoute
        level_shifter_dac_load_indice   <= 15; -- 20091130 ajoute -- 20091201 modifie
        IF (level_shifter_dac_load='1') THEN -- 20091130 ajoute
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_pre_cs; -- 20091130 ajoute
        ELSE -- 20091130 ajoute
          ladder_fpga_level_shifter_dac_state <= st_lev_shft_wait; -- 20091130 ajoute
        END IF; -- 20091130 ajoute
      WHEN OTHERS => -- unexpected state
        level_shifter_dac_ld_cs_n       <= '1'; -- 20091130 ajoute
        level_shifter_dac_sck_en        <= '0'; -- 20091130 ajoute
        level_shifter_dac_load_indice   <= 15; -- 20091130 ajoute -- 20091201 modifie
        ladder_fpga_level_shifter_dac_state <= st_lev_shft_pre_cs; -- 20091130 ajoute
    END CASE; -- 20091130 ajoute
  END IF; -- 20091130 ajoute
end process proc_ladder_fpga_level_shifter_dac; -- 20091130 ajoute


proc_ladder_fpga_level_shifter_sdi : process(reset_n, ladder_fpga_clock4MHz, ladder_fpga_level_shifter_dac_state) is -- 20091130 ajoute
begin -- 20091130 ajoute
  IF (reset_n='0') then -- 20091130 ajoute
    level_shifter_dac_sdi           <= '0'; -- 20091130 ajoute
  ELSIF ((ladder_fpga_clock4MHz'EVENT) AND (ladder_fpga_clock4MHz='0')) THEN
    CASE ladder_fpga_level_shifter_dac_state is
      WHEN st_lev_shft_load_a => -- load DAC A channel
        level_shifter_dac_sdi   <= level_shifter_dac_a(level_shifter_dac_load_indice); -- 20091130 ajoute
      WHEN st_lev_shft_load_b => -- load DAC B channel
        level_shifter_dac_sdi   <= level_shifter_dac_b(level_shifter_dac_load_indice); -- 20091130 ajoute
      WHEN OTHERS => -- unexpected state
        level_shifter_dac_sdi           <= '0'; -- 20091130 ajoute
    END CASE; -- 20091130 ajoute
  END IF; -- 20091130 ajoute
end process proc_ladder_fpga_level_shifter_sdi; -- 20091130 ajoute


  ladder_fpga_fifo8_usb_clock         <= ladder_fpga_clock1MHz; -- 20090824 ajoute -- 20090826 modifie

  ladder_fpga_ok <= '1'; -- 20090817 ajoute --A_PREVOIR: CALCULER CE BIT D'ERREUR
  dbg_ladder_fpga_adc_bit_count_cs_integer <= CONV_STD_LOGIC_VECTOR(ladder_fpga_adc_bit_count_cs_integer, 4); -- 20090819 ajoute

  fibre_mod_scl  <= 'Z'; -- 20110128 ajoute
  fibre_mod_sda  <= 'Z'; -- 20110128 ajoute


END ladder_fpga_arch;


-- send switch value
--        ladder_fpga_fifo8_to_usb_input <= "0000" & switch_val(3 downto 0);
--        ladder_fpga_fifo8_to_usb_wr <= '1';
--        acquire_state <= acq_send_preamble_1;
--      when acq_send_preamble_1 =>
--        ladder_fpga_fifo8_to_usb_wr <= '0';
--        acquire_state <= acq_send_preamble_2;
--      when acq_send_preamble_2 =>
--        -- send DAC register
--        ladder_fpga_fifo8_to_usb_wr <= '1';
--        ladder_fpga_fifo8_to_usb_input <= 
--        acquire_state <= acq_send_preamble_3;
--      when acq_send_preamble_3 =>
--        ladder_fpga_fifo8_to_usb_wr <= '1';
--        ladder_fpga_fifo8_to_usb_input <= ladder_fpga_sc_level_shifter_dac(17 downto 10) ;
--        acquire_state <= acq_send_preamble_4;
--      when acq_send_preamble_4 =>
--        ladder_fpga_fifo8_to_usb_input <= "000000" & ladder_fpga_sc_level_shifter_dac(9 downto 8) ;
--        acquire_state <= acq_send_preamble_5;
--      when acq_send_preamble_5 =>
--        ladder_fpga_fifo8_to_usb_input <= ladder_fpga_sc_level_shifter_dac(7 downto 0) ;
--        acquire_state <= acq_send_preamble_6;
--      when acq_send_preamble_6 =>
--        ladder_fpga_fifo8_to_usb_wr <= '0';
--        acquire_state <= acq_send_adcs_0;
--        n_adc := 0;
