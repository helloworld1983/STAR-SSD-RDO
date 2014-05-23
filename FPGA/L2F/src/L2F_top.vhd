-- L2F with serdes code for 200MHz iodeley


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

LIBRARY UNISIM;
USE UNISIM.vcomponents.ALL;



ENTITY L2F_top IS
   PORT (
      CLK40             : IN    STD_LOGIC;
      -- Fiber 0
      F0_DES_D          : IN    STD_LOGIC_VECTOR (23 DOWNTO 0);
      F0_SER_D          : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      F0_DES_RCLK       : IN    STD_LOGIC;
      F0_SER_TCLK       : OUT   STD_LOGIC;
      F0_LED            : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
      F0_SER_DEN        : OUT   STD_LOGIC;
      F0_SER_TPWDNB     : OUT   STD_LOGIC;
      F0_DES_RPWDNB     : OUT   STD_LOGIC;
      F0_DES_PASS       : IN    STD_LOGIC;
      F0_DES_LOCK       : IN    STD_LOGIC;
      F0_DES_SLEW       : OUT   STD_LOGIC;
      F0_DES_BISTM      : OUT   STD_LOGIC;
      F0_DES_BISTEN     : OUT   STD_LOGIC;
      F0_DES_REN        : OUT   STD_LOGIC;
      F0_DES_PTOSEL     : OUT   STD_LOGIC;
      F0_TX_FAULT       : IN    STD_LOGIC;
      F0_TX_DISABLE     : OUT   STD_LOGIC;
      F0_MOD_DEF        : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      F0_RX_LOSS        : IN    STD_LOGIC;
      -- Fiber 1
      F1_DES_D          : IN    STD_LOGIC_VECTOR (23 DOWNTO 0);
      F1_SER_D          : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      F1_DES_RCLK       : IN    STD_LOGIC;
      F1_SER_TCLK       : OUT   STD_LOGIC;
      F1_LED            : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
      F1_SER_DEN        : OUT   STD_LOGIC;
      F1_SER_TPWDNB     : OUT   STD_LOGIC;
      F1_DES_RPWDNB     : OUT   STD_LOGIC;
      F1_DES_PASS       : IN    STD_LOGIC;
      F1_DES_LOCK       : IN    STD_LOGIC;
      F1_DES_SLEW       : OUT   STD_LOGIC;
      F1_DES_BISTM      : OUT   STD_LOGIC;
      F1_DES_BISTEN     : OUT   STD_LOGIC;
      F1_DES_REN        : OUT   STD_LOGIC;
      F1_DES_PTOSEL     : OUT   STD_LOGIC;
      F1_TX_FAULT       : IN    STD_LOGIC;
      F1_TX_DISABLE     : OUT   STD_LOGIC;
      F1_MOD_DEF        : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      F1_RX_LOSS        : IN    STD_LOGIC;
      -- Fiber 2
      F2_DES_D          : IN    STD_LOGIC_VECTOR (23 DOWNTO 0);
      F2_SER_D          : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      F2_DES_RCLK       : IN    STD_LOGIC;
      F2_SER_TCLK       : OUT   STD_LOGIC;
      F2_LED            : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
      F2_SER_DEN        : OUT   STD_LOGIC;
      F2_SER_TPWDNB     : OUT   STD_LOGIC;
      F2_DES_RPWDNB     : OUT   STD_LOGIC;
      F2_DES_PASS       : IN    STD_LOGIC;
      F2_DES_LOCK       : IN    STD_LOGIC;
      F2_DES_SLEW       : OUT   STD_LOGIC;
      F2_DES_BISTM      : OUT   STD_LOGIC;
      F2_DES_BISTEN     : OUT   STD_LOGIC;
      F2_DES_REN        : OUT   STD_LOGIC;
      F2_DES_PTOSEL     : OUT   STD_LOGIC;
      F2_TX_FAULT       : IN    STD_LOGIC;
      F2_TX_DISABLE     : OUT   STD_LOGIC;
      F2_MOD_DEF        : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      F2_RX_LOSS        : IN    STD_LOGIC;
      -- Fiber 3
      F3_DES_D          : IN    STD_LOGIC_VECTOR (23 DOWNTO 0);
      F3_SER_D          : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      F3_DES_RCLK       : IN    STD_LOGIC;
      F3_SER_TCLK       : OUT   STD_LOGIC;
      F3_LED            : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
      F3_SER_DEN        : OUT   STD_LOGIC;
      F3_SER_TPWDNB     : OUT   STD_LOGIC;
      F3_DES_RPWDNB     : OUT   STD_LOGIC;
      F3_DES_PASS       : IN    STD_LOGIC;
      F3_DES_LOCK       : IN    STD_LOGIC;
      F3_DES_SLEW       : OUT   STD_LOGIC;
      F3_DES_BISTM      : OUT   STD_LOGIC;
      F3_DES_BISTEN     : OUT   STD_LOGIC;
      F3_DES_REN        : OUT   STD_LOGIC;
      F3_DES_PTOSEL     : OUT   STD_LOGIC;
      F3_TX_FAULT       : IN    STD_LOGIC;
      F3_TX_DISABLE     : OUT   STD_LOGIC;
      F3_MOD_DEF        : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      F3_RX_LOSS        : IN    STD_LOGIC;
      -- LVDS links
      L3_JTAG_P         : IN    STD_LOGIC_VECTOR (2 DOWNTO 0);
      L3_JTAG_N         : IN    STD_LOGIC_VECTOR (2 DOWNTO 0);
      L3_START_P        : IN    STD_LOGIC;
      L3_START_N        : IN    STD_LOGIC;
      L3_RSTB_P         : IN    STD_LOGIC;
      L3_RSTB_N         : IN    STD_LOGIC;
      L3_MARKER_P       : OUT   STD_LOGIC;
      L3_MARKER_N       : OUT   STD_LOGIC;
      L1_JTAG_P         : IN    STD_LOGIC_VECTOR (2 DOWNTO 0);
      L1_JTAG_N         : IN    STD_LOGIC_VECTOR (2 DOWNTO 0);
      L1_START_P        : IN    STD_LOGIC;
      L1_START_N        : IN    STD_LOGIC;
      L1_RSTB_P         : IN    STD_LOGIC;
      L1_RSTB_N         : IN    STD_LOGIC;
      L1_MARKER_P       : OUT   STD_LOGIC;
      L1_MARKER_N       : OUT   STD_LOGIC;
      L3_FIBER2LVDS_P   : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      L3_FIBER2LVDS_N   : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      L3_LVDS2FIBER_P   : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
      L3_LVDS2FIBER_N   : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
      L1_FIBER2LVDS_P   : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      L1_FIBER2LVDS_N   : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
      L1_LVDS2FIBER_P   : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
      L1_LVDS2FIBER_N   : IN    STD_LOGIC_VECTOR (15 DOWNTO 0);
      -- ALTERA
      ALTERA_DCLK       : IN    STD_LOGIC;
      ALTERA_CONIG_DONE : OUT   STD_LOGIC;
      ALTERA_nCONFIG    : IN    STD_LOGIC;
      ALTERA_nSTATUS    : OUT   STD_LOGIC;
      ALTERA_DATA0      : IN    STD_LOGIC;
      -- SPARE
      SPARE             : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0)
      );
END L2F_top;

ARCHITECTURE L2F_top_arch OF L2F_top IS

   COMPONENT Clock_generator
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
   END COMPONENT;

   COMPONENT fiber
      PORT (
         CLK40      : IN    STD_LOGIC;
         CLK80      : IN    STD_LOGIC;
         CLK200     : IN    STD_LOGIC;
         RST        : IN    STD_LOGIC;
         -- fiber TX
         D_TX       : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
         DEN        : OUT   STD_LOGIC;
         TCLK       : OUT   STD_LOGIC;
         TPWDNB     : OUT   STD_LOGIC;
                                        -- fiber RX
         D_RX       : IN    STD_LOGIC_VECTOR (23 DOWNTO 0);
         RPWDNB     : OUT   STD_LOGIC;
         PASS       : IN    STD_LOGIC;
         RCLK       : IN    STD_LOGIC;
         LOCK       : IN    STD_LOGIC;
         SLEW       : OUT   STD_LOGIC;
         BISTM      : OUT   STD_LOGIC;
         BISTEN     : OUT   STD_LOGIC;
         REN        : OUT   STD_LOGIC;
         PTOSEL     : OUT   STD_LOGIC;
                                        -- fiber module
         TX_FAULT   : IN    STD_LOGIC;
         TX_DISABLE : OUT   STD_LOGIC;
         MOD_DEF    : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
         RX_LOSS    : IN    STD_LOGIC;
                                        -- result
         sD_TX      : IN    STD_LOGIC_VECTOR (23 DOWNTO 0);
         sD_RX      : OUT   STD_LOGIC_VECTOR (23 DOWNTO 0);
         status     : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
                                        -- test
         TC         : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT serdes5x1
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
   END COMPONENT;

   SIGNAL sCLK200 : STD_LOGIC;
   SIGNAL sCLK160 : STD_LOGIC;
   SIGNAL sCLK100 : STD_LOGIC;
   SIGNAL sCLK80  : STD_LOGIC;
   SIGNAL sCLK40  : STD_LOGIC;
   SIGNAL RST     : STD_LOGIC;
   SIGNAL LOCKED  : STD_LOGIC;

   SIGNAL s_mode   : STD_LOGIC_VECTOR (1 DOWNTO 0);
   -- sync mode
   SIGNAL s_mode_0 : STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL s_mode_1 : STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL s_mode_2 : STD_LOGIC_VECTOR (1 DOWNTO 0);


   -- single ended signal in front of LVDS
   SIGNAL L3_toRDO   : STD_LOGIC_VECTOR (23 DOWNTO 0) := (OTHERS => '0');
   SIGNAL L1_toRDO   : STD_LOGIC_VECTOR (23 DOWNTO 0) := (OTHERS => '0');
   SIGNAL L3_fromRDO : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL L1_fromRDO : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

   -- paralel signal from serdes
   SIGNAL L3_par_toRDO   : STD_LOGIC_VECTOR (79 DOWNTO 0);
   SIGNAL L1_par_toRDO   : STD_LOGIC_VECTOR (79 DOWNTO 0);
   SIGNAL L3_par_fromRDO : STD_LOGIC_VECTOR (79 DOWNTO 0);
   SIGNAL L1_par_fromRDO : STD_LOGIC_VECTOR (79 DOWNTO 0);

   SIGNAL sF0_D_TX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF0_D_RX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF1_D_TX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF1_D_RX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF2_D_TX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF2_D_RX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF3_D_TX : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL sF3_D_RX : STD_LOGIC_VECTOR (23 DOWNTO 0);

-------------------------------------------------------------------------------   
   SIGNAL L3_misc_in  : STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => '0');
   SIGNAL L3_misc_out : STD_LOGIC                     := '0';
   SIGNAL L1_misc_in  : STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => '0');
   SIGNAL L1_misc_out : STD_LOGIC                     := '0';


   SIGNAL status_F0 : STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL status_F1 : STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL status_F2 : STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL status_F3 : STD_LOGIC_VECTOR (3 DOWNTO 0);


   SIGNAL L3_START_in : STD_LOGIC;
   SIGNAL L1_START_in : STD_LOGIC;

BEGIN  -- L2F_top_arch


   Clock_generator_inst : Clock_generator
      PORT MAP (
         CLK_IN1  => L3_START_in,
         CLK_OUT1 => sCLK200,
         CLK_OUT2 => sCLK160,
         CLK_OUT3 => sCLK100,
         CLK_OUT4 => sCLK80,
         CLK_OUT5 => sCLK40,
         CLK_BUFG => OPEN,
         RESET    => '0',
         LOCKED   => LOCKED
         );

   RST <= NOT LOCKED;


   fiber_inst0 : fiber
      PORT MAP (
         CLK40      => sCLK40,
         CLK80      => sCLK80,
         CLK200     => sCLK200,
         RST        => RST,
         -- fiber TX
         D_TX       => F0_SER_D,
         DEN        => F0_SER_DEN,
         TCLK       => F0_SER_TCLK,
         TPWDNB     => F0_SER_TPWDNB,
         -- fiber RX
         D_RX       => F0_DES_D,
         RPWDNB     => F0_DES_RPWDNB,
         PASS       => F0_DES_PASS,
         RCLK       => F0_DES_RCLK,
         LOCK       => F0_DES_LOCK,
         SLEW       => F0_DES_SLEW,
         BISTM      => F0_DES_BISTM,
         BISTEN     => F0_DES_BISTEN,
         REN        => F0_DES_REN,
         PTOSEL     => F0_DES_PTOSEL,
         -- fiber module
         TX_FAULT   => F0_TX_FAULT,
         TX_DISABLE => F0_TX_DISABLE,
         MOD_DEF    => F0_MOD_DEF,
         RX_LOSS    => F0_RX_LOSS,
         -- result
         sD_TX      => sF0_D_TX,
         sD_RX      => sF0_D_RX,
         status     => status_F0,
         -- test
         TC         => OPEN
         );

   fiber_inst1 : fiber
      PORT MAP (
         CLK40      => sCLK40,
         CLK80      => sCLK80,
         CLK200     => sCLK200,
         RST        => RST,
         -- fiber TX
         D_TX       => F1_SER_D,
         DEN        => F1_SER_DEN,
         TCLK       => F1_SER_TCLK,
         TPWDNB     => F1_SER_TPWDNB,
         -- fiber RX
         D_RX       => F1_DES_D,
         RPWDNB     => F1_DES_RPWDNB,
         PASS       => F1_DES_PASS,
         RCLK       => F1_DES_RCLK,
         LOCK       => F1_DES_LOCK,
         SLEW       => F1_DES_SLEW,
         BISTM      => F1_DES_BISTM,
         BISTEN     => F1_DES_BISTEN,
         REN        => F1_DES_REN,
         PTOSEL     => F1_DES_PTOSEL,
         -- fiber module
         TX_FAULT   => F1_TX_FAULT,
         TX_DISABLE => F1_TX_DISABLE,
         MOD_DEF    => F1_MOD_DEF,
         RX_LOSS    => F1_RX_LOSS,
         -- result
         sD_TX      => sF1_D_TX,
         sD_RX      => sF1_D_RX,
         status     => status_F1,
         -- test
         TC         => OPEN
         );

   fiber_inst2 : fiber
      PORT MAP (
         CLK40      => sCLK40,
         CLK80      => sCLK80,
         CLK200     => sCLK200,
         RST        => RST,
         -- fiber TX
         D_TX       => F2_SER_D,
         DEN        => F2_SER_DEN,
         TCLK       => F2_SER_TCLK,
         TPWDNB     => F2_SER_TPWDNB,
         -- fiber RX
         D_RX       => F2_DES_D,
         RPWDNB     => F2_DES_RPWDNB,
         PASS       => F2_DES_PASS,
         RCLK       => F2_DES_RCLK,
         LOCK       => F2_DES_LOCK,
         SLEW       => F2_DES_SLEW,
         BISTM      => F2_DES_BISTM,
         BISTEN     => F2_DES_BISTEN,
         REN        => F2_DES_REN,
         PTOSEL     => F2_DES_PTOSEL,
         -- fiber module
         TX_FAULT   => F2_TX_FAULT,
         TX_DISABLE => F2_TX_DISABLE,
         MOD_DEF    => F2_MOD_DEF,
         RX_LOSS    => F2_RX_LOSS,
         -- result
         sD_TX      => sF2_D_TX,
         sD_RX      => sF2_D_RX,
         status     => status_F2,
         -- test
         TC         => OPEN
         );

   fiber_inst3 : fiber
      PORT MAP (
         CLK40      => sCLK40,
         CLK80      => sCLK80,
         CLK200     => sCLK200,
         RST        => RST,
         -- fiber TX
         D_TX       => F3_SER_D,
         DEN        => F3_SER_DEN,
         TCLK       => F3_SER_TCLK,
         TPWDNB     => F3_SER_TPWDNB,
         -- fiber RX
         D_RX       => F3_DES_D,
         RPWDNB     => F3_DES_RPWDNB,
         PASS       => F3_DES_PASS,
         RCLK       => F3_DES_RCLK,
         LOCK       => F3_DES_LOCK,
         SLEW       => F3_DES_SLEW,
         BISTM      => F3_DES_BISTM,
         BISTEN     => F3_DES_BISTEN,
         REN        => F3_DES_REN,
         PTOSEL     => F3_DES_PTOSEL,
         -- fiber module
         TX_FAULT   => F3_TX_FAULT,
         TX_DISABLE => F3_TX_DISABLE,
         MOD_DEF    => F3_MOD_DEF,
         RX_LOSS    => F3_RX_LOSS,
         -- result
         sD_TX      => sF3_D_TX,
         sD_RX      => sF3_D_RX,
         status     => status_F3,
         -- test
         TC         => OPEN
         );

-------------------------------------------------------------------------------

   L3_serdes : FOR i IN 0 TO 15 GENERATE
      L3_serdes5x1_inst : serdes5x1
         PORT MAP (
            iCLK40        => sCLK40,
            iCLK200       => sCLK200,
            iRST          => RST,
            -- setup
            mode          => s_mode,
            -- internal bus
            iD_l2f2rdo    => L3_par_toRDO ((i*5)+4 DOWNTO (i*5)),
            oD_rdo2l2f    => L3_par_fromRDO ((i*5)+4 DOWNTO (i*5)),
            -- LVDS
            iLVDS_rdo2l2f => L3_fromRDO (i),
            oLVDS_l2f2rdo => L3_toRDO (i),
            -- test connector
            oTC           => OPEN
            );
   END GENERATE L3_serdes;

   L1_serdes : FOR i IN 0 TO 15 GENERATE
      L1_serdes5x1_inst : serdes5x1
         PORT MAP (
            iCLK40        => sCLK40,
            iCLK200       => sCLK200,
            iRST          => RST,
            -- setup
            mode          => s_mode,
            -- internal bus
            iD_l2f2rdo    => L1_par_toRDO ((i*5)+4 DOWNTO (i*5)),
            oD_rdo2l2f    => L1_par_fromRDO ((i*5)+4 DOWNTO (i*5)),
            -- LVDS
            iLVDS_rdo2l2f => L1_fromRDO (i),
            oLVDS_l2f2rdo => L1_toRDO (i),
            -- test connector
            oTC           => OPEN
            );
   END GENERATE L1_serdes;

   ----------------------------------------------------------------------------

   -- map parallel LVDS signals to fibers

   sF0_D_TX <= L3_par_fromRDO (23 DOWNTO 0);
   sF1_D_TX <= L3_par_fromRDO (47 DOWNTO 24);
   sF2_D_TX <= L1_par_fromRDO (23 DOWNTO 0);
   sF3_D_TX <= L1_par_fromRDO (47 DOWNTO 24);

   L3_par_toRDO (23 DOWNTO 0)  <= sF0_D_RX;
   L3_par_toRDO (47 DOWNTO 24) <= sF1_D_RX;
   L1_par_toRDO (23 DOWNTO 0)  <= sF2_D_RX;
   L1_par_toRDO (47 DOWNTO 24) <= sF3_D_RX;

   L3_par_toRDO (51 DOWNTO 48) <= status_F0;
   L3_par_toRDO (55 DOWNTO 52) <= status_F1;
   L1_par_toRDO (51 DOWNTO 48) <= status_F2;
   L1_par_toRDO (55 DOWNTO 52) <= status_F3;

   LED_OUT : PROCESS (sCLK40, RST) IS
   BEGIN  -- PROCESS LED_OUT
      IF RST = '1' THEN                 -- asynchronous reset (active high)

      ELSIF sCLK40'EVENT AND sCLK40 = '1' THEN  -- rising clock edge
         F0_LED <= L3_par_fromRDO (51 DOWNTO 48);
         F1_LED <= L3_par_fromRDO (55 DOWNTO 52);
         F2_LED <= L1_par_fromRDO (51 DOWNTO 48);
         F3_LED <= L3_par_fromRDO (55 DOWNTO 52);
      END IF;
   END PROCESS LED_OUT;



   -- loop back for testing
   L3_par_toRDO (79 DOWNTO 56) <= L3_par_fromRDO (79 DOWNTO 56);  --(OTHERS => '0');
   L1_par_toRDO (79 DOWNTO 56) <= L1_par_fromRDO (79 DOWNTO 56);  --(OTHERS => '0');


   SYNC_MODE : PROCESS (sCLK40, RST) IS
   BEGIN  -- PROCESS SYNC_MODE
      IF RST = '1' THEN                 -- asynchronous reset (active high)
         s_mode <= "00";
      ELSIF sCLK40'EVENT AND sCLK40 = '1' THEN  -- rising clock edge
         IF s_mode_2 = s_mode_1 THEN
            s_mode <= s_mode_2;
         END IF;

         s_mode_2 <= s_mode_1;
         s_mode_1 <= s_mode_0;
         s_mode_0 <= L3_misc_in (1 DOWNTO 0);
      END IF;
   END PROCESS SYNC_MODE;

   L3_toRDO (23 DOWNTO 16) <= (OTHERS => '0');
   L1_toRDO (23 DOWNTO 16) <= (OTHERS => '0');

   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------



   L3_LVDS_OUT : FOR i IN 0 TO 23 GENERATE
      L3_OBUFDS_inst : OBUFDS
         GENERIC MAP
         (
            IOSTANDARD => "LVDS_33"
            )
         PORT MAP
         (
            O  => L3_FIBER2LVDS_P(i),
            OB => L3_FIBER2LVDS_N(i),
            I  => L3_toRDO(i)
            );
   END GENERATE L3_LVDS_OUT;

   L3_LVDS_IN : FOR i IN 0 TO 15 GENERATE
      L3_IBUFDS_inst : IBUFDS
         GENERIC MAP
         (
            DIFF_TERM    => TRUE,
            IBUF_LOW_PWR => FALSE,
            IOSTANDARD   => "LVDS_33"
            )
         PORT MAP
         (
            O  => L3_fromRDO(i),
            I  => L3_LVDS2FIBER_P(i),
            IB => L3_LVDS2FIBER_N(i)
            );
   END GENERATE L3_LVDS_IN;

   L1_LVDS_OUT : FOR i IN 0 TO 23 GENERATE
      L1_OBUFDS_inst : OBUFDS
         GENERIC MAP
         (
            IOSTANDARD => "LVDS_33"
            )
         PORT MAP
         (
            O  => L1_FIBER2LVDS_P(i),
            OB => L1_FIBER2LVDS_N(i),
            I  => L1_toRDO(i)
            );
   END GENERATE L1_LVDS_OUT;

   L1_LVDS_IN : FOR i IN 0 TO 15 GENERATE
      L1_IBUFDS_inst : IBUFDS
         GENERIC MAP
         (
            DIFF_TERM    => TRUE,
            IBUF_LOW_PWR => FALSE,
            IOSTANDARD   => "LVDS_33"
            )
         PORT MAP
         (
            O  => L1_fromRDO(i),
            I  => L1_LVDS2FIBER_P(i),
            IB => L1_LVDS2FIBER_N(i)
            );
   END GENERATE L1_LVDS_IN;

----------------------------------------------------------------------------
----------------------------------------------------------------------------

   L3_LVDS_JTAG_IN : FOR i IN 0 TO 2 GENERATE
      L3_IBUFDS_JTAG_inst : IBUFDS
         GENERIC MAP
         (
            DIFF_TERM    => TRUE,
            IBUF_LOW_PWR => FALSE,
            IOSTANDARD   => "LVDS_33"
            )
         PORT MAP
         (
            O  => L3_misc_in(i),
            I  => L3_JTAG_P(i),
            IB => L3_JTAG_N(i)
            );
   END GENERATE L3_LVDS_JTAG_IN;


   L3_IBUFDS_START_inst : IBUFDS
      GENERIC MAP
      (
         DIFF_TERM    => TRUE,
         IBUF_LOW_PWR => FALSE,
         IOSTANDARD   => "LVDS_33"
         )
      PORT MAP
      (
         O  => L3_START_in,
         I  => L3_START_P,
         IB => L3_START_N
         );

   L3_IBUFDS_RSTB_inst : IBUFDS
      GENERIC MAP
      (
         DIFF_TERM    => TRUE,
         IBUF_LOW_PWR => FALSE,
         IOSTANDARD   => "LVDS_33"
         )
      PORT MAP
      (
         O  => L3_misc_in(4),
         I  => L3_RSTB_P,
         IB => L3_RSTB_N
         );

   L3_misc_out <= L3_misc_in(0) XOR L3_misc_in(1) XOR L3_misc_in(2) XOR L3_misc_in(3) XOR L3_misc_in(4);

   L3_OBUFDS_MARKER_inst : OBUFDS
      GENERIC MAP
      (
         IOSTANDARD => "LVDS_33"
         )
      PORT MAP
      (
         O  => L3_MARKER_P,
         OB => L3_MARKER_N,
         I  => L3_misc_out
         );


----------------------------------------------------------------------------
----------------------------------------------------------------------------

   L1_LVDS_JTAG_IN : FOR i IN 0 TO 2 GENERATE
      L1_IBUFDS_JTAG_inst : IBUFDS
         GENERIC MAP
         (
            DIFF_TERM    => TRUE,
            IBUF_LOW_PWR => FALSE,
            IOSTANDARD   => "LVDS_33"
            )
         PORT MAP
         (
            O  => L1_misc_in(i),
            I  => L1_JTAG_P(i),
            IB => L1_JTAG_N(i)
            );
   END GENERATE L1_LVDS_JTAG_IN;


   L1_IBUFDS_START_inst : IBUFDS
      GENERIC MAP
      (
         DIFF_TERM    => TRUE,
         IBUF_LOW_PWR => FALSE,
         IOSTANDARD   => "LVDS_33"
         )
      PORT MAP
      (
         O  => L1_START_in,
         I  => L1_START_P,
         IB => L1_START_N
         );

   L1_IBUFDS_RSTB_inst : IBUFDS
      GENERIC MAP
      (
         DIFF_TERM    => TRUE,
         IBUF_LOW_PWR => FALSE,
         IOSTANDARD   => "LVDS_33"
         )
      PORT MAP
      (
         O  => L1_misc_in(4),
         I  => L1_RSTB_P,
         IB => L1_RSTB_N
         );

   L1_misc_out <= L1_misc_in(0) XOR L1_misc_in(1) XOR L1_misc_in(2) XOR L1_misc_in(3) XOR L1_misc_in(4);

   L1_OBUFDS_MARKER_inst : OBUFDS
      GENERIC MAP
      (
         IOSTANDARD => "LVDS_33"
         )
      PORT MAP
      (
         O  => L1_MARKER_P,
         OB => L1_MARKER_N,
         I  => L1_misc_out
         );




   ALTERA_CONIG_DONE <= ALTERA_DCLK;
   ALTERA_nSTATUS    <= ALTERA_nCONFIG OR ALTERA_DATA0;


   SPARE (3 DOWNTO 2) <= (OTHERS => '0');
   SPARE (1 DOWNTO 0) <= s_mode;
END L2F_top_arch;

