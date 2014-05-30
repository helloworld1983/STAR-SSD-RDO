# Run with quartus_sh -t <x_cons.tcl>

# Global assignments 
set_global_assignment -name TOP_LEVEL_ENTITY "|ladder_fpga"
set_global_assignment -name ROUTING_BACK_ANNOTATION_MODE NORMAL
set_global_assignment -name FAMILY "CYCLONE III"
set_global_assignment -name DEVICE "EP3C16F484C6"
set_global_assignment -section_id ladder_fpga -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "SYNPLIFY"
set_global_assignment -section_id eda_design_synthesis -name EDA_USE_LMF synplcty.lmf
set_global_assignment -name TAO_FILE "myresults.tao"
set_global_assignment -name SOURCES_PER_DESTINATION_INCLUDE_COUNT "1000" 
set_global_assignment -name ROUTER_REGISTER_DUPLICATION ON
set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS "OFF"
set_global_assignment -name REMOVE_DUPLICATE_REGISTERS "OFF"
set_global_assignment -name REMOVE_DUPLICATE_LOGIC "OFF"
# set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
#set_global_assignment -name EDA_RESYNTHESIS_TOOL "AMPLIFY"
set_global_assignment -name ENABLE_CLOCK_LATENCY "ON"
set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON
set_global_assignment -name SDC_FILE "/SPACE/users/renard/projets/star_upgrade/ladder_fpga/rev_1/complete_data_packer_altera.scf"

# Clock assignments 

create_base_clock clock80mhz_fpga_setting -fmax 692.042mhz -duty_cycle 50.00 -target clock80mhz_fpga 
create_base_clock rdo_to_ladder\[3\]_setting -fmax 508.958mhz -duty_cycle 50.00 -target rdo_to_ladder\[3\] 


# False path constraints 

# Multicycle constraints 

# Path delay constraints 


# Physical synthesis - Placement constraints

