#!/bin/bash
# Version 1.0 Feb 18 2014
# Created by: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
# Script to Configure RDOs by using the Batch mode of Impact

versionFlag=false
sectorFlag=false
boardFlag=false

#Getting options from the commad line
while getopts ":v:b:s:" opt; do
	case $opt in
   	v) 	#v=version
		RDOVersion=$OPTARG
		versionFlag=true
		;;
	b) 	#b=board
		RDO=$OPTARG
		boardFlag=true
		if [ $RDO -lt 1 ] || [ $RDO -gt 5 ]; then
			echo "Invalid -b (RDO board) argument, please type 1, 2, 3, 4 or 5"
			exit
		fi
		;;
	s)	#s=sector sector 1 is sst01 (3 first RDOs) and secot 2 is sst02 (2 last RDOs)
		SECTOR=$OPTARG
		sectorFlag=true
		if [ $SECTOR -lt 1 ] || [ $SECTOR -gt 2 ]; then
			echo "Invalid sector argument, please type 1 or 2"
			exit
		fi
		;;
	\?)
		echo "Invalid option: -"$OPTARG"" >&2
		exit 
		;;
	:)
		echo "Option -"$OPTARG" requires an argument" >&2 
		exit
		;;
	esac
done
#Checking if option -v is used
if ! $versionFlag; then
	echo "option -v must be included and the version number as argument" >&2
	exit 
fi
#Assigning configuration file
file="C:/Users/ssd/Desktop/ConfFiles/RDO_$RDOVersion.bit"

#Checking if file exist
if [ ! -f "$file" ]; then
	echo $file
	echo "File does not exist"
	exit
else
#Configure RDOs according to sector selected, All RDOs, or single RDO
	
	cd /cygdrive/c/Xilinx/14.5/LabTools/LabTools/bin/nt/
	cat impactBatchBIT_INIT.cmd | sed "s/XXXX/$RDOVersion/" > impactBatchBIT.cmd

	if $sectorFlag; then
		if [ $SECTOR -eq 1 ]; then
			cat impactBatchBIT_RDO1.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO2.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO3.cmd >> impactBatchBIT.cmd
		else
			cat impactBatchBIT_RDO4.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO5.cmd >> impactBatchBIT.cmd
		fi
		cat impactBatchBIT_END.cmd >> impactBatchBIT.cmd
		
		./impact.exe -batch impactBatchBIT.cmd
		echo "RDOs in sector $SECTOR are configured with Firmware version $RDOVersion"
		exit
	else
		if $boardFlag; then
			cat impactBatchBIT_RDO$RDO.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_END.cmd >> impactBatchBIT.cmd

			./impact.exe -batch impactBatchBIT.cmd
			echo "RDO $RDO is configured with Firmware version $RDOVersion"
			exit
		else
			cat impactBatchBIT_RDO1.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO2.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO3.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO4.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_RDO5.cmd >> impactBatchBIT.cmd
			cat impactBatchBIT_END.cmd >> impactBatchBIT.cmd
			
			./impact.exe -batch impactBatchBIT.cmd
	                echo "All RDOs are configured with Firmware version $RDOVersion"
			exit
		fi
	fi
fi

