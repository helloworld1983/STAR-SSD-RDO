set_global_assignment -name TOP_LEVEL_ENTITY "|ladder_fpga" -remove 
set_global_assignment -name FAMILY -remove 
set_global_assignment -name TAO_FILE "myresults.tao" -remove
set_global_assignment -name SOURCES_PER_DESTINATION_INCLUDE_COUNT "1000" -remove 
set_global_assignment -name ROUTER_REGISTER_DUPLICATION ON -remove 
set_global_assignment -name REMOVE_DUPLICATE_LOGIC "OFF" -remove 
set_global_assignment -name REMOVE_DUPLICATE_REGISTERS "OFF" -remove 
set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS "OFF" -remove 
set_global_assignment -name REMOVE_DUPLICATE_REGISTERS "OFF" -remove 
set_global_assignment -name REMOVE_DUPLICATE_LOGIC "OFF" -remove 
set_global_assignment -name EDA_RESYNTHESIS_TOOL "SYNPLIFY PREMIER" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "reset_n" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "card_ser_num\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "card_ser_num\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "card_ser_num\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "card_ser_num\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "card_ser_num\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "card_ser_num\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "clock40mhz_fpga" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "clock40mhz_xtal" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "clock80mhz_adc" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_horloge40_phase\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_horloge40_phase\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_horloge40_phase\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_horloge40_phase\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "roboclock_adc_phase\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "adc_cs_n\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "data_serial\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "level_shifter_dac_ld_cs_n" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "level_shifter_dac_sdi" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "level_shifter_dac_sck" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_magnd_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "pilotage_mvdd_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "des_lock" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[16\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[17\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[18\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[19\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "rdo_to_ladder\[20\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_addr\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_addr\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_addr\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_echelle" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "testin_echelle" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "holdin_echelle" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_fpga_sc_tck" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_fpga_sc_tms" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_fpga_sc_trstb" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_fpga_sc_tdi" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "des_bist_pass" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[16\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[17\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[18\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[19\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[20\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_to_rdo\[21\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_fpga_sc_tdo" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fibre_mod_absent" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fibre_mod_scl" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fibre_mod_sda" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fibre_rx_loss" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fibre_tx_disable" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fibre_tx_fault" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "latchup_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "mux_ref_latchup\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "mux_ref_latchup\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "test_16hybrides" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "hold_16hybrides" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "ladder_fpga_rclk_16hybrides" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenin_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "tokenout_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tck_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tms_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_trstb_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdi_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[8\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[9\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[10\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[11\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[12\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[13\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[14\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_tdo_hybride\[15\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[4\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[5\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[6\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_data\[7\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_present" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_ready_n" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_read_n" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_reset_n" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_rx_empty" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_tx_full" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "usb_write" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "debug_present_n" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "xtal_en" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "sc_serdes_ou_connec" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "fpga_serdes_ou_connec" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "spare_switch" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "dbg_ladder_fpga_adc_bit_count_cs_integer\[0\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "dbg_ladder_fpga_adc_bit_count_cs_integer\[1\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "dbg_ladder_fpga_adc_bit_count_cs_integer\[2\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "dbg_ladder_fpga_adc_bit_count_cs_integer\[3\]" -remove
set_instance_assignment -name io_standard "3.3-V LVCMOS" -to "dbg_ladder_fpga_sc_bypass" -remove
set_location_assignment PIN_A11 -to reset_n -remove 
set_location_assignment PIN_A3 -to card_ser_num\[0\] -remove 
set_location_assignment PIN_A4 -to card_ser_num\[1\] -remove 
set_location_assignment PIN_E1 -to card_ser_num\[2\] -remove 
set_location_assignment PIN_H1 -to card_ser_num\[3\] -remove 
set_location_assignment PIN_L7 -to card_ser_num\[4\] -remove 
set_location_assignment PIN_V1 -to card_ser_num\[5\] -remove 
set_location_assignment PIN_L21 -to crc_error -remove 
set_location_assignment PIN_G2 -to clock40mhz_fpga -remove 
set_location_assignment PIN_G1 -to clock40mhz_xtal -remove 
set_location_assignment PIN_AA3 -to clock80mhz_adc -remove 
set_location_assignment PIN_C2 -to roboclock_horloge40_phase\[0\] -remove 
set_location_assignment PIN_C1 -to roboclock_horloge40_phase\[1\] -remove 
set_location_assignment PIN_B1 -to roboclock_horloge40_phase\[2\] -remove 
set_location_assignment PIN_B2 -to roboclock_horloge40_phase\[3\] -remove 
set_location_assignment PIN_G15 -to roboclock_adc_phase\[0\] -remove 
set_location_assignment PIN_G14 -to roboclock_adc_phase\[1\] -remove 
set_location_assignment PIN_K19 -to roboclock_adc_phase\[2\] -remove 
set_location_assignment PIN_K15 -to roboclock_adc_phase\[3\] -remove 
set_location_assignment PIN_W15 -to roboclock_adc_phase\[4\] -remove 
set_location_assignment PIN_U15 -to roboclock_adc_phase\[5\] -remove 
set_location_assignment PIN_T17 -to roboclock_adc_phase\[6\] -remove 
set_location_assignment PIN_V15 -to roboclock_adc_phase\[7\] -remove 
set_location_assignment PIN_B4 -to adc_cs_n\[0\] -remove 
set_location_assignment PIN_B7 -to adc_cs_n\[1\] -remove 
set_location_assignment PIN_H9 -to adc_cs_n\[2\] -remove 
set_location_assignment PIN_G9 -to adc_cs_n\[3\] -remove 
set_location_assignment PIN_B5 -to adc_cs_n\[4\] -remove 
set_location_assignment PIN_C7 -to adc_cs_n\[5\] -remove 
set_location_assignment PIN_C8 -to adc_cs_n\[6\] -remove 
set_location_assignment PIN_G10 -to adc_cs_n\[7\] -remove 
set_location_assignment PIN_AA8 -to data_serial\[0\] -remove 
set_location_assignment PIN_M6 -to data_serial\[1\] -remove 
set_location_assignment PIN_AA9 -to data_serial\[2\] -remove 
set_location_assignment PIN_E11 -to data_serial\[3\] -remove 
set_location_assignment PIN_AB13 -to data_serial\[4\] -remove 
set_location_assignment PIN_V12 -to data_serial\[5\] -remove 
set_location_assignment PIN_R22 -to data_serial\[6\] -remove 
set_location_assignment PIN_G22 -to data_serial\[7\] -remove 
set_location_assignment PIN_M2 -to data_serial\[8\] -remove 
set_location_assignment PIN_N5 -to data_serial\[9\] -remove 
set_location_assignment PIN_B8 -to data_serial\[10\] -remove 
set_location_assignment PIN_A9 -to data_serial\[11\] -remove 
set_location_assignment PIN_AB10 -to data_serial\[12\] -remove 
set_location_assignment PIN_V11 -to data_serial\[13\] -remove 
set_location_assignment PIN_AA13 -to data_serial\[14\] -remove 
set_location_assignment PIN_P20 -to data_serial\[15\] -remove 
set_location_assignment PIN_U9 -to level_shifter_dac_ld_cs_n -remove 
set_location_assignment PIN_V9 -to level_shifter_dac_sdi -remove 
set_location_assignment PIN_T10 -to level_shifter_dac_sck -remove 
set_location_assignment PIN_K8 -to pilotage_magnd_hybride\[0\] -remove 
set_location_assignment PIN_G13 -to pilotage_magnd_hybride\[1\] -remove 
set_location_assignment PIN_C15 -to pilotage_magnd_hybride\[2\] -remove 
set_location_assignment PIN_B14 -to pilotage_magnd_hybride\[3\] -remove 
set_location_assignment PIN_B13 -to pilotage_magnd_hybride\[4\] -remove 
set_location_assignment PIN_F21 -to pilotage_magnd_hybride\[5\] -remove 
set_location_assignment PIN_B15 -to pilotage_magnd_hybride\[6\] -remove 
set_location_assignment PIN_D15 -to pilotage_magnd_hybride\[7\] -remove 
set_location_assignment PIN_L16 -to pilotage_magnd_hybride\[8\] -remove 
set_location_assignment PIN_V22 -to pilotage_magnd_hybride\[9\] -remove 
set_location_assignment PIN_AB19 -to pilotage_magnd_hybride\[10\] -remove 
set_location_assignment PIN_AA20 -to pilotage_magnd_hybride\[11\] -remove 
set_location_assignment PIN_AB20 -to pilotage_magnd_hybride\[12\] -remove 
set_location_assignment PIN_AA4 -to pilotage_magnd_hybride\[13\] -remove 
set_location_assignment PIN_AA2 -to pilotage_magnd_hybride\[14\] -remove 
set_location_assignment PIN_AA16 -to pilotage_magnd_hybride\[15\] -remove 
set_location_assignment PIN_K7 -to pilotage_mvdd_hybride\[0\] -remove 
set_location_assignment PIN_J7 -to pilotage_mvdd_hybride\[1\] -remove 
set_location_assignment PIN_J21 -to pilotage_mvdd_hybride\[2\] -remove 
set_location_assignment PIN_G11 -to pilotage_mvdd_hybride\[3\] -remove 
set_location_assignment PIN_E13 -to pilotage_mvdd_hybride\[4\] -remove 
set_location_assignment PIN_J22 -to pilotage_mvdd_hybride\[5\] -remove 
set_location_assignment PIN_U22 -to pilotage_mvdd_hybride\[6\] -remove 
set_location_assignment PIN_L22 -to pilotage_mvdd_hybride\[7\] -remove 
set_location_assignment PIN_U21 -to pilotage_mvdd_hybride\[8\] -remove 
set_location_assignment PIN_Y22 -to pilotage_mvdd_hybride\[9\] -remove 
set_location_assignment PIN_AB8 -to pilotage_mvdd_hybride\[10\] -remove 
set_location_assignment PIN_AB4 -to pilotage_mvdd_hybride\[11\] -remove 
set_location_assignment PIN_C21 -to pilotage_mvdd_hybride\[12\] -remove 
set_location_assignment PIN_AB15 -to pilotage_mvdd_hybride\[13\] -remove 
set_location_assignment PIN_V21 -to pilotage_mvdd_hybride\[14\] -remove 
set_location_assignment PIN_AA7 -to pilotage_mvdd_hybride\[15\] -remove 
set_location_assignment PIN_V2 -to des_lock -remove 
set_location_assignment PIN_J2 -to rdo_to_ladder\[10\] -remove 
set_location_assignment PIN_V16 -to rdo_to_ladder\[11\] -remove 
set_location_assignment PIN_P4 -to rdo_to_ladder\[12\] -remove 
set_location_assignment PIN_AA5 -to rdo_to_ladder\[13\] -remove 
set_location_assignment PIN_N17 -to rdo_to_ladder\[14\] -remove 
set_location_assignment PIN_AB5 -to rdo_to_ladder\[15\] -remove 
set_location_assignment PIN_AB16 -to rdo_to_ladder\[16\] -remove 
set_location_assignment PIN_P3 -to rdo_to_ladder\[17\] -remove 
set_location_assignment PIN_T1 -to rdo_to_ladder\[18\] -remove 
set_location_assignment PIN_V5 -to rdo_to_ladder\[19\] -remove 
set_location_assignment PIN_U14 -to rdo_to_ladder\[20\] -remove 
set_location_assignment PIN_P2 -to ladder_addr\[0\] -remove 
set_location_assignment PIN_R1 -to ladder_addr\[1\] -remove 
set_location_assignment PIN_U2 -to ladder_addr\[2\] -remove 
set_location_assignment PIN_AB12 -to tokenin_echelle -remove 
set_location_assignment PIN_AA11 -to testin_echelle -remove 
set_location_assignment PIN_V8 -to holdin_echelle -remove 
set_location_assignment PIN_T2 -to ladder_fpga_sc_tck -remove 
set_location_assignment PIN_G3 -to ladder_fpga_sc_tms -remove 
set_location_assignment PIN_AB11 -to ladder_fpga_sc_trstb -remove 
set_location_assignment PIN_Y7 -to ladder_fpga_sc_tdi -remove 
set_location_assignment PIN_W2 -to des_bist_pass -remove 
set_location_assignment PIN_B9 -to ladder_to_rdo\[0\] -remove 
set_location_assignment PIN_U1 -to ladder_to_rdo\[1\] -remove 
set_location_assignment PIN_R2 -to ladder_to_rdo\[2\] -remove 
set_location_assignment PIN_F2 -to ladder_to_rdo\[3\] -remove 
set_location_assignment PIN_R7 -to ladder_to_rdo\[4\] -remove 
set_location_assignment PIN_N2 -to ladder_to_rdo\[5\] -remove 
set_location_assignment PIN_E6 -to ladder_to_rdo\[6\] -remove 
set_location_assignment PIN_W13 -to ladder_to_rdo\[7\] -remove 
set_location_assignment PIN_N1 -to ladder_to_rdo\[8\] -remove 
set_location_assignment PIN_M8 -to ladder_to_rdo\[9\] -remove 
set_location_assignment PIN_M1 -to ladder_to_rdo\[10\] -remove 
set_location_assignment PIN_J3 -to ladder_to_rdo\[11\] -remove 
set_location_assignment PIN_Y10 -to ladder_to_rdo\[12\] -remove 
set_location_assignment PIN_J1 -to ladder_to_rdo\[13\] -remove 
set_location_assignment PIN_H10 -to ladder_to_rdo\[14\] -remove 
set_location_assignment PIN_F1 -to ladder_to_rdo\[15\] -remove 
set_location_assignment PIN_AA10 -to ladder_to_rdo\[16\] -remove 
set_location_assignment PIN_J4 -to ladder_to_rdo\[17\] -remove 
set_location_assignment PIN_M5 -to ladder_to_rdo\[18\] -remove 
set_location_assignment PIN_M3 -to ladder_to_rdo\[19\] -remove 
set_location_assignment PIN_D2 -to ladder_to_rdo\[20\] -remove 
set_location_assignment PIN_C4 -to ladder_to_rdo\[21\] -remove 
set_location_assignment PIN_AA1 -to ladder_fpga_sc_tdo -remove 
set_location_assignment PIN_W1 -to fibre_mod_absent -remove 
set_location_assignment PIN_G4 -to fibre_mod_scl -remove 
set_location_assignment PIN_B10 -to fibre_mod_sda -remove 
set_location_assignment PIN_D6 -to fibre_rx_loss -remove 
set_location_assignment PIN_Y1 -to fibre_tx_disable -remove 
set_location_assignment PIN_H2 -to fibre_tx_fault -remove 
set_location_assignment PIN_T15 -to latchup_hybride\[0\] -remove 
set_location_assignment PIN_R19 -to latchup_hybride\[1\] -remove 
set_location_assignment PIN_F17 -to latchup_hybride\[2\] -remove 
set_location_assignment PIN_W19 -to latchup_hybride\[3\] -remove 
set_location_assignment PIN_E15 -to latchup_hybride\[4\] -remove 
set_location_assignment PIN_H11 -to latchup_hybride\[5\] -remove 
set_location_assignment PIN_B18 -to latchup_hybride\[6\] -remove 
set_location_assignment PIN_K21 -to latchup_hybride\[7\] -remove 
set_location_assignment PIN_U7 -to latchup_hybride\[8\] -remove 
set_location_assignment PIN_F15 -to latchup_hybride\[9\] -remove 
set_location_assignment PIN_H6 -to latchup_hybride\[10\] -remove 
set_location_assignment PIN_V13 -to latchup_hybride\[11\] -remove 
set_location_assignment PIN_W22 -to latchup_hybride\[12\] -remove 
set_location_assignment PIN_M15 -to latchup_hybride\[13\] -remove 
set_location_assignment PIN_Y21 -to latchup_hybride\[14\] -remove 
set_location_assignment PIN_W21 -to latchup_hybride\[15\] -remove 
set_location_assignment PIN_U11 -to mux_ref_latchup\[0\] -remove 
set_location_assignment PIN_B17 -to mux_ref_latchup\[1\] -remove 
set_location_assignment PIN_F13 -to test_16hybrides -remove 
set_location_assignment PIN_K18 -to hold_16hybrides -remove 
set_location_assignment PIN_A15 -to ladder_fpga_rclk_16hybrides -remove 
set_location_assignment PIN_D10 -to tokenin_hybride\[0\] -remove 
set_location_assignment PIN_D13 -to tokenin_hybride\[1\] -remove 
set_location_assignment PIN_H12 -to tokenin_hybride\[2\] -remove 
set_location_assignment PIN_J15 -to tokenin_hybride\[3\] -remove 
set_location_assignment PIN_J17 -to tokenin_hybride\[4\] -remove 
set_location_assignment PIN_F9 -to tokenin_hybride\[5\] -remove 
set_location_assignment PIN_H17 -to tokenin_hybride\[6\] -remove 
set_location_assignment PIN_J18 -to tokenin_hybride\[7\] -remove 
set_location_assignment PIN_A20 -to tokenin_hybride\[8\] -remove 
set_location_assignment PIN_E21 -to tokenin_hybride\[9\] -remove 
set_location_assignment PIN_B19 -to tokenin_hybride\[10\] -remove 
set_location_assignment PIN_M16 -to tokenin_hybride\[11\] -remove 
set_location_assignment PIN_F19 -to tokenin_hybride\[12\] -remove 
set_location_assignment PIN_N14 -to tokenin_hybride\[13\] -remove 
set_location_assignment PIN_L8 -to tokenin_hybride\[14\] -remove 
set_location_assignment PIN_AA14 -to tokenin_hybride\[15\] -remove 
set_location_assignment PIN_B6 -to tokenout_hybride\[0\] -remove 
set_location_assignment PIN_F10 -to tokenout_hybride\[1\] -remove 
set_location_assignment PIN_N21 -to tokenout_hybride\[2\] -remove 
set_location_assignment PIN_N6 -to tokenout_hybride\[3\] -remove 
set_location_assignment PIN_E22 -to tokenout_hybride\[4\] -remove 
set_location_assignment PIN_E9 -to tokenout_hybride\[5\] -remove 
set_location_assignment PIN_A16 -to tokenout_hybride\[6\] -remove 
set_location_assignment PIN_AA15 -to tokenout_hybride\[7\] -remove 
set_location_assignment PIN_E12 -to tokenout_hybride\[8\] -remove 
set_location_assignment PIN_AA17 -to tokenout_hybride\[9\] -remove 
set_location_assignment PIN_N18 -to tokenout_hybride\[10\] -remove 
set_location_assignment PIN_U20 -to tokenout_hybride\[11\] -remove 
set_location_assignment PIN_Y17 -to tokenout_hybride\[12\] -remove 
set_location_assignment PIN_R21 -to tokenout_hybride\[13\] -remove 
set_location_assignment PIN_F22 -to tokenout_hybride\[14\] -remove 
set_location_assignment PIN_AA12 -to tokenout_hybride\[15\] -remove 
set_location_assignment PIN_E3 -to temperature -remove 
set_location_assignment PIN_D22 -to sc_tck_hybride\[0\] -remove 
set_location_assignment PIN_A10 -to sc_tck_hybride\[1\] -remove 
set_location_assignment PIN_A14 -to sc_tck_hybride\[2\] -remove 
set_location_assignment PIN_A13 -to sc_tck_hybride\[3\] -remove 
set_location_assignment PIN_C22 -to sc_tck_hybride\[4\] -remove 
set_location_assignment PIN_H22 -to sc_tck_hybride\[5\] -remove 
set_location_assignment PIN_C13 -to sc_tck_hybride\[6\] -remove 
set_location_assignment PIN_E16 -to sc_tck_hybride\[7\] -remove 
set_location_assignment PIN_F20 -to sc_tck_hybride\[8\] -remove 
set_location_assignment PIN_AA19 -to sc_tck_hybride\[9\] -remove 
set_location_assignment PIN_B21 -to sc_tck_hybride\[10\] -remove 
set_location_assignment PIN_R14 -to sc_tck_hybride\[11\] -remove 
set_location_assignment PIN_P22 -to sc_tck_hybride\[12\] -remove 
set_location_assignment PIN_H7 -to sc_tck_hybride\[13\] -remove 
set_location_assignment PIN_Y13 -to sc_tck_hybride\[14\] -remove 
set_location_assignment PIN_T11 -to sc_tck_hybride\[15\] -remove 
set_location_assignment PIN_T9 -to sc_tms_hybride\[0\] -remove 
set_location_assignment PIN_P5 -to sc_tms_hybride\[1\] -remove 
set_location_assignment PIN_F16 -to sc_tms_hybride\[2\] -remove 
set_location_assignment PIN_J16 -to sc_tms_hybride\[3\] -remove 
set_location_assignment PIN_K16 -to sc_tms_hybride\[4\] -remove 
set_location_assignment PIN_R5 -to sc_tms_hybride\[5\] -remove 
set_location_assignment PIN_H19 -to sc_tms_hybride\[6\] -remove 
set_location_assignment PIN_A19 -to sc_tms_hybride\[7\] -remove 
set_location_assignment PIN_B16 -to sc_tms_hybride\[8\] -remove 
set_location_assignment PIN_AA18 -to sc_tms_hybride\[9\] -remove 
set_location_assignment PIN_AB18 -to sc_tms_hybride\[10\] -remove 
set_location_assignment PIN_E7 -to sc_tms_hybride\[11\] -remove 
set_location_assignment PIN_W10 -to sc_tms_hybride\[12\] -remove 
set_location_assignment PIN_W17 -to sc_tms_hybride\[13\] -remove 
set_location_assignment PIN_T12 -to sc_tms_hybride\[14\] -remove 
set_location_assignment PIN_E10 -to sc_tms_hybride\[15\] -remove 
set_location_assignment PIN_F12 -to sc_trstb_hybride\[0\] -remove 
set_location_assignment PIN_C19 -to sc_trstb_hybride\[1\] -remove 
set_location_assignment PIN_D19 -to sc_trstb_hybride\[2\] -remove 
set_location_assignment PIN_B22 -to sc_trstb_hybride\[3\] -remove 
set_location_assignment PIN_W20 -to sc_trstb_hybride\[4\] -remove 
set_location_assignment PIN_U13 -to sc_trstb_hybride\[5\] -remove 
set_location_assignment PIN_M19 -to sc_trstb_hybride\[6\] -remove 
set_location_assignment PIN_R16 -to sc_trstb_hybride\[7\] -remove 
set_location_assignment PIN_N15 -to sc_trstb_hybride\[8\] -remove 
set_location_assignment PIN_M21 -to sc_trstb_hybride\[9\] -remove 
set_location_assignment PIN_R15 -to sc_trstb_hybride\[10\] -remove 
set_location_assignment PIN_AB7 -to sc_trstb_hybride\[11\] -remove 
set_location_assignment PIN_H20 -to sc_trstb_hybride\[12\] -remove 
set_location_assignment PIN_P21 -to sc_trstb_hybride\[13\] -remove 
set_location_assignment PIN_L6 -to sc_trstb_hybride\[14\] -remove 
set_location_assignment PIN_J6 -to sc_trstb_hybride\[15\] -remove 
set_location_assignment PIN_M4 -to sc_tdi_hybride\[0\] -remove 
set_location_assignment PIN_F11 -to sc_tdi_hybride\[1\] -remove 
set_location_assignment PIN_H16 -to sc_tdi_hybride\[2\] -remove 
set_location_assignment PIN_K17 -to sc_tdi_hybride\[3\] -remove 
set_location_assignment PIN_M20 -to sc_tdi_hybride\[4\] -remove 
set_location_assignment PIN_AB9 -to sc_tdi_hybride\[5\] -remove 
set_location_assignment PIN_D21 -to sc_tdi_hybride\[6\] -remove 
set_location_assignment PIN_AB17 -to sc_tdi_hybride\[7\] -remove 
set_location_assignment PIN_N20 -to sc_tdi_hybride\[8\] -remove 
set_location_assignment PIN_A17 -to sc_tdi_hybride\[9\] -remove 
set_location_assignment PIN_D20 -to sc_tdi_hybride\[10\] -remove 
set_location_assignment PIN_C17 -to sc_tdi_hybride\[11\] -remove 
set_location_assignment PIN_N22 -to sc_tdi_hybride\[12\] -remove 
set_location_assignment PIN_R17 -to sc_tdi_hybride\[13\] -remove 
set_location_assignment PIN_C6 -to sc_tdi_hybride\[14\] -remove 
set_location_assignment PIN_R11 -to sc_tdi_hybride\[15\] -remove 
set_location_assignment PIN_A5 -to sc_tdo_hybride\[0\] -remove 
set_location_assignment PIN_B11 -to sc_tdo_hybride\[1\] -remove 
set_location_assignment PIN_A18 -to sc_tdo_hybride\[2\] -remove 
set_location_assignment PIN_A12 -to sc_tdo_hybride\[3\] -remove 
set_location_assignment PIN_G21 -to sc_tdo_hybride\[4\] -remove 
set_location_assignment PIN_B12 -to sc_tdo_hybride\[5\] -remove 
set_location_assignment PIN_T21 -to sc_tdo_hybride\[6\] -remove 
set_location_assignment PIN_H15 -to sc_tdo_hybride\[7\] -remove 
set_location_assignment PIN_G18 -to sc_tdo_hybride\[8\] -remove 
set_location_assignment PIN_H21 -to sc_tdo_hybride\[9\] -remove 
set_location_assignment PIN_B20 -to sc_tdo_hybride\[10\] -remove 
set_location_assignment PIN_V14 -to sc_tdo_hybride\[11\] -remove 
set_location_assignment PIN_R12 -to sc_tdo_hybride\[12\] -remove 
set_location_assignment PIN_P15 -to sc_tdo_hybride\[13\] -remove 
set_location_assignment PIN_R13 -to sc_tdo_hybride\[14\] -remove 
set_location_assignment PIN_U12 -to sc_tdo_hybride\[15\] -remove 
set_location_assignment PIN_P1 -to usb_data\[0\] -remove 
set_location_assignment PIN_AB3 -to usb_data\[1\] -remove 
set_location_assignment PIN_C3 -to usb_data\[2\] -remove 
set_location_assignment PIN_T8 -to usb_data\[3\] -remove 
set_location_assignment PIN_M7 -to usb_data\[4\] -remove 
set_location_assignment PIN_AA21 -to usb_data\[5\] -remove 
set_location_assignment PIN_Y6 -to usb_data\[6\] -remove 
set_location_assignment PIN_N8 -to usb_data\[7\] -remove 
set_location_assignment PIN_Y2 -to usb_present -remove 
set_location_assignment PIN_AB14 -to usb_ready_n -remove 
set_location_assignment PIN_T4 -to usb_read_n -remove 
set_location_assignment PIN_A7 -to usb_reset_n -remove 
set_location_assignment PIN_M22 -to usb_rx_empty -remove 
set_location_assignment PIN_A6 -to usb_tx_full -remove 
set_location_assignment PIN_AA22 -to usb_write -remove 
set_location_assignment PIN_B3 -to debug_present_n -remove 
set_location_assignment PIN_D17 -to xtal_en -remove 
set_location_assignment PIN_A8 -to sc_serdes_ou_connec -remove 
set_location_assignment PIN_C10 -to fpga_serdes_ou_connec -remove 
set_location_assignment PIN_E4 -to spare_switch -remove 
