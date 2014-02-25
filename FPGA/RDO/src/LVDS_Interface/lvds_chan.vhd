-- $Id: lvds_chan.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : One TX and RX LVDS link
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : lvds_chan.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Combines one serializer and one deserializer to one channel
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-01-08  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.l2f_pkg.ALL;

ENTITY lvds_chan IS
   PORT (
      iCLK40         : IN  STD_LOGIC;
      iCLK200        : IN  STD_LOGIC;
      iRST           : IN  STD_LOGIC;
      -- status
      ser_status     : OUT LVDS_STATUS;
      des_status     : OUT LVDS_STATUS;
      -- control ser
      iodel_cal_ctrl : IN  LVDS_IODEL_CTRL_TYPE;
      -- LVDS
      iLVDS_l2f2rdo  : IN  STD_LOGIC;
      oLVDS_rdo2l2f  : OUT STD_LOGIC;
      -- data
      iD_rdo2l2f     : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
      oD_l2f2rdo     : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      -- test connector
      oTC            : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
END ENTITY lvds_chan;

ARCHITECTURE lvds_chan_arch OF lvds_chan IS

   COMPONENT ser5to1
      PORT (
         iCLK40        : IN  STD_LOGIC;
         iCLK200       : IN  STD_LOGIC;
         iRST          : IN  STD_LOGIC;
         -- status
         ser_status    : OUT LVDS_STATUS;
         -- control
         mode          : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
         tx_iodel_rst  : IN  STD_LOGIC;
         tx_iodel_tap  : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
         tx_iodel_eval : IN  STD_LOGIC;
         tx_iodel_set  : IN  STD_LOGIC;
         tx_carse_set  : IN  STD_LOGIC;
         -- from RX
         change_flag   : IN  STD_LOGIC;
         rx_d          : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
         -- data
         iD_rdo2l2f    : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
         -- LVDS
         oLVDS_rdo2l2f : OUT STD_LOGIC;
         -- test connector
         oTC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT des1to5
      PORT (
         iCLK40        : IN  STD_LOGIC;
         iCLK200       : IN  STD_LOGIC;
         iRST          : IN  STD_LOGIC;
         -- status
         des_status    : OUT LVDS_STATUS;
         -- control
         rx_iodel_rst  : IN  STD_LOGIC;
         rx_iodel_tap  : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
         rx_iodel_eval : IN  STD_LOGIC;
         rx_iodel_set  : IN  STD_LOGIC;
         rx_carse_set  : IN  STD_LOGIC;
         -- to TX
         o_change_flag : OUT STD_LOGIC;
         o_rx_d        : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
         -- LVDS in
         iLVDS_l2f2rdo : IN  STD_LOGIC;
         -- data out
         oD_l2f2rdo    : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
         -- test connector
         oTC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   -- signals between serializer and deserializer
   SIGNAL change_flag : STD_LOGIC;
   SIGNAL rx_d        : STD_LOGIC_VECTOR (4 DOWNTO 0);

BEGIN  -- ARCHITECTURE lvds_chan_arch

   ser5to1_inst : ser5to1
      PORT MAP (
         iCLK40        => iCLK40,
         iCLK200       => iCLK200,
         iRST          => iRST,
         -- status
         ser_status    => ser_status,
         -- control
         mode          => iodel_cal_ctrl.mode,
         tx_iodel_rst  => iodel_cal_ctrl.tx_iodel_rst,
         tx_iodel_tap  => iodel_cal_ctrl.tx_iodel_tap,
         tx_iodel_eval => iodel_cal_ctrl.tx_iodel_eval,
         tx_iodel_set  => iodel_cal_ctrl.tx_iodel_set,
         tx_carse_set  => iodel_cal_ctrl.tx_carse_set,
         -- from RX
         change_flag   => change_flag,
         rx_d          => rx_d,
         -- data
         iD_rdo2l2f    => iD_rdo2l2f,
         -- LVDS
         oLVDS_rdo2l2f => oLVDS_rdo2l2f,
         -- test connector
         oTC           => OPEN
         );

   des1to5_inst : des1to5
      PORT MAP (
         iCLK40        => iCLK40,
         iCLK200       => iCLK200,
         iRST          => iRST,
         -- status
         des_status    => des_status,
         -- control
         rx_iodel_rst  => iodel_cal_ctrl.rx_iodel_rst,
         rx_iodel_tap  => iodel_cal_ctrl.rx_iodel_tap,
         rx_iodel_eval => iodel_cal_ctrl.rx_iodel_eval,
         rx_iodel_set  => iodel_cal_ctrl.rx_iodel_set,
         rx_carse_set  => iodel_cal_ctrl.rx_carse_set,
         -- to TX
         o_change_flag => change_flag,
         o_rx_d        => rx_d,
         -- LVDS in
         iLVDS_l2f2rdo => iLVDS_l2f2rdo,
         -- data out
         oD_l2f2rdo    => oD_l2f2rdo,
         -- test connector
         oTC           => OPEN
         );


   oTC <= (OTHERS => '0');

END ARCHITECTURE lvds_chan_arch;
