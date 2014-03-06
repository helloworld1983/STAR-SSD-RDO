-- $Id: LVDS2Fiber_interface.vhd 138 2013-01-30 21:57:58Z thorsten $
-------------------------------------------------------------------------------
-- Title      : L2F wrapper on Motherboard
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : LVDS2Fiber_interface.vhd
-- Author     : Thorsten Stezelberger
-- Company    : LBNL
-- Created    : 2013-07-17
-- Last update: 2014-02-18
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Interface to the LVDS 2 Fiber interface card
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-07-17  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.SSD_pkg.ALL;
USE WORK.l2f_pkg.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY LVDS2Fiber_interface IS
   PORT (
      iCLK40          : IN  STD_LOGIC;
      iCLK200         : IN  STD_LOGIC;
      iRST            : IN  STD_LOGIC;
      iClkLocked      : IN  STD_LOGIC;
      -- control
      iManual_CalLine : IN  STD_LOGIC;
      oLinkStatus     : OUT FIBER8_STATUS;
      iLinkCtrl       : IN  FIBER8_CTRL;
      oL2Fversion     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      oL2Flocked      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      -- fiber links
      iFiber_RDOtoLC  : IN  FIBER_ARRAY_TYPE;
      oFiber_LCtoRDO  : OUT FIBER_ARRAY_TYPE;
      -- LVDS links
      oL_START        : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
      iL_Marker       : IN  STD_LOGIC_VECTOR (4 DOWNTO 1);
      oL_SENSOR_OUT   : OUT LVDS_OUT_ARRAY_TYPE;
      iL_SENSOR_IN    : IN  LVDS_IN_ARRAY_TYPE;
      oL_RSTB         : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
      iL_LU_digital_1 : IN  STD_LOGIC;  -- L2F done signal
      iL_LU_analog_2  : IN  STD_LOGIC;  -- L2F done signal
      oL_LU_analog_1  : OUT STD_LOGIC;  -- L2F FPGA PROGRAMM_B
      oL_LU_digital_2 : OUT STD_LOGIC;  -- L2F FPGA PROGRAMM_B
      oL_JTAG_TCK     : OUT STD_LOGIC_VECTOR (4 DOWNTO 3);  -- iodel cal mode bit 0
      oL_JTAG_TMS     : OUT STD_LOGIC_VECTOR (4 DOWNTO 3);  -- iodel cal mode bit 1
      -- test connector
      oTC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
END ENTITY LVDS2Fiber_interface;

ARCHITECTURE LVDS2Fiber_interface_arch OF LVDS2Fiber_interface IS

   COMPONENT to_l2f_fpga IS
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
   END COMPONENT;

   COMPONENT L2F_startup_reset
      PORT (
         iCLK40          : IN  STD_LOGIC;
         iRST            : IN  STD_LOGIC;
         -- Manual Call line
         iManual_CalLine : IN  STD_LOGIC;
         -- done lines
         iL2F_done       : IN  STD_LOGIC;
         -- cal line
         oRecalibrate    : OUT STD_LOGIC;
         -- test signals
         TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   -- LVDS
   SIGNAL iLVDS_l2f2rdo_F0 : STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL oLVDS_rdo2l2f_F0 : STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL iLVDS_l2f2rdo_F1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL oLVDS_rdo2l2f_F1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
   -- data
   SIGNAL iD_rdo2l2f_F0    : STD_LOGIC_VECTOR (159 DOWNTO 0);
   SIGNAL oD_l2f2rdo_F0    : STD_LOGIC_VECTOR (159 DOWNTO 0);
   SIGNAL iD_rdo2l2f_F1    : STD_LOGIC_VECTOR (159 DOWNTO 0);
   SIGNAL oD_l2f2rdo_F1    : STD_LOGIC_VECTOR (159 DOWNTO 0);


   SIGNAL sRecalibrate0 : STD_LOGIC;
   SIGNAL sRecalibrate1 : STD_LOGIC;

   SIGNAL mode0 : STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL mode1 : STD_LOGIC_VECTOR (1 DOWNTO 0);

   SIGNAL LVDS_test_cnt : UNSIGNED (31 DOWNTO 0) := (OTHERS => '0');

   SIGNAL sIODELstatus0 : LVDS_32CHAN_STATUS;
   SIGNAL sIODELstatus1 : LVDS_32CHAN_STATUS;

   SIGNAL sRST : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN  -- ARCHITECTURE LVDS2Fiber_interface_arch


   oL_RSTB <= (OTHERS => '0');          -- ??? Marcos does it

   -- remote reconfiguration of L2F FPGAs
   -- hard coded for now
   --iL_LU_digital_1                      -- DONE signal
   --iL_LU_analog_2                       -- DONE signal
   oL_LU_analog_1  <= '0';              -- PROGRAMM_B
   oL_LU_digital_2 <= '0';              -- PROGRAMM_B


   -- purpose: fanout of the reset
   RST_FANOUT : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS RST_FANOUT
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         sRST <= (OTHERS => '1');
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF iRST = '1' THEN
            sRST <= (OTHERS => '1');
         ELSE
            sRST <= (OTHERS => '0');
         END IF;
      END IF;
   END PROCESS RST_FANOUT;


   -- generate the clock going to the L2F card FPGAs
   ODDR_CLK_L3_inst : ODDR
      GENERIC MAP(
         DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',  -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
      PORT MAP (
         Q  => oL_START (3),            -- 1-bit DDR output
         C  => iCLK40,                  -- 1-bit clock input
         CE => '1',                     -- 1-bit clock enable input
         D1 => '1',                     -- 1-bit data input (positive edge)
         D2 => '0',                     -- 1-bit data input (negative edge)
         R  => '0',                     -- 1-bit reset input
         S  => '0'                      -- 1-bit set input
         );
   ODDR_CLK_L4_inst : ODDR
      GENERIC MAP(
         DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',  -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
      PORT MAP (
         Q  => oL_START (4),            -- 1-bit DDR output
         C  => iCLK40,                  -- 1-bit clock input
         CE => '1',                     -- 1-bit clock enable input
         D1 => '1',                     -- 1-bit data input (positive edge)
         D2 => '0',                     -- 1-bit data input (negative edge)
         R  => '0',                     -- 1-bit reset input
         S  => '0'                      -- 1-bit set input
         );

   -- in top level already
--   IDELAYCTRL_inst : IDELAYCTRL
--      PORT MAP (
--         RDY    => OPEN,     -- 1-bit output indicates validity of the REFCLK
--         REFCLK => iCLK200,             -- 1-bit reference clock input
--         RST    => '0'                  -- 1-bit reset input
--         );


   ----------------------------------------------------------------------------

   to_l2f_fpga_0_inst : to_l2f_fpga
      PORT MAP (
         iCLK40        => iCLK40,
         iCLK200       => iCLK200,
         iRST          => sRST(0),
         -- status
         iRecalibrate  => sRecalibrate0,
         oDONE         => OPEN,
         oIODELstatus  => sIODELstatus0,
         --
         mode          => mode0,
         -- LVDS
         iLVDS_l2f2rdo => iLVDS_l2f2rdo_F0,
         oLVDS_rdo2l2f => oLVDS_rdo2l2f_F0,
         -- data
         iD_rdo2l2f    => iD_rdo2l2f_F0,
         oD_l2f2rdo    => oD_l2f2rdo_F0,
         -- test conector
         oTC           => OPEN
         );

   -- parallel data map
   iD_rdo2l2f_F0 (23 DOWNTO 0)    <= iFiber_RDOtoLC (0);
   iD_rdo2l2f_F0 (47 DOWNTO 24)   <= iFiber_RDOtoLC (1);
   iD_rdo2l2f_F0 (103 DOWNTO 80)  <= iFiber_RDOtoLC (2);
   iD_rdo2l2f_F0 (127 DOWNTO 104) <= iFiber_RDOtoLC (3);

   iD_rdo2l2f_F0 (79 DOWNTO 56)   <= STD_LOGIC_VECTOR (LVDS_test_cnt (23 DOWNTO 0));  --(OTHERS => '0');
   iD_rdo2l2f_F0 (159 DOWNTO 136) <= STD_LOGIC_VECTOR (LVDS_test_cnt (23 DOWNTO 0));  --(OTHERS => '0');

   oFiber_LCtoRDO (0) <= oD_l2f2rdo_F0 (23 DOWNTO 0);
   oFiber_LCtoRDO (1) <= oD_l2f2rdo_F0 (47 DOWNTO 24);
   oFiber_LCtoRDO (2) <= oD_l2f2rdo_F0 (103 DOWNTO 80);
   oFiber_LCtoRDO (3) <= oD_l2f2rdo_F0 (127 DOWNTO 104);

   -- L3 from l2f
   GENERATE_SENSOR_I3 : FOR s IN 1 TO 8 GENERATE
      iLVDS_l2f2rdo_F0 (0*16 + (s-1)*2)     <= iL_SENSOR_IN (3, s, 1);
      iLVDS_l2f2rdo_F0 (0*16 + (s-1)*2 + 1) <= iL_SENSOR_IN (3, s, 2);
   END GENERATE GENERATE_SENSOR_I3;
   -- L1 from l2f
   GENERATE_SENSOR_I1 : FOR s IN 1 TO 8 GENERATE
      iLVDS_l2f2rdo_F0 (1*16 + (s-1)*2)     <= iL_SENSOR_IN (1, s, 1);
      iLVDS_l2f2rdo_F0 (1*16 + (s-1)*2 + 1) <= iL_SENSOR_IN (1, s, 2);
   END GENERATE GENERATE_SENSOR_I1;

   -- L3 to l2f
   GENERATE_SENSOR_O3 : FOR s IN 3 TO 10 GENERATE
      oL_SENSOR_OUT (3, s, 3) <= oLVDS_rdo2l2f_F0 (0*16 + (s-3)*2);
      oL_SENSOR_OUT (3, s, 4) <= oLVDS_rdo2l2f_F0 (0*16 + (s-3)*2 + 1);
   END GENERATE GENERATE_SENSOR_O3;
   -- L1 to l2f
   GENERATE_SENSOR_O1 : FOR s IN 3 TO 10 GENERATE
      oL_SENSOR_OUT (1, s, 3) <= oLVDS_rdo2l2f_F0 (1*16 + (s-3)*2);
      oL_SENSOR_OUT (1, s, 4) <= oLVDS_rdo2l2f_F0 (1*16 + (s-3)*2 + 1);
   END GENERATE GENERATE_SENSOR_O1;

   PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         oL_JTAG_TCK (3) <= mode0 (0);
         oL_JTAG_TMS (3) <= mode0 (1);
      END IF;
   END PROCESS;

   to_l2f_fpga_1_inst : to_l2f_fpga
      PORT MAP (
         iCLK40        => iCLK40,
         iCLK200       => iCLK200,
         iRST          => sRST(1),
         -- status
         iRecalibrate  => sRecalibrate1,
         oDONE         => OPEN,
         oIODELstatus  => sIODELstatus1,
         --
         mode          => mode1,
         -- LVDS
         iLVDS_l2f2rdo => iLVDS_l2f2rdo_F1,
         oLVDS_rdo2l2f => oLVDS_rdo2l2f_F1,
         -- data
         iD_rdo2l2f    => iD_rdo2l2f_F1,
         oD_l2f2rdo    => oD_l2f2rdo_F1,
         -- test conector
         oTC           => OPEN
         );

   -- parallel data map
   iD_rdo2l2f_F1 (23 DOWNTO 0)    <= iFiber_RDOtoLC (4);
   iD_rdo2l2f_F1 (47 DOWNTO 24)   <= iFiber_RDOtoLC (5);
   iD_rdo2l2f_F1 (103 DOWNTO 80)  <= iFiber_RDOtoLC (6);
   iD_rdo2l2f_F1 (127 DOWNTO 104) <= iFiber_RDOtoLC (7);

   iD_rdo2l2f_F1 (79 DOWNTO 56)   <= STD_LOGIC_VECTOR (LVDS_test_cnt (23 DOWNTO 0));  --(OTHERS => '0');
   iD_rdo2l2f_F1 (159 DOWNTO 136) <= STD_LOGIC_VECTOR (LVDS_test_cnt (23 DOWNTO 0));  --(OTHERS => '0');

   oFiber_LCtoRDO (4) <= oD_l2f2rdo_F1 (23 DOWNTO 0);
   oFiber_LCtoRDO (5) <= oD_l2f2rdo_F1 (47 DOWNTO 24);
   oFiber_LCtoRDO (6) <= oD_l2f2rdo_F1 (103 DOWNTO 80);
   oFiber_LCtoRDO (7) <= oD_l2f2rdo_F1 (127 DOWNTO 104);


   -- L4 from l2f
   GENERATE_SENSOR_I4 : FOR s IN 1 TO 8 GENERATE
      iLVDS_l2f2rdo_F1 (0*16 + (s-1)*2)     <= iL_SENSOR_IN (4, s, 1);
      iLVDS_l2f2rdo_F1 (0*16 + (s-1)*2 + 1) <= iL_SENSOR_IN (4, s, 2);
   END GENERATE GENERATE_SENSOR_I4;
   -- L2 from l2f
   GENERATE_SENSOR_I2 : FOR s IN 1 TO 8 GENERATE
      iLVDS_l2f2rdo_F1 (1*16 + (s-1)*2)     <= iL_SENSOR_IN (2, s, 1);
      iLVDS_l2f2rdo_F1 (1*16 + (s-1)*2 + 1) <= iL_SENSOR_IN (2, s, 2);
   END GENERATE GENERATE_SENSOR_I2;

   -- L4 to L2F
   GENERATE_SENSOR_O4 : FOR s IN 3 TO 10 GENERATE
      oL_SENSOR_OUT (4, s, 3) <= oLVDS_rdo2l2f_F1 (0*16 + (s-3)*2);
      oL_SENSOR_OUT (4, s, 4) <= oLVDS_rdo2l2f_F1 (0*16 + (s-3)*2 + 1);
   END GENERATE GENERATE_SENSOR_O4;
   -- L2 to L2F
   GENERATE_SENSOR_O2 : FOR s IN 3 TO 10 GENERATE
      oL_SENSOR_OUT (2, s, 3) <= oLVDS_rdo2l2f_F1 (1*16 + (s-3)*2);
      oL_SENSOR_OUT (2, s, 4) <= oLVDS_rdo2l2f_F1 (1*16 + (s-3)*2 + 1);
   END GENERATE GENERATE_SENSOR_O2;

   PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         oL_JTAG_TCK (4) <= mode1 (0);
         oL_JTAG_TMS (4) <= mode1 (1);
      END IF;
   END PROCESS;

   ----------------------------------------------------------------------------

   LVDS_cnt : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS LVDS_cnt
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         LVDS_test_cnt <= LVDS_test_cnt + 1;
      END IF;
   END PROCESS LVDS_cnt;

   ----------------------------------------------------------------------------

   L2F_startup_reset_0_inst : L2F_startup_reset
      PORT MAP (
         iCLK40          => iCLK40,
         iRST            => sRST(2),
         iManual_CalLine => iManual_CalLine,
                                              -- done lines
         iL2F_done       => iL_LU_digital_1,  -- DONE signal
                                              -- cal line
         oRecalibrate    => sRecalibrate0,
                                              -- test signals
         TC              => OPEN
         );

   L2F_startup_reset_1_inst : L2F_startup_reset
      PORT MAP (
         iCLK40          => iCLK40,
         iRST            => sRST(3),
         iManual_CalLine => iManual_CalLine,
                                             -- done lines
         iL2F_done       => iL_LU_analog_2,  -- DONE signal
                                             -- cal line
         oRecalibrate    => sRecalibrate1,
                                             -- test signals
         TC              => OPEN
         );

   oL2Flocked <= (OTHERS => '0');       -- leftover from marcos



   oL_START (1) <= '0';
   oL_START (2) <= '0';



   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- Keep for future
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------

   -- map status and control signals
   oLinkStatus(0).F_PLUGGED  <= oD_l2f2rdo_F0 (48);
   oLinkStatus(0).F_TX_FAULT <= oD_l2f2rdo_F0 (49);
   oLinkStatus(0).F_RX_LOSS  <= oD_l2f2rdo_F0 (50);
   oLinkStatus(0).RX_LOCK    <= oD_l2f2rdo_F0 (51);

   oLinkStatus(1).F_PLUGGED  <= oD_l2f2rdo_F0 (52);
   oLinkStatus(1).F_TX_FAULT <= oD_l2f2rdo_F0 (53);
   oLinkStatus(1).F_RX_LOSS  <= oD_l2f2rdo_F0 (54);
   oLinkStatus(1).RX_LOCK    <= oD_l2f2rdo_F0 (55);

   oLinkStatus(2).F_PLUGGED  <= oD_l2f2rdo_F0 (128);
   oLinkStatus(2).F_TX_FAULT <= oD_l2f2rdo_F0 (129);
   oLinkStatus(2).F_RX_LOSS  <= oD_l2f2rdo_F0 (130);
   oLinkStatus(2).RX_LOCK    <= oD_l2f2rdo_F0 (131);

   oLinkStatus(3).F_PLUGGED  <= oD_l2f2rdo_F0 (132);
   oLinkStatus(3).F_TX_FAULT <= oD_l2f2rdo_F0 (133);
   oLinkStatus(3).F_RX_LOSS  <= oD_l2f2rdo_F0 (134);
   oLinkStatus(3).RX_LOCK    <= oD_l2f2rdo_F0 (135);

   oLinkStatus(4).F_PLUGGED  <= oD_l2f2rdo_F1 (48);
   oLinkStatus(4).F_TX_FAULT <= oD_l2f2rdo_F1 (49);
   oLinkStatus(4).F_RX_LOSS  <= oD_l2f2rdo_F1 (50);
   oLinkStatus(4).RX_LOCK    <= oD_l2f2rdo_F1 (51);

   oLinkStatus(5).F_PLUGGED  <= oD_l2f2rdo_F1 (52);
   oLinkStatus(5).F_TX_FAULT <= oD_l2f2rdo_F1 (53);
   oLinkStatus(5).F_RX_LOSS  <= oD_l2f2rdo_F1 (54);
   oLinkStatus(5).RX_LOCK    <= oD_l2f2rdo_F1 (55);

   oLinkStatus(6).F_PLUGGED  <= oD_l2f2rdo_F1 (128);
   oLinkStatus(6).F_TX_FAULT <= oD_l2f2rdo_F1 (129);
   oLinkStatus(6).F_RX_LOSS  <= oD_l2f2rdo_F1 (130);
   oLinkStatus(6).RX_LOCK    <= oD_l2f2rdo_F1 (131);

   oLinkStatus(7).F_PLUGGED  <= oD_l2f2rdo_F1 (132);
   oLinkStatus(7).F_TX_FAULT <= oD_l2f2rdo_F1 (133);
   oLinkStatus(7).F_RX_LOSS  <= oD_l2f2rdo_F1 (134);
   oLinkStatus(7).RX_LOCK    <= oD_l2f2rdo_F1 (135);

   -- L2F FPGA versions
   oL2Fversion (3 DOWNTO 0) <= (OTHERS => '0');
   oL2Fversion (7 DOWNTO 4) <= (OTHERS => '0');


   -- LEDs
   iD_rdo2l2f_F0 (51 DOWNTO 48)   <= iLinkCtrl(0).LEDs;
   iD_rdo2l2f_F0 (55 DOWNTO 52)   <= iLinkCtrl(1).LEDs;
   iD_rdo2l2f_F0 (131 DOWNTO 128) <= iLinkCtrl(2).LEDs;
   iD_rdo2l2f_F0 (135 DOWNTO 132) <= iLinkCtrl(3).LEDs;

   iD_rdo2l2f_F0 (51 DOWNTO 48)   <= iLinkCtrl(4).LEDs;
   iD_rdo2l2f_F0 (55 DOWNTO 52)   <= iLinkCtrl(5).LEDs;
   iD_rdo2l2f_F0 (131 DOWNTO 128) <= iLinkCtrl(6).LEDs;
   iD_rdo2l2f_F0 (135 DOWNTO 132) <= iLinkCtrl(7).LEDs;

END ARCHITECTURE LVDS2Fiber_interface_arch;