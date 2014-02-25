-- $Id: l2f_pkg.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : LVDS interface package
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : l2f_pkg.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: datatypes for the RDO-L2F LVDS link
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-01-08  1.0      thorsten        Created
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE l2f_pkg IS

   -- record for the LVDS self adjust status
   TYPE LVDS_STATUS IS RECORD
      edge_g2b   : STD_LOGIC_VECTOR (5 DOWNTO 0);
      edge_b2g   : STD_LOGIC_VECTOR (5 DOWNTO 0);
      tap_sel    : STD_LOGIC_VECTOR (5 DOWNTO 0);
      coarse_sel : STD_LOGIC_VECTOR (2 DOWNTO 0);
   END RECORD LVDS_STATUS;

   TYPE LVDS_CHAN_STATUS IS RECORD
      ser_status : LVDS_STATUS;
      des_status : LVDS_STATUS;
   END RECORD LVDS_CHAN_STATUS;

   TYPE LVDS_32CHAN_STATUS IS ARRAY (0 TO 31) OF LVDS_CHAN_STATUS;

   -- control signal for the auto adjustment
   TYPE LVDS_IODEL_CTRL_TYPE IS RECORD
      -- control ser
      mode          : STD_LOGIC_VECTOR (1 DOWNTO 0);
      tx_iodel_rst  : STD_LOGIC;
      tx_iodel_tap  : STD_LOGIC_VECTOR (5 DOWNTO 0);
      tx_iodel_eval : STD_LOGIC;
      tx_iodel_set  : STD_LOGIC;
      tx_carse_set  : STD_LOGIC;
      -- control des
      rx_iodel_rst  : STD_LOGIC;
      rx_iodel_tap  : STD_LOGIC_VECTOR (5 DOWNTO 0);
      rx_iodel_eval : STD_LOGIC;
      rx_iodel_set  : STD_LOGIC;
      rx_carse_set  : STD_LOGIC;
   END RECORD LVDS_IODEL_CTRL_TYPE;

END PACKAGE l2f_pkg;


PACKAGE BODY l2f_pkg IS

END PACKAGE BODY l2f_pkg;
