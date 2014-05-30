## Generated SDC file "ladder_fpga.out.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.1 Build 177 11/07/2012 SJ Web Edition"

## DATE    "Tue May 13 09:18:49 2014"

##
## DEVICE  "EP3C16F484C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock40mhz_fpga} -period 25.000 -waveform { 0.000 12.500 } [get_ports {clock40mhz_fpga}]
create_clock -name {clock40mhz_xtal} -period 25.000 -waveform { 0.000 12.500 } [get_ports {clock40mhz_xtal}]
create_clock -name {sc_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {ladder_fpga_sc_tck}]
create_clock -name {temperature} -period 100.000 -waveform { 0.000 50.000 } [get_ports {temperature}]
create_clock -name {switchover} -period 25.000 -waveform { 0.000 12.500 } 
create_clock -name {updateIR} -period 100.000 -waveform { 0.000 50.000 } [get_registers {COMP_ladder_fpga_SC_TAP_CONTROL|updateIR}]
create_clock -name {ladder_fpga|holdin_echelle} -period 1000.000 -waveform { 0.000 500.000 } [get_ports {holdin_echelle}]
create_clock -name {ladder_fpga|testin_echelle} -period 1000.000 -waveform { 0.000 500.000 } [get_ports {testin_echelle}]
create_clock -name {ladder_fpga_clock80MHz} -period 12.500 -waveform { 0.000 6.250 } 
create_clock -name {clockIR} -period 100.000 -waveform { 0.000 50.000 } 
create_clock -name {clockDR} -period 100.000 -waveform { 0.000 50.000 } 
create_clock -name {updateDR} -period 100.000 -waveform { 0.000 50.000 } 
create_clock -name {tempclk4M} -period 250.000 -waveform { 0.000 125.000 } 


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[0]~1} -source [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {clock40mhz_xtal} [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {clock40mhz_fpga} [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[1]~1} -source [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {clock40mhz_xtal} [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {clock40mhz_fpga} [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[2]~1} -source [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 10 -master_clock {clock40mhz_xtal} [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 10 -master_clock {clock40mhz_fpga} [get_pins {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {ladder_fpga|COMP_LADDER_FPGA_SC_CONFIG.a_6_d_e.level_shifter_dac_load_derived_clock} -source [get_pins {COMP_LADDER_FPGA_SC_CONFIG|a_6_d_e|data_out_Z|clk}] -master_clock {sc_tck} [get_pins {COMP_LADDER_FPGA_SC_CONFIG|a_6_d_e|data_out_Z|q}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[0]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[0]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[1]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[1]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[2]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[2]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[3]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[3]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[4]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[4]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[5]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[5]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[6]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[6]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[7]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[7]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[8]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[8]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[9]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[9]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[10]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[10]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[11]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[11]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[12]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[12]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[13]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[13]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[14]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[14]}]
set_input_delay -add_delay -max -clock [get_clocks {clock40mhz_fpga}]  3.000 [get_ports {data_serial[15]}]
set_input_delay -add_delay -min -clock [get_clocks {clock40mhz_fpga}]  -3.000 [get_ports {data_serial[15]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[0]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[1]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[2]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[3]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[4]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[5]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[6]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {ladder_fpga_clock80MHz}]  0.000 [get_ports {adc_cs_n[7]}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {ladder_fpga|testin_echelle}] -group [get_clocks {ladder_fpga|holdin_echelle}] -group [get_clocks {clock40mhz_fpga {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[2]} 0 {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[0]} 0 {comp_mega_func_pll_40MHz_switchover_cycloneIII|altpll_component|auto_generated|pll1|clk[1]}}] -group [get_clocks {clock40mhz_xtal}] -group [get_clocks {sc_tck updateIR ladder_fpga|COMP_LADDER_FPGA_SC_CONFIG.a_6_d_e.level_shifter_dac_load_derived_clock clockIR clockDR updateDR}] -group [get_clocks {temperature tempclk4M}] -group [get_clocks {switchover ladder_fpga_clock80MHz}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_ed9:dffpipe10|dffe11a*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

