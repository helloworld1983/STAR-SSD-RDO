-- fiber mapping
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fiber IS
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
END ENTITY fiber;


ARCHITECTURE fiber_arch OF fiber IS

   COMPONENT des_sync_fifo
      PORT (
         rst           : IN  STD_LOGIC;
         wr_clk        : IN  STD_LOGIC;
         rd_clk        : IN  STD_LOGIC;
         din           : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
         wr_en         : IN  STD_LOGIC;
         rd_en         : IN  STD_LOGIC;
         dout          : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
         full          : OUT STD_LOGIC;
         empty         : OUT STD_LOGIC;
         rd_data_count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
         );
   END COMPONENT;

   SIGNAL sTCLK   : STD_LOGIC;
   SIGNAL cnt_rst : INTEGER RANGE 0 TO 34;

   TYPE state_type IS (RESET, RUN);
   SIGNAL state : state_type;

   SIGNAL RCLKold   : STD_LOGIC;
   SIGNAL Dsync0    : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL RCLKsync0 : STD_LOGIC;
   SIGNAL Dsync1    : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL RCLKsync1 : STD_LOGIC;

   SIGNAL D_FIFO_in : STD_LOGIC_VECTOR (23 DOWNTO 0);
   SIGNAL FIFO_WE   : STD_LOGIC;

   SIGNAL rd_data_count : STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL FIFO_RE       : STD_LOGIC;

BEGIN  -- ARCHITECTURE fiber_test_arch

   DEN    <= '1';
   TPWDNB <= '1';

   RPWDNB <= '1';
   SLEW   <= '0';
   BISTEN <= '0';
   BISTM  <= '0';
   REN    <= '1';
   PTOSEL <= '1';

   TX_DISABLE <= '0';
   MOD_DEF    <= (OTHERS => 'Z');

   PROCESS (CLK80, RST) IS
   BEGIN  -- PROCESS
      IF RST = '1' THEN                 -- asynchronous reset (active high)
         sTCLK <= '0';
      ELSIF rising_edge(CLK80) THEN     -- rising clock edge
         IF state = RESET THEN
            sTCLK <= '0';
            TCLK  <= sTCLK;
         ELSE
            sTCLK <= NOT sTCLK;
            TCLK  <= sTCLK;
         END IF;
      END IF;
   END PROCESS;


   TX : PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS TX
      IF RST = '1' THEN                 -- asynchronous reset (active high)
         cnt_rst <= 0;
         state   <= RESET;
      ELSIF rising_edge(CLK40) THEN     -- rising clock edge
         D_TX <= sD_TX;
         CASE state IS
            WHEN RESET =>
               cnt_rst <= cnt_rst + 1;
               IF cnt_rst > 32 THEN
                  state <= RUN;
               END IF;
            WHEN RUN =>
               -- wait here forever
               state <= RUN;
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS TX;

   RX : PROCESS (CLK200, RST) IS
   BEGIN  -- PROCESS RX
      IF RST = '1' THEN                 -- asynchronous reset (active high)
         FIFO_WE <= '0';
      ELSIF rising_edge(CLK200) THEN    -- rising clock edge
         Dsync0    <= D_RX;
         Dsync1    <= Dsync0;
         RCLKsync0 <= RCLK;
         RCLKsync1 <= RCLKsync0;

         RCLKold <= RCLKsync1;
         IF RCLKold = '0' AND RCLKsync1 = '1' THEN
            D_FIFO_in <= Dsync1;
            FIFO_WE   <= '1';
         ELSE
            FIFO_WE <= '0';
         END IF;
      END IF;
   END PROCESS RX;

   TC(0) <= RCLKold;

   des_sync_fifo_inst : des_sync_fifo
      PORT MAP (
         rst           => RST,
         wr_clk        => CLK200,
         rd_clk        => CLK40,
         din           => D_FIFO_in,
         wr_en         => FIFO_WE,
         rd_en         => FIFO_RE,
         dout          => sD_RX,
         full          => OPEN,
         empty         => OPEN,
         rd_data_count => rd_data_count
         );

   PROCESS (CLK40, RST)
   BEGIN
      IF RST = '1' THEN
         FIFO_RE <= '0';
      ELSIF rising_edge(CLK40) THEN
         IF UNSIGNED(rd_data_count) > 10 THEN
            FIFO_RE <= '1';
         ELSIF UNSIGNED(rd_data_count) < 3 THEN
            FIFO_RE <= '0';
         ELSE
            FIFO_RE <= FIFO_RE;
         END IF;
      END IF;
   END PROCESS;

   STATUS_FF : PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS STATUS_FF
      IF RST = '1' THEN                 -- asynchronous reset (active high)

      ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
         status (0) <= MOD_DEF (0);
         status (1) <= TX_FAULT;
         status (2) <= RX_LOSS;
         status (3) <= LOCK;
      END IF;
   END PROCESS STATUS_FF;

END ARCHITECTURE fiber_arch;

