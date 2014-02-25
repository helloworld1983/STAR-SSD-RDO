-- $Id: to_l2f_fpga.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : LVDS links to one L2F FPGA
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : to_l2f_fpga.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: combines 1 iodel_ctrl and 32 lvds_chan to form th einterface to
--              one L2F FPGA
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-01-08  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

USE WORK.l2f_pkg.ALL;

ENTITY to_l2f_fpga IS
   PORT (
      iCLK40        : IN  STD_LOGIC;
      iCLK200       : IN  STD_LOGIC;
      iRST          : IN  STD_LOGIC;
      -- status
      iRecalibrate  : IN  STD_LOGIC;
      oDONE         : OUT STD_LOGIC;
      oIODELstatus  : OUT LVDS_32CHAN_STATUS;
      --
      mode          : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      -- LVDS
      iLVDS_l2f2rdo : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
      oLVDS_rdo2l2f : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      -- data
      iD_rdo2l2f    : IN  STD_LOGIC_VECTOR (159 DOWNTO 0);
      oD_l2f2rdo    : OUT STD_LOGIC_VECTOR (159 DOWNTO 0);
      -- test conector
      oTC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
END ENTITY to_l2f_fpga;


ARCHITECTURE to_l2f_fpga_arch OF to_l2f_fpga IS

   COMPONENT iodel_ctrl
      PORT (
         iCLK40        : IN  STD_LOGIC;
         iCLK200       : IN  STD_LOGIC;
         iRST          : IN  STD_LOGIC;
         -- status
         iRecalibrate  : IN  STD_LOGIC;
         oDONE         : OUT STD_LOGIC;
         --
         mode          : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         -- RX
         rx_iodel_rst  : OUT STD_LOGIC;
         rx_iodel_tap  : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
         rx_iodel_eval : OUT STD_LOGIC;
         rx_iodel_set  : OUT STD_LOGIC;
         rx_carse_set  : OUT STD_LOGIC;
         -- TX
         tx_iodel_rst  : OUT STD_LOGIC;
         tx_iodel_tap  : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
         tx_iodel_eval : OUT STD_LOGIC;
         tx_iodel_set  : OUT STD_LOGIC;
         tx_carse_set  : OUT STD_LOGIC;
         -- test conector
         oTC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT lvds_chan
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
   END COMPONENT;

   SIGNAL iodel_cal_ctrl : LVDS_IODEL_CTRL_TYPE;

BEGIN  -- ARCHITECTURE to_l2f_fpga_arch

   mode_ff : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS mode_ff
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         mode <= "00";
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         mode <= iodel_cal_ctrl.mode;
      END IF;
   END PROCESS mode_ff;

   iodel_ctrl_inst : iodel_ctrl
      PORT MAP (
         iCLK40        => iCLK40,
         iCLK200       => iCLK200,
         iRST          => iRST,
         -- status
         iRecalibrate  => iRecalibrate,
         oDONE         => oDONE,
         --
         mode          => iodel_cal_ctrl.mode,
         -- RX
         rx_iodel_rst  => iodel_cal_ctrl.rx_iodel_rst,
         rx_iodel_tap  => iodel_cal_ctrl.rx_iodel_tap,
         rx_iodel_eval => iodel_cal_ctrl.rx_iodel_eval,
         rx_iodel_set  => iodel_cal_ctrl.rx_iodel_set,
         rx_carse_set  => iodel_cal_ctrl.rx_carse_set,
         -- TX
         tx_iodel_rst  => iodel_cal_ctrl.tx_iodel_rst,
         tx_iodel_tap  => iodel_cal_ctrl.tx_iodel_tap,
         tx_iodel_eval => iodel_cal_ctrl.tx_iodel_eval,
         tx_iodel_set  => iodel_cal_ctrl.tx_iodel_set,
         tx_carse_set  => iodel_cal_ctrl.tx_carse_set,
         -- test conector
         oTC           => OPEN
         );

   LVDS_CHANNELS_GENERATE : FOR i IN 0 TO 31 GENERATE
      lvds_chan_inst : lvds_chan
         PORT MAP (
            iCLK40         => iCLK40,
            iCLK200        => iCLK200,
            iRST           => iRST,
            -- status
            ser_status     => oIODELstatus(i).ser_status,
            des_status     => oIODELstatus(i).des_status,
            -- control ser
            iodel_cal_ctrl => iodel_cal_ctrl,
            -- LVDS
            iLVDS_l2f2rdo  => iLVDS_l2f2rdo (i),
            oLVDS_rdo2l2f  => oLVDS_rdo2l2f (i),
            -- data
            iD_rdo2l2f     => iD_rdo2l2f (((i*5)+4) DOWNTO (i*5)),
            oD_l2f2rdo     => oD_l2f2rdo (((i*5)+4) DOWNTO (i*5)),
            -- test connector
            oTC            => OPEN
            );
   END GENERATE LVDS_CHANNELS_GENERATE;

END ARCHITECTURE to_l2f_fpga_arch;
