#define_clock  {ladder_fpga_sc_tck} -name  {sc_tck} -freq  {10} -clockgroup  {default_clkgroup_0} 
define_clock  {p:ladder_fpga_sc_tck} -name sc_tck -freq {10} -clockgroup {default_clkgroup_0} 

#define_clock  {COMP_ladder_fpga_SC_TAP_CONTROL.clockIR} -name  {clockIR} -freq  {10} -clockgroup  {default_clkgroup_0} 
define_clock {COMP_ladder_fpga_SC_TAP_CONTROL.clockIR} -name {clockIR} -freq {10} -clockgroup {default_clkgroup_0} 

#define_clock  {COMP_ladder_fpga_SC_TAP_CONTROL.clockDR} -name  {clockDR} -freq  {10} -clockgroup  {default_clkgroup_0} 
define_clock {COMP_ladder_fpga_SC_TAP_CONTROL.clockDR} -name {clockDR} -freq {10} -clockgroup {default_clkgroup_0} 

#define_clock  {temperature} -name  {temperature} -freq  {10} -clockgroup  {default_clkgroup_1} 
define_clock  {p:temperature} -name {temperature} -freq {10} -clockgroup {default_clkgroup_1} 

#define_clock  {comp_mega_func_pll_40MHz_switchover_cycloneIII.altpll_component} -name  {switchover} -freq  {40} -clockgroup  {default_clkgroup_2} 
define_clock  {i:comp_mega_func_pll_40MHz_switchover_cycloneIII.altpll_component} -name switchover -freq {40} -clockgroup {default_clkgroup_2} 

#define_clock  {comp_mesure_temperature.ck_4M} -name  {tempclk4M} -freq  {4} -clockgroup  {default_clkgroup_1} 
define_clock {comp_mesure_temperature.ck_4M} -name {tempclk4M} -freq {4} -clockgroup {default_clkgroup_1} 

#define_clock  {clock40mhz_fpga} -name  {clock40mhz_fpga} -freq  {40} -clockgroup  {default_clkgroup_3} 
define_clock  {p:clock40mhz_fpga} -name {clock40mhz_fpga} -freq {40} -clockgroup {default_clkgroup_3} 

#define_clock  {clock40mhz_xtal} -name  {clock40mhz_xtal} -freq  {40} -clockgroup  {default_clkgroup_4} 
define_clock  {p:clock40mhz_xtal} -name {clock40mhz_xtal} -freq {40} -clockgroup {default_clkgroup_4} 

#define_clock  {ladder_fpga_clock80MHz} -name  {ladder_fpga_clock80MHz} -freq  {80} -clockgroup  {default_clkgroup_2} 
define_clock {ladder_fpga_clock80MHz} -name {ladder_fpga_clock80MHz} -freq {80} -clockgroup {default_clkgroup_2} 

#define_clock  {COMP_ladder_fpga_SC_TAP_CONTROL.updateIR} -name  {updateIR} -freq  {10} -clockgroup  {default_clkgroup_0} 
define_clock  {i:COMP_ladder_fpga_SC_TAP_CONTROL.updateIR t:COMP_ladder_fpga_SC_TAP_CONTROL.updateIR.q} -name {updateIR} -freq {10} -clockgroup {default_clkgroup_0} 

#define_clock  {ladder_fpga_sc_updateDR} -name  {updateDR} -freq  {10} -clockgroup  {default_clkgroup_0} 
define_clock {ladder_fpga_sc_updateDR} -name {updateDR} -freq {10} -clockgroup {default_clkgroup_0} 

#define_io_standard -default_output -delay_type  {output}  {syn_pad_type}  {LVCMOS_25} 
define_io_standard -default_output -delay_type {output} syn_pad_type {LVCMOS_25} 

#define_false_path -from [get_ports {reset_n}] -to  {all_registers} 
define_false_path -from  {p:reset_n} -to {all_registers} 

#define_attribute [get_ports {fibre_mod_scl}]  {altera_chip_pin_lc}  {@G4} 
define_attribute  {p:fibre_mod_scl} {altera_chip_pin_lc} {@G4} 

#define_attribute [get_ports {usb_tx_full}]  {altera_chip_pin_lc}  {@A6} 
define_attribute  {p:usb_tx_full} {altera_chip_pin_lc} {@A6} 

#define_attribute [get_ports {tokenout_hybride[13]}]  {altera_chip_pin_lc}  {@R21} 
define_attribute  {b:tokenout_hybride[13]} {altera_chip_pin_lc} {@R21} 

#define_attribute [get_ports {pilotage_magnd_hybride[3]}]  {altera_chip_pin_lc}  {@B14} 
define_attribute  {b:pilotage_magnd_hybride[3]} {altera_chip_pin_lc} {@B14} 

#define_attribute [get_ports {data_serial[11]}]  {altera_chip_pin_lc}  {@A9} 
define_attribute  {b:data_serial[11]} {altera_chip_pin_lc} {@A9} 

#define_attribute [get_ports {usb_data[2]}]  {altera_chip_pin_lc}  {@C3} 
define_attribute  {b:usb_data[2]} {altera_chip_pin_lc} {@C3} 

#define_attribute [get_ports {sc_tdo_hybride[2]}]  {altera_chip_pin_lc}  {@A18} 
define_attribute  {b:sc_tdo_hybride[2]} {altera_chip_pin_lc} {@A18} 

#define_attribute [get_ports {ladder_fpga_sc_trstb}]  {altera_chip_pin_lc}  {@AB11} 
define_attribute  {p:ladder_fpga_sc_trstb} {altera_chip_pin_lc} {@AB11} 

#define_attribute [get_ports {tokenin_hybride[9]}]  {altera_chip_pin_lc}  {@E21} 
define_attribute  {b:tokenin_hybride[9]} {altera_chip_pin_lc} {@E21} 

#define_attribute [get_ports {latchup_hybride[3]}]  {altera_chip_pin_lc}  {@W19} 
define_attribute  {b:latchup_hybride[3]} {altera_chip_pin_lc} {@W19} 

#define_attribute [get_ports {sc_tck_hybride[15]}]  {altera_chip_pin_lc}  {@T11} 
define_attribute  {b:sc_tck_hybride[15]} {altera_chip_pin_lc} {@T11} 

#define_attribute [get_ports {latchup_hybride[0]}]  {altera_chip_pin_lc}  {@T15} 
define_attribute  {b:latchup_hybride[0]} {altera_chip_pin_lc} {@T15} 

#define_attribute [get_ports {sc_tdi_hybride[9]}]  {altera_chip_pin_lc}  {@A17} 
define_attribute  {b:sc_tdi_hybride[9]} {altera_chip_pin_lc} {@A17} 

#define_attribute [get_ports {sc_tms_hybride[15]}]  {altera_chip_pin_lc}  {@E10} 
define_attribute  {b:sc_tms_hybride[15]} {altera_chip_pin_lc} {@E10} 

#define_attribute [get_ports {sc_tdo_hybride[7]}]  {altera_chip_pin_lc}  {@H15} 
define_attribute  {b:sc_tdo_hybride[7]} {altera_chip_pin_lc} {@H15} 

#define_attribute [get_ports {sc_tdi_hybride[8]}]  {altera_chip_pin_lc}  {@N20} 
define_attribute  {b:sc_tdi_hybride[8]} {altera_chip_pin_lc} {@N20} 

#define_attribute [get_ports {sc_serdes_ou_connec}]  {altera_chip_pin_lc}  {@A8} 
define_attribute  {p:sc_serdes_ou_connec} {altera_chip_pin_lc} {@A8} 

#define_attribute [get_ports {clock80mhz_adc}]  {altera_chip_pin_lc}  {@AA3} 
define_attribute  {p:clock80mhz_adc} {altera_chip_pin_lc} {@AA3} 

#define_attribute [get_ports {rdo_to_ladder[13]}]  {altera_chip_pin_lc}  {@AA5} 
define_attribute  {b:rdo_to_ladder[13]} {altera_chip_pin_lc} {@AA5} 

#define_attribute [get_ports {des_bist_pass}]  {altera_chip_pin_lc}  {@W2} 
define_attribute  {p:des_bist_pass} {altera_chip_pin_lc} {@W2} 

#define_attribute [get_ports {data_serial[0]}]  {altera_chip_pin_lc}  {@AA8} 
define_attribute  {b:data_serial[0]} {altera_chip_pin_lc} {@AA8} 

#define_attribute [get_ports {data_serial[2]}]  {altera_chip_pin_lc}  {@AA9} 
define_attribute  {b:data_serial[2]} {altera_chip_pin_lc} {@AA9} 

#define_attribute [get_ports {ladder_to_rdo[16]}]  {altera_chip_pin_lc}  {@AA10} 
define_attribute  {b:ladder_to_rdo[16]} {altera_chip_pin_lc} {@AA10} 

#define_attribute [get_ports {testin_echelle}]  {altera_chip_pin_lc}  {@AA11} 
define_attribute  {p:testin_echelle} {altera_chip_pin_lc} {@AA11} 

#define_attribute [get_ports {reset_n}]  {altera_chip_pin_lc}  {@A11} 
define_attribute  {p:reset_n} {altera_chip_pin_lc} {@A11} 

#define_attribute [get_ports {data_serial[14]}]  {altera_chip_pin_lc}  {@AA13} 
define_attribute  {b:data_serial[14]} {altera_chip_pin_lc} {@AA13} 

#define_attribute [get_ports {ladder_to_rdo[2]}]  {altera_chip_pin_lc}  {@R2} 
define_attribute  {b:ladder_to_rdo[2]} {altera_chip_pin_lc} {@R2} 

#define_attribute [get_ports {tokenout_hybride[7]}]  {altera_chip_pin_lc}  {@AA15} 
define_attribute  {b:tokenout_hybride[7]} {altera_chip_pin_lc} {@AA15} 

#define_attribute [get_ports {roboclock_horloge40_phase[0]}]  {altera_chip_pin_lc}  {@C2} 
define_attribute  {b:roboclock_horloge40_phase[0]} {altera_chip_pin_lc} {@C2} 

#define_attribute [get_ports {tokenout_hybride[9]}]  {altera_chip_pin_lc}  {@AA17} 
define_attribute  {b:tokenout_hybride[9]} {altera_chip_pin_lc} {@AA17} 

#define_attribute [get_ports {sc_tms_hybride[9]}]  {altera_chip_pin_lc}  {@AA18} 
define_attribute  {b:sc_tms_hybride[9]} {altera_chip_pin_lc} {@AA18} 

#define_attribute [get_ports {sc_tck_hybride[9]}]  {altera_chip_pin_lc}  {@AA19} 
define_attribute  {b:sc_tck_hybride[9]} {altera_chip_pin_lc} {@AA19} 

#define_attribute [get_ports {sc_trstb_hybride[0]}]  {altera_chip_pin_lc}  {@F12} 
define_attribute  {b:sc_trstb_hybride[0]} {altera_chip_pin_lc} {@F12} 

#define_attribute [get_ports {tokenout_hybride[0]}]  {altera_chip_pin_lc}  {@B6} 
define_attribute  {b:tokenout_hybride[0]} {altera_chip_pin_lc} {@B6} 

#define_attribute [get_ports {sc_tms_hybride[2]}]  {altera_chip_pin_lc}  {@F16} 
define_attribute  {b:sc_tms_hybride[2]} {altera_chip_pin_lc} {@F16} 

#define_attribute [get_ports {sc_tck_hybride[2]}]  {altera_chip_pin_lc}  {@A14} 
define_attribute  {b:sc_tck_hybride[2]} {altera_chip_pin_lc} {@A14} 

#define_attribute [get_ports {roboclock_horloge40_phase[2]}]  {altera_chip_pin_lc}  {@B1} 
define_attribute  {b:roboclock_horloge40_phase[2]} {altera_chip_pin_lc} {@B1} 

#define_attribute [get_ports {tokenout_hybride[4]}]  {altera_chip_pin_lc}  {@E22} 
define_attribute  {b:tokenout_hybride[4]} {altera_chip_pin_lc} {@E22} 

#define_attribute [get_ports {ladder_fpga_sc_tdo}]  {altera_chip_pin_lc}  {@AA1} 
define_attribute  {p:ladder_fpga_sc_tdo} {altera_chip_pin_lc} {@AA1} 

#define_attribute [get_ports {fpga_serdes_ou_connec}]  {altera_chip_pin_lc}  {@C10} 
define_attribute  {p:fpga_serdes_ou_connec} {altera_chip_pin_lc} {@C10} 

#define_attribute [get_ports {sc_tdi_hybride[5]}]  {altera_chip_pin_lc}  {@AB9} 
define_attribute  {b:sc_tdi_hybride[5]} {altera_chip_pin_lc} {@AB9} 

#define_attribute [get_ports {data_serial[12]}]  {altera_chip_pin_lc}  {@AB10} 
define_attribute  {b:data_serial[12]} {altera_chip_pin_lc} {@AB10} 

#define_attribute [get_ports {ladder_fpga_sc_tck}]  {altera_chip_pin_lc}  {@T2} 
define_attribute  {p:ladder_fpga_sc_tck} {altera_chip_pin_lc} {@T2} 

#define_attribute [get_ports {tokenin_echelle}]  {altera_chip_pin_lc}  {@AB12} 
define_attribute  {p:tokenin_echelle} {altera_chip_pin_lc} {@AB12} 

#define_attribute [get_ports {data_serial[4]}]  {altera_chip_pin_lc}  {@AB13} 
define_attribute  {b:data_serial[4]} {altera_chip_pin_lc} {@AB13} 

#define_attribute [get_ports {usb_data[1]}]  {altera_chip_pin_lc}  {@AB3} 
define_attribute  {b:usb_data[1]} {altera_chip_pin_lc} {@AB3} 

#define_attribute [get_ports {pilotage_magnd_hybride[7]}]  {altera_chip_pin_lc}  {@D15} 
define_attribute  {b:pilotage_magnd_hybride[7]} {altera_chip_pin_lc} {@D15} 

#define_attribute [get_ports {sc_tms_hybride[4]}]  {altera_chip_pin_lc}  {@K16} 
define_attribute  {b:sc_tms_hybride[4]} {altera_chip_pin_lc} {@K16} 

#define_attribute [get_ports {sc_tdi_hybride[7]}]  {altera_chip_pin_lc}  {@AB17} 
define_attribute  {b:sc_tdi_hybride[7]} {altera_chip_pin_lc} {@AB17} 

#define_attribute [get_ports {sc_tms_hybride[10]}]  {altera_chip_pin_lc}  {@AB18} 
define_attribute  {b:sc_tms_hybride[10]} {altera_chip_pin_lc} {@AB18} 

#define_attribute [get_ports {card_ser_num[4]}]  {altera_chip_pin_lc}  {@L7} 
define_attribute  {b:card_ser_num[4]} {altera_chip_pin_lc} {@L7} 

#define_attribute [get_ports {sc_trstb_hybride[11]}]  {altera_chip_pin_lc}  {@AB7} 
define_attribute  {b:sc_trstb_hybride[11]} {altera_chip_pin_lc} {@AB7} 

#define_attribute [get_ports {adc_cs_n[0]}]  {altera_chip_pin_lc}  {@B4} 
define_attribute  {b:adc_cs_n[0]} {altera_chip_pin_lc} {@B4} 

#define_attribute [get_ports {adc_cs_n[4]}]  {altera_chip_pin_lc}  {@B5} 
define_attribute  {b:adc_cs_n[4]} {altera_chip_pin_lc} {@B5} 

#define_attribute [get_ports {rdo_to_ladder[11]}]  {altera_chip_pin_lc}  {@V16} 
define_attribute  {b:rdo_to_ladder[11]} {altera_chip_pin_lc} {@V16} 

#define_attribute [get_ports {adc_cs_n[1]}]  {altera_chip_pin_lc}  {@B7} 
define_attribute  {b:adc_cs_n[1]} {altera_chip_pin_lc} {@B7} 

#define_attribute [get_ports {data_serial[10]}]  {altera_chip_pin_lc}  {@B8} 
define_attribute  {b:data_serial[10]} {altera_chip_pin_lc} {@B8} 

#define_attribute [get_ports {ladder_to_rdo[0]}]  {altera_chip_pin_lc}  {@B9} 
define_attribute  {b:ladder_to_rdo[0]} {altera_chip_pin_lc} {@B9} 

#define_attribute [get_ports {sc_tck_hybride[12]}]  {altera_chip_pin_lc}  {@P22} 
define_attribute  {b:sc_tck_hybride[12]} {altera_chip_pin_lc} {@P22} 

#define_attribute [get_ports {sc_tdo_hybride[1]}]  {altera_chip_pin_lc}  {@B11} 
define_attribute  {b:sc_tdo_hybride[1]} {altera_chip_pin_lc} {@B11} 

#define_attribute [get_ports {sc_tdo_hybride[5]}]  {altera_chip_pin_lc}  {@B12} 
define_attribute  {b:sc_tdo_hybride[5]} {altera_chip_pin_lc} {@B12} 

#define_attribute [get_ports {tokenout_hybride[12]}]  {altera_chip_pin_lc}  {@Y17} 
define_attribute  {b:tokenout_hybride[12]} {altera_chip_pin_lc} {@Y17} 

#define_attribute [get_ports {sc_tck_hybride[11]}]  {altera_chip_pin_lc}  {@R14} 
define_attribute  {b:sc_tck_hybride[11]} {altera_chip_pin_lc} {@R14} 

#define_attribute [get_ports {latchup_hybride[13]}]  {altera_chip_pin_lc}  {@M15} 
define_attribute  {b:latchup_hybride[13]} {altera_chip_pin_lc} {@M15} 

#define_attribute [get_ports {sc_tdo_hybride[10]}]  {altera_chip_pin_lc}  {@B20} 
define_attribute  {b:sc_tdo_hybride[10]} {altera_chip_pin_lc} {@B20} 

#define_attribute [get_ports {mux_ref_latchup[1]}]  {altera_chip_pin_lc}  {@B17} 
define_attribute  {b:mux_ref_latchup[1]} {altera_chip_pin_lc} {@B17} 

#define_attribute [get_ports {tokenin_hybride[10]}]  {altera_chip_pin_lc}  {@B19} 
define_attribute  {b:tokenin_hybride[10]} {altera_chip_pin_lc} {@B19} 

#define_attribute [get_ports {latchup_hybride[5]}]  {altera_chip_pin_lc}  {@H11} 
define_attribute  {b:latchup_hybride[5]} {altera_chip_pin_lc} {@H11} 

#define_attribute [get_ports {latchup_hybride[4]}]  {altera_chip_pin_lc}  {@E15} 
define_attribute  {b:latchup_hybride[4]} {altera_chip_pin_lc} {@E15} 

#define_attribute [get_ports {level_shifter_dac_sdi}]  {altera_chip_pin_lc}  {@V9} 
define_attribute  {p:level_shifter_dac_sdi} {altera_chip_pin_lc} {@V9} 

#define_attribute [get_ports {sc_trstb_hybride[3]}]  {altera_chip_pin_lc}  {@B22} 
define_attribute  {b:sc_trstb_hybride[3]} {altera_chip_pin_lc} {@B22} 

#define_attribute [get_ports {sc_tdo_hybride[14]}]  {altera_chip_pin_lc}  {@R13} 
define_attribute  {b:sc_tdo_hybride[14]} {altera_chip_pin_lc} {@R13} 

#define_attribute [get_ports {sc_tms_hybride[13]}]  {altera_chip_pin_lc}  {@W17} 
define_attribute  {b:sc_tms_hybride[13]} {altera_chip_pin_lc} {@W17} 

#define_attribute [get_ports {adc_cs_n[5]}]  {altera_chip_pin_lc}  {@C7} 
define_attribute  {b:adc_cs_n[5]} {altera_chip_pin_lc} {@C7} 

#define_attribute [get_ports {adc_cs_n[6]}]  {altera_chip_pin_lc}  {@C8} 
define_attribute  {b:adc_cs_n[6]} {altera_chip_pin_lc} {@C8} 

#define_attribute [get_ports {usb_present}]  {altera_chip_pin_lc}  {@Y2} 
define_attribute  {p:usb_present} {altera_chip_pin_lc} {@Y2} 

#define_attribute [get_ports {tokenin_hybride[12]}]  {altera_chip_pin_lc}  {@F19} 
define_attribute  {b:tokenin_hybride[12]} {altera_chip_pin_lc} {@F19} 

#define_attribute [get_ports {tokenout_hybride[11]}]  {altera_chip_pin_lc}  {@U20} 
define_attribute  {b:tokenout_hybride[11]} {altera_chip_pin_lc} {@U20} 

#define_attribute [get_ports {sc_tck_hybride[10]}]  {altera_chip_pin_lc}  {@B21} 
define_attribute  {b:sc_tck_hybride[10]} {altera_chip_pin_lc} {@B21} 

#define_attribute [get_ports {pilotage_mvdd_hybride[12]}]  {altera_chip_pin_lc}  {@C21} 
define_attribute  {b:pilotage_mvdd_hybride[12]} {altera_chip_pin_lc} {@C21} 

#define_attribute [get_ports {pilotage_mvdd_hybride[15]}]  {altera_chip_pin_lc}  {@AA7} 
define_attribute  {b:pilotage_mvdd_hybride[15]} {altera_chip_pin_lc} {@AA7} 

#define_attribute [get_ports {sc_tck_hybride[4]}]  {altera_chip_pin_lc}  {@C22} 
define_attribute  {b:sc_tck_hybride[4]} {altera_chip_pin_lc} {@C22} 

#define_attribute [get_ports {~ALTERA_ASDO_DATA1~ / RESERVED_INPUT}]  {altera_chip_pin_lc}  {@D1} 
define_attribute {b:~ALTERA_ASDO_DATA1~ / RESERVED_INPUT} {altera_chip_pin_lc} {@D1} 

#define_attribute [get_ports {usb_reset_n}]  {altera_chip_pin_lc}  {@A7} 
define_attribute  {p:usb_reset_n} {altera_chip_pin_lc} {@A7} 

#define_attribute [get_ports {ladder_to_rdo[19]}]  {altera_chip_pin_lc}  {@M3} 
define_attribute  {b:ladder_to_rdo[19]} {altera_chip_pin_lc} {@M3} 

#define_attribute [get_ports {rdo_to_ladder[14]}]  {altera_chip_pin_lc}  {@N17} 
define_attribute  {b:rdo_to_ladder[14]} {altera_chip_pin_lc} {@N17} 

#define_attribute [get_ports {rdo_to_ladder[16]}]  {altera_chip_pin_lc}  {@AB16} 
define_attribute  {b:rdo_to_ladder[16]} {altera_chip_pin_lc} {@AB16} 

#define_attribute [get_ports {tokenin_hybride[11]}]  {altera_chip_pin_lc}  {@M16} 
define_attribute  {b:tokenin_hybride[11]} {altera_chip_pin_lc} {@M16} 

#define_attribute [get_ports {pilotage_mvdd_hybride[7]}]  {altera_chip_pin_lc}  {@L22} 
define_attribute  {b:pilotage_mvdd_hybride[7]} {altera_chip_pin_lc} {@L22} 

#define_attribute [get_ports {pilotage_magnd_hybride[9]}]  {altera_chip_pin_lc}  {@V22} 
define_attribute  {b:pilotage_magnd_hybride[9]} {altera_chip_pin_lc} {@V22} 

#define_attribute [get_ports {tokenout_hybride[8]}]  {altera_chip_pin_lc}  {@E12} 
define_attribute  {b:tokenout_hybride[8]} {altera_chip_pin_lc} {@E12} 

#define_attribute [get_ports {sc_tck_hybride[8]}]  {altera_chip_pin_lc}  {@F20} 
define_attribute  {b:sc_tck_hybride[8]} {altera_chip_pin_lc} {@F20} 

#define_attribute [get_ports {sc_tck_hybride[0]}]  {altera_chip_pin_lc}  {@D22} 
define_attribute  {b:sc_tck_hybride[0]} {altera_chip_pin_lc} {@D22} 

#define_attribute [get_ports {pilotage_mvdd_hybride[2]}]  {altera_chip_pin_lc}  {@J21} 
define_attribute  {b:pilotage_mvdd_hybride[2]} {altera_chip_pin_lc} {@J21} 

#define_attribute [get_ports {~ALTERA_FLASH_nCE_nCSO~ / RESERVED_INPUT}]  {altera_chip_pin_lc}  {@E2} 
define_attribute {b:~ALTERA_FLASH_nCE_nCSO~ / RESERVED_INPUT} {altera_chip_pin_lc} {@E2} 

#define_attribute [get_ports {sc_tdo_hybride[13]}]  {altera_chip_pin_lc}  {@P15} 
define_attribute  {b:sc_tdo_hybride[13]} {altera_chip_pin_lc} {@P15} 

#define_attribute [get_ports {sc_tms_hybride[12]}]  {altera_chip_pin_lc}  {@W10} 
define_attribute  {b:sc_tms_hybride[12]} {altera_chip_pin_lc} {@W10} 

#define_attribute [get_ports {usb_data[7]}]  {altera_chip_pin_lc}  {@N8} 
define_attribute  {b:usb_data[7]} {altera_chip_pin_lc} {@N8} 

#define_attribute [get_ports {data_serial[3]}]  {altera_chip_pin_lc}  {@E11} 
define_attribute  {b:data_serial[3]} {altera_chip_pin_lc} {@E11} 

#define_attribute [get_ports {sc_tdi_hybride[12]}]  {altera_chip_pin_lc}  {@N22} 
define_attribute  {b:sc_tdi_hybride[12]} {altera_chip_pin_lc} {@N22} 

#define_attribute [get_ports {sc_tdi_hybride[14]}]  {altera_chip_pin_lc}  {@C6} 
define_attribute  {b:sc_tdi_hybride[14]} {altera_chip_pin_lc} {@C6} 

#define_attribute [get_ports {sc_tms_hybride[11]}]  {altera_chip_pin_lc}  {@E7} 
define_attribute  {b:sc_tms_hybride[11]} {altera_chip_pin_lc} {@E7} 

#define_attribute [get_ports {sc_tdi_hybride[10]}]  {altera_chip_pin_lc}  {@D20} 
define_attribute  {b:sc_tdi_hybride[10]} {altera_chip_pin_lc} {@D20} 

#define_attribute [get_ports {latchup_hybride[1]}]  {altera_chip_pin_lc}  {@R19} 
define_attribute  {b:latchup_hybride[1]} {altera_chip_pin_lc} {@R19} 

#define_attribute [get_ports {sc_tdi_hybride[6]}]  {altera_chip_pin_lc}  {@D21} 
define_attribute  {b:sc_tdi_hybride[6]} {altera_chip_pin_lc} {@D21} 

#define_attribute [get_ports {sc_tdo_hybride[4]}]  {altera_chip_pin_lc}  {@G21} 
define_attribute  {b:sc_tdo_hybride[4]} {altera_chip_pin_lc} {@G21} 

#define_attribute [get_ports {sc_tdi_hybride[15]}]  {altera_chip_pin_lc}  {@R11} 
define_attribute  {b:sc_tdi_hybride[15]} {altera_chip_pin_lc} {@R11} 

#define_attribute [get_ports {pilotage_mvdd_hybride[4]}]  {altera_chip_pin_lc}  {@E13} 
define_attribute  {b:pilotage_mvdd_hybride[4]} {altera_chip_pin_lc} {@E13} 

#define_attribute [get_ports {tokenin_hybride[13]}]  {altera_chip_pin_lc}  {@N14} 
define_attribute  {b:tokenin_hybride[13]} {altera_chip_pin_lc} {@N14} 

#define_attribute [get_ports {rdo_to_ladder[15]}]  {altera_chip_pin_lc}  {@AB5} 
define_attribute  {b:rdo_to_ladder[15]} {altera_chip_pin_lc} {@AB5} 

#define_attribute [get_ports {sc_tdi_hybride[1]}]  {altera_chip_pin_lc}  {@F11} 
define_attribute  {b:sc_tdi_hybride[1]} {altera_chip_pin_lc} {@F11} 

#define_attribute [get_ports {roboclock_horloge40_phase[1]}]  {altera_chip_pin_lc}  {@C1} 
define_attribute  {b:roboclock_horloge40_phase[1]} {altera_chip_pin_lc} {@C1} 

#define_attribute [get_ports {sc_tdo_hybride[9]}]  {altera_chip_pin_lc}  {@H21} 
define_attribute  {b:sc_tdo_hybride[9]} {altera_chip_pin_lc} {@H21} 

#define_attribute [get_ports {latchup_hybride[7]}]  {altera_chip_pin_lc}  {@K21} 
define_attribute  {b:latchup_hybride[7]} {altera_chip_pin_lc} {@K21} 

#define_attribute [get_ports {latchup_hybride[9]}]  {altera_chip_pin_lc}  {@F15} 
define_attribute  {b:latchup_hybride[9]} {altera_chip_pin_lc} {@F15} 

#define_attribute [get_ports {rdo_to_ladder[12]}]  {altera_chip_pin_lc}  {@P4} 
define_attribute  {b:rdo_to_ladder[12]} {altera_chip_pin_lc} {@P4} 

#define_attribute [get_ports {usb_read_n}]  {altera_chip_pin_lc}  {@T4} 
define_attribute  {p:usb_read_n} {altera_chip_pin_lc} {@T4} 

#define_attribute [get_ports {sc_tms_hybride[8]}]  {altera_chip_pin_lc}  {@B16} 
define_attribute  {b:sc_tms_hybride[8]} {altera_chip_pin_lc} {@B16} 

#define_attribute [get_ports {sc_tck_hybride[7]}]  {altera_chip_pin_lc}  {@E16} 
define_attribute  {b:sc_tck_hybride[7]} {altera_chip_pin_lc} {@E16} 

#define_attribute [get_ports {roboclock_adc_phase[6]}]  {altera_chip_pin_lc}  {@T17} 
define_attribute  {b:roboclock_adc_phase[6]} {altera_chip_pin_lc} {@T17} 

#define_attribute [get_ports {sc_tdi_hybride[11]}]  {altera_chip_pin_lc}  {@C17} 
define_attribute  {b:sc_tdi_hybride[11]} {altera_chip_pin_lc} {@C17} 

#define_attribute [get_ports {clock40mhz_xtal}]  {altera_chip_pin_lc}  {@G1} 
define_attribute  {p:clock40mhz_xtal} {altera_chip_pin_lc} {@G1} 

#define_attribute [get_ports {clock40mhz_fpga}]  {altera_chip_pin_lc}  {@G2} 
define_attribute  {p:clock40mhz_fpga} {altera_chip_pin_lc} {@G2} 

#define_attribute [get_ports {ladder_fpga_sc_tms}]  {altera_chip_pin_lc}  {@G3} 
define_attribute  {p:ladder_fpga_sc_tms} {altera_chip_pin_lc} {@G3} 

#define_attribute [get_ports {sc_tms_hybride[14]}]  {altera_chip_pin_lc}  {@T12} 
define_attribute  {b:sc_tms_hybride[14]} {altera_chip_pin_lc} {@T12} 

#define_attribute [get_ports {adc_cs_n[3]}]  {altera_chip_pin_lc}  {@G9} 
define_attribute  {b:adc_cs_n[3]} {altera_chip_pin_lc} {@G9} 

#define_attribute [get_ports {adc_cs_n[7]}]  {altera_chip_pin_lc}  {@G10} 
define_attribute  {b:adc_cs_n[7]} {altera_chip_pin_lc} {@G10} 

#define_attribute [get_ports {pilotage_mvdd_hybride[3]}]  {altera_chip_pin_lc}  {@G11} 
define_attribute  {b:pilotage_mvdd_hybride[3]} {altera_chip_pin_lc} {@G11} 

#define_attribute [get_ports {sc_tdo_hybride[12]}]  {altera_chip_pin_lc}  {@R12} 
define_attribute  {b:sc_tdo_hybride[12]} {altera_chip_pin_lc} {@R12} 

#define_attribute [get_ports {pilotage_magnd_hybride[14]}]  {altera_chip_pin_lc}  {@AA2} 
define_attribute  {b:pilotage_magnd_hybride[14]} {altera_chip_pin_lc} {@AA2} 

#define_attribute [get_ports {pilotage_mvdd_hybride[9]}]  {altera_chip_pin_lc}  {@Y22} 
define_attribute  {b:pilotage_mvdd_hybride[9]} {altera_chip_pin_lc} {@Y22} 

#define_attribute [get_ports {pilotage_magnd_hybride[13]}]  {altera_chip_pin_lc}  {@AA4} 
define_attribute  {b:pilotage_magnd_hybride[13]} {altera_chip_pin_lc} {@AA4} 

#define_attribute [get_ports {sc_tdo_hybride[8]}]  {altera_chip_pin_lc}  {@G18} 
define_attribute  {b:sc_tdo_hybride[8]} {altera_chip_pin_lc} {@G18} 

#define_attribute [get_ports {card_ser_num[5]}]  {altera_chip_pin_lc}  {@V1} 
define_attribute  {b:card_ser_num[5]} {altera_chip_pin_lc} {@V1} 

#define_attribute [get_ports {data_serial[7]}]  {altera_chip_pin_lc}  {@G22} 
define_attribute  {b:data_serial[7]} {altera_chip_pin_lc} {@G22} 

#define_attribute [get_ports {pilotage_magnd_hybride[12]}]  {altera_chip_pin_lc}  {@AB20} 
define_attribute  {b:pilotage_magnd_hybride[12]} {altera_chip_pin_lc} {@AB20} 

#define_attribute [get_ports {tokenin_hybride[15]}]  {altera_chip_pin_lc}  {@AA14} 
define_attribute  {b:tokenin_hybride[15]} {altera_chip_pin_lc} {@AA14} 

#define_attribute [get_ports {sc_tck_hybride[13]}]  {altera_chip_pin_lc}  {@H7} 
define_attribute  {b:sc_tck_hybride[13]} {altera_chip_pin_lc} {@H7} 

#define_attribute [get_ports {sc_trstb_hybride[14]}]  {altera_chip_pin_lc}  {@L6} 
define_attribute  {b:sc_trstb_hybride[14]} {altera_chip_pin_lc} {@L6} 

#define_attribute [get_ports {adc_cs_n[2]}]  {altera_chip_pin_lc}  {@H9} 
define_attribute  {b:adc_cs_n[2]} {altera_chip_pin_lc} {@H9} 

#define_attribute [get_ports {ladder_to_rdo[5]}]  {altera_chip_pin_lc}  {@N2} 
define_attribute  {b:ladder_to_rdo[5]} {altera_chip_pin_lc} {@N2} 

#define_attribute [get_ports {usb_data[4]}]  {altera_chip_pin_lc}  {@M7} 
define_attribute  {b:usb_data[4]} {altera_chip_pin_lc} {@M7} 

#define_attribute [get_ports {tokenin_hybride[2]}]  {altera_chip_pin_lc}  {@H12} 
define_attribute  {b:tokenin_hybride[2]} {altera_chip_pin_lc} {@H12} 

#define_attribute [get_ports {mux_ref_latchup[0]}]  {altera_chip_pin_lc}  {@U11} 
define_attribute  {b:mux_ref_latchup[0]} {altera_chip_pin_lc} {@U11} 

#define_attribute [get_ports {latchup_hybride[10]}]  {altera_chip_pin_lc}  {@H6} 
define_attribute  {b:latchup_hybride[10]} {altera_chip_pin_lc} {@H6} 

#define_attribute [get_ports {sc_tms_hybride[7]}]  {altera_chip_pin_lc}  {@A19} 
define_attribute  {b:sc_tms_hybride[7]} {altera_chip_pin_lc} {@A19} 

#define_attribute [get_ports {sc_tdi_hybride[2]}]  {altera_chip_pin_lc}  {@H16} 
define_attribute  {b:sc_tdi_hybride[2]} {altera_chip_pin_lc} {@H16} 

#define_attribute [get_ports {tokenin_hybride[6]}]  {altera_chip_pin_lc}  {@H17} 
define_attribute  {b:tokenin_hybride[6]} {altera_chip_pin_lc} {@H17} 

#define_attribute [get_ports {latchup_hybride[8]}]  {altera_chip_pin_lc}  {@U7} 
define_attribute  {b:latchup_hybride[8]} {altera_chip_pin_lc} {@U7} 

#define_attribute [get_ports {sc_tms_hybride[6]}]  {altera_chip_pin_lc}  {@H19} 
define_attribute  {b:sc_tms_hybride[6]} {altera_chip_pin_lc} {@H19} 

#define_attribute [get_ports {latchup_hybride[6]}]  {altera_chip_pin_lc}  {@B18} 
define_attribute  {b:latchup_hybride[6]} {altera_chip_pin_lc} {@B18} 

#define_attribute [get_ports {tokenout_hybride[6]}]  {altera_chip_pin_lc}  {@A16} 
define_attribute  {b:tokenout_hybride[6]} {altera_chip_pin_lc} {@A16} 

#define_attribute [get_ports {sc_trstb_hybride[9]}]  {altera_chip_pin_lc}  {@M21} 
define_attribute  {b:sc_trstb_hybride[9]} {altera_chip_pin_lc} {@M21} 

#define_attribute [get_ports {tokenout_hybride[15]}]  {altera_chip_pin_lc}  {@AA12} 
define_attribute  {b:tokenout_hybride[15]} {altera_chip_pin_lc} {@AA12} 

#define_attribute [get_ports {rdo_to_ladder[10]}]  {altera_chip_pin_lc}  {@J2} 
define_attribute  {b:rdo_to_ladder[10]} {altera_chip_pin_lc} {@J2} 

#define_attribute [get_ports {sc_tck_hybride[14]}]  {altera_chip_pin_lc}  {@Y13} 
define_attribute  {b:sc_tck_hybride[14]} {altera_chip_pin_lc} {@Y13} 

#define_attribute [get_ports {ladder_fpga_sc_tdi}]  {altera_chip_pin_lc}  {@Y7} 
define_attribute  {p:ladder_fpga_sc_tdi} {altera_chip_pin_lc} {@Y7} 

#define_attribute [get_ports {sc_trstb_hybride[15]}]  {altera_chip_pin_lc}  {@J6} 
define_attribute  {b:sc_trstb_hybride[15]} {altera_chip_pin_lc} {@J6} 

#define_attribute [get_ports {roboclock_horloge40_phase[3]}]  {altera_chip_pin_lc}  {@B2} 
define_attribute  {b:roboclock_horloge40_phase[3]} {altera_chip_pin_lc} {@B2} 

#define_attribute [get_ports {tokenin_hybride[1]}]  {altera_chip_pin_lc}  {@D13} 
define_attribute  {b:tokenin_hybride[1]} {altera_chip_pin_lc} {@D13} 

#define_attribute [get_ports {sc_tms_hybride[3]}]  {altera_chip_pin_lc}  {@J16} 
define_attribute  {b:sc_tms_hybride[3]} {altera_chip_pin_lc} {@J16} 

#define_attribute [get_ports {tokenin_hybride[4]}]  {altera_chip_pin_lc}  {@J17} 
define_attribute  {b:tokenin_hybride[4]} {altera_chip_pin_lc} {@J17} 

#define_attribute [get_ports {tokenin_hybride[5]}]  {altera_chip_pin_lc}  {@F9} 
define_attribute  {b:tokenin_hybride[5]} {altera_chip_pin_lc} {@F9} 

#define_attribute [get_ports {roboclock_adc_phase[7]}]  {altera_chip_pin_lc}  {@V15} 
define_attribute  {b:roboclock_adc_phase[7]} {altera_chip_pin_lc} {@V15} 

#define_attribute [get_ports {sc_tck_hybride[5]}]  {altera_chip_pin_lc}  {@H22} 
define_attribute  {b:sc_tck_hybride[5]} {altera_chip_pin_lc} {@H22} 

#define_attribute [get_ports {~ALTERA_DATA0~ / RESERVED_INPUT}]  {altera_chip_pin_lc}  {@K1} 
define_attribute {b:~ALTERA_DATA0~ / RESERVED_INPUT} {altera_chip_pin_lc} {@K1} 

#define_attribute [get_ports {~ALTERA_DCLK~ / RESERVED_INPUT}]  {altera_chip_pin_lc}  {@K2} 
define_attribute {b:~ALTERA_DCLK~ / RESERVED_INPUT} {altera_chip_pin_lc} {@K2} 

#define_attribute [get_ports {pilotage_mvdd_hybride[0]}]  {altera_chip_pin_lc}  {@K7} 
define_attribute  {b:pilotage_mvdd_hybride[0]} {altera_chip_pin_lc} {@K7} 

#define_attribute [get_ports {pilotage_magnd_hybride[0]}]  {altera_chip_pin_lc}  {@K8} 
define_attribute  {b:pilotage_magnd_hybride[0]} {altera_chip_pin_lc} {@K8} 

#define_attribute [get_ports {roboclock_adc_phase[3]}]  {altera_chip_pin_lc}  {@K15} 
define_attribute  {b:roboclock_adc_phase[3]} {altera_chip_pin_lc} {@K15} 

#define_attribute [get_ports {tokenin_hybride[3]}]  {altera_chip_pin_lc}  {@J15} 
define_attribute  {b:tokenin_hybride[3]} {altera_chip_pin_lc} {@J15} 

#define_attribute [get_ports {sc_tdi_hybride[3]}]  {altera_chip_pin_lc}  {@K17} 
define_attribute  {b:sc_tdi_hybride[3]} {altera_chip_pin_lc} {@K17} 

#define_attribute [get_ports {hold_16hybrides}]  {altera_chip_pin_lc}  {@K18} 
define_attribute  {p:hold_16hybrides} {altera_chip_pin_lc} {@K18} 

#define_attribute [get_ports {roboclock_adc_phase[5]}]  {altera_chip_pin_lc}  {@U15} 
define_attribute  {b:roboclock_adc_phase[5]} {altera_chip_pin_lc} {@U15} 

#define_attribute [get_ports {tokenout_hybride[5]}]  {altera_chip_pin_lc}  {@E9} 
define_attribute  {b:tokenout_hybride[5]} {altera_chip_pin_lc} {@E9} 

#define_attribute [get_ports {~ALTERA_nCEO~ / RESERVED_OUTPUT_OPEN_DRAIN}]  {altera_chip_pin_lc}  {@K22} 
define_attribute {b:~ALTERA_nCEO~ / RESERVED_OUTPUT_OPEN_DRAIN} {altera_chip_pin_lc} {@K22} 

#define_attribute [get_ports {tokenin_hybride[14]}]  {altera_chip_pin_lc}  {@L8} 
define_attribute  {b:tokenin_hybride[14]} {altera_chip_pin_lc} {@L8} 

#define_attribute [get_ports {latchup_hybride[11]}]  {altera_chip_pin_lc}  {@V13} 
define_attribute  {b:latchup_hybride[11]} {altera_chip_pin_lc} {@V13} 

#define_attribute [get_ports {roboclock_adc_phase[1]}]  {altera_chip_pin_lc}  {@G14} 
define_attribute  {b:roboclock_adc_phase[1]} {altera_chip_pin_lc} {@G14} 

#define_attribute [get_ports {roboclock_adc_phase[0]}]  {altera_chip_pin_lc}  {@G15} 
define_attribute  {b:roboclock_adc_phase[0]} {altera_chip_pin_lc} {@G15} 

#define_attribute [get_ports {crc_error}]  {altera_chip_pin_lc}  {@L21} 
define_attribute  {p:crc_error} {altera_chip_pin_lc} {@L21} 

#define_attribute [get_ports {roboclock_adc_phase[2]}]  {altera_chip_pin_lc}  {@K19} 
define_attribute  {b:roboclock_adc_phase[2]} {altera_chip_pin_lc} {@K19} 

#define_attribute [get_ports {sc_tdo_hybride[15]}]  {altera_chip_pin_lc}  {@U12} 
define_attribute  {b:sc_tdo_hybride[15]} {altera_chip_pin_lc} {@U12} 

#define_attribute [get_ports {data_serial[8]}]  {altera_chip_pin_lc}  {@M2} 
define_attribute  {b:data_serial[8]} {altera_chip_pin_lc} {@M2} 

#define_attribute [get_ports {ladder_to_rdo[9]}]  {altera_chip_pin_lc}  {@M8} 
define_attribute  {b:ladder_to_rdo[9]} {altera_chip_pin_lc} {@M8} 

#define_attribute [get_ports {ladder_to_rdo[21]}]  {altera_chip_pin_lc}  {@C4} 
define_attribute  {b:ladder_to_rdo[21]} {altera_chip_pin_lc} {@C4} 

#define_attribute [get_ports {ladder_to_rdo[18]}]  {altera_chip_pin_lc}  {@M5} 
define_attribute  {b:ladder_to_rdo[18]} {altera_chip_pin_lc} {@M5} 

#define_attribute [get_ports {data_serial[1]}]  {altera_chip_pin_lc}  {@M6} 
define_attribute  {b:data_serial[1]} {altera_chip_pin_lc} {@M6} 

#define_attribute [get_ports {sc_tdi_hybride[13]}]  {altera_chip_pin_lc}  {@R17} 
define_attribute  {b:sc_tdi_hybride[13]} {altera_chip_pin_lc} {@R17} 

#define_attribute [get_ports {ladder_addr[2]}]  {altera_chip_pin_lc}  {@U2} 
define_attribute  {b:ladder_addr[2]} {altera_chip_pin_lc} {@U2} 

#define_attribute [get_ports {sc_trstb_hybride[8]}]  {altera_chip_pin_lc}  {@N15} 
define_attribute  {b:sc_trstb_hybride[8]} {altera_chip_pin_lc} {@N15} 

#define_attribute [get_ports {sc_trstb_hybride[7]}]  {altera_chip_pin_lc}  {@R16} 
define_attribute  {b:sc_trstb_hybride[7]} {altera_chip_pin_lc} {@R16} 

#define_attribute [get_ports {sc_tdi_hybride[4]}]  {altera_chip_pin_lc}  {@M20} 
define_attribute  {b:sc_tdi_hybride[4]} {altera_chip_pin_lc} {@M20} 

#define_attribute [get_ports {roboclock_adc_phase[4]}]  {altera_chip_pin_lc}  {@W15} 
define_attribute  {b:roboclock_adc_phase[4]} {altera_chip_pin_lc} {@W15} 

#define_attribute [get_ports {usb_rx_empty}]  {altera_chip_pin_lc}  {@M22} 
define_attribute  {p:usb_rx_empty} {altera_chip_pin_lc} {@M22} 

#define_attribute [get_ports {ladder_to_rdo[15]}]  {altera_chip_pin_lc}  {@F1} 
define_attribute  {b:ladder_to_rdo[15]} {altera_chip_pin_lc} {@F1} 

#define_attribute [get_ports {ladder_to_rdo[4]}]  {altera_chip_pin_lc}  {@R7} 
define_attribute  {b:ladder_to_rdo[4]} {altera_chip_pin_lc} {@R7} 

#define_attribute [get_ports {data_serial[9]}]  {altera_chip_pin_lc}  {@N5} 
define_attribute  {b:data_serial[9]} {altera_chip_pin_lc} {@N5} 

#define_attribute [get_ports {tokenout_hybride[3]}]  {altera_chip_pin_lc}  {@N6} 
define_attribute  {b:tokenout_hybride[3]} {altera_chip_pin_lc} {@N6} 

#define_attribute [get_ports {level_shifter_dac_ld_cs_n}]  {altera_chip_pin_lc}  {@U9} 
define_attribute  {p:level_shifter_dac_ld_cs_n} {altera_chip_pin_lc} {@U9} 

#define_attribute [get_ports {ladder_to_rdo[6]}]  {altera_chip_pin_lc}  {@E6} 
define_attribute  {b:ladder_to_rdo[6]} {altera_chip_pin_lc} {@E6} 

#define_attribute [get_ports {pilotage_mvdd_hybride[1]}]  {altera_chip_pin_lc}  {@J7} 
define_attribute  {b:pilotage_mvdd_hybride[1]} {altera_chip_pin_lc} {@J7} 

#define_attribute [get_ports {usb_write}]  {altera_chip_pin_lc}  {@AA22} 
define_attribute  {p:usb_write} {altera_chip_pin_lc} {@AA22} 

#define_attribute [get_ports {usb_data[5]}]  {altera_chip_pin_lc}  {@AA21} 
define_attribute  {b:usb_data[5]} {altera_chip_pin_lc} {@AA21} 

#define_attribute [get_ports {sc_tck_hybride[3]}]  {altera_chip_pin_lc}  {@A13} 
define_attribute  {b:sc_tck_hybride[3]} {altera_chip_pin_lc} {@A13} 

#define_attribute [get_ports {pilotage_magnd_hybride[11]}]  {altera_chip_pin_lc}  {@AA20} 
define_attribute  {b:pilotage_magnd_hybride[11]} {altera_chip_pin_lc} {@AA20} 

#define_attribute [get_ports {usb_ready_n}]  {altera_chip_pin_lc}  {@AB14} 
define_attribute  {p:usb_ready_n} {altera_chip_pin_lc} {@AB14} 

#define_attribute [get_ports {tokenout_hybride[2]}]  {altera_chip_pin_lc}  {@N21} 
define_attribute  {b:tokenout_hybride[2]} {altera_chip_pin_lc} {@N21} 

#define_attribute [get_ports {sc_tdo_hybride[3]}]  {altera_chip_pin_lc}  {@A12} 
define_attribute  {b:sc_tdo_hybride[3]} {altera_chip_pin_lc} {@A12} 

#define_attribute [get_ports {usb_data[0]}]  {altera_chip_pin_lc}  {@P1} 
define_attribute  {b:usb_data[0]} {altera_chip_pin_lc} {@P1} 

#define_attribute [get_ports {rdo_to_ladder[17]}]  {altera_chip_pin_lc}  {@P3} 
define_attribute  {b:rdo_to_ladder[17]} {altera_chip_pin_lc} {@P3} 

#define_attribute [get_ports {temperature}]  {altera_chip_pin_lc}  {@E3} 
define_attribute  {p:temperature} {altera_chip_pin_lc} {@E3} 

#define_attribute [get_ports {fibre_tx_fault}]  {altera_chip_pin_lc}  {@H2} 
define_attribute  {p:fibre_tx_fault} {altera_chip_pin_lc} {@H2} 

#define_attribute [get_ports {pilotage_magnd_hybride[15]}]  {altera_chip_pin_lc}  {@AA16} 
define_attribute  {b:pilotage_magnd_hybride[15]} {altera_chip_pin_lc} {@AA16} 

#define_attribute [get_ports {card_ser_num[2]}]  {altera_chip_pin_lc}  {@E1} 
define_attribute  {b:card_ser_num[2]} {altera_chip_pin_lc} {@E1} 

#define_attribute [get_ports {pilotage_mvdd_hybride[5]}]  {altera_chip_pin_lc}  {@J22} 
define_attribute  {b:pilotage_mvdd_hybride[5]} {altera_chip_pin_lc} {@J22} 

#define_attribute [get_ports {pilotage_magnd_hybride[8]}]  {altera_chip_pin_lc}  {@L16} 
define_attribute  {b:pilotage_magnd_hybride[8]} {altera_chip_pin_lc} {@L16} 

#define_attribute [get_ports {data_serial[15]}]  {altera_chip_pin_lc}  {@P20} 
define_attribute  {b:data_serial[15]} {altera_chip_pin_lc} {@P20} 

#define_attribute [get_ports {tokenout_hybride[14]}]  {altera_chip_pin_lc}  {@F22} 
define_attribute  {b:tokenout_hybride[14]} {altera_chip_pin_lc} {@F22} 

#define_attribute [get_ports {ladder_fpga_rclk_16hybrides}]  {altera_chip_pin_lc}  {@A15} 
define_attribute  {p:ladder_fpga_rclk_16hybrides} {altera_chip_pin_lc} {@A15} 

#define_attribute [get_ports {ladder_addr[1]}]  {altera_chip_pin_lc}  {@R1} 
define_attribute  {b:ladder_addr[1]} {altera_chip_pin_lc} {@R1} 

#define_attribute [get_ports {ladder_to_rdo[13]}]  {altera_chip_pin_lc}  {@J1} 
define_attribute  {b:ladder_to_rdo[13]} {altera_chip_pin_lc} {@J1} 

#define_attribute [get_ports {sc_tms_hybride[5]}]  {altera_chip_pin_lc}  {@R5} 
define_attribute  {b:sc_tms_hybride[5]} {altera_chip_pin_lc} {@R5} 

#define_attribute [get_ports {sc_tck_hybride[6]}]  {altera_chip_pin_lc}  {@C13} 
define_attribute  {b:sc_tck_hybride[6]} {altera_chip_pin_lc} {@C13} 

#define_attribute [get_ports {sc_tdi_hybride[0]}]  {altera_chip_pin_lc}  {@M4} 
define_attribute  {b:sc_tdi_hybride[0]} {altera_chip_pin_lc} {@M4} 

#define_attribute [get_ports {tokenin_hybride[0]}]  {altera_chip_pin_lc}  {@D10} 
define_attribute  {b:tokenin_hybride[0]} {altera_chip_pin_lc} {@D10} 

#define_attribute [get_ports {sc_tms_hybride[1]}]  {altera_chip_pin_lc}  {@P5} 
define_attribute  {b:sc_tms_hybride[1]} {altera_chip_pin_lc} {@P5} 

#define_attribute [get_ports {pilotage_mvdd_hybride[14]}]  {altera_chip_pin_lc}  {@V21} 
define_attribute  {b:pilotage_mvdd_hybride[14]} {altera_chip_pin_lc} {@V21} 

#define_attribute [get_ports {sc_trstb_hybride[10]}]  {altera_chip_pin_lc}  {@R15} 
define_attribute  {b:sc_trstb_hybride[10]} {altera_chip_pin_lc} {@R15} 

#define_attribute [get_ports {sc_trstb_hybride[6]}]  {altera_chip_pin_lc}  {@M19} 
define_attribute  {b:sc_trstb_hybride[6]} {altera_chip_pin_lc} {@M19} 

#define_attribute [get_ports {sc_trstb_hybride[13]}]  {altera_chip_pin_lc}  {@P21} 
define_attribute  {b:sc_trstb_hybride[13]} {altera_chip_pin_lc} {@P21} 

#define_attribute [get_ports {pilotage_magnd_hybride[10]}]  {altera_chip_pin_lc}  {@AB19} 
define_attribute  {b:pilotage_magnd_hybride[10]} {altera_chip_pin_lc} {@AB19} 

#define_attribute [get_ports {usb_data[6]}]  {altera_chip_pin_lc}  {@Y6} 
define_attribute  {b:usb_data[6]} {altera_chip_pin_lc} {@Y6} 

#define_attribute [get_ports {pilotage_magnd_hybride[5]}]  {altera_chip_pin_lc}  {@F21} 
define_attribute  {b:pilotage_magnd_hybride[5]} {altera_chip_pin_lc} {@F21} 

#define_attribute [get_ports {sc_trstb_hybride[12]}]  {altera_chip_pin_lc}  {@H20} 
define_attribute  {b:sc_trstb_hybride[12]} {altera_chip_pin_lc} {@H20} 

#define_attribute [get_ports {data_serial[6]}]  {altera_chip_pin_lc}  {@R22} 
define_attribute  {b:data_serial[6]} {altera_chip_pin_lc} {@R22} 

#define_attribute [get_ports {rdo_to_ladder[18]}]  {altera_chip_pin_lc}  {@T1} 
define_attribute  {b:rdo_to_ladder[18]} {altera_chip_pin_lc} {@T1} 

#define_attribute [get_ports {sc_tdo_hybride[0]}]  {altera_chip_pin_lc}  {@A5} 
define_attribute  {b:sc_tdo_hybride[0]} {altera_chip_pin_lc} {@A5} 

#define_attribute [get_ports {sc_tms_hybride[0]}]  {altera_chip_pin_lc}  {@T9} 
define_attribute  {b:sc_tms_hybride[0]} {altera_chip_pin_lc} {@T9} 

#define_attribute [get_ports {ladder_to_rdo[20]}]  {altera_chip_pin_lc}  {@D2} 
define_attribute  {b:ladder_to_rdo[20]} {altera_chip_pin_lc} {@D2} 

#define_attribute [get_ports {ladder_to_rdo[14]}]  {altera_chip_pin_lc}  {@H10} 
define_attribute  {b:ladder_to_rdo[14]} {altera_chip_pin_lc} {@H10} 

#define_attribute [get_ports {ladder_to_rdo[11]}]  {altera_chip_pin_lc}  {@J3} 
define_attribute  {b:ladder_to_rdo[11]} {altera_chip_pin_lc} {@J3} 

#define_attribute [get_ports {ladder_addr[0]}]  {altera_chip_pin_lc}  {@P2} 
define_attribute  {b:ladder_addr[0]} {altera_chip_pin_lc} {@P2} 

#define_attribute [get_ports {sc_tck_hybride[1]}]  {altera_chip_pin_lc}  {@A10} 
define_attribute  {b:sc_tck_hybride[1]} {altera_chip_pin_lc} {@A10} 

#define_attribute [get_ports {pilotage_mvdd_hybride[10]}]  {altera_chip_pin_lc}  {@AB8} 
define_attribute  {b:pilotage_mvdd_hybride[10]} {altera_chip_pin_lc} {@AB8} 

#define_attribute [get_ports {sc_tdo_hybride[6]}]  {altera_chip_pin_lc}  {@T21} 
define_attribute  {b:sc_tdo_hybride[6]} {altera_chip_pin_lc} {@T21} 

#define_attribute [get_ports {ladder_to_rdo[1]}]  {altera_chip_pin_lc}  {@U1} 
define_attribute  {b:ladder_to_rdo[1]} {altera_chip_pin_lc} {@U1} 

#define_attribute [get_ports {fibre_mod_absent}]  {altera_chip_pin_lc}  {@W1} 
define_attribute  {p:fibre_mod_absent} {altera_chip_pin_lc} {@W1} 

#define_attribute [get_ports {tokenin_hybride[8]}]  {altera_chip_pin_lc}  {@A20} 
define_attribute  {b:tokenin_hybride[8]} {altera_chip_pin_lc} {@A20} 

#define_attribute [get_ports {level_shifter_dac_sck}]  {altera_chip_pin_lc}  {@T10} 
define_attribute  {p:level_shifter_dac_sck} {altera_chip_pin_lc} {@T10} 

#define_attribute [get_ports {ladder_to_rdo[17]}]  {altera_chip_pin_lc}  {@J4} 
define_attribute  {b:ladder_to_rdo[17]} {altera_chip_pin_lc} {@J4} 

#define_attribute [get_ports {ladder_to_rdo[3]}]  {altera_chip_pin_lc}  {@F2} 
define_attribute  {b:ladder_to_rdo[3]} {altera_chip_pin_lc} {@F2} 

#define_attribute [get_ports {ladder_to_rdo[10]}]  {altera_chip_pin_lc}  {@M1} 
define_attribute  {b:ladder_to_rdo[10]} {altera_chip_pin_lc} {@M1} 

#define_attribute [get_ports {sc_trstb_hybride[5]}]  {altera_chip_pin_lc}  {@U13} 
define_attribute  {b:sc_trstb_hybride[5]} {altera_chip_pin_lc} {@U13} 

#define_attribute [get_ports {rdo_to_ladder[20]}]  {altera_chip_pin_lc}  {@U14} 
define_attribute  {b:rdo_to_ladder[20]} {altera_chip_pin_lc} {@U14} 

#define_attribute [get_ports {sc_trstb_hybride[1]}]  {altera_chip_pin_lc}  {@C19} 
define_attribute  {b:sc_trstb_hybride[1]} {altera_chip_pin_lc} {@C19} 

#define_attribute [get_ports {pilotage_mvdd_hybride[11]}]  {altera_chip_pin_lc}  {@AB4} 
define_attribute  {b:pilotage_mvdd_hybride[11]} {altera_chip_pin_lc} {@AB4} 

#define_attribute [get_ports {card_ser_num[1]}]  {altera_chip_pin_lc}  {@A4} 
define_attribute  {b:card_ser_num[1]} {altera_chip_pin_lc} {@A4} 

#define_attribute [get_ports {pilotage_magnd_hybride[6]}]  {altera_chip_pin_lc}  {@B15} 
define_attribute  {b:pilotage_magnd_hybride[6]} {altera_chip_pin_lc} {@B15} 

#define_attribute [get_ports {pilotage_mvdd_hybride[6]}]  {altera_chip_pin_lc}  {@U22} 
define_attribute  {b:pilotage_mvdd_hybride[6]} {altera_chip_pin_lc} {@U22} 

#define_attribute [get_ports {debug_present_n}]  {altera_chip_pin_lc}  {@B3} 
define_attribute  {p:debug_present_n} {altera_chip_pin_lc} {@B3} 

#define_attribute [get_ports {des_lock}]  {altera_chip_pin_lc}  {@V2} 
define_attribute  {p:des_lock} {altera_chip_pin_lc} {@V2} 

#define_attribute [get_ports {rdo_to_ladder[19]}]  {altera_chip_pin_lc}  {@V5} 
define_attribute  {b:rdo_to_ladder[19]} {altera_chip_pin_lc} {@V5} 

#define_attribute [get_ports {holdin_echelle}]  {altera_chip_pin_lc}  {@V8} 
define_attribute  {p:holdin_echelle} {altera_chip_pin_lc} {@V8} 

#define_attribute [get_ports {fibre_mod_sda}]  {altera_chip_pin_lc}  {@B10} 
define_attribute  {p:fibre_mod_sda} {altera_chip_pin_lc} {@B10} 

#define_attribute [get_ports {xtal_en}]  {altera_chip_pin_lc}  {@D17} 
define_attribute  {p:xtal_en} {altera_chip_pin_lc} {@D17} 

#define_attribute [get_ports {data_serial[13]}]  {altera_chip_pin_lc}  {@V11} 
define_attribute  {b:data_serial[13]} {altera_chip_pin_lc} {@V11} 

#define_attribute [get_ports {data_serial[5]}]  {altera_chip_pin_lc}  {@V12} 
define_attribute  {b:data_serial[5]} {altera_chip_pin_lc} {@V12} 

#define_attribute [get_ports {pilotage_mvdd_hybride[13]}]  {altera_chip_pin_lc}  {@AB15} 
define_attribute  {b:pilotage_mvdd_hybride[13]} {altera_chip_pin_lc} {@AB15} 

#define_attribute [get_ports {sc_tdo_hybride[11]}]  {altera_chip_pin_lc}  {@V14} 
define_attribute  {b:sc_tdo_hybride[11]} {altera_chip_pin_lc} {@V14} 

#define_attribute [get_ports {pilotage_magnd_hybride[4]}]  {altera_chip_pin_lc}  {@B13} 
define_attribute  {b:pilotage_magnd_hybride[4]} {altera_chip_pin_lc} {@B13} 

#define_attribute [get_ports {tokenout_hybride[1]}]  {altera_chip_pin_lc}  {@F10} 
define_attribute  {b:tokenout_hybride[1]} {altera_chip_pin_lc} {@F10} 

#define_attribute [get_ports {pilotage_mvdd_hybride[8]}]  {altera_chip_pin_lc}  {@U21} 
define_attribute  {b:pilotage_mvdd_hybride[8]} {altera_chip_pin_lc} {@U21} 

#define_attribute [get_ports {pilotage_magnd_hybride[1]}]  {altera_chip_pin_lc}  {@G13} 
define_attribute  {b:pilotage_magnd_hybride[1]} {altera_chip_pin_lc} {@G13} 

#define_attribute [get_ports {spare_switch}]  {altera_chip_pin_lc}  {@E4} 
define_attribute  {p:spare_switch} {altera_chip_pin_lc} {@E4} 

#define_attribute [get_ports {tokenin_hybride[7]}]  {altera_chip_pin_lc}  {@J18} 
define_attribute  {b:tokenin_hybride[7]} {altera_chip_pin_lc} {@J18} 

#define_attribute [get_ports {ladder_to_rdo[7]}]  {altera_chip_pin_lc}  {@W13} 
define_attribute  {b:ladder_to_rdo[7]} {altera_chip_pin_lc} {@W13} 

#define_attribute [get_ports {latchup_hybride[2]}]  {altera_chip_pin_lc}  {@F17} 
define_attribute  {b:latchup_hybride[2]} {altera_chip_pin_lc} {@F17} 

#define_attribute [get_ports {card_ser_num[0]}]  {altera_chip_pin_lc}  {@A3} 
define_attribute  {b:card_ser_num[0]} {altera_chip_pin_lc} {@A3} 

#define_attribute [get_ports {usb_data[3]}]  {altera_chip_pin_lc}  {@T8} 
define_attribute  {b:usb_data[3]} {altera_chip_pin_lc} {@T8} 

#define_attribute [get_ports {tokenout_hybride[10]}]  {altera_chip_pin_lc}  {@N18} 
define_attribute  {b:tokenout_hybride[10]} {altera_chip_pin_lc} {@N18} 

#define_attribute [get_ports {sc_trstb_hybride[4]}]  {altera_chip_pin_lc}  {@W20} 
define_attribute  {b:sc_trstb_hybride[4]} {altera_chip_pin_lc} {@W20} 

#define_attribute [get_ports {latchup_hybride[15]}]  {altera_chip_pin_lc}  {@W21} 
define_attribute  {b:latchup_hybride[15]} {altera_chip_pin_lc} {@W21} 

#define_attribute [get_ports {latchup_hybride[12]}]  {altera_chip_pin_lc}  {@W22} 
define_attribute  {b:latchup_hybride[12]} {altera_chip_pin_lc} {@W22} 

#define_attribute [get_ports {fibre_tx_disable}]  {altera_chip_pin_lc}  {@Y1} 
define_attribute  {p:fibre_tx_disable} {altera_chip_pin_lc} {@Y1} 

#define_attribute [get_ports {test_16hybrides}]  {altera_chip_pin_lc}  {@F13} 
define_attribute  {p:test_16hybrides} {altera_chip_pin_lc} {@F13} 

#define_attribute [get_ports {fibre_rx_loss}]  {altera_chip_pin_lc}  {@D6} 
define_attribute  {p:fibre_rx_loss} {altera_chip_pin_lc} {@D6} 

#define_attribute [get_ports {pilotage_magnd_hybride[2]}]  {altera_chip_pin_lc}  {@C15} 
define_attribute  {b:pilotage_magnd_hybride[2]} {altera_chip_pin_lc} {@C15} 

#define_attribute [get_ports {ladder_to_rdo[12]}]  {altera_chip_pin_lc}  {@Y10} 
define_attribute  {b:ladder_to_rdo[12]} {altera_chip_pin_lc} {@Y10} 

#define_attribute [get_ports {ladder_to_rdo[8]}]  {altera_chip_pin_lc}  {@N1} 
define_attribute  {b:ladder_to_rdo[8]} {altera_chip_pin_lc} {@N1} 

#define_attribute [get_ports {card_ser_num[3]}]  {altera_chip_pin_lc}  {@H1} 
define_attribute  {b:card_ser_num[3]} {altera_chip_pin_lc} {@H1} 

#define_attribute [get_ports {latchup_hybride[14]}]  {altera_chip_pin_lc}  {@Y21} 
define_attribute  {b:latchup_hybride[14]} {altera_chip_pin_lc} {@Y21} 

#define_attribute [get_ports {sc_trstb_hybride[2]}]  {altera_chip_pin_lc}  {@D19} 
define_attribute  {b:sc_trstb_hybride[2]} {altera_chip_pin_lc} {@D19} 

#define_clock -internal  {4} [get_nets {comp_mega_func_pll_40MHz_switchover_cycloneIII.c0}] -name  {mega_func_pll_40MHz_switchover_cycloneIII|c0_derived_clock} -ref_rise  {0.000000} -ref_fall  {12.500000} -uncertainty  {0.000000} -period  {25.000000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {12.500000} 
#define_clock -internal  {4} [get_nets {comp_mega_func_pll_40MHz_switchover_cycloneIII.c1}] -name  {mega_func_pll_40MHz_switchover_cycloneIII|c1_derived_clock} -ref_rise  {0.000000} -ref_fall  {6.250000} -uncertainty  {0.000000} -period  {12.500000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {6.250000} 
#define_clock -internal  {4} [get_nets {comp_mega_func_pll_40MHz_switchover_cycloneIII.c2}] -name  {mega_func_pll_40MHz_switchover_cycloneIII|c2_derived_clock} -ref_rise  {0.000000} -ref_fall  {125.000000} -uncertainty  {0.000000} -period  {250.000000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {125.000000} 
#define_clock -internal  {4} [get_nets {comp_mega_func_pll_40MHz_switchover_cycloneIII.c3}] -name  {mega_func_pll_40MHz_switchover_cycloneIII|c3_derived_clock} -ref_rise  {0.000000} -ref_fall  {500.000000} -uncertainty  {0.000000} -period  {1000.000000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {500.000000} 
#define_clock -internal  {4} [get_nets {comp_mega_func_pll_40MHz_switchover_cycloneIII.clkbad0}] -name  {mega_func_pll_40MHz_switchover_cycloneIII|clkbad0_derived_clock} -ref_rise  {0.000000} -ref_fall  {12.500000} -uncertainty  {0.000000} -period  {25.000000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {12.500000} 
#define_clock -internal  {4} [get_nets {comp_mega_func_pll_40MHz_switchover_cycloneIII.clkbad1}] -name  {mega_func_pll_40MHz_switchover_cycloneIII|clkbad1_derived_clock} -ref_rise  {0.000000} -ref_fall  {6.250000} -uncertainty  {0.000000} -period  {12.500000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {6.250000} 
#define_clock -internal  {6} [get_ports {holdin_echelle}] -name  {ladder_fpga|holdin_echelle} -ref_rise  {0.000000} -ref_fall  {500.000000} -uncertainty  {0.000000} -period  {1000.000000} -clockgroup  {Inferred_clkgroup_0} -rise  {0.000000} -fall  {500.000000} 
#define_clock -internal  {6} [get_ports {testin_echelle}] -name  {ladder_fpga|testin_echelle} -ref_rise  {0.000000} -ref_fall  {500.000000} -uncertainty  {0.000000} -period  {1000.000000} -clockgroup  {Inferred_clkgroup_1} -rise  {0.000000} -fall  {500.000000} 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_ETAT_REG.a.10.d.e.scan_out}] -name  {dr_cell_a_10_d_e_0|scan_out_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} 
#define_multicycle_path -internal  {5} -from [get_clocks {dr_cell_a_10_d_e_0|scan_out_derived_clock}] -to [get_clocks {dr_cell_a_10_d_e_0|scan_out_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_ETAT_REG.a.9.d.e.scan_out}] -name  {dr_cell_a_9_d_e_0|scan_out_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} 
#define_multicycle_path -internal  {5} -from [get_clocks {dr_cell_a_9_d_e_0|scan_out_derived_clock}] -to [get_clocks {dr_cell_a_9_d_e_0|scan_out_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {tst_tokenin_echelle}] -name  {ladder_fpga|tst_tokenin_echelle_derived_clock} -ref_rise  {0.000000} -ref_fall  {12.500000} -uncertainty  {0.000000} -period  {25.000000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {12.500000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {ladder_fpga|tst_tokenin_echelle_derived_clock}] -to [get_clocks {ladder_fpga|tst_tokenin_echelle_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {ladder_fpga_abort}] -name  {ladder_fpga|ladder_fpga_abort_derived_clock} -ref_rise  {0.000000} -ref_fall  {6.250000} -uncertainty  {0.000000} -period  {12.500000} -clockgroup  {default_clkgroup_3} -rise  {0.000000} -fall  {6.250000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {ladder_fpga|ladder_fpga_abort_derived_clock}] -to [get_clocks {ladder_fpga|ladder_fpga_abort_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_TAP_CONTROL.sc_updateDR_0x01}] -name  {tap_control|sc_updateDR_0x01_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {tap_control|sc_updateDR_0x01_derived_clock}] -to [get_clocks {tap_control|sc_updateDR_0x01_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_TAP_CONTROL.sc_updateDR_0x03}] -name  {tap_control|sc_updateDR_0x03_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {tap_control|sc_updateDR_0x03_derived_clock}] -to [get_clocks {tap_control|sc_updateDR_0x03_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_TAP_CONTROL.sc_updateDR_0x04}] -name  {tap_control|sc_updateDR_0x04_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {tap_control|sc_updateDR_0x04_derived_clock}] -to [get_clocks {tap_control|sc_updateDR_0x04_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_TAP_CONTROL.sc_updateDR_0x08}] -name  {tap_control|sc_updateDR_0x08_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {tap_control|sc_updateDR_0x08_derived_clock}] -to [get_clocks {tap_control|sc_updateDR_0x08_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_TAP_CONTROL.sc_updateDR_0x09}] -name  {tap_control|sc_updateDR_0x09_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} 
#define_multicycle_path -internal  {5} -from [get_clocks {tap_control|sc_updateDR_0x09_derived_clock}] -to [get_clocks {tap_control|sc_updateDR_0x09_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {COMP_ladder_fpga_SC_TAP_CONTROL.sc_updateDR_0x0b}] -name  {tap_control|sc_updateDR_0x0b_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} -disable 
#define_multicycle_path -internal  {5} -from [get_clocks {tap_control|sc_updateDR_0x0b_derived_clock}] -to [get_clocks {tap_control|sc_updateDR_0x0b_derived_clock}]  {2} -disable 
#define_clock -internal  {5} [get_nets {level_shifter_dac_load}] -name  {ladder_fpga|COMP_LADDER_FPGA_SC_CONFIG.a_6_d_e.level_shifter_dac_load_derived_clock} -ref_rise  {0.000000} -ref_fall  {50.000000} -uncertainty  {0.000000} -period  {100.000000} -clockgroup  {default_clkgroup_0} -rise  {0.000000} -fall  {50.000000} 
#define_multicycle_path -internal  {5} -from [get_clocks {ladder_fpga|COMP_LADDER_FPGA_SC_CONFIG.a_6_d_e.level_shifter_dac_load_derived_clock}] -to [get_clocks {ladder_fpga|COMP_LADDER_FPGA_SC_CONFIG.a_6_d_e.level_shifter_dac_load_derived_clock}]  {2} -disable 
