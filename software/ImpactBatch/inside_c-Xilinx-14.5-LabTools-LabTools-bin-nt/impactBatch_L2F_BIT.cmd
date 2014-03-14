setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -target "digilent_plugin DEVICE=SN:210205873779 FREQUENCY=10000000"
Identify -inferir 
identifyMPM 
assignFile -p 1 -file "C:/Users/ssd/Desktop/ConfFiles/L2F_0001.bit"
assignFile -p 3 -file "C:/Users/ssd/Desktop/ConfFiles/L2F_0001.bit"
setCable -target "digilent_plugin DEVICE=SN:210205873885 FREQUENCY=10000000"
Program -p 1 
Program -p 3 
setMode -bs
exit
