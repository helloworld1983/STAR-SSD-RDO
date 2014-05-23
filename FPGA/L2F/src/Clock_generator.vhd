-- $Id: Clock_generator.vhd 110 2012-10-16 17:57:48Z jschamba $
-------------------------------------------------------------------------------
-- Title      : Clock Generator
-- Project    : HFT PXL
-------------------------------------------------------------------------------
-- File       : Clock_generator.vhd
-- Author     : Joachim Schambach
-- Company    : University of Texas 
-- Created    : 2012-02-16
-- Last update: 2013-09-11
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Generate synthesized clocks needed for Virtex 6 board
--              Uses MMCM_BASE primitive, and global clock buffers for ALL
--              generated clocks.
--              It currently generates 3 clocks: 100MHz, 160MHz, and 200MHz.
--              The original 40MHz clock is also output after buffering.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-02-16  1.0      jschamba        Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY Clock_generator IS
   PORT (
      CLK_IN1  : IN  STD_LOGIC;
      CLK_OUT1 : OUT STD_LOGIC;
      CLK_OUT2 : OUT STD_LOGIC;
      CLK_OUT3 : OUT STD_LOGIC;
      CLK_OUT4 : OUT STD_LOGIC;
      CLK_OUT5 : OUT STD_LOGIC;
      CLK_BUFG : OUT STD_LOGIC;
      RESET    : IN  STD_LOGIC;
      LOCKED   : OUT STD_LOGIC
      );
END Clock_generator;

ARCHITECTURE arc OF Clock_generator IS
   -- Input clock buffering
   SIGNAL sClkin1   : STD_LOGIC;
   SIGNAL sClkin1_1 : STD_LOGIC;
   -- Output clock buffering
   SIGNAL sClkfbout : STD_LOGIC;
   SIGNAL sClkout0  : STD_LOGIC;
   SIGNAL sClkout1  : STD_LOGIC;
   SIGNAL sClkout2  : STD_LOGIC;
   SIGNAL sClkout3  : STD_LOGIC;
   SIGNAL sClkout4  : STD_LOGIC;

BEGIN
   -- Input Clock buffering
   --------------------------------------
--clkin1_buf : IBUFG
--      PORT MAP (
--         O => sClkin1_1,
--         I => CLK_IN1
--         );
   sClkin1_1 <= CLK_IN1;
   
   clkin_outbuf : BUFG
      PORT MAP (
         O => sClkin1,
         I => sClkin1_1
         );

   -- Clocking primitive
   --------------------------------------
   -- Instantiation of the MMCM primitive
   pll_base_inst : PLL_BASE
      GENERIC MAP (
         BANDWIDTH          => "OPTIMIZED",
         DIVCLK_DIVIDE      => 1,
         CLKFBOUT_MULT    => 20,
         CLKFBOUT_PHASE     => 0.000,
         CLKOUT0_DIVIDE   => 4,
         CLKOUT0_PHASE      => 0.000,
         CLKOUT0_DUTY_CYCLE => 0.500,
         CLKOUT1_DIVIDE     => 5,
         CLKOUT1_PHASE      => 0.000,
         CLKOUT1_DUTY_CYCLE => 0.500,
         CLKOUT2_DIVIDE     => 8,
         CLKOUT2_PHASE      => 0.000,
         CLKOUT2_DUTY_CYCLE => 0.500,
         CLKOUT3_DIVIDE     => 10,
         CLKOUT3_PHASE      => 0.000,
         CLKOUT3_DUTY_CYCLE => 0.500,
         CLKOUT4_DIVIDE     => 20,
         CLKOUT4_PHASE      => 0.000,
         CLKOUT4_DUTY_CYCLE => 0.500,
         CLKIN_PERIOD      => 25.000,
         REF_JITTER        => 0.010
         )
      PORT MAP (
         CLKFBOUT  => sClkfbout,
         CLKOUT0   => sClkout0,         -- 200 MHz
         CLKOUT1   => sClkout1,         -- 160 MHz
         CLKOUT2   => sClkout2,         -- 100 MHz
         CLKOUT3   => sClkout3,         -- 80  MHz
         CLKOUT4   => sClkout4,         -- 40  MHz
         CLKOUT5   => OPEN,
         -- Input clock control
         CLKFBIN   => sClkfbout,
         CLKIN    => sClkin1,
         -- Other control and status signals
         LOCKED    => LOCKED,
         RST       => RESET
         );

   -- Output clocks buffering
   -------------------------------------

   clkout1_buf : BUFG
      PORT MAP (
         O => CLK_OUT1,
         I => sClkout0);

   clkout2_buf : BUFG
      PORT MAP (
         O => CLK_OUT2,
         I => sClkout1);

   clkout3_buf : BUFG
      PORT MAP (
         O => CLK_OUT3,
         I => sClkout2);

   clkout4_buf : BUFG
      PORT MAP (
         O => CLK_OUT4,
         I => sClkout3);

   clkout5_buf : BUFG
      PORT MAP (
         O => CLK_OUT5,
         I => sClkout4);

   -- also output a copy of the buffered input clock
   CLK_BUFG <= sClkin1;

END arc;
