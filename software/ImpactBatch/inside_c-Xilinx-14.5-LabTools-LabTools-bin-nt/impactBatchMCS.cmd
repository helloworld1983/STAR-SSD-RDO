setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
attachflash -position 1 -bpi "XCF128X"
assignfiletoattachedflash -position 1 -file "C:/Users/ssd/Desktop/ConfFiles/RDO_0030.mcs"
setCable -target "digilent_plugin DEVICE=SN:210205837724 FREQUENCY=10000000"
Program -p 1 -dataWidth 16 -rs1 NONE -rs0 NONE -bpionly -e -v -loadfpga 
setCable -target "digilent_plugin DEVICE=SN:210205837742 FREQUENCY=10000000"
Program -p 1 -dataWidth 16 -rs1 NONE -rs0 NONE -bpionly -e -v -loadfpga 
setMode -bs
exit
setMode -bs
exit
setMode -bs
exit
