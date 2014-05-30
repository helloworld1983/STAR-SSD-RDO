-- changed to a more reliable radout

LIBRARY IEEE;
USE IEEE.STD_Logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mesure_temperature IS
   PORT (
      reset_sys         : IN  STD_LOGIC;  -- reset (utilise le trstb)
      clock4mhz_fpga    : IN  STD_LOGIC;  -- oscillateur a 4 MHz -- 20090826 modifie
      temperature_in    : IN  STD_LOGIC;  -- bus 1-wire en entree
      temperature_out   : OUT STD_LOGIC;  -- bus 1-wire en sortie
      end_of_temp_conv  : OUT STD_LOGIC;  -- registre JTAG en sortie pour status
      temperature_value : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)  -- registre JTAG des valeurs de temperatures (3 valeurs codees sur 12 bits)
      );
END mesure_temperature;

ARCHITECTURE structurel OF mesure_temperature IS


   TYPE state_type IS (RST_MAX6575, SETUP, START_PULSE, START_PULSE_SYNC_WT, WT_LOW_T0, WT_HIGH_T0, WT_LOW_T1, WT_HIGH_T1, WT_LOW_T2, WT_HIGH_T2, WT_LOW_T3, WT_HIGH_T3, WT_CNT);
   SIGNAL state : state_type := RST_MAX6575;

   SIGNAL temperature0 : UNSIGNED (11 DOWNTO 0) := (OTHERS => '1');
   SIGNAL temperature1 : UNSIGNED (11 DOWNTO 0) := (OTHERS => '1');
   SIGNAL temperature2 : UNSIGNED (11 DOWNTO 0) := (OTHERS => '1');
   SIGNAL temperature3 : UNSIGNED (11 DOWNTO 0) := (OTHERS => '1');

   CONSTANT CNT_SIZE   : INTEGER                        := 22; --18;  -- size of the temperture measurement counter
   SIGNAL cnt          : UNSIGNED (CNT_SIZE-1 DOWNTO 0) := (others=>'0');
   CONSTANT RST_TIME   : INTEGER                        := (4 * 10000);  -- 10ms
--   CONSTANT START_TIME : INTEGER                        := (4 * 10);  -- 10us
--   CONSTANT START_TIME : INTEGER                        := (4 * 100);  -- 100us
   CONSTANT START_TIME : INTEGER                        := (4 * 500);  -- 500us
--   CONSTANT DONE_TIME  : INTEGER                        := (4 * 60000);  -- 60ms
   CONSTANT DONE_TIME  : INTEGER                        := (4 * 600000);  -- 600ms
   -- constants to ship a temperature sensor if it doen not respond
   -- 4 (MHz) * 400Kelvin * sensor scaling
   CONSTANT SKIP_T0    : INTEGER                        := (4 * 400 * 5);
   CONSTANT SKIP_T1    : INTEGER                        := (4 * 400 * 20);
   CONSTANT SKIP_T2    : INTEGER                        := (4 * 400 * 40);
   CONSTANT SKIP_T3    : INTEGER                        := (4 * 400 * 80);

   -- synchronize the temperture in signal
   SIGNAL sTemp_in            : STD_LOGIC;
   SIGNAL temperature_in_sync : STD_LOGIC;

BEGIN


   PROCESS (clock4mhz_fpga, reset_sys) IS
   BEGIN  -- PROCESS
      IF reset_sys = '0' THEN           -- asynchronous reset (active low)
         state           <= RST_MAX6575;
         cnt             <= (OTHERS => '0');
         temperature_out <= 'Z';
      ELSIF clock4mhz_fpga'EVENT AND clock4mhz_fpga = '1' THEN  -- rising clock edge
         cnt <= cnt + 1;
         CASE state IS
            WHEN RST_MAX6575 =>
               temperature_out <= 'Z'; --'0';
               IF cnt >= RST_TIME THEN
                  cnt   <= (OTHERS => '0');
                  state <= SETUP;
               END IF;
            WHEN SETUP =>
               temperature_out <= 'Z';
               IF cnt >= RST_TIME THEN
                  cnt   <= (OTHERS => '0');
                  state <= START_PULSE;
               END IF;
            WHEN START_PULSE =>
               temperature_out <= '0';
               IF cnt >= START_TIME THEN
                  state <= START_PULSE_SYNC_WT;
               END IF;
            WHEN START_PULSE_SYNC_WT =>
               -- we synchronize the input signel. It is still low at this time
               -- and woudl trigger the LOW test of WT_LOW_T0
               temperature_out <= 'Z';
               IF cnt >= (START_TIME + 64) THEN
                  state <= WT_LOW_T0;
               END IF;
            WHEN WT_LOW_T0 =>
               temperature_out <= 'Z';
               IF sTemp_in = '0' THEN
                  temperature0 <= cnt (12 DOWNTO 1);
                  state        <= WT_HIGH_T0;
               ELSIF cnt >= SKIP_T0 THEN
                  temperature0 <= (OTHERS => '1');
                  state        <= WT_LOW_T1;
               END IF;
            WHEN WT_HIGH_T0 =>
               temperature_out <= 'Z';
               IF sTemp_in = '1' THEN
                  state <= WT_LOW_T1;
               END IF;
            WHEN WT_LOW_T1 =>
               temperature_out <= 'Z';
               IF sTemp_in = '0' THEN
                  temperature1 <= cnt (14 DOWNTO 3);
                  state        <= WT_HIGH_T1;
               ELSIF cnt >= SKIP_T1 THEN
                  temperature1 <= (OTHERS => '1');
                  state        <= WT_LOW_T2;
               END IF;
            WHEN WT_HIGH_T1 =>
               temperature_out <= 'Z';
               IF sTemp_in = '1' THEN
                  state <= WT_LOW_T2;
               END IF;
            WHEN WT_LOW_T2 =>
               temperature_out <= 'Z';
               IF sTemp_in = '0' THEN
                  temperature2 <= cnt (15 DOWNTO 4);
                  state        <= WT_HIGH_T2;
               ELSIF cnt >= SKIP_T2 THEN
                  temperature2 <= (OTHERS => '1');
                  state        <= WT_LOW_T3;
               END IF;
            WHEN WT_HIGH_T2 =>
               temperature_out <= 'Z';
               IF sTemp_in = '1' THEN
                  state <= WT_LOW_T3;
               END IF;
            WHEN WT_LOW_T3 =>
               temperature_out <= 'Z';
               IF sTemp_in = '0' THEN
                  temperature3 <= cnt (16 DOWNTO 5);
                  state        <= WT_HIGH_T3;
               ELSIF cnt >= SKIP_T3 THEN
                  temperature3 <= (OTHERS => '1');
                  state        <= WT_CNT;
               END IF;
            WHEN WT_HIGH_T3 =>
               temperature_out <= 'Z';
               IF sTemp_in = '1' THEN
                  state <= WT_CNT;
               END IF;
            WHEN WT_CNT =>
               temperature_out <= 'Z';
               IF cnt >= DONE_TIME THEN
                  cnt   <= (OTHERS => '0');
                  state <= RST_MAX6575;
               END IF;
            WHEN OTHERS =>
               NULL;
         END CASE;

         -- synchronize the temperture in reading
         sTemp_in            <= temperature_in_sync;
         temperature_in_sync <= temperature_in;
      END IF;
   END PROCESS;

   temperature_value (11 DOWNTO 0)  <= STD_LOGIC_VECTOR (temperature0);
   temperature_value (23 DOWNTO 12) <= STD_LOGIC_VECTOR (temperature1);
   temperature_value (35 DOWNTO 24) <= STD_LOGIC_VECTOR (temperature2);
   temperature_value (47 DOWNTO 36) <= STD_LOGIC_VECTOR (temperature3);

   end_of_temp_conv <= '0';

END structurel;