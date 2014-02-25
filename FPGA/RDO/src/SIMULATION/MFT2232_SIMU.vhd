--------------------------------------------------------------------------------
-- Company: LBNL
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
--
-- Create Date:    14:42:12 07/26/2013
-- Design Name:   
-- Module Name:    MFT2232_SIMU - MFT2232_SIMU_Arch
-- Project Name: 	 STAR HFT SSD
-- Target Devices: XILINX Virtex 6 (XC6VLX240T-FF1759)
-- Tool versions:  ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Date              Version         Author          Description
-- 07/26/2013        1.0             Luis Ardila     File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL;
USE std.textio.ALL;  
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.VComponents.all;
 
ENTITY MFT2232_SIMU IS
	PORT(
		---------------------------------------------------------------------------
      -- Motherboard FT2232H adapter board ("MFT")
      ---------------------------------------------------------------------------
      MFT_PWREN_n       : OUT    STD_LOGIC;
      MFT_SUSPEND_n     : OUT    STD_LOGIC;
      MFT_RESET_n       : IN   STD_LOGIC;
      -- 
      MFT_EEDATA        : OUT    STD_LOGIC;
      MFT_EECS          : OUT    STD_LOGIC;
      MFT_EECLK         : OUT    STD_LOGIC;
      -- 
      MFTA_D            : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      MFTB_D            : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      -- 
      MFTA_RXF_n        : OUT    STD_LOGIC;
      MFTA_TXE_n        : OUT    STD_LOGIC;
      MFTA_RD_n         : IN   STD_LOGIC;
      MFTA_WR_n         : IN   STD_LOGIC;
      MFTA_SIWU         : IN   STD_LOGIC;
      MFTA_CLKOUT       : OUT    STD_LOGIC;
      MFTA_OE_n         : IN   STD_LOGIC;
      MFTA_C7           : OUT    STD_LOGIC;
      -- 
      MFTB_RXF_n        : OUT    STD_LOGIC;
      MFTB_TXE_n        : OUT    STD_LOGIC;
      MFTB_RD_n         : IN   STD_LOGIC;
      MFTB_WR_n         : IN   STD_LOGIC;
      MFTB_SIWU         : IN   STD_LOGIC;
      MFTB_CLKOUT       : OUT    STD_LOGIC;
      MFTB_OE_n         : IN   STD_LOGIC;
      MFTB_C7           : OUT    STD_LOGIC;
      --  
      MFT_SPARE         : OUT    STD_LOGIC_VECTOR (32 DOWNTO 1));
END MFT2232_SIMU;
 
ARCHITECTURE MFT2232_SIMU_Arch OF MFT2232_SIMU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
--    COMPONENT M_FT2232H
--    PORT(
--         CLK : IN  std_logic;
--         RESET : IN  std_logic;
--         D_in : IN  std_logic_vector(7 downto 0);
--         D_out : OUT  std_logic_vector(7 downto 0);
--         D_T : OUT  std_logic;
--         RXF_n : IN  std_logic;
--         TXE_n : IN  std_logic;
--         RD_n : OUT  std_logic;
--         WR_n : OUT  std_logic;
--         SIWU : OUT  std_logic;
--         CLKOUT : IN  std_logic;
--         OE_n : OUT  std_logic;
--         FIFO_Q : IN  std_logic_vector(35 downto 0);
--         FIFO_EMPTY : IN  std_logic;
--         FIFO_RDREQ : OUT  std_logic;
--         FIFO_RDCLK : OUT  std_logic;
--         CMD_FIFO_Q : OUT  std_logic_vector(35 downto 0);
--         CMD_FIFO_EMPTY : OUT  std_logic;
--         CMD_FIFO_RDREQ : IN  std_logic
--        );
--    END COMPONENT;
	 
--	  -- FIFO for USB event data
--  COMPONENT fifo36x512
--    PORT (
--      rst    : IN  std_logic;
--      wr_clk : IN  std_logic;
--      rd_clk : IN  std_logic;
--      din    : IN  std_logic_vector(35 DOWNTO 0);
--      wr_en  : IN  std_logic;
--      rd_en  : IN  std_logic;
--      dout   : OUT std_logic_vector(35 DOWNTO 0);
--      full   : OUT std_logic;
--      empty  : OUT std_logic
--      );
--  END COMPONENT;
    
	TYPE state_type IS (STARTUP, HEADER, RD_FILE, TRANSMIT1, TRANSMIT2, NEXTWORD1, NEXTWORD2, WT_RD_n, ST_END, WT_WR_n_H, WT_WR_n_L, WT_WR_n, RECV1, WT1, WT2, WT3, WT4);
   SIGNAL state : state_type;
	
	SIGNAL zero				: std_logic 		:= '0';
	SIGNAL sLatchData    : std_logic 		:= '0';
   SIGNAL byteCtr       : integer RANGE 0 TO 4;
	SIGNAL lineCnt       : integer RANGE 0 TO 255;
	SIGNAL writing 		: std_logic 		:= '0';
   --Inputs
   signal CLOCK 				: std_logic 	:= '1';
   signal RESET				: std_logic 	:= '1';
   signal D_in 				: std_logic_vector(7 downto 0) := (others => '0');
   signal RXF_n 				: std_logic 	:= '1';
   signal TXE_n 				: std_logic 	:= '1';
   signal CLKOUT 				: std_logic 	:= '0';
-- signal FIFO_Q 				: std_logic_vector(35 downto 0) := (others => '0');
-- signal FIFO_EMPTY 		: std_logic		:= '0';
-- signal CMD_FIFO_RDREQ	: std_logic 	:= '0';

 	--Outputs
   signal D_out 				: std_logic_vector(7 downto 0) := (others => '0');
-- signal D_T 					: std_logic		:= '0';
   signal RD_n 				: std_logic		:= '0';
   signal WR_n 				: std_logic		:= '0';
   signal SIWU 				: std_logic		:= '0';
   signal OE_n 				: std_logic		:= '0';
	signal n_OE_n 				: std_logic		:= '0';
-- signal FIFO_RDREQ 		: std_logic		:= '0';
--	signal FIFO_RDCLK 		: std_logic		:= '0';
--	signal CMD_FIFO_Q 		: std_logic_vector(35 downto 0) := (others => '0');
--	signal CMD_FIFO_EMPTY	: std_logic		:= '0';
   signal TOcnt : integer := 0;
   -- Clock period definitions
   constant CLOCK_period : time := 25 ns;
	SIGNAL usbdata2pc 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
 
BEGIN

	RESET   			<= '0'        AFTER 1000 NS;
	
	-------------------------------------------------------------------------
	--SIGNAL MASKING
	------------------------------------------------------------------------
	zero <= '0';
	MFTA_RXF_n     <= RXF_n;   
	MFTA_TXE_n     <= TXE_n;
	RD_n 				<= MFTA_RD_n;		--INPUT
	WR_n				<= MFTA_WR_n;		--INPUT
	SIWU				<= MFTA_SIWU;		--INPUT
	MFTA_CLKOUT    <= zero;				--NOT USED only for sync mode in FTDI2232
	OE_n				<= MFTA_OE_n;		--INPUT
	n_OE_n			<= not MFTA_OE_n;
	MFTA_C7        <= zero;				--NOT USED
	
	MFT_PWREN_n    <= zero;				--NOT USED  
   MFT_SUSPEND_n	<= zero;				--NOT USED
	
	MFT_EEDATA		<= zero;				--NOT USED        
	MFT_EECS			<= zero;				--NOT USED          
	MFT_EECLK 		<= zero;				--NOT USED 
	
	MFTB_RXF_n  	<= zero;				--NOT USED     
	MFTB_TXE_n  	<= zero;				--NOT USED      
	MFTB_CLKOUT  	<= zero;				--NOT USED     
	MFTB_C7			<= zero;				--NOT USED
	MFT_SPARE 		<= (OTHERS => '0');				--NOT USED
	
	-- bi-directional data signals:
   mfta_bufd : FOR i IN 0 TO 7 GENERATE  -- A port
      IOBUF_mfta_di : IOBUF
         PORT MAP (
            O  => D_out(i),        -- Buffer output
            IO => MFTA_D(i),  -- Buffer inout port (connect directly to top-level port)
            I  => D_in(i),       -- Buffer input
            T  => n_OE_n   -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE mfta_bufd;
	
	
	mftb_bufd : FOR i IN 0 TO 7 GENERATE  -- B port
      IOBUF_mftb_di : IOBUF
         PORT MAP (
            O  => OPEN,        -- Buffer output
            IO => MFTB_D(i),  -- Buffer inout port (connect directly to top-level port)
            I  => '0',       -- Buffer input
            T  => '1'   -- 3-state enable signal, 1=input, 0=output
            );
   END GENERATE mftb_bufd;
	-----------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
	
	
	-- Instantiate the Unit Under Test (UUT)
--   uut: M_FT2232H 
--	PORT MAP (
--          CLK => CLOCK,
--          RESET => RESET,
--          D_in => D_in,
--          D_out => D_out,
--          D_T => D_T,
--          RXF_n => RXF_n,
--          TXE_n => TXE_n,
--          RD_n => RD_n,
--          WR_n => WR_n,
--          SIWU => SIWU,
--          CLKOUT => CLKOUT,
--          OE_n => OE_n,
--          FIFO_Q => CMD_FIFO_Q,
--          FIFO_EMPTY => FIFO_EMPTY,
--          FIFO_RDREQ => FIFO_RDREQ,
--          FIFO_RDCLK => FIFO_RDCLK,
--          CMD_FIFO_Q => CMD_FIFO_Q,
--          CMD_FIFO_EMPTY => CMD_FIFO_EMPTY,
--          CMD_FIFO_RDREQ => FIFO_RDREQ
--        );
		  
--	-- jtag fifo
--	jtag_fifo : fifo36x512
--	PORT MAP (
--			rst    => RESET,
--			wr_clk => CLOCK,
--			rd_clk => FIFO_RDCLK,
--			din    => CMD_FIFO_Q,
--			wr_en  => CMD_FIFO_RDREQ,
--			rd_en  => FIFO_RDREQ,
--			dout   => FIFO_Q,
--			full   => OPEN,
--			empty  => FIFO_EMPTY
--		);

   -- Clock process definition
   CLOCK_process :process
   begin
		CLOCK <= '1';
		wait for CLOCK_period/2;
		CLOCK <= '0';
		wait for CLOCK_period/2;
   end process;
	
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------	 
	Reading_writing : PROCESS (CLOCK, RESET) IS
      FILE data_file_rd : TEXT OPEN READ_MODE IS "usbdata2fpga.txt";
      VARIABLE l    : LINE;
      FILE data_file_wr : TEXT OPEN WRITE_MODE IS "usbdata2pc.txt";

      VARIABLE usbdata2fpga 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
		--SIGNAL usbdata2pc 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
      VARIABLE cnt  				: INTEGER := 0;
		VARIABLE wrcnt 			: INTEGER := 0;
		VARIABLE rdcnt 			: INTEGER := 0;
   BEGIN  -- PROCESS
      IF RESET = '1' THEN                -- asynchronous reset (active high)
         state    <= STARTUP;
         usbdata2fpga := (OTHERS => '0');
			usbdata2pc <= (OTHERS => '0');
         cnt      := 0;
			byteCtr                <= 0;
			sLatchData             <= '0';
			lineCnt  		<= 0;
			RXF_n <= '1';
			TXE_n <= '1';
      ELSIF rising_edge(CLOCK) THEN  -- rising clock edge
         CASE state IS
			
            WHEN STARTUP =>
					cnt      := cnt + 1;
               IF cnt > 500 THEN
						state <= RD_FILE;
               END IF;

            WHEN RD_FILE =>
					if endfile(data_file_rd) then 
						state <= ST_END;
					else
						if writing = '1' then 
							state <= RECV1;
							If OE_n = '0' THEN 
								byteCtr <= 4;
							END IF;
						else
							readline(data_file_rd, l);
							hread(l, usbdata2fpga);
							if usbdata2fpga (31 downto 16) = x"AAAB" and wrcnt <= 0 then 
								writing <= '1'; 
								--byteCtr <= 4;
								wrcnt := TO_INTEGER(unsigned(usbdata2fpga (15 downto 0))) * 4 ;
								state   <= TRANSMIT1;
							elsif usbdata2fpga (31 downto 16) = x"AAAA" and rdcnt <= 0 then
								writing <= '0';
								rdcnt := TO_INTEGER(unsigned(usbdata2fpga (7 downto 0)));
							end if;
							if rdcnt >= 0 then 
								state   <= TRANSMIT1;
							end if;
						end if;
					end if;
            WHEN TRANSMIT1 =>
					D_in <= usbdata2fpga (7 downto 0);
					if RD_n = '1' then
						state   <= TRANSMIT2;
					end if;
            WHEN TRANSMIT2 =>
					RXF_n <= '0';
					if RD_n = '0' then
						usbdata2fpga := x"00" & usbdata2fpga (31 DOWNTO 8);
						IF byteCtr = 3 THEN -- latch 32bit word
							sLatchData <= '1';
							byteCtr    <= 0;
							rdcnt := rdcnt - 1;
						ELSE
							byteCtr <= byteCtr + 1;
						END IF;
						state   <= WT_RD_n;
					end if;
            WHEN WT_RD_n =>
					if RD_n = '1' then 
						RXF_n <= '1';
						state <= NEXTWORD1;
					end if;
				WHEN NEXTWORD1 =>
					RXF_n <= '1';
					state <= NEXTWORD2;
				WHEN NEXTWORD2 =>
					If sLatchData = '1' then
						state <= RD_FILE;
						sLatchData <= '0';
					ELSE
						state <= TRANSMIT1;
					END IF;
				
				WHEN RECV1 =>
					if WR_n = '1' then 
						if wrcnt > 0 then 
							TXE_n <= '0';
							state <= WT_WR_n_L;
							wrcnt := wrcnt - 1;
							if byteCtr = 4 THEN 
								byteCtr <= 0;
							ELSIF byteCtr = 3 THEN -- latch 32bit word
								hwrite(l, usbdata2pc);
								writeline(data_file_wr, l);	
								byteCtr    <= 0;
							ELSE
								byteCtr <= byteCtr + 1;
							END IF;
						else 
							state <= RD_FILE;
							writing <= '0';
						end if;
					end if;						
				WHEN WT_WR_n_L =>
					TOcnt <= TOcnt + 1;
					if WR_n = '0' then 
						usbdata2pc (31 downto 24) <= D_out;
						usbdata2pc (23 downto 0) <= usbdata2pc (31 downto 8);
						TXE_n <= '1';
						
						if wrcnt = 0 then
							writing <= '0';
							state <= WT2;
							TOcnt <= 0;
						else 
							state <= RECV1;
							TOcnt <= 0;
						end if;
					ELSIF TOcnt > 4 THEN
						state <= RD_FILE;
						writing <= '0';
						wrcnt := 0;
						TOcnt <= 0;
					end if; 
				WHEN WT2 =>
						state <= WT3;
				WHEN WT3 =>
						state <= WT4;
				WHEN WT4 =>
						state <= RD_FILE;
				WHEN ST_END =>
					file_close(data_file_rd);
					file_close(data_file_wr);
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS reading_writing;

END MFT2232_SIMU_Arch;
