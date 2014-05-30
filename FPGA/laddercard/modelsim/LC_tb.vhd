LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


ENTITY LC_tb IS
END ENTITY LC_tb;

ARCHITECTURE LC_tb_arch OF LC_tb IS


   COMPONENT ladder_fpga
      PORT (
         reset_n                                  : IN    STD_LOGIC;
         card_ser_num                             : IN    STD_LOGIC_VECTOR (5 DOWNTO 0);
--      hv_side                   : IN    STD_LOGIC; -- 20100108 ajoute -- 20100310 enleve
         crc_error                                : INOUT STD_LOGIC;  -- 20100311 ajoute
         -- CLOCKS --
         clock40mhz_fpga                          : IN    STD_LOGIC;
         clock40mhz_xtal                          : IN    STD_LOGIC;  -- 20090812 ajoute
         clock80mhz_adc                           : OUT   STD_LOGIC;  -- 20090814 ajoute
         roboclock_horloge40_phase                : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
         roboclock_adc_phase                      : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
         -- ADC --
         adc_cs_n                                 : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
         data_serial                              : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- MULTIPLEXEURS --
         level_shifter_dac_ld_cs_n                : OUT   STD_LOGIC;  -- 20091130 ajoute
         level_shifter_dac_sdi                    : OUT   STD_LOGIC;  -- 20091130 ajoute
         level_shifter_dac_sck                    : OUT   STD_LOGIC;  -- 20091130 ajoute
         pilotage_magnd_hybride                   : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         pilotage_mvdd_hybride                    : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- DESERIALISEUR --
         des_lock                                 : IN    STD_LOGIC;
--      rdo_to_ladder             : IN    STD_LOGIC_VECTOR (20 DOWNTO  0); -- 20090629 enleve
         rdo_to_ladder                            : IN    STD_LOGIC_VECTOR (20 DOWNTO 10);
         ladder_addr                              : IN    STD_LOGIC_VECTOR (2 DOWNTO 0);
         tokenin_echelle                          : IN    STD_LOGIC;  -- token injection for acquisition
         testin_echelle                           : IN    STD_LOGIC;
         holdin_echelle                           : IN    STD_LOGIC;
         ladder_fpga_sc_tck                       : IN    STD_LOGIC;
         ladder_fpga_sc_tms                       : IN    STD_LOGIC;
         ladder_fpga_sc_trstb                     : IN    STD_LOGIC;
         ladder_fpga_sc_tdi                       : IN    STD_LOGIC;
         des_bist_pass                            : IN    STD_LOGIC;
         -- SERIALISEUR --
         ladder_to_rdo                            : OUT   STD_LOGIC_VECTOR (21 DOWNTO 0);
         ladder_fpga_sc_tdo                       : OUT   STD_LOGIC;
         -- FIBRE OPTIQUE --
         fibre_mod_absent                         : IN    STD_LOGIC;
         fibre_mod_scl                            : INOUT STD_LOGIC;
         fibre_mod_sda                            : INOUT STD_LOGIC;
         fibre_rx_loss                            : IN    STD_LOGIC;
         fibre_tx_disable                         : OUT   STD_LOGIC;  -- must be '0' 
         fibre_tx_fault                           : IN    STD_LOGIC;  -- 20090305 ajoute
         -- SECURITE ALICE128 (LATCHUP) --
         latchup_hybride                          : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
         mux_ref_latchup                          : OUT   STD_LOGIC_VECTOR (1 DOWNTO 0);
         -- ACQUISITION --
         test_16hybrides                          : OUT   STD_LOGIC;
         hold_16hybrides                          : OUT   STD_LOGIC;
--      rclk_echelle                      : IN   STD_LOGIC; -- 20090309 ajoute -- 20090814 enleve
--      rclk_16hybrides                   :   OUT STD_LOGIC; -- 20090309 ajoute -- 20090814 enleve
         ladder_fpga_rclk_16hybrides              : OUT   STD_LOGIC;
         tokenin_hybride                          : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         tokenout_hybride                         : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- SLOW-CONTROL --
         temperature                              : INOUT STD_LOGIC;
         sc_tck_hybride                           : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         sc_tms_hybride                           : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         sc_trstb_hybride                         : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         sc_tdi_hybride                           : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0);
         sc_tdo_hybride                           : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
         -- USB DEBUG --
         usb_data                                 : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         usb_present                              : IN    STD_LOGIC;  -- 20090825 ajoute
         usb_ready_n                              : IN    STD_LOGIC;  -- 20090305 ajoute
         usb_read_n                               : OUT   STD_LOGIC;  -- 20090305 ajoute
         usb_reset_n                              : INOUT STD_LOGIC;  -- ATTENTION : open-colector 
         usb_rx_empty                             : IN    STD_LOGIC;  -- 20090305 ajoute
         usb_tx_full                              : IN    STD_LOGIC;  -- 20090305 ajoute
         usb_write                                : OUT   STD_LOGIC;  -- 16-jun-2011 mjl
         debug_present_n                          : IN    STD_LOGIC;  -- 20100401 ajoute
         xtal_en                                  : IN    STD_LOGIC;  -- 20100401 ajoute
         sc_serdes_ou_connec                      : IN    STD_LOGIC;  -- 20100401 ajoute
         fpga_serdes_ou_connec                    : IN    STD_LOGIC;  -- 20100401 ajoute
         spare_switch                             : IN    STD_LOGIC;  -- 20100401 ajoute
         -- DEBUG --
         dbg_ladder_fpga_adc_bit_count_cs_integer : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
         dbg_ladder_fpga_sc_bypass                : OUT   STD_LOGIC
         );
   END COMPONENT;


   SIGNAL tokenin_echelle      : STD_LOGIC;  -- token injection for acquisition
   SIGNAL testin_echelle       : STD_LOGIC;
   SIGNAL holdin_echelle       : STD_LOGIC;
   SIGNAL ladder_fpga_sc_tck   : STD_LOGIC;
   SIGNAL ladder_fpga_sc_tms   : STD_LOGIC;
   SIGNAL ladder_fpga_sc_trstb : STD_LOGIC;
   SIGNAL ladder_fpga_sc_tdi   : STD_LOGIC;


   SIGNAL CLK40 : STD_LOGIC := '0';
   SIGNAL RSTn  : STD_LOGIC := '0';

   SIGNAL  ladder_fpga_rclk_16hybrides : STD_LOGIC;
   SIGNAL cnt_rclk  : INTEGER := 0;

BEGIN  -- ARCHITECTURE LC_tb_arch

   CLK40 <= NOT CLK40 AFTER 12.5 NS;
   RSTn  <= '1'       AFTER 250 NS;

   PROCESS IS
   BEGIN  -- PROCESS
      WAIT FOR 10 US;
      holdin_echelle  <= '1';
      WAIT FOR 200 NS;
      tokenin_echelle <= '1';
      WAIT FOR 200 NS;
      tokenin_echelle <= '0';
      WAIT FOR 175 US;
      holdin_echelle  <= '0';
   END PROCESS;

   PROCESS (ladder_fpga_rclk_16hybrides) IS
   BEGIN  -- PROCESS
      IF ladder_fpga_rclk_16hybrides'event AND ladder_fpga_rclk_16hybrides = '1' THEN  -- rising clock edge
         cnt_rclk <= cnt_rclk + 1;
      END IF;
   END PROCESS;


   ladder_fpga_inst : ladder_fpga
      PORT MAP (
         reset_n                                  => RSTn,
         card_ser_num                             => "001100",
--      hv_side                   : IN    STD_LOGIC; -- 20100108 ajoute -- 20100310 enleve
         crc_error                                => OPEN,
         -- CLOCKS --
         clock40mhz_fpga                          => CLK40,
         clock40mhz_xtal                          => '0',
         clock80mhz_adc                           => OPEN,
         roboclock_horloge40_phase                => OPEN,
         roboclock_adc_phase                      => OPEN,
         -- ADC --
         adc_cs_n                                 => OPEN,
         data_serial                              => x"0000",
         -- MULTIPLEXEURS --
         level_shifter_dac_ld_cs_n                => OPEN,
         level_shifter_dac_sdi                    => OPEN,
         level_shifter_dac_sck                    => OPEN,
         pilotage_magnd_hybride                   => OPEN,
         pilotage_mvdd_hybride                    => OPEN,
         -- DESERIALISEUR --
         des_lock                                 => '1',
--      rdo_to_ladder             : IN    STD_LOGIC_VECTOR (20 DOWNTO  0); -- 20090629 enleve
         rdo_to_ladder                            => "00000000000",
         ladder_addr                              => "101",
         tokenin_echelle                          => tokenin_echelle,
         testin_echelle                           => testin_echelle,
         holdin_echelle                           => holdin_echelle,
         ladder_fpga_sc_tck                       => ladder_fpga_sc_tck,
         ladder_fpga_sc_tms                       => ladder_fpga_sc_tms,
         ladder_fpga_sc_trstb                     => ladder_fpga_sc_trstb,
         ladder_fpga_sc_tdi                       => ladder_fpga_sc_tdi,
         des_bist_pass                            => '1',
         -- SERIALISEUR --
         ladder_to_rdo                            => OPEN,
         ladder_fpga_sc_tdo                       => OPEN,
         -- FIBRE OPTIQUE --
         fibre_mod_absent                         => '0',
         fibre_mod_scl                            => OPEN,
         fibre_mod_sda                            => OPEN,
         fibre_rx_loss                            => '0',
         fibre_tx_disable                         => OPEN,
         fibre_tx_fault                           => '0',
         -- SECURITE ALICE128 (LATCHUP) --
         latchup_hybride                          => x"0000",
         mux_ref_latchup                          => OPEN,
         -- ACQUISITION --
         test_16hybrides                          => OPEN,
         hold_16hybrides                          => OPEN,
--      rclk_echelle                      : IN   STD_LOGIC; -- 20090309 ajoute -- 20090814 enleve
--      rclk_16hybrides                   :   OUT STD_LOGIC; -- 20090309 ajoute -- 20090814 enleve
         ladder_fpga_rclk_16hybrides              => ladder_fpga_rclk_16hybrides,
         tokenin_hybride                          => OPEN,
         tokenout_hybride                         => x"0000",
         -- SLOW-CONTROL --
         temperature                              => OPEN,
         sc_tck_hybride                           => OPEN,
         sc_tms_hybride                           => OPEN,
         sc_trstb_hybride                         => OPEN,
         sc_tdi_hybride                           => OPEN,
         sc_tdo_hybride                           => x"FFFF",
         -- USB DEBUG --
         usb_data                                 => OPEN,
         usb_present                              => 'Z',
         usb_ready_n                              => 'Z',
         usb_read_n                               => OPEN,
         usb_reset_n                              => OPEN,
         usb_rx_empty                             => 'Z',
         usb_tx_full                              => 'Z',
         usb_write                                => OPEN,
         debug_present_n                          => '1',
         xtal_en                                  => 'Z',
         sc_serdes_ou_connec                      => 'Z',
         fpga_serdes_ou_connec                    => 'Z',
         spare_switch                             => '0',
         -- DEBUG --
         dbg_ladder_fpga_adc_bit_count_cs_integer => OPEN,
         dbg_ladder_fpga_sc_bypass                => OPEN
         );


END ARCHITECTURE LC_tb_arch;
