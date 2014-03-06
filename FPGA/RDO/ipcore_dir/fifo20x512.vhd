--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.58f
--  \   \         Application: netgen
--  /   /         Filename: fifo20x512.vhd
-- /___/   /\     Timestamp: Thu Mar 06 12:27:20 2014
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl C:/Luis/Dropbox/SSD/svn/ssd/FPGA/RDO/ipcore_dir/tmp/_cg/fifo20x512.ngc C:/Luis/Dropbox/SSD/svn/ssd/FPGA/RDO/ipcore_dir/tmp/_cg/fifo20x512.vhd 
-- Device	: 6vlx240tff1759-2
-- Input file	: C:/Luis/Dropbox/SSD/svn/ssd/FPGA/RDO/ipcore_dir/tmp/_cg/fifo20x512.ngc
-- Output file	: C:/Luis/Dropbox/SSD/svn/ssd/FPGA/RDO/ipcore_dir/tmp/_cg/fifo20x512.vhd
-- # of Entities	: 2
-- Design Name	: fifo20x512
-- Xilinx	: C:\Xilinx\14.5\ISE_DS\ISE\
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity reset_builtin is
  port (
    CLK : in STD_LOGIC := 'X'; 
    WR_CLK : in STD_LOGIC := 'X'; 
    RD_CLK : in STD_LOGIC := 'X'; 
    INT_CLK : in STD_LOGIC := 'X'; 
    RST : in STD_LOGIC := 'X'; 
    WR_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
    RD_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
    INT_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
  );
end reset_builtin;

architecture STRUCTURE of reset_builtin is
  signal wr_rst_reg_3 : STD_LOGIC; 
  signal rd_rst_reg_15 : STD_LOGIC; 
  signal wr_rst_reg_GND_25_o_MUX_1_o : STD_LOGIC; 
  signal rd_rst_reg_GND_25_o_MUX_2_o : STD_LOGIC; 
  signal wr_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal power_on_wr_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal rd_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal power_on_rd_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal NlwRenamedSignal_WR_RST_I : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal NlwRenamedSig_OI_n0019 : STD_LOGIC_VECTOR ( 5 downto 5 ); 
begin
  WR_RST_I(1) <= NlwRenamedSignal_WR_RST_I(0);
  WR_RST_I(0) <= NlwRenamedSignal_WR_RST_I(0);
  INT_RST_I(1) <= NlwRenamedSig_OI_n0019(5);
  INT_RST_I(0) <= NlwRenamedSig_OI_n0019(5);
  XST_GND : GND
    port map (
      G => NlwRenamedSig_OI_n0019(5)
    );
  wr_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(1),
      Q => wr_rst_fb(0)
    );
  wr_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(2),
      Q => wr_rst_fb(1)
    );
  wr_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(3),
      Q => wr_rst_fb(2)
    );
  wr_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(4),
      Q => wr_rst_fb(3)
    );
  wr_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_reg_3,
      Q => wr_rst_fb(4)
    );
  power_on_wr_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(1),
      Q => power_on_wr_rst(0)
    );
  power_on_wr_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(2),
      Q => power_on_wr_rst(1)
    );
  power_on_wr_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(3),
      Q => power_on_wr_rst(2)
    );
  power_on_wr_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(4),
      Q => power_on_wr_rst(3)
    );
  power_on_wr_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(5),
      Q => power_on_wr_rst(4)
    );
  power_on_wr_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => NlwRenamedSig_OI_n0019(5),
      Q => power_on_wr_rst(5)
    );
  rd_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(1),
      Q => rd_rst_fb(0)
    );
  rd_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(2),
      Q => rd_rst_fb(1)
    );
  rd_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(3),
      Q => rd_rst_fb(2)
    );
  rd_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(4),
      Q => rd_rst_fb(3)
    );
  rd_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_reg_15,
      Q => rd_rst_fb(4)
    );
  power_on_rd_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(1),
      Q => power_on_rd_rst(0)
    );
  power_on_rd_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(2),
      Q => power_on_rd_rst(1)
    );
  power_on_rd_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(3),
      Q => power_on_rd_rst(2)
    );
  power_on_rd_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(4),
      Q => power_on_rd_rst(3)
    );
  power_on_rd_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(5),
      Q => power_on_rd_rst(4)
    );
  power_on_rd_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => NlwRenamedSig_OI_n0019(5),
      Q => power_on_rd_rst(5)
    );
  wr_rst_reg : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_reg_GND_25_o_MUX_1_o,
      PRE => RST,
      Q => wr_rst_reg_3
    );
  rd_rst_reg : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_reg_GND_25_o_MUX_2_o,
      PRE => RST,
      Q => rd_rst_reg_15
    );
  WR_RST_I_1_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => wr_rst_reg_3,
      I1 => power_on_wr_rst(0),
      O => NlwRenamedSignal_WR_RST_I(0)
    );
  Mmux_wr_rst_reg_GND_25_o_MUX_1_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => wr_rst_fb(0),
      I1 => wr_rst_reg_3,
      O => wr_rst_reg_GND_25_o_MUX_1_o
    );
  Mmux_rd_rst_reg_GND_25_o_MUX_2_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => rd_rst_fb(0),
      I1 => rd_rst_reg_15,
      O => rd_rst_reg_GND_25_o_MUX_2_o
    );

end STRUCTURE;

-- synthesis translate_on

-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity fifo20x512 is
  port (
    rst : in STD_LOGIC := 'X'; 
    wr_clk : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    rd_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    din : in STD_LOGIC_VECTOR ( 19 downto 0 ); 
    dout : out STD_LOGIC_VECTOR ( 19 downto 0 ) 
  );
end fifo20x512;

architecture STRUCTURE of fifo20x512 is
  component reset_builtin
    port (
      CLK : in STD_LOGIC := 'X'; 
      WR_CLK : in STD_LOGIC := 'X'; 
      RD_CLK : in STD_LOGIC := 'X'; 
      INT_CLK : in STD_LOGIC := 'X'; 
      RST : in STD_LOGIC := 'X'; 
      WR_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
      RD_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
      INT_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
    );
  end component;
  signal N1 : STD_LOGIC; 
  signal NlwRenamedSig_OI_empty : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  empty <= NlwRenamedSig_OI_empty;
  XST_GND : GND
    port map (
      G => N1
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt : reset_builtin
    port map (
      CLK => N1,
      WR_CLK => wr_clk,
      RD_CLK => rd_clk,
      INT_CLK => N1,
      RST => rst,
      WR_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED,
      WR_RST_I(0) => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RD_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED,
      RD_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_0_UNCONNECTED,
      INT_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED,
      INT_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1 : FIFO18E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"0005",
      ALMOST_FULL_OFFSET => X"0006",
      DATA_WIDTH => 36,
      DO_REG => 1,
      EN_SYN => FALSE,
      FIFO_MODE => "FIFO18_36",
      FIRST_WORD_FALL_THROUGH => FALSE,
      INIT => X"000000000",
      SIM_DEVICE => "VIRTEX6",
      SRVAL => X"000000000"
    )
    port map (
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_ALMOSTEMPTY_UNCONNECTED
,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_ALMOSTFULL_UNCONNECTED
,
      EMPTY => NlwRenamedSig_OI_empty,
      FULL => full,
      RDCLK => rd_clk,
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp,
      RDERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDERR_UNCONNECTED,
      REGCE => N1,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RSTREG => N1,
      WRCLK => wr_clk,
      WREN => wr_en,
      WRERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRERR_UNCONNECTED,
      DI(31) => N1,
      DI(30) => N1,
      DI(29) => N1,
      DI(28) => N1,
      DI(27) => N1,
      DI(26) => N1,
      DI(25) => N1,
      DI(24) => N1,
      DI(23) => N1,
      DI(22) => N1,
      DI(21) => N1,
      DI(20) => N1,
      DI(19) => N1,
      DI(18) => N1,
      DI(17) => din(19),
      DI(16) => din(18),
      DI(15) => din(15),
      DI(14) => din(14),
      DI(13) => din(13),
      DI(12) => din(12),
      DI(11) => din(11),
      DI(10) => din(10),
      DI(9) => din(9),
      DI(8) => din(8),
      DI(7) => din(7),
      DI(6) => din(6),
      DI(5) => din(5),
      DI(4) => din(4),
      DI(3) => din(3),
      DI(2) => din(2),
      DI(1) => din(1),
      DI(0) => din(0),
      DIP(3) => N1,
      DIP(2) => N1,
      DIP(1) => din(17),
      DIP(0) => din(16),
      DO(31) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_31_UNCONNECTED,
      DO(30) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_30_UNCONNECTED,
      DO(29) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_29_UNCONNECTED,
      DO(28) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_28_UNCONNECTED,
      DO(27) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_27_UNCONNECTED,
      DO(26) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_26_UNCONNECTED,
      DO(25) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_25_UNCONNECTED,
      DO(24) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_24_UNCONNECTED,
      DO(23) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_23_UNCONNECTED,
      DO(22) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_22_UNCONNECTED,
      DO(21) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_21_UNCONNECTED,
      DO(20) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_20_UNCONNECTED,
      DO(19) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_19_UNCONNECTED,
      DO(18) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DO_18_UNCONNECTED,
      DO(17) => dout(19),
      DO(16) => dout(18),
      DO(15) => dout(15),
      DO(14) => dout(14),
      DO(13) => dout(13),
      DO(12) => dout(12),
      DO(11) => dout(11),
      DO(10) => dout(10),
      DO(9) => dout(9),
      DO(8) => dout(8),
      DO(7) => dout(7),
      DO(6) => dout(6),
      DO(5) => dout(5),
      DO(4) => dout(4),
      DO(3) => dout(3),
      DO(2) => dout(2),
      DO(1) => dout(1),
      DO(0) => dout(0),
      DOP(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DOP_3_UNCONNECTED,
      DOP(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_DOP_2_UNCONNECTED,
      DOP(1) => dout(17),
      DOP(0) => dout(16),
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_11_UNCONNECTED
,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_10_UNCONNECTED
,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_9_UNCONNECTED
,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_8_UNCONNECTED
,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_7_UNCONNECTED
,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_6_UNCONNECTED
,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_5_UNCONNECTED
,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_4_UNCONNECTED
,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_3_UNCONNECTED
,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_2_UNCONNECTED
,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_1_UNCONNECTED
,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_RDCOUNT_0_UNCONNECTED
,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_11_UNCONNECTED
,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_10_UNCONNECTED
,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_9_UNCONNECTED
,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_8_UNCONNECTED
,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_7_UNCONNECTED
,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_6_UNCONNECTED
,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_5_UNCONNECTED
,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_4_UNCONNECTED
,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_3_UNCONNECTED
,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_2_UNCONNECTED
,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_1_UNCONNECTED
,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf18e1_inst_sngfifo18e1_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => NlwRenamedSig_OI_empty,
      I1 => rd_en,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp
    );

end STRUCTURE;

-- synthesis translate_on
