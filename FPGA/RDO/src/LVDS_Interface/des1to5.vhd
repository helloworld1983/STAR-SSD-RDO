-- $Id: des1to5.vhd 359 2013-08-16 15:58:21Z thorsten $
-------------------------------------------------------------------------------
-- Title      : deserializer with IDELAY
-- Project    : HFT SSD
-------------------------------------------------------------------------------
-- File       : des1to5.vhd
-- Author     : Thorsten
-- Company    : LBNL
-- Created    : 2014-01-08
-- Last update: 2014-02-27
-- Platform   : Windows, Xilinx ISE 14.5
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This modules forms the deserializer for the L2F LVDS link
--              Data flow:
--              1. IDELAY
--              2. IDDR to double the IDELAY range to 5ns
--              3. deserializer
--              4. coarse (bit slip) adjustment
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

ENTITY des1to5 IS
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
END ENTITY des1to5;

ARCHITECTURE des1to5_arch OF des1to5 IS

   SIGNAL DDR_IN  : STD_LOGIC;
   SIGNAL DDR_P   : STD_LOGIC;
   SIGNAL DDR_N   : STD_LOGIC;
   SIGNAL DDR_P_d : STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL DDR_N_d : STD_LOGIC_VECTOR (1 DOWNTO 0);

   SIGNAL tap     : STD_LOGIC_VECTOR (5 DOWNTO 0);
   SIGNAL rst_tap : STD_LOGIC;

   CONSTANT SRG_LENGTH : INTEGER := 10;
   SIGNAL srg_in       : STD_LOGIC_VECTOR (SRG_LENGTH-1 DOWNTO 0);
   SIGNAL d_at40M      : STD_LOGIC_VECTOR (SRG_LENGTH-1 DOWNTO 0);
   SIGNAL d_edge       : STD_LOGIC_VECTOR (SRG_LENGTH-1 DOWNTO 0);
   SIGNAL d_edge_old   : STD_LOGIC_VECTOR (SRG_LENGTH-1 DOWNTO 0);
   SIGNAL change_flag  : STD_LOGIC;
   SIGNAL edge_flag    : STD_LOGIC;
   SIGNAL eval_old     : STD_LOGIC;
   SIGNAL srg_change   : STD_LOGIC_VECTOR (7 DOWNTO 0);

   SIGNAL edge_g2b : UNSIGNED (5 DOWNTO 0);
   SIGNAL edge_b2g : UNSIGNED (5 DOWNTO 0);

   SIGNAL eye_tap : STD_LOGIC_VECTOR (5 DOWNTO 0);

   SIGNAL coarse_sel : INTEGER RANGE 0 TO 4;

   -- The KEEP ATTRIBUTE prevents ISE from palcing the signals into the LUT and thus
   -- negating the intention the pipeline the signal to ease the timing
   ATTRIBUTE KEEP              : STRING;
   ATTRIBUTE KEEP OF DDR_P     : SIGNAL IS "TRUE";
   ATTRIBUTE KEEP OF DDR_N     : SIGNAL IS "TRUE";
   ATTRIBUTE KEEP OF DDR_P_d   : SIGNAL IS "TRUE";
   ATTRIBUTE KEEP OF DDR_N_d   : SIGNAL IS "TRUE";

BEGIN  -- ARCHITECTURE des1to5_arch

   MUX_tap : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS MUX_tap
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF rx_iodel_rst = '1' THEN
            tap     <= rx_iodel_tap;
            rst_tap <= '1';
         ELSIF rx_iodel_set = '1' THEN
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
         DELAY_SRC             => "I",  -- Delay input ("I", "CLKIN", "DATAIN", "IO", "O")
         HIGH_PERFORMANCE_MODE => TRUE,  -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
         IDELAY_TYPE           => "VAR_LOADABLE",  -- "DEFAULT", "FIXED", "VARIABLE", or "VAR_LOADABLE"
         IDELAY_VALUE          => 0,    -- Input delay tap setting (0-32)
         ODELAY_TYPE           => "FIXED",  -- "FIXED", "VARIABLE", or "VAR_LOADABLE"
         ODELAY_VALUE          => 0,    -- Output delay tap setting (0-32)
         REFCLK_FREQUENCY      => 200.0,  -- IDELAYCTRL clock input frequency in MHz
         SIGNAL_PATTERN        => "DATA"  -- "DATA" or "CLOCK" input signal
         )
      PORT MAP (
         CNTVALUEOUT => OPEN,  -- 5-bit output - Counter value for monitoring purpose
         DATAOUT     => DDR_IN,         -- 1-bit output - Delayed data output
         C           => iCLK40,         -- 1-bit input - Clock input
         CE          => '0',  -- 1-bit input - Active high enable increment/decrement function
         CINVCTRL    => '0',  -- 1-bit input - Dynamically inverts the Clock (C) polarity
         CLKIN       => '0',  -- 1-bit input - Clock Access into the IODELAY
         CNTVALUEIN  => tap (4 DOWNTO 0),  -- 5-bit input - Counter value for loadable counter application
         DATAIN      => '0',            -- 1-bit input - Internal delay data
         IDATAIN     => iLVDS_l2f2rdo,  -- 1-bit input - Delay data input
         INC         => '0',  -- 1-bit input - Increment / Decrement tap delay
         ODATAIN     => '0',  -- 1-bit input - Data input for the output datapath from the device
         RST         => rst_tap,  -- 1-bit input - Active high, synchronous reset, resets delay chain to IDELAY_VALUE/
-- ODELAY_VALUE tap. If no value is specified, the default is 0.
         T           => '1'  -- 1-bit input - 3-state input control. Tie high for input-only or internal delay or
-- tie low for output only.
         );

   IDDR_inst : IDDR
      GENERIC MAP (
         DDR_CLK_EDGE => "SAME_EDGE",  --"OPPOSITE_EDGE",  -- "OPPOSITE_EDGE", "SAME_EDGE"
-- or "SAME_EDGE_PIPELINED"
         INIT_Q1      => '0',           -- Initial value of Q1: ¡¯0¡¯ or ¡¯1¡¯
         INIT_Q2      => '0',           -- Initial value of Q2: ¡¯0¡¯ or ¡¯1¡¯
         SRTYPE       => "SYNC")        -- Set/Reset type: "SYNC" or "ASYNC"
      PORT MAP (
         Q1 => DDR_P,  -- 1-bit output for positive edge of clock
         Q2 => DDR_N,  -- 1-bit output for negative edge of clock
         C  => iCLK200,                 -- 1-bit clock input
         CE => '1',                     -- 1-bit clock enable input
         D  => DDR_IN,                  -- 1-bit DDR data input
         R  => '0',                     -- 1-bit reset
         S  => '0'                      -- 1-bit set
         );

   -- deley the DDR signals to move the coarse adjustment to the middle of the
   -- range
   DDR_COARSE_SHIFT : PROCESS (iCLK200, iRST) IS
   BEGIN  -- PROCESS DDR_COARSE_SHIFT
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         DDR_P_d (0) <= DDR_P_d (1);
         DDR_P_d (1) <= DDR_P;
         DDR_N_d (0) <= DDR_N_d (1);
         DDR_N_d (1) <= DDR_N;
      END IF;
   END PROCESS DDR_COARSE_SHIFT;

   RX_200MHz : PROCESS (iCLK200, iRST) IS
   BEGIN  -- PROCESS RX_200Mhz
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         srg_in <= (OTHERS => '0');
      ELSIF iCLK200'EVENT AND iCLK200 = '1' THEN  -- rising clock edge
         IF tap (5) = '1' THEN
            srg_in <= srg_in (SRG_LENGTH-2 DOWNTO 0) & DDR_P_d (0);
         ELSE
            srg_in <= srg_in (SRG_LENGTH-2 DOWNTO 0) & DDR_N_d (0);
         END IF;
      END IF;
   END PROCESS RX_200MHz;

   RX_40MHz : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS RX_40MHz
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         d_at40M <= srg_in;
         d_edge  <= d_at40M;
      END IF;
   END PROCESS RX_40MHz;


   edge_detect : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS edge_detect
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         d_edge_old <= (OTHERS => '0');
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF d_edge = d_edge_old THEN
            -- the data matched (good sign)
            change_flag <= '0';
         ELSE
            change_flag <= '1';
         END IF;
         d_edge_old <= d_edge;
      END IF;
   END PROCESS edge_detect;

   o_change_flag <= change_flag;

   -- This process evaluates a given tap checking if the data changes
   -- NOTE: the tap scan runs backwards (counting down the taps)
   --       but the eye evaluation uses the other diection
   --       this is why the edge labels seem reversed
   eval_tap : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS eval_tap
      IF iRST = '1' THEN                -- asynchronous reset (active high)
         edge_flag <= '0';
      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF rx_iodel_eval = '1' THEN
            IF change_flag = '1' THEN
               edge_flag <= '1';
            END IF;
         ELSIF eval_old = '1' THEN
            IF srg_change = x"80" THEN
               -- good to bad edge
               edge_g2b <= UNSIGNED(rx_iodel_tap) + 8;
            ELSIF srg_change = x"7F" THEN
               -- edge bad to good
               edge_b2g <= UNSIGNED(rx_iodel_tap) + 8;
            END IF;
            srg_change <= srg_change (6 DOWNTO 0) & edge_flag;
         ELSE
            edge_flag <= '0';
         END IF;
         eval_old <= rx_iodel_eval;
      END IF;
   END PROCESS eval_tap;

   eye_tap <= STD_LOGIC_VECTOR (edge_b2g + ((edge_g2b - edge_b2g) / 2));

   COARSE_SHIFT : PROCESS (iCLK40, iRST) IS
   BEGIN  -- PROCESS COARSE_SHIFT
      IF iRST = '1' THEN                -- asynchronous reset (active high)

      ELSIF iCLK40'EVENT AND iCLK40 = '1' THEN  -- rising clock edge
         IF rx_carse_set = '1' THEN
            IF d_at40M (4 DOWNTO 0) = "01010" THEN
               coarse_sel <= 0;
            END IF;
            IF d_at40M (5 DOWNTO 1) = "01010" THEN
               coarse_sel <= 1;
            END IF;
            IF d_at40M (6 DOWNTO 2) = "01010" THEN
               coarse_sel <= 2;
            END IF;
            IF d_at40M (7 DOWNTO 3) = "01010" THEN
               coarse_sel <= 3;
            END IF;
            IF d_at40M (8 DOWNTO 4) = "01010" THEN
               coarse_sel <= 4;
            END IF;
         END IF;
      END IF;
   END PROCESS COARSE_SHIFT;

   oD_l2f2rdo <= d_at40M (4 DOWNTO 0) WHEN coarse_sel = 0 ELSE
                 d_at40M (5 DOWNTO 1) WHEN coarse_sel = 1 ELSE
                 d_at40M (6 DOWNTO 2) WHEN coarse_sel = 2 ELSE
                 d_at40M (7 DOWNTO 3) WHEN coarse_sel = 3 ELSE
                 d_at40M (8 DOWNTO 4);

   o_rx_d <= d_at40M (4 DOWNTO 0) WHEN coarse_sel = 0 ELSE
             d_at40M (5 DOWNTO 1) WHEN coarse_sel = 1 ELSE
             d_at40M (6 DOWNTO 2) WHEN coarse_sel = 2 ELSE
             d_at40M (7 DOWNTO 3) WHEN coarse_sel = 3 ELSE
             d_at40M (8 DOWNTO 4);

   des_status.edge_g2b   <= STD_LOGIC_VECTOR (edge_g2b);
   des_status.edge_b2g   <= STD_LOGIC_VECTOR (edge_b2g);
   des_status.tap_sel    <= tap;
   des_status.coarse_sel <= STD_LOGIC_VECTOR (TO_UNSIGNED (coarse_sel, 3));

END ARCHITECTURE des1to5_arch;
