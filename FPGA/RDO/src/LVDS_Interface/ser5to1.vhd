-- $Id: ser5to1.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : serializer with ODELAY
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : ser5to1.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-03
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This modules forms the serializer for the L2F LVDS link
--              Data flow:
--              1. coarse (bit slip) adjustment
--              2. serializer
--              3. ODDR to double the IDELAY range to 5ns
--              4. ODELAY
--
--              In addition there is an engine to find the edges of the eye by
--              looking at changing bit patterns
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

USE work.l2f_pkg.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY ser5to1 IS
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
END ENTITY ser5to1;

ARCHITECTURE ser5to1_arch OF ser5to1 IS

   SIGNAL sDDR_out : STD_LOGIC;
   SIGNAL sDDR_N   : STD_LOGIC;
   SIGNAL sDDR_P   : STD_LOGIC;

   SIGNAL tx_data_out_sync     : STD_LOGIC := '0';
   SIGNAL tx_data_out_sync_old : STD_LOGIC := '0';

   SIGNAL tap     : STD_LOGIC_VECTOR (5 DOWNTO 0);
   SIGNAL rst_tap : STD_LOGIC;

   SIGNAL srg_shift : STD_LOGIC_VECTOR (9 DOWNTO 0);
   SIGNAL data_out  : STD_LOGIC_VECTOR (4 DOWNTO 0);

   SIGNAL edge_flag  : STD_LOGIC;
   SIGNAL eval_old   : STD_LOGIC;
   SIGNAL srg_change : STD_LOGIC_VECTOR (7 DOWNTO 0);

   SIGNAL edge_g2b : UNSIGNED (5 DOWNTO 0);
   SIGNAL edge_b2g : UNSIGNED (5 DOWNTO 0);

   SIGNAL eye_tap    : STD_LOGIC_VECTOR (5 DOWNTO 0);
   SIGNAL coarse_sel : INTEGER RANGE 0 TO 4;

BEGIN  -- ARCHITECTURE ser5to1_arch

   oTC <= (OTHERS => '0');

   MUX_tap : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS MUX_tap
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF tx_iodel_rst = '1' THEN
            tap     <= tx_iodel_tap;
            rst_tap <= '1';
         ELSIF tx_iodel_set = '1' THEN
            tap     <= eye_tap;
            rst_tap <= '1';
         ELSE
            rst_tap <= '0';
         END IF;
      END IF;
   END PROCESS MUX_tap;



   IODELAYE1_inst : IODELAYE1
      GENERIC MAP (
         CINVCTRL_SEL          => FALSE,  -- Enable dynamic clock inversion ("TRUE"/"FALSE")
         DELAY_SRC             => "O",  -- Delay input ("I", "CLKIN", "DATAIN", "IO", "O")
         HIGH_PERFORMANCE_MODE => TRUE,  -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
         IDELAY_TYPE           => "FIXED",  -- "DEFAULT", "FIXED", "VARIABLE", or "VAR_LOADABLE"
         IDELAY_VALUE          => 0,    -- Input delay tap setting (0-32)
         ODELAY_TYPE           => "VAR_LOADABLE",  -- "FIXED", "VARIABLE", or "VAR_LOADABLE"
         ODELAY_VALUE          => 0,    -- Output delay tap setting (0-32)
         REFCLK_FREQUENCY      => 200.0,  -- IDELAYCTRL clock input frequency in MHz
         SIGNAL_PATTERN        => "DATA"  -- "DATA" or "CLOCK" input signal
         )
      PORT MAP (
         CNTVALUEOUT => OPEN,  -- 5-bit output - Counter value for monitoring purpose
         DATAOUT     => oLVDS_rdo2l2f,  -- 1-bit output - Delayed data output
         C           => iCLK40,         -- 1-bit input - Clock input
         CE          => '0',  -- 1-bit input - Active high enable increment/decrement function
         CINVCTRL    => '0',  -- 1-bit input - Dynamically inverts the Clock (C) polarity
         CLKIN       => '0',  -- 1-bit input - Clock Access into the IODELAY
         CNTVALUEIN  => tap (4 DOWNTO 0),  -- 5-bit input - Counter value for loadable counter application
         DATAIN      => '0',            -- 1-bit input - Internal delay data
         IDATAIN     => '0',            -- 1-bit input - Delay data input
         INC         => '0',  -- 1-bit input - Increment / Decrement tap delay
         ODATAIN     => sDDR_out,  -- 1-bit input - Data input for the output datapath from the device
         RST         => rst_tap,  -- 1-bit input - Active high, synchronous reset, resets delay chain to IDELAY_VALUE/
-- ODELAY_VALUE tap. If no value is specified, the default is 0.
         T           => '0'  -- 1-bit input - 3-state input control. Tie high for input-only or internal delay or
-- tie low for output only.
         );


   ODDR_inst : ODDR
      GENERIC MAP(
         DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',  -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
      PORT MAP (
         Q  => sDDR_out,                -- 1-bit DDR output
         C  => iCLK200,                 -- 1-bit clock input
         CE => '1',                     -- 1-bit clock enable input
         D1 => sDDR_P,                  -- 1-bit data input (positive edge)
         D2 => sDDR_N,                  -- 1-bit data input (negative edge)
         R  => '0',                     -- 1-bit reset input
         S  => '0'                      -- 1-bit set input
         );

   --   sDDR_P <= srg_shift (8);
   --   sDDR_N <= srg_shift (9) WHEN tap (5) = '0' ELSE srg_shift (8);
   DDR_Select : PROCESS (iCLK200, iRST) IS
   BEGIN  -- PROCESS DDR_Select
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         sDDR_P <= srg_shift (8);
         IF tap (5) = '0' THEN
            sDDR_N <= srg_shift (9);
         ELSE
            sDDR_N <= srg_shift (8);
         END IF;
      END IF;
   END PROCESS DDR_Select;


   TX_200MHz : PROCESS (iCLK200, iRST) IS
   BEGIN  -- PROCESS TX_200MHz
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         IF tx_data_out_sync = tx_data_out_sync_old THEN
            -- no update (shift the data out)
            srg_shift <= srg_shift (8 DOWNTO 0) & '0';
         ELSE
            -- update the srg word with new data
            srg_shift <= srg_shift (8 DOWNTO 0) & '0';

            CASE coarse_sel IS
               WHEN 0 =>
                  srg_shift (5 DOWNTO 1) <= data_out;
               WHEN 1 =>
                  srg_shift (6 DOWNTO 2) <= data_out;
               WHEN 2 =>
                  srg_shift (7 DOWNTO 3) <= data_out;
               WHEN 3 =>
                  srg_shift (8 DOWNTO 4) <= data_out;
               WHEN 4 =>
                  srg_shift (9 DOWNTO 5) <= data_out;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END IF;
         tx_data_out_sync_old <= tx_data_out_sync;
      END IF;
   END PROCESS TX_200MHz;

   data_out <= "10101" WHEN mode = "10" ELSE iD_rdo2l2f;



   PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         tx_data_out_sync <= NOT tx_data_out_sync;
      END IF;
   END PROCESS;

   -- This process evaluates a given tap checking if the data changes
   -- NOTE: the tap scan runs backwards (counting down the taps)
   --       but the eye evaluation uses the other diection
   --       this is why the edge labels seem reversed
   eval_tap : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS eval_tap
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         edge_flag <= '0';
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF tx_iodel_eval = '1' THEN
            IF change_flag = '1' THEN
               edge_flag <= '1';
            END IF;
         ELSIF eval_old = '1' THEN
            IF srg_change = x"80" THEN
               -- good to bad edge
               edge_g2b <= UNSIGNED(tx_iodel_tap) + 8;
            ELSIF srg_change = x"7F" THEN
               -- edge bad to good
               edge_b2g <= UNSIGNED(tx_iodel_tap) + 8;
            END IF;
            srg_change <= srg_change (6 DOWNTO 0) & edge_flag;
         ELSE
            edge_flag <= '0';
         END IF;
         eval_old <= tx_iodel_eval;
      END IF;
   END PROCESS eval_tap;

   eye_tap <= STD_LOGIC_VECTOR (edge_b2g + ((edge_g2b - edge_b2g) / 2));


   PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         coarse_sel <= 0;
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF mode = "01" THEN
            -- constant for calibration
            coarse_sel <= 0;
         ELSIF tx_carse_set = '1' THEN
            IF rx_d = "11010" THEN
               coarse_sel <= 1;
            END IF;
            IF rx_d = "10101" THEN
               coarse_sel <= 0;
            END IF;
            IF rx_d = "01011" THEN
               coarse_sel <= 4;
            END IF;
            IF rx_d = "10110" THEN
               coarse_sel <= 3;
            END IF;
            IF rx_d = "01101" THEN
               coarse_sel <= 2;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   ser_status.edge_g2b   <= STD_LOGIC_VECTOR (edge_g2b);
   ser_status.edge_b2g   <= STD_LOGIC_VECTOR (edge_b2g);
   ser_status.tap_sel    <= tap;
   ser_status.coarse_sel <= STD_LOGIC_VECTOR (TO_UNSIGNED (coarse_sel, 3));

END ARCHITECTURE ser5to1_arch;
