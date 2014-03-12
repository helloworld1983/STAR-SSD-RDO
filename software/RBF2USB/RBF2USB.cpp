// Written by: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
// Feb 18 2014
// Transforms RBF configuration files into a txt file to be send over the USB comunication tool
#include <iostream>
#include <string>
#include <stdio.h>
#include <fstream>
#include <cstring>
using namespace std;

ofstream USB;
ifstream RBF;

string RBFname;
string USBName;
int ext;
unsigned int RBF_byte1;
unsigned int RBF_byte2;
string header;

int main(int argc, char** argv)
{
	
	RBFname = argv[1];	
	ext = (RBFname.length() - 4 );
	USBName = RBFname;
	USBName.replace(ext, 4, "_USB.txt");									

	USB.open(USBName);

  
  RBF.open(argv[1], std::ios_base::binary); // open a file
  if (!RBF.good()) 
    return 1; // exit if file not found

 //printing the header
	USB << "0x08050000 LC JTAG reset" << endl;
	USB << "0x08000000 Config state machine to idle - out of abort" << endl;
	USB << "0x08000000 Config state machine to idle - out of abort" << endl;
	USB << "0x08000001 Config state machine reset sequence" << endl;
	USB << "0x08000002 Config state machine ready for data" << endl;
 
	
	// read each line of the file
  while (!RBF.eof())
  {
   		// read two characters
		RBF_byte1 = RBF.get();
		RBF_byte2 = RBF.get();
		
		if (RBF_byte1 == -1) 
			RBF_byte1 = 0;
		if (RBF_byte2 == -1)
			RBF_byte2 = 0;
				
			header = "0x0801"; //just the fiber0 address  

		
		if (USB.is_open() )
		{
			
			if ((RBF_byte1 < 16) & (RBF_byte2 < 16))
			USB << hex << header << "0" << RBF_byte2 << hex << "0" << RBF_byte1 << endl;
			else
			if (RBF_byte1 < 16)
			USB << hex << header << RBF_byte2 << hex << "0" << RBF_byte1 << endl;
			else
			if (RBF_byte2 < 16)
			USB << hex << header << "0" << RBF_byte2 << hex << RBF_byte1 << endl;
			else
			USB << hex << header << RBF_byte2 << hex <<RBF_byte1 << endl;

		}
	}
	USB << "0x08000003 Config command to unknown state" << endl;
	USB << "0x08050001 LC JTAG RST line high - JTAG out of reset" << endl;  //added an end of line on Feb 18
	USB.close();
}

