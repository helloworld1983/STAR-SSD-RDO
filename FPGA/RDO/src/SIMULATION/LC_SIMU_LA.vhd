----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
--
-- Create Date:   16:39:57 07/30/2013
-- Design Name:   
-- Module Name:   LC_SIMU_LA - LC_SIMU_LA_Arch
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Descroption
-- 09/11/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL;
USE std.textio.ALL;   
Use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
ENTITY LC_SIMU_LA IS
PORT (
		CLK40             : IN    STD_LOGIC;
		RST					: IN 	  STD_LOGIC;
		LC_SERIAL 			: IN    std_logic_vector (5 downto 0);
      -- Fiber 
      DES_D          : OUT    STD_LOGIC_VECTOR (23 DOWNTO 0);
      SER_D          : IN   STD_LOGIC_VECTOR (23 DOWNTO 0);
      DES_RCLK       : OUT    STD_LOGIC;
      SER_TCLK       : IN   STD_LOGIC;
      LED            : IN   STD_LOGIC_VECTOR (3 DOWNTO 0);
      SER_DEN        : IN   STD_LOGIC;
      SER_TPWDNB     : IN   STD_LOGIC;
      DES_RPWDNB     : IN   STD_LOGIC;
      DES_PASS       : OUT    STD_LOGIC;
      DES_LOCK       : OUT    STD_LOGIC;
      DES_SLEW       : IN   STD_LOGIC;
      DES_BISTM      : IN   STD_LOGIC;
      DES_BISTEN     : IN   STD_LOGIC;
      DES_REN        : IN   STD_LOGIC;
      DES_PTOSEL     : IN   STD_LOGIC;
      TX_FAULT       : OUT    STD_LOGIC;
      TX_DISABLE     : IN   STD_LOGIC;
      MOD_DEF        : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      RX_LOSS        : OUT    STD_LOGIC);
END LC_SIMU_LA;
 
ARCHITECTURE LC_SIMU_LA_Arch OF LC_SIMU_LA IS 

--INPUTS OF THE FIBER MODULE FROM THE LADDER CARD TO THE RDO SYSTEM
	signal PAYLOAD	: std_logic_vector (21 downto 0) := (OTHERS => '0');
	signal TDO		: std_logic := '0';					--RETURN FROM FPGA
	signal CONFIG_DONE	: std_logic := '0';			--RETURN FROM FPGA
	signal NSTATUS	: std_logic := '0';
	signal DATA_READY : std_logic := '0';
	signal HYBRID_POWER : std_logic_vector (15 downto 0) := (OTHERS => '0');
	signal LADDER_BUSY : std_logic := '0';
	signal TEMP_S0 : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal TEMP_S1 : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal TEMP_S2 : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal TEMP_S3 : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal NBR_HOLD : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal NBR_TEST : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal NBR_TOKEN : std_logic_vector (11 downto 0) := (OTHERS => '0');
	signal NBR_ABORT : std_logic_vector (11 downto 0) := (OTHERS => '0');
	--
   signal PASS 	: std_logic := '0';
   signal RCLK 	: std_logic := '0';
   signal LOCK 	: std_logic := '0';
   
--OUTPUTS TO THE LADDER CARD
   --SLOW CONTROL
	signal TDI 		: std_logic := '0';
	signal TRST		: std_logic := '0';
	signal TMS 		: std_logic := '0';
	signal TCK 		: std_logic := '0';
	--TRIGGER
	signal HOLD		: std_logic := '0';
	signal TEST		: std_logic := '0';
	signal TOKEN	: std_logic := '0';
	--ADDRESS
	signal ADDRESS	: std_logic_vector (2 downto 0) := (OTHERS => '0');
	--MODE
	signal MODE		: std_logic := '0';
	--SPARE
	signal SPARE	: std_logic_vector (8 downto 0) := (OTHERS => '0');
	--FPGA CONFIGURATION
	signal INIT_SWITCH	: std_logic := '0';
	signal DATA0			: std_logic := '0';
	signal NCONFIG			: std_logic := '0';
	signal DCLK				: std_logic := '0';
	--
   signal DEN : std_logic:= '0';
   signal TCLK : std_logic:= '0';
   signal TPWDNB : std_logic:= '0';
   signal RPWDNB : std_logic:= '0';
   signal SLEW : std_logic:= '0';
   signal BISTM : std_logic:= '0';
   signal BISTEN : std_logic:= '0';
   signal REN : std_logic:= '0';
   signal PTOSEL : std_logic:= '0';
---------------------------------------------------------------------------
---------------------------------------------------------------------------

	type state_type IS (st_wait4hold, st_wait4token, st_abort, st_end, st_acquisition, st_acquisition1, st_acquisition2);
   signal trigger_state : state_type;
	
	signal sCLK40 : std_logic := '0';
	signal sRST	: std_logic := '0';
	signal reading : std_logic := '0';
	signal REG : std_logic := '0';
	signal busy : std_logic := '0';
	signal cnt : std_logic_vector (2 downto 0) := b"000";
   -- Clock period definitions
   constant CLK40_period : time := 25 ns;
	
	signal sCnt_Conf : INTEGER := 0;
	signal sCnt_readfile : INTEGER := 0;
	
BEGIN
 
	sCLK40 <= CLK40;												--LA sep 12 un commented to run simulation
   sRST   <= RST;
--	sCLK40 <= NOT sCLK40 AFTER 12.5 NS;
--   sRST   <= '0'        AFTER 100 NS;
	DES_RCLK <= CLK40;
-----------------------------------------------------------------------------------
--temp
-----------------------------------------------------------------------------------
	
	TEMP_S0 <= x"210";
	TEMP_S1 <= x"543";
	TEMP_S2 <= x"876";
	TEMP_S3 <= x"BA9";
---------------------------------------------------------------------------------------------------
-- reading input values in the rising edge
---------------------------------------------------------------------------------------------------
process (RST, SER_TCLK) is	
begin
	if RST = '1' then 
	
		TDI			<= '0';	
		TRST			<= '0';	
		TMS 			<= '0';	
		TCK 			<= '0';	
		HOLD			<= '0';	
		TEST			<= '0';	
		TOKEN			<= '0';
		ADDRESS 		<= (others => '0');
		MODE			<= '0';	
		SPARE			<= (others => '0');	
		INIT_SWITCH	<= '0';	
		DATA0			<= '0';	
		NCONFIG		<= '0';	
		DCLK			<= '0';	
		
	elsif rising_edge(SER_TCLK) then 	
	
		TDI			<=	SER_D (0);
		TRST			<=	SER_D (1);
		TMS 			<=	SER_D (2);
		TCK 			<=	SER_D (3);
		HOLD			<=	SER_D (4);
		TEST			<=	SER_D (5);
		TOKEN			<=	SER_D (6);
		ADDRESS		<=	SER_D (9 DOWNTO 7);
		MODE			<=	SER_D (10);
		SPARE			<=	SER_D (19 DOWNTO 11);
		INIT_SWITCH	<=	SER_D (20);
		DATA0			<=	SER_D (21);
		NCONFIG		<=	SER_D (22);
		DCLK			<=	SER_D (23);
	end if;
end process; 
---------------------------------------------------------------------------------------------------
-- updating output values in the falling edge sCLK40 is the same DES_RCLK
---------------------------------------------------------------------------------------------------
process (RST, sCLK40) is  
begin
	if RST = '1' then 
	
		DES_D (23) 	<= '0';
		DES_D (22) 	<= '0';
		DES_D (21 DOWNTO 0) <= (OTHERS => '0');
			
		
	elsif falling_edge(sCLK40) then 	
	
		DES_D (23) 	<= NSTATUS;
		if INIT_SWITCH = '0' then
			DES_D (22) 	<= CONFIG_DONE ;
		else 
			DES_D (22) <= TDO;
		end if;
		DES_D (21 DOWNTO 0) <= PAYLOAD;
		
	end if;
end process; 	
	
---------------------------------------------------------------------------------------------------
--JTAG one delay
---------------------------------------------------------------------------------------------------
process (TCK) is
begin
	if rising_edge(TCK) then
		REG <= TDI;
		TDO <= REG;
	end if;
end process;
---------------------------------------------------------------------------------------------------
--Trigger process
---------------------------------------------------------------------------------------------------
process(HOLD, TOKEN, sCLK40) is 
begin
	if RST = '1' then
		trigger_state <= st_wait4hold;
		NBR_HOLD <= (OTHERS => '0');
		NBR_TOKEN <= (OTHERS => '0');
		NBR_ABORT <= (OTHERS => '0');
		trigger_state <= st_wait4hold;
   else
		case trigger_state is
		
			when st_wait4hold =>  
				
				if rising_edge (HOLD) then 
					trigger_state <= st_wait4token;
					NBR_HOLD <= NBR_HOLD + '1' ;
				end if;
				
			when st_wait4token => 
				
				if HOLD = '1' then
					if rising_edge (TOKEN) then 
						trigger_state <= st_acquisition;
						NBR_TOKEN <= NBR_TOKEN + '1' ;
					end if;
				else
					trigger_state <= st_abort;
				end if;
				
			when st_acquisition =>
				DATA_READY <= '1';
				if HOLD = '1' then 
					trigger_state <= st_acquisition1;
				else
					trigger_state <= st_abort;
				end if;
				
			when st_acquisition1 =>
				if HOLD = '1' then 
					trigger_state <= st_acquisition2;
				else
					trigger_state <= st_abort;
				end if;
			when st_acquisition2 =>
				if HOLD = '1' then 
					if busy = '0' then 
						trigger_state <= st_end;
						DATA_READY <= '0';
					end if;
				else
					trigger_state <= st_abort;
				end if;
				
			when st_end =>
				
				if HOLD = '0' then  	
					trigger_state <= st_wait4hold;
				end if;
			
			when st_abort =>
			   DATA_READY <= '0';
				if busy = '0' then 
					NBR_ABORT <= NBR_ABORT + '1' ;
					trigger_state <= st_wait4hold;
				end if;
			
			when others =>
				trigger_state <= st_wait4hold;

    end case;
  end if;
end process;	
---------------------------------------------------------------------------------------------------
--test counter process
---------------------------------------------------------------------------------------------------
process (RST, TEST) is
begin
	if RST = '1' then
		NBR_TEST <= (others => '0');
	elsif rising_edge(TEST) then
		NBR_TEST <= NBR_TEST + '1' ;
	end if;
end process; 

---------------------------------------------------------------------------------------------------
--DATA OUT
---------------------------------------------------------------------------------------------------
process (RST, sCLK40, DATA_READY) is 
		FILE data_file_rd : TEXT;
      VARIABLE l    : LINE;
		VARIABLE	f_status : FILE_OPEN_STATUS;
      VARIABLE triggerdata : STD_LOGIC_VECTOR (19 DOWNTO 0);
begin 
	if rising_edge(DATA_READY) then 
		cnt <= b"000";
		file_open(f_status, data_file_rd, "triggerdata.txt", read_mode);
		sCnt_readfile <= 0;
	end if;
	if RST = '1' then 
		cnt <= b"000";
	elsif rising_edge(sCLK40) then
		if DATA_READY = '1' then 
			if sCnt_readfile < 6143 then 
				readline(data_file_rd, l);
				hread(l, triggerdata);
				busy <= '1';
				sCnt_readfile <= sCnt_readfile + 1;
			else 
				busy <= '0';
				file_close(data_file_rd);
			end if;
			case cnt is 
				when b"000" | b"100" =>
					PAYLOAD <= DATA_READY & '1' & triggerdata;
				when others =>
					PAYLOAD <= DATA_READY & '0' & triggerdata;
			end case; 
		else
			case cnt is 
				when b"000" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (1 downto 0) & LADDER_BUSY & cnt & TEMP_S0;
				when b"001" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (3 downto 2) & LADDER_BUSY & cnt & TEMP_S1;
				when b"010" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (5 downto 4) & LADDER_BUSY & cnt & TEMP_S2;
				when b"011" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (7 downto 6) & LADDER_BUSY & cnt & TEMP_S3;
				when b"100" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (9 downto 8) & LADDER_BUSY & cnt & NBR_HOLD;
				when b"101" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (11 downto 10) & LADDER_BUSY & LC_SERIAL (5 downto 3) & NBR_TEST;
				when b"110" =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (13 downto 12) & LADDER_BUSY & LC_SERIAL (2 downto 0) & NBR_TOKEN;
				when others =>
					PAYLOAD <= DATA_READY & cnt & HYBRID_POWER (15 downto 14) & LADDER_BUSY & ADDRESS & NBR_ABORT;
			end case; 
		end if;
		cnt <= cnt + '1';
		
	end if; 
end process;
-------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--CONFIG PROCESS

	NSTATUS <= NCONFIG;
	
	PROCESS (DCLK, NCONFIG) IS
		BEGIN 
			IF NCONFIG = '0' THEN 
				sCnt_Conf <= 0;
			ELSIF rising_edge(DCLK) THEN
				IF sCnt_Conf < 8 THEN
					sCnt_Conf <= sCnt_Conf + 1;
				ELSE
					sCnt_Conf <= 8;
				END IF;
			END IF;
	END PROCESS;
	CONFIG_DONE <= '1' WHEN sCnt_Conf > 5 ELSE '0';
			



END LC_SIMU_LA_Arch;
