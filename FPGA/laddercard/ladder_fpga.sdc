# Synopsys, Inc. constraint file
# C:/work/SSD/laddercard/fpga/ladder_fpga_v0e/ladder_fpga.sdc
# Written on Tue May 13 09:01:38 2014
# by Synplify Pro, H-2013.03-1  Scope Editor

#
# Collections
#

#
# Clocks
#
define_clock   {ladder_fpga_sc_tck} -name {sc_tck}  -freq 10 -clockgroup default_clkgroup_0
define_clock   {COMP_ladder_fpga_SC_TAP_CONTROL.clockIR} -name {clockIR}  -freq 10 -clockgroup default_clkgroup_0
define_clock   {COMP_ladder_fpga_SC_TAP_CONTROL.clockDR} -name {clockDR}  -freq 10 -clockgroup default_clkgroup_0
define_clock   {temperature} -name {temperature}  -freq 10 -clockgroup default_clkgroup_1
define_clock   {comp_mega_func_pll_40MHz_switchover_cycloneIII.altpll_component} -name {switchover}  -freq 40 -clockgroup default_clkgroup_2
define_clock   {comp_mesure_temperature.ck_4M} -name {tempclk4M}  -freq 4 -clockgroup default_clkgroup_1
define_clock   {clock40mhz_fpga} -name {clock40mhz_fpga}  -freq 40 -clockgroup default_clkgroup_3
define_clock   {clock40mhz_xtal} -name {clock40mhz_xtal}  -freq 40 -clockgroup default_clkgroup_4
define_clock   {ladder_fpga_clock80MHz} -name {ladder_fpga_clock80MHz}  -freq 80 -clockgroup default_clkgroup_2
define_clock   {COMP_ladder_fpga_SC_TAP_CONTROL.updateIR} -name {updateIR}  -freq 10 -clockgroup default_clkgroup_0
define_clock   {ladder_fpga_sc_updateDR} -name {updateDR}  -freq 10 -clockgroup default_clkgroup_0
define_clock -disable   {}  -clockgroup default_clkgroup_5

#
# Clock to Clock
#

#
# Inputs/Outputs
#
define_input_delay -disable      -default  0.00 -improve 0.00 -route 0.00
define_output_delay -disable     -default -improve 0.00 -route 0.00
define_input_delay -disable      {reset_n} -improve 0.00 -route 0.00
define_input_delay -disable      {card_ser_num[5:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {roboclock_horloge40_phase[3:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {roboclock_adc_phase[7:0]} -improve 0.00 -route 0.00
define_output_delay              {adc_cs_n[7:0]} -improve 0.00 -route 0.00 -ref {ladder_fpga_clock80MHz:f}
define_input_delay               {data_serial[15:0]} -improve 0.00 -route 0.00 -ref {ladder_fpga_clock80MHz:f}
define_output_delay -disable     {addr_mux_h_neg} -improve 0.00 -route 0.00
define_output_delay -disable     {addr_mux_l_neg} -improve 0.00 -route 0.00
define_output_delay -disable     {pilotage_magnd_hybride[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {pilotage_mvdd_hybride[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {des_lock} -improve 0.00 -route 0.00
define_input_delay -disable      {rdo_to_ladder[20:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {des_bist_enable} -improve 0.00 -route 0.00
define_output_delay -disable     {des_bist_mode} -improve 0.00 -route 0.00
define_input_delay -disable      {des_bist_pass} -improve 0.00 -route 0.00
define_output_delay -disable     {des_high_slew_rate} -improve 0.00 -route 0.00
define_output_delay -disable     {des_output_enable} -improve 0.00 -route 0.00
define_output_delay -disable     {des_power_down_n} -improve 0.00 -route 0.00
define_output_delay -disable     {des_progressive_turn_on_sel} -improve 0.00 -route 0.00
define_output_delay -disable     {des_randomize_off} -improve 0.00 -route 0.00
define_output_delay -disable     {des_strobe_on_rising_edge} -improve 0.00 -route 0.00
define_output_delay -disable     {ladder_to_rdo[22:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {ser_output_enable} -improve 0.00 -route 0.00
define_output_delay -disable     {ser_power_down_n} -improve 0.00 -route 0.00
define_output_delay -disable     {ser_randomize_off} -improve 0.00 -route 0.00
define_output_delay -disable     {ser_strobe_on_rising_edge} -improve 0.00 -route 0.00
define_input_delay -disable      {fibre_mod_absent} -improve 0.00 -route 0.00
define_input_delay -disable      {fibre_mod_scl} -improve 0.00 -route 0.00
define_input_delay -disable      {fibre_mod_sda} -improve 0.00 -route 0.00
define_input_delay -disable      {fibre_rx_loss} -improve 0.00 -route 0.00
define_output_delay -disable     {fibre_tx_disable} -improve 0.00 -route 0.00
define_input_delay -disable      {fibre_tx_fault} -improve 0.00 -route 0.00
define_input_delay -disable      {latchup_hybride[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {mux_ref_latchup[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {test_16hybrides} -improve 0.00 -route 0.00
define_output_delay -disable     {hold_16hybrides} -improve 0.00 -route 0.00
define_output_delay -disable     {rclk_16hybrides} -improve 0.00 -route 0.00
define_output_delay -disable     {tokenin_hybride[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {tokenout_hybride[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tck_hybride[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tms_hybride[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {trstb_hybride[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tdi_hybride[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {tdo_hybride[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {usb_data[7:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {usb_ready} -improve 0.00 -route 0.00
define_output_delay -disable     {usb_read_n} -improve 0.00 -route 0.00
define_input_delay -disable      {usb_reset_n} -improve 0.00 -route 0.00
define_input_delay -disable      {usb_rx_empty} -improve 0.00 -route 0.00
define_input_delay -disable      {usb_tx_full} -improve 0.00 -route 0.00
define_output_delay -disable     {usb_write} -improve 0.00 -route 0.00

#
# Registers
#

#
# Delay Paths
#

#
# Attributes
#

#
# I/O Standards
#
define_io_standard               -default_input -delay_type input syn_pad_type {LVCMOS_33}
define_io_standard               -default_output -delay_type output syn_pad_type {LVCMOS_33}
define_io_standard -disable      -default_bidir -delay_type bidir
define_io_standard -disable      {reset_n} -delay_type input
define_io_standard -disable      {card_ser_num[5:0]} -delay_type input
define_io_standard -disable      {roboclock_horloge40_phase[3:0]} -delay_type output
define_io_standard -disable      {roboclock_adc_phase[7:0]} -delay_type output
define_io_standard               {adc_cs_n[7:0]} -delay_type output syn_pad_type {LVCMOS_33}
define_io_standard -disable      {data_serial[15:0]} -delay_type input syn_pad_type {LVCMOS_25}
define_io_standard -disable      {addr_mux_h_neg} -delay_type output
define_io_standard -disable      {addr_mux_l_neg} -delay_type output
define_io_standard -disable      {pilotage_magnd_hybride[15:0]} -delay_type output syn_pad_type {LVCMOS_25}
define_io_standard -disable      {pilotage_mvdd_hybride[15:0]} -delay_type output syn_pad_type {LVCMOS_25}
define_io_standard -disable      {des_lock} -delay_type input
define_io_standard -disable      {rdo_to_ladder[20:0]} -delay_type input
define_io_standard -disable      {des_bist_enable} -delay_type output
define_io_standard -disable      {des_bist_mode} -delay_type output
define_io_standard -disable      {des_bist_pass} -delay_type input
define_io_standard -disable      {des_high_slew_rate} -delay_type output
define_io_standard -disable      {des_output_enable} -delay_type output
define_io_standard -disable      {des_power_down_n} -delay_type output
define_io_standard -disable      {des_progressive_turn_on_sel} -delay_type output
define_io_standard -disable      {des_randomize_off} -delay_type output
define_io_standard -disable      {des_strobe_on_rising_edge} -delay_type output
define_io_standard -disable      {ladder_to_rdo[22:0]} -delay_type output
define_io_standard -disable      {ser_output_enable} -delay_type output
define_io_standard -disable      {ser_power_down_n} -delay_type output
define_io_standard -disable      {ser_randomize_off} -delay_type output
define_io_standard -disable      {ser_strobe_on_rising_edge} -delay_type output
define_io_standard -disable      {fibre_mod_absent} -delay_type input
define_io_standard -disable      {fibre_mod_scl} -delay_type input
define_io_standard -disable      {fibre_mod_sda} -delay_type input
define_io_standard -disable      {fibre_rx_loss} -delay_type input
define_io_standard -disable      {fibre_tx_disable} -delay_type output syn_pad_type {LVCMOS_25}
define_io_standard -disable      {fibre_tx_fault} -delay_type input
define_io_standard -disable      {latchup_hybride[15:0]} -delay_type input
define_io_standard -disable      {mux_ref_latchup[1:0]} -delay_type output
define_io_standard -disable      {test_16hybrides} -delay_type output syn_pad_type {LVCMOS_25}
define_io_standard -disable      {hold_16hybrides} -delay_type output syn_pad_type {LVCMOS_25}
define_io_standard -disable      {rclk_16hybrides} -delay_type output
define_io_standard -disable      {tokenin_hybride[15:0]} -delay_type output
define_io_standard -disable      {tokenout_hybride[15:0]} -delay_type input
define_io_standard -disable      {tck_hybride[15:0]} -delay_type output
define_io_standard -disable      {tms_hybride[15:0]} -delay_type output
define_io_standard -disable      {trstb_hybride[15:0]} -delay_type output
define_io_standard -disable      {tdi_hybride[15:0]} -delay_type output
define_io_standard -disable      {tdo_hybride[15:0]} -delay_type input
define_io_standard -disable      {usb_data[7:0]} -delay_type input
define_io_standard -disable      {usb_ready} -delay_type input
define_io_standard -disable      {usb_read_n} -delay_type output syn_pad_type {LVCMOS_25}
define_io_standard -disable      {usb_reset_n} -delay_type input
define_io_standard -disable      {usb_rx_empty} -delay_type input
define_io_standard -disable      {usb_tx_full} -delay_type input
define_io_standard -disable      {usb_write} -delay_type output

#
# Compile Points
#

#
# Other
#
