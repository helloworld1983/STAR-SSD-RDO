
proc syn_dump_io {} {
	execute_module -tool cdb -args "--back_annotate=pin_device"
}

source "C:/FPGAtools/Synopsys/fpga_H2013031/lib/altera/quartus_cons.tcl"
syn_create_and_open_prj ladder_fpga
source $::quartus(binpath)/prj_asd_import.tcl
syn_create_and_open_csf ladder_fpga
syn_handle_cons ladder_fpga
syn_dump_io
