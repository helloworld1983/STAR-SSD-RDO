-- $Id: iodel_ctrl.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : IODELAY calibrayion control engine
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : iodel_ctrl.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: control the IODELAY calibration to the L2F board
--              1. set L2F to transmit know pattern
--              2. Scan through all 64 idelay steps
--              3. compute and set the delay to the center of the eye
--              4. set L2F to loop data back and transmit know pattern from RDO
--              5. scan through all 64 odelay steps
--              6. computr and set the odelay to the cente rof the eye
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

ENTITY iodel_ctrl IS
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
END ENTITY iodel_ctrl;

ARCHITECTURE iodel_ctrl_arch OF iodel_ctrl IS

   CONSTANT SETTLE_CYCLES : INTEGER := 100;
   CONSTANT CHECK_CYCLES  : INTEGER := 100000;

   TYPE state_type IS (START, RX_RESET, RX_WR_TAP, RX_WT_TAP, RX_CHECK_TAP, RX_DONE, RX_WR_IODEL, RX_WT_IODEL, TX_RESET, TX_WR_TAP, TX_WT_TAP, TX_CHECK_TAP, TX_DONE, TX_WR_IODEL, TX_WT_IODEL, TX_SET_COARSE, TX_WT_COARSE, DONE);
   SIGNAL state : state_type := START;

   SIGNAL cnt_rx_tap : SIGNED (7 DOWNTO 0);
   SIGNAL cnt_tx_tap : SIGNED (7 DOWNTO 0);
   SIGNAL cnt_wt     : INTEGER RANGE -2 TO SETTLE_CYCLES;
   SIGNAL cnt_check  : INTEGER RANGE -2 TO CHECK_CYCLES;

BEGIN  -- ARCHITECTURE iodel_ctrl_arch

   rx_iodel_tap <= STD_LOGIC_VECTOR (cnt_rx_tap (5 DOWNTO 0));
   tx_iodel_tap <= STD_LOGIC_VECTOR (cnt_tx_tap (5 DOWNTO 0));

   PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         CASE state IS
            WHEN START =>
               oDONE         <= '0';
               mode          <= "00";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               state <= RX_RESET;
            WHEN RX_RESET =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_rx_tap <= to_signed(96, 8);
               state      <= RX_WR_TAP;
            WHEN RX_WR_TAP =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '1';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_rx_tap <= cnt_rx_tap - 1;
               cnt_wt     <= SETTLE_CYCLES;
               state      <= RX_WT_TAP;
            WHEN RX_WT_TAP =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_check <= CHECK_CYCLES;
               cnt_wt    <= cnt_wt - 1;
               IF cnt_wt < 0 THEN
                  state <= RX_CHECK_TAP;
               END IF;
            WHEN RX_CHECK_TAP =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '1';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_check <= cnt_check - 1;
               IF cnt_check < 0 THEN
                  IF cnt_rx_tap < 0 THEN
                     state <= RX_DONE;
                  ELSE
                     state <= RX_WR_TAP;
                  END IF;
               END IF;
            WHEN RX_DONE =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               state <= RX_WR_IODEL;
            WHEN RX_WR_IODEL =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '1';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_wt <= SETTLE_CYCLES;
               state  <= RX_WT_IODEL;
            WHEN RX_WT_IODEL =>
               oDONE         <= '0';
               mode          <= "01";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '1';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_wt <= cnt_wt - 1;
               IF cnt_wt < 0 THEN
                  state <= TX_RESET;
               END IF;
            WHEN TX_RESET =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_tx_tap <= to_signed(96, 8);
               state      <= TX_WR_TAP;
            WHEN TX_WR_TAP =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '1';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_tx_tap <= cnt_tx_tap - 1;
               cnt_wt     <= SETTLE_CYCLES;
               state      <= TX_WT_TAP;
            WHEN TX_WT_TAP =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_wt    <= cnt_wt - 1;
               cnt_check <= CHECK_CYCLES;
               IF cnt_wt < 0 THEN
                  state <= TX_CHECK_TAP;
               END IF;
            WHEN TX_CHECK_TAP =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '1';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_check <= cnt_check - 1;
               IF cnt_check < 0 THEN
                  IF cnt_tx_tap < 0 THEN
                     state <= TX_DONE;
                  ELSE
                     state <= TX_WR_TAP;
                  END IF;
               END IF;
            WHEN TX_DONE =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               state <= TX_WR_IODEL;
            WHEN TX_WR_IODEL =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '1';
               tx_carse_set  <= '0';

               cnt_wt <= SETTLE_CYCLES;
               state  <= TX_WT_IODEL;
            WHEN TX_WT_IODEL =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_wt <= cnt_wt - 1;
               IF cnt_wt < 0 THEN
                  state <= TX_SET_COARSE;
               END IF;
            WHEN TX_SET_COARSE =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '1';
               tx_carse_set  <= '1';

               cnt_wt <= SETTLE_CYCLES;
               state  <= TX_WT_COARSE;
            WHEN TX_WT_COARSE =>
               oDONE         <= '0';
               mode          <= "10";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               cnt_wt <= cnt_wt - 1;
               IF cnt_wt < 0 THEN
                  state <= DONE;
               END IF;
            WHEN DONE =>
               oDONE         <= '1';
               mode          <= "00";
               rx_iodel_rst  <= '0';
               rx_iodel_eval <= '0';
               rx_iodel_set  <= '0';
               rx_carse_set  <= '0';
               tx_iodel_rst  <= '0';
               tx_iodel_eval <= '0';
               tx_iodel_set  <= '0';
               tx_carse_set  <= '0';

               --state <= START;

            WHEN OTHERS =>
               NULL;
         END CASE;

         IF iRecalibrate = '1' THEN
            state <= START;
         END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE iodel_ctrl_arch;
