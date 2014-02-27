-- rudimentary check of the data format
-- this assumes the constand ADC value LC code is loaded

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY debud_data_verify IS
   PORT (
      CLK   : IN STD_LOGIC;
      rdreq : IN STD_LOGIC;
      Din   : IN STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
END ENTITY debud_data_verify;

ARCHITECTURE debud_data_verify_arch OF debud_data_verify IS

component chipscope_icon_siu
  PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	 );
end component;

component chipscope_ila_siu
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CLK : IN STD_LOGIC;
    TRIG0 : IN STD_LOGIC_VECTOR(53 DOWNTO 0)
	 );
end component;

signal CONTROL0 : STD_LOGIC_VECTOR(35 DOWNTO 0);
signal TRIG0 : STD_LOGIC_VECTOR(53 DOWNTO 0);

   SIGNAL error_flag            : STD_LOGIC := '0';
   ATTRIBUTE KEEP               : STRING;
   ATTRIBUTE KEEP OF error_flag : SIGNAL IS "TRUE";

   SIGNAL skip_cnt  : INTEGER RANGE 0 TO 15;
   SIGNAL data_cnt  : INTEGER RANGE 0 TO 8000;
   SIGNAL fiber_cnt : INTEGER RANGE 0 TO 8;
	
--	signal s_rdreq : std_logic := '0';


   TYPE state_type IS (IDLE, SKIP_HEADER, CHECK_FIBER_MARKER, SKIP_FIBER_HEADER, CHECK_FIBER_DATA);
   SIGNAL state : state_type := IDLE;

   TYPE CONST_DATA_TYPE IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
   CONSTANT EXPECTED_DATA : CONST_DATA_TYPE := (x"09014010",
                                                x"150440D0",
                                                x"21074190",
                                                x"2D0A4250",
                                                x"390D4310",
                                                x"050043D0",
                                                x"11034090",
                                                x"1D064150",
                                                x"29094210",
                                                x"350C42D0",
                                                x"010F4390",
                                                x"0D024050",
                                                x"19054110",
                                                x"250841D0",
                                                x"310B4290",
                                                x"3D0E4350");

BEGIN  -- ARCHITECTURE debud_data_verify_arch

   PROCESS (CLK) IS
   BEGIN  -- PROCESS
      IF CLK'EVENT AND CLK = '1' THEN   -- rising clock edge
--	   s_rdreq <= rdreq;
         IF rdreq = '1' THEN
            -- only act on read requests
            CASE state IS
               WHEN IDLE =>
                  error_flag <= '0';
                  skip_cnt   <= 1;
                  fiber_cnt  <= 0;
                  IF Din = x"AAAAAAAA" THEN
                     state <= SKIP_HEADER;
                  END IF;
               WHEN SKIP_HEADER =>
                  -- count the header bytes
                  IF skip_cnt >= 7 THEN
                     state <= CHECK_FIBER_MARKER;
                  ELSE
                     skip_cnt <= skip_cnt + 1;
                     state    <= SKIP_HEADER;
                  END IF;
               WHEN CHECK_FIBER_MARKER =>
                  skip_cnt  <= 1;
                  fiber_cnt <= fiber_cnt + 1;
                  IF Din = x"DDDDDDDD" THEN
                     -- we got a match
                     state <= SKIP_FIBER_HEADER;
                  ELSE
                     error_flag <= '1';
                     state      <= IDLE;
                  END IF;
               WHEN SKIP_FIBER_HEADER =>
                  data_cnt <= 0;
                  IF skip_cnt = 9 THEN
                     state <= CHECK_FIBER_DATA;
                  ELSE
                     skip_cnt <= skip_cnt + 1;
                     state    <= SKIP_FIBER_HEADER;
                  END IF;
               WHEN CHECK_FIBER_DATA =>
                  IF Din /= EXPECTED_DATA(data_cnt MOD 16) THEN
                     error_flag <= '1';
                     state      <= IDLE;
                  END IF;
                  data_cnt <= data_cnt + 1;
                  IF data_cnt = (2**12-1) THEN
                     IF fiber_cnt >= 8 THEN
                        state <= IDLE;
                     ELSE
                        state <= CHECK_FIBER_MARKER;
                     END IF;
                  END IF;
               WHEN OTHERS =>
                  state <= IDLE;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
	
	chipscope_icon_siu_inst : chipscope_icon_siu
  PORT map (
    CONTROL0 => CONTROL0
	 );

chipscope_ila_siu_inst : chipscope_ila_siu
  PORT map (
    CONTROL => CONTROL0,
    CLK => CLK,
    TRIG0 => TRIG0
	 );
	 
    TRIG0 (0) <= error_flag;
	 TRIG0 (1) <= rdreq;
	 TRIG0 (2) <= '1' when state = IDLE else '0';
	 TRIG0 (3) <= '1' when state = SKIP_HEADER else '0';
	 TRIG0 (4) <= '1' when state = CHECK_FIBER_MARKER else '0';
	 TRIG0 (5) <= '1' when state = SKIP_FIBER_HEADER else '0';
	 TRIG0 (6) <= '1' when state = CHECK_FIBER_DATA else '0';
    TRIG0 (7) <= '0';
	 TRIG0 (39 downto 8) <= Din;
	 TRIG0 (53 downto 40) <= std_logic_vector (to_unsigned(data_cnt, 14));

END ARCHITECTURE debud_data_verify_arch;
