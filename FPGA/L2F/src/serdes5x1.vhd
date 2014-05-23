-- $Id: serdes5x1.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : L2F board ; serializer/deserializer for 1 LVDS link
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : serdes5x1.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Spartan 6
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 5 to 1 serializer and deserializer for one LVDS link to RDO
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-01-08  1.0      thorsten        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY serdes5x1 IS
   PORT (
      iCLK40        : IN  STD_LOGIC;
      iCLK200       : IN  STD_LOGIC;
      iRST          : IN  STD_LOGIC;
      -- setup
      mode          : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
      -- internal bus
      iD_l2f2rdo    : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
      oD_rdo2l2f    : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      -- LVDS
      iLVDS_rdo2l2f : IN  STD_LOGIC;
      oLVDS_l2f2rdo : OUT STD_LOGIC;
      -- test connector
      oTC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
END ENTITY serdes5x1;

ARCHITECTURE serdes5x1_arch OF serdes5x1 IS

   SIGNAL srg_in  : STD_LOGIC_VECTOR (4 DOWNTO 0);
   SIGNAL srg_out : STD_LOGIC_VECTOR (4 DOWNTO 0);

   SIGNAL data_out : STD_LOGIC_VECTOR (4 DOWNTO 0);
   SIGNAL data_in  : STD_LOGIC_VECTOR (4 DOWNTO 0);

   SIGNAL tx_data_out_sync     : STD_LOGIC := '0';
   SIGNAL tx_data_out_sync_old : STD_LOGIC := '0';

   SIGNAL sLVDS_rdo2l2f : STD_LOGIC;
   SIGNAL sLVDS_l2f2rdo : STD_LOGIC;

   ATTRIBUTE IOB                  : STRING;
   ATTRIBUTE IOB OF oLVDS_l2f2rdo : SIGNAL IS "true";
   ATTRIBUTE IOB OF sLVDS_rdo2l2f : SIGNAL IS "true";

BEGIN  -- ARCHITECTURE serdes5x1_arch

   oTC <= (OTHERS => '0');


   IOB_FF : PROCESS (iCLK200) IS
   BEGIN  -- PROCESS IOB_FF
      IF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         oLVDS_l2f2rdo <= sLVDS_l2f2rdo;
         sLVDS_rdo2l2f <= iLVDS_rdo2l2f;
      END IF;
   END PROCESS IOB_FF;


   LVDS_RX : PROCESS (iCLK200, iRST) IS
   BEGIN  -- PROCESS LVDS_RX
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         srg_in <= (OTHERS => '0');
      ELSIF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         srg_in <= srg_in (3 DOWNTO 0) & sLVDS_rdo2l2f;
      END IF;
   END PROCESS LVDS_RX;

   LVDS_TX : PROCESS (iCLK200, iRST) IS
   BEGIN  -- PROCESS LVDS_TX
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         srg_out              <= (OTHERS => '0');
         tx_data_out_sync_old <= '0';
      ELSIF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         IF tx_data_out_sync = tx_data_out_sync_old THEN
            -- no update (shift the data out)
            sLVDS_l2f2rdo <= srg_out (4);
            srg_out       <= srg_out (3 DOWNTO 0) & '0';
         ELSE
            -- update the srg word with new data
            sLVDS_l2f2rdo <= srg_out (4);  -- last bit of the previous word
            srg_out       <= data_out;
         END IF;
         tx_data_out_sync_old <= tx_data_out_sync;
      END IF;
   END PROCESS LVDS_TX;

   RX_40MHz : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS RX_40MHz
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         data_in <= (OTHERS => '0');
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         data_in <= srg_in;
      END IF;
   END PROCESS RX_40MHz;

   --oD_rdo2l2f <= data_in WHEN mode = "00" OR mode = "11";
   DATA_LATCH : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS DATA_LATCH
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '0' THEN  -- falling clock edge
         IF mode = "00" OR mode = "11" THEN
            oD_rdo2l2f <= data_in;
         END IF;
      END IF;
   END PROCESS DATA_LATCH;



   TX_40MHz : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS TX_40MHz
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         tx_data_out_sync <= '0';
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         tx_data_out_sync <= NOT tx_data_out_sync;
         CASE mode IS
            WHEN "01" =>
               data_out <= "01010";     -- test pattern
            WHEN "10" =>
               data_out <= data_in;     -- loop back
            WHEN OTHERS =>
               data_out <= iD_l2f2rdo;  -- normal operation
         END CASE;
      END IF;
   END PROCESS TX_40MHz;

END ARCHITECTURE serdes5x1_arch;
