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
#set_global_assignment -name EDA_RESYNTHESIS_TOOL "AMPLIFY" -remove
create_base_clock clock80mhz_fpga_setting -fmax 692.042mhz -duty_cycle 50.00 -target clock80mhz_fpga -disable
create_base_clock rdo_to_ladder\[3\]_setting -fmax 508.958mhz -duty_cycle 50.00 -target rdo_to_ladder\[3\] -disable
