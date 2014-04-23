-- $Id: SSD_pkg.vhd 110 2012-10-16 17:57:48Z thorsten $
-------------------------------------------------------------------------------
-- Title      : SSD Package
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : SSD_pkg.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 2013-07-18
-- Last update: 2014-02-07
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Several utility functions
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-07-18  1.0      thorsten        Created
-- 2013-09-01  1.1      Luis            Added types to accomodate the Fiber signals in bundles 
-- 2013-09-17  1.2      Luis            inplemented quick Hack by Thorsten, Look for "T_Sep17" as comment
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE SSD_pkg IS
   -- array for the 24 data lines of the (de)serializers
   TYPE FIBER_ARRAY_TYPE IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (23 DOWNTO 0);

   -- array for the LVDS lines out of the RDO (SSD mod)
   TYPE LVDS_OUT_ARRAY_TYPE IS ARRAY (1 TO 4,  -- 4 ladders
                                      3 TO 10,               -- 8 sectors
                                      3 TO 4) OF STD_LOGIC;  -- 2 data lines
   -- array for the LVDS lines into the RDO (SSD)
   TYPE LVDS_IN_ARRAY_TYPE IS ARRAY (1 TO 4,   -- 4 ladders
                                     1 TO 12,  --8,             -- 12  -- original 8 sectors  ------------------------------------> T_Sep17
                                     1 TO 2) OF STD_LOGIC;   -- 2 data lines

   -- array for the 7 lc signals with 35 bit long
   TYPE FIBER_ARRAY_TYPE_36 IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (35 DOWNTO 0);  -- 7 LC

   -- array for the 7 lc signals with 16 bit long
   TYPE FIBER_ARRAY_TYPE_16 IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 7 LC

   -- array for the 7 lc signals with 1 bit long
   TYPE FIBER_ARRAY_TYPE_16_8 IS ARRAY (0 TO 7) OF FIBER_ARRAY_TYPE_16;  -- 7 LC , 7 status reg of 36 bit wide

   -- array for the 16 hybrids adc signals with 10 bit long
   TYPE HYBRIDS_ARRAY_TYPE IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (9 DOWNTO 0);  -- 16 hybrids with 10 bit ADC values

   -- array for the 16 hybrids adc signals with 10 bit long
   TYPE HYBRIDS_ARRAY_TYPE_EXT IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (9 DOWNTO 0);  -- 16 hybrids with 10 bit ADC values

   -- array for the 16 hybrids adc signals with 10 bit long
   TYPE TRIGGER_MODE_ARRAY_TYPE IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (1 DOWNTO 0);

   TYPE PAYLOAD_MEM_RADDR_ARRAY_TYPE IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (14 DOWNTO 0);

   TYPE PAYLOAD_MEM_OUT_ARRAY_TYPE IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (35 DOWNTO 0);


   -- data type for one fiber channel status information
   TYPE FIBER_STATUS IS
   RECORD
      F_PLUGGED  : STD_LOGIC;
      F_TX_FAULT : STD_LOGIC;
      F_RX_LOSS  : STD_LOGIC;
      RX_LOCK    : STD_LOGIC;
   END RECORD FIBER_STATUS;

   TYPE FIBER8_STATUS IS ARRAY (0 TO 7) OF FIBER_STATUS;

   -- data type for one fiber channel configuration information
   TYPE FIBER_CTRL IS
   RECORD
      LEDs : STD_LOGIC_VECTOR (3 DOWNTO 0);
   END RECORD FIBER_CTRL;

   TYPE FIBER8_CTRL IS ARRAY (0 TO 7) OF FIBER_CTRL;


   -- Pedestal Memory write
   TYPE PED_MEM_WRITE IS
   RECORD
      CLK  : STD_LOGIC;                      -- memory write clock
      DATA : STD_LOGIC_VECTOR (9 DOWNTO 0);
      ADDR : STD_LOGIC_VECTOR (13 DOWNTO 0);
      WE   : STD_LOGIC_VECTOR (7 DOWNTO 0);  -- one bit per channel
   END RECORD PED_MEM_WRITE;

END PACKAGE SSD_pkg;

PACKAGE BODY SSD_pkg IS

END PACKAGE BODY SSD_pkg;
