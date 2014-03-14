#!/bin/bash
# Version 1.0 March 14 2014
# Created by: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
# Script to Configure L2F PROMs using the Batch mode of Impact

versionFlag=false
sectorFlag=false
boardFlag=false

#Getting options from the commad line
while getopts ":v:b:s:" opt; do
	case $opt in
   	v) 	#v=version
		L2FVersion=$OPTARG
		versionFlag=true
		;;
	b) 	#b=board
		L2F=$OPTARG
		boardFlag=true
		if [ $L2F -lt 1 ] || [ $L2F -gt 5 ]; then
			echo "Invalid -b (L2F board) argument, please type 1, 2, 3, 4 or 5"
			exit
		fi
		;;
	s)	#s=sector sector 1 is sst01 (3 first L2Fs) and sector 2 is sst02 (2 last L2Fs)
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
file="C:/Users/ssd/Desktop/ConfFiles/L2F_$L2FVersion.mcs"

#Checking if file exist
if [ ! -f "$file" ]; then
	echo $file
	echo "File does not exist"
	exit
else
#Configure RDOs according to sector selected, All RDOs, or single RDO
	
	cd /cygdrive/c/Xilinx/14.5/LabTools/LabTools/bin/nt/
	cat impactBatch_L2F_MCS_INIT.cmd | sed "s/XXXX/$L2FVersion/" > impactBatch_L2F_MCS.cmd

	if $sectorFlag; then
		if [ $SECTOR -eq 1 ]; then
			cat impactBatch_L2F_MCS_1.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_2.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_3.cmd >> impactBatch_L2F_MCS.cmd
		else
			cat impactBatch_L2F_MCS_4.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_5.cmd >> impactBatch_L2F_MCS.cmd
		fi
		cat impactBatch_L2F_MCS_END.cmd >> impactBatchMCS.cmd
		
	#	./impact.exe -batch impactBatch_L2F_MCS.cmd
		echo "L2F's PROMs in sector $SECTOR are configured with Firmware version $L2FVersion"
		exit
	else
		if $boardFlag; then
			cat impactBatch_L2F_MCS_$L2F.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_END.cmd >> impactBatch_L2F_MCS.cmd

	#		./impact.exe -batch impactBatch_L2F_MCS.cmd
			echo "L2F $L2F PROMs are configured with Firmware version $L2FVersion"
			exit
		else
			cat impactBatch_L2F_MCS_1.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_2.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_3.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_4.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_5.cmd >> impactBatch_L2F_MCS.cmd
			cat impactBatch_L2F_MCS_END.cmd >> impactBatch_L2F_MCS.cmd
			
	#		./impact.exe -batch impactBatch_L2F_MCS.cmd
	                echo "All L2F's PROMs are configured with Firmware version $L2FVersion"
			exit
		fi
	fi
fi

