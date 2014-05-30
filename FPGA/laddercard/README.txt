The ladder card FPGA design is originaly from Christophe RENARD at SUBATECH

To compile:
1. Synopsis Synplify Pro (verion H-2013.03-1)
     Projetc file: ladder_fpga.prj
     Compile the design
2. Altera Quartus (32bit 12.1 Build 177 web Edition)
     Project file: rev_1/ladder_fpga.qpf
     Compile the design
2.1 Quartus
     Convert programming File to "Raw Binery File (.rbf)"

3. RBF2USB (in doftware section of repository)
     Convert RBF file to file usable by EPICS

