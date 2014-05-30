
#Begin clock constraint
define_clock -name {n:ladder_fpga|comp_mega_func_pll_40MHzto50MHz_cycloneIII.ladder_fpga_clock50MHz_derived_clock} -period 1.752 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 0.876 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {p:ladder_fpga|clock40mhz_fpga} -period 2.190 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 1.095 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {p:ladder_fpga|rclk_echelle} -period 3.471 -clockgroup Autoconstr_clkgroup_2 -rise 0.000 -fall 1.735 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {p:ladder_fpga|clock80mhz_fpga} -period 1.450 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 0.725 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {p:ladder_fpga|rdo_to_ladder[3]} -period 4.690 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 2.345 -route 0.000 
#End clock constraint
