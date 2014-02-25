-- $Id: L2F_startup_reset.vhd 138 2013-01-30 21:57:58Z thorsten $
-------------------------------------------------------------------------------
-- Title      : L2F startup reset on Motherboard
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : LVDS2Fiber_interface.vhd
-- Author     : Thorsten Stezelberger
-- Company    : LBNL
-- Created    : 2013-12-05
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: generate a do calibration for the LVDS2Fier interface code
--              The calibration signal initialtes a timing selfcalibration
--              whenever both of the FPGAs on the L2F card are initialized
--              (done signal is high)
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-12-05  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY L2F_startup_reset IS
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
END ENTITY L2F_startup_reset;

ARCHITECTURE L2F_startup_reset_arch OF L2F_startup_reset IS

   SIGNAL sL2F_done          : STD_LOGIC;
   SIGNAL sL2F_done_sync     : STD_LOGIC;
   SIGNAL sL2F_done_deglitch : STD_LOGIC;

   SIGNAL cnt_startup         : SIGNED (15 DOWNTO 0);
   SIGNAL cnt_deglitch_done   : SIGNED (15 DOWNTO 0);
   -- marcos needs 250us
   CONSTANT CNT_STARTUP_RESET : SIGNED (15 DOWNTO 0) := x"7FFF";
   CONSTANT CNT_DONE_DEGLITCH : SIGNED (15 DOWNTO 0) := x"7FFF";

BEGIN  -- ARCHITECTURE L2F_startup_reset_arch


   sync_done : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS sync_done
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         sL2F_done      <= '0';
         sL2F_done_sync <= '0';
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         sL2F_done      <= iL2F_done;
         sL2F_done_sync <= sL2F_done;
      END IF;
   END PROCESS sync_done;

   done_deglitch : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS done_deglitch
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         cnt_deglitch_done  <= CNT_DONE_DEGLITCH;
         sL2F_done_deglitch <= '0';
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF sL2F_done_sync = '1' THEN
            -- L2F is loaded, we can use it
            cnt_deglitch_done  <= CNT_DONE_DEGLITCH;
            sL2F_done_deglitch <= '1';
         ELSIF sL2F_done_sync = '0' AND cnt_deglitch_done < 0 THEN
            -- we lost L2F done for a long time
            -- it is time to have the link resynced
            sL2F_done_deglitch <= '0';
         ELSE
            -- L2F DONE is low; lets count how long
            cnt_deglitch_done <= cnt_deglitch_done - 1;
         END IF;
      END IF;
   END PROCESS done_deglitch;

   startup_cnt : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS startup_cnt

      IF iRST = '1' THEN                -- asynchronous reset (active high)
         cnt_startup  <= CNT_STARTUP_RESET;
         oRecalibrate <= '1';
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF (iManual_CalLine = '1') OR (sL2F_done_deglitch = '0') THEN
            -- reset when the L2F FPGA are not configured
            cnt_startup  <= CNT_STARTUP_RESET;
            oRecalibrate <= '1';
         ELSIF cnt_startup >= 0 THEN
            cnt_startup  <= cnt_startup - 1;
            oRecalibrate <= '1';
         ELSE
            cnt_startup  <= cnt_startup;
            oRecalibrate <= '0';
         END IF;
      END IF;
   END PROCESS startup_cnt;

   TC <= (OTHERS => '0');

END ARCHITECTURE L2F_startup_reset_arch;
