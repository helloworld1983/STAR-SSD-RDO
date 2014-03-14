setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -target "digilent_plugin DEVICE=SN:210205873779 FREQUENCY=10000000"
Identify -inferir 
identifyMPM 
assignFile -p 2 -file "C:/Users/ssd/Desktop/ConfFiles/L2F_0001.mcs"
setAttribute -position 2 -attr packageName -value ""
assignFile -p 4 -file "C:/Users/ssd/Desktop/ConfFiles/L2F_0001.mcs"
setAttribute -position 4 -attr packageName -value ""
setCable -target "digilent_plugin DEVICE=SN:210205873828 FREQUENCY=10000000"
Program -p 2 -e -defaultVersion 0
Program -p 4 -e -defaultVersion 0
setCable -target "digilent_plugin DEVICE=SN:210205873885 FREQUENCY=10000000"
Program -p 2 -e -defaultVersion 0
Program -p 4 -e -defaultVersion 0
