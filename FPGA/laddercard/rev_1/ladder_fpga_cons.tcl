
proc syn_dump_io {} {
	execute_module -tool cdb -args "--back_annotate=pin_device"
}

source "C:/Synopsys/fpga_F201109SP1/lib/altera/quartus_cons.tcl"
syn_create_and_open_prj ladder_fpga
source $::quartus(binpath)/prj_asd_import.tcl
syn_create_and_open_csf ladder_fpga
syn_handle_cons ladder_fpga
syn_compile_quartus
syn_dump_io
