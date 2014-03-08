----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013
-- Create Date:    15:05:56 11/04/2013 
-- Design Name: 
-- Module Name:    Data_Packer - Data_Packer_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 15:05:56 11/04/2013    1.0    Luis Ardila    File created
-- Feb 21 2014 	1.1		Luis Ardila 	sStatus_Counters_RST_REG_buff create this signal to help in the clock domain crossing
-- Feb 26 2014		1.2		Luis Ardila		added pipeline for mem_rd_Add and data from the 8 fiber memories
-- Additional Comments: 
--						!!! WARNING: The lenght of the pipeline registers is maxed out by the header lenght
--											sPAYLOAD_MEM_RADDR_PIPE 								
--											sDDL_FIFO_WE_PIPE(6) <= sDDL_FIFO_WE
--											sPAYLOAD_MEM_OUT_PIPE_1 	<= PAYLOAD_MEM_OUT;
--											If you want to increase it please check carefully in simulation
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY Data_Packer IS
PORT (
		CLK80 							: IN STD_LOGIC;
		RST 								: IN STD_LOGIC;
		--GENERAL
		BoardID 					: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Data_FormatV 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		FPGA_BuildN				: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		--PAYLOAD MEMORIES FROM 8 FIBER PIPES
		RD_SERIAL 						: OUT  STD_LOGIC_VECTOR (11 DOWNTO 0); 
		PAYLOAD_MEM_GT_ONE   		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);  
		PAYLOAD_MEM_RADDR				: OUT PAYLOAD_MEM_RADDR_ARRAY_TYPE; --14 downto 0 (15 bits)
		PAYLOAD_MEM_OUT				: IN  PAYLOAD_MEM_OUT_ARRAY_TYPE;   --35 downto 0 (36 bits)
		--Trigger Admin module
		TCD_FIFO_Q     				: IN std_logic_vector (19 DOWNTO 0);  -- Triggerwords for inclusion in data
		TCD_FIFO_EMPTY 				: IN std_logic;         -- Triggerwords FIFO emtpy
		TCD_FIFO_RDREQ 				: OUT  std_logic;         -- Read Request for Triggerwords FIFO
		RScnt_TRGword_FIFO_OUT 		: IN std_logic_vector (35 DOWNTO 0);
		RScnt_TRGword_FIFO_EMPTY 	: IN std_logic; 
		RScnt_TRGword_FIFO_RDREQ 	: OUT std_logic;
		-- REGISTERS COUNTERS
		Status_Counters_RST_REG : IN STD_LOGIC;
		TCD_TRG_RCVD_REG			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		SIU_PACKET_CNT_REG		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		--SIU DDL LINK
		DDL_FIFO_Q         			: OUT  std_logic_vector(35 DOWNTO 0);  -- interface fifo data output port
		DDL_FIFO_EMPTY     			: OUT  std_logic;     -- interface fifo "emtpy" signal
		DDL_FIFO_RDREQ     			: IN std_logic;     -- interface fifo read request
		DDL_FIFO_RDCLK     			: IN std_logic     -- interface fifo read clock
		);
		
END Data_Packer;

ARCHITECTURE Data_Packer_arch OF Data_Packer IS

COMPONENT fifo36x32k
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
	 prog_full : OUT STD_LOGIC -- prog full at 32737 words 
  );
END COMPONENT;

	COMPONENT debud_data_verify IS
		PORT (
			CLK   : IN STD_LOGIC;
			rdreq : IN STD_LOGIC;
			Din   : IN STD_LOGIC_VECTOR (31 DOWNTO 0)
			);
	END COMPONENT debud_data_verify;

--CONSTANTS
CONSTANT sHEADER_TOKEN 	: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"0AAAAAAAA"; 
CONSTANT sFIBER_TOKEN  	: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"0DDDDDDDD"; 
CONSTANT sTCD_TOKEN		: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"0CCCCCCCC";
CONSTANT sTCD_END_TOKEN	: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"0EEEEEEEE";
CONSTANT sEND_TOKEN		: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"1BBBBBBBB"; -- bit 32 is the transmit signal
CONSTANT sTCD_ONLY_EVT  : STD_LOGIC_VECTOR (35 DOWNTO 0) := x"022200000"; --TOKEN  for an only TCD EVENT

--FIFO
SIGNAL sRST_DDL_FIFO 	: STD_LOGIC := '0';
SIGNAL sRST_buff			: STD_LOGIC := '0';
SIGNAL sDDL_FIFO_IN_DIN	: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
SIGNAL sDDL_FIFO_WE_IN 	: STD_LOGIC := '0';
SIGNAL sDDL_FIFO_FULL 	: STD_LOGIC := '0';
SIGNAL sDDL_FIFO_EMPTY 	: STD_LOGIC := '0';

--STATE MACHINE
TYPE state_type IS (ST_IDLE, ST_GET_TCD_INFO, ST_HEADER, ST_FIBERS, ST_TCD_INFO, ST_TRAILER);
SIGNAL sState     	: state_type;
SIGNAL sCnt 			: INTEGER := 0;
SIGNAL sFIBER_Cnt		: INTEGER := 0;
SIGNAL sBUSY_WT 		: INTEGER := 0;
SIGNAL s1ms_No_Trigger 			: INTEGER RANGE 0 to 900000 := 0;
SIGNAL sTCD_ONLY_FLAG 			: STD_LOGIC := '0';
SIGNAL sWordCnt 					: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
SIGNAL sSEEN_END_MARKER_FLAG 	: STD_LOGIC := '0';
SIGNAL sSTART_ADD					: STD_LOGIC_VECTOR (14 DOWNTO 0) := (OTHERS => '0');
SIGNAL sEND_ADD					: STD_LOGIC_VECTOR (14 DOWNTO 0) := (OTHERS => '0');

--TCD INFO
SIGNAL sRD_SERIAL 		: STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0');
SIGNAL sTRGWORD			: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
SIGNAL sRS_CTR 			: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
SIGNAL sTCD_FIFO_RDREQ	: STD_LOGIC := '0';
SIGNAL sTCD_EMPTY_FLAG  : STD_LOGIC := '0';
SIGNAL sTCD_FIFO_Q 		: std_logic_vector (19 DOWNTO 0) := (OTHERS => '0');
SIGNAL sTCD_FIFO_Q_buff : std_logic_vector (19 DOWNTO 0) := (OTHERS => '0');

--STATUS COUNTERS
SIGNAL sTCD_TRG_RCVD_REG 					: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
SIGNAL sSIU_PACKET_CNT_REG 				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
SIGNAL sStatus_Counters_RST_REG 			: STD_LOGIC := '0';
SIGNAL sStatus_Counters_RST_REG_buff 	: STD_LOGIC := '0';

--
SIGNAL sID_VERSIONS 		: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"000000000";
SIGNAL sRESERVED	 		: STD_LOGIC_VECTOR (35 DOWNTO 0) := x"077772222"; --TEMPORAL

--PAYLOAD
SIGNAL sPAYLOAD_MEM_RADDR : PAYLOAD_MEM_RADDR_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));

--PIPELINE
SIGNAL sPAYLOAD_MEM_RADDR_PIPE 	: PAYLOAD_MEM_RADDR_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));
SIGNAL sDDL_FIFO_IN					: STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
SIGNAL sDDL_FIFO_WE 					: STD_LOGIC := '0';
SIGNAL sDDL_FIFO_WE_PIPE 			: STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '0'); -- signal used to pipeline the WE to the DDL FIFO
SIGNAL sPAYLOAD_MEM_OUT_PIPE_1 	: PAYLOAD_MEM_OUT_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));   --35 downto 0 (36 bits)
SIGNAL sPAYLOAD_MEM_OUT_PIPE_0 	: PAYLOAD_MEM_OUT_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));   --35 downto 0 (36 bits)
SIGNAL sPAYLOAD_MEM_OUT				: PAYLOAD_MEM_OUT_ARRAY_TYPE := (OTHERS => (OTHERS => '0'));

-- The KEEP ATTRIBUTE prevents ISE from palcing the signals into the LUT and thus
-- negating the intention the pipeline the signal to ease the timing
ATTRIBUTE KEEP 											: STRING;
ATTRIBUTE KEEP OF sStatus_Counters_RST_REG 		: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sStatus_Counters_RST_REG_buff : SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sPAYLOAD_MEM_RADDR_PIPE 		: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sDDL_FIFO_WE_PIPE 				: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sPAYLOAD_MEM_OUT_PIPE_1 		: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sPAYLOAD_MEM_OUT_PIPE_0 		: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sPAYLOAD_MEM_OUT 					: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sDDL_FIFO_WE 						: SIGNAL IS "TRUE";
ATTRIBUTE KEEP OF sDDL_FIFO_IN 						: SIGNAL IS "TRUE";


BEGIN

Data_Packer_DDL_FIFO : fifo36x32k
  PORT MAP (
    rst => sRST_DDL_FIFO,
    wr_clk => CLK80,
    rd_clk => DDL_FIFO_RDCLK,
    din => sDDL_FIFO_IN_DIN,
    wr_en => sDDL_FIFO_WE_IN,
    rd_en => DDL_FIFO_RDREQ,
    dout => DDL_FIFO_Q,
    full => open, --sDDL_FIFO_FULL,
    empty => sDDL_FIFO_EMPTY,
	 prog_full => sDDL_FIFO_FULL --using the prog full flag
  );
--- SIU STATUS COUNTER ADDRESS 0x33

--	debud_data_verify_inst : debud_data_verify 
--	PORT MAP(
--			CLK   => CLK80,
--			rdreq => sDDL_FIFO_WE_IN,
--			Din   => sDDL_FIFO_IN_DIN(31 DOWNTO 0)
--			);

PROCESS (DDL_FIFO_RDCLK, RST) IS
BEGIN
	IF RST = '1' THEN 
		sRST_DDL_FIFO <= '1';
	ELSIF rising_edge (DDL_FIFO_RDCLK) THEN 
		sStatus_Counters_RST_REG <= Status_Counters_RST_REG;
		sStatus_Counters_RST_REG_buff <= sStatus_Counters_RST_REG;
		
		sRST_buff <= RST;
		sRST_DDL_FIFO <= sRST_buff OR RST; 
		
		IF sStatus_Counters_RST_REG_buff = '1' THEN
			sSIU_PACKET_CNT_REG <= (OTHERS => '0');
		--ELSIF DDL_FIFO_RDREQ = '1' AND sDDL_FIFO_EMPTY = '0' THEN 
		--	sSIU_PACKET_CNT_REG <= STD_LOGIC_VECTOR(UNSIGNED(sSIU_PACKET_CNT_REG) + 1); --increment status counter
		END IF;
		
	END IF;
END PROCESS;


--DATA PACKER STATE MACHINE
PROCESS (CLK80, RST) IS
VARIABLE sCountDownWord 			: STD_LOGIC := '0';
BEGIN
	IF RST = '1' THEN 
		sPAYLOAD_MEM_RADDR <= (OTHERS => (OTHERS => '0'));
		sTCD_FIFO_RDREQ <= '0';
		RScnt_TRGword_FIFO_RDREQ <= '0';
		sDDL_FIFO_WE <= '0';
		sTCD_EMPTY_FLAG <= '0';
		sState <= ST_IDLE;
		sTCD_TRG_RCVD_REG <= (OTHERS => '0');
		
	ELSIF RISING_EDGE(CLK80) THEN 
		
		CASE sState IS
			WHEN ST_IDLE =>
				sTCD_FIFO_RDREQ <= '0';
				RScnt_TRGword_FIFO_RDREQ <= '0';
				sDDL_FIFO_WE <= '0';
				sTCD_EMPTY_FLAG <= '0';
				sTCD_ONLY_FLAG 	<= '0';
				
				IF ((RScnt_TRGword_FIFO_EMPTY = '0') AND (PAYLOAD_MEM_GT_ONE = x"FF")) THEN 
					sState 		<= ST_GET_TCD_INFO;
					sCnt 			<= 0;
					s1ms_No_Trigger 	<= 0;
					
				ELSIF s1ms_No_Trigger > 80000 THEN   
				--1 ms has passed and no trigger has come yet, buffers are empty then do TCD info only
					sState 				<= ST_HEADER;
					sCnt 					<= 0;
					sTCD_ONLY_FLAG 	<= '1'; 
					s1ms_No_Trigger 	<= 0;
					sTRGWORD <= sTCD_ONLY_EVT;  --x"022200000"; token to denote that we have an event that is only TCD info
					sRS_CTR <= (OTHERS => '0');
				END IF;
						
				IF TCD_FIFO_EMPTY = '0' AND RScnt_TRGword_FIFO_EMPTY = '1' AND s1ms_No_Trigger < 80002 THEN
					s1ms_No_Trigger <= s1ms_No_Trigger + 1;
				END IF;
				
			WHEN ST_GET_TCD_INFO =>
				IF sCnt < 5 THEN
					sCnt <= sCnt + 1;
				END IF;
				CASE sCnt IS 
					WHEN 0 | 1 =>
						RScnt_TRGword_FIFO_RDREQ <= '1';
					WHEN 2 => 
						sRD_SERIAL <= RScnt_TRGword_FIFO_OUT (11 DOWNTO 0); --sRD_SERIAL 12 bits
					WHEN 3 => 
						RScnt_TRGword_FIFO_RDREQ <= '0';
						sTRGWORD <= RScnt_TRGword_FIFO_OUT; --x"0111" & sTRGWORD; for FORCED and x"0000" & sTRGWORD; for TCD
					WHEN 4 => 
						sRS_CTR <= RScnt_TRGword_FIFO_OUT(31 DOWNTO 0); --x"0" & sRS_CTR;
					WHEN OTHERS =>
						IF sDDL_FIFO_FULL = '0' THEN
							sCnt <= 0;
							sState <= ST_HEADER;
						END IF;
				END CASE;
				
			WHEN ST_HEADER => --writes the header information Header is 10 words long, less than the prog full flag of total-30.
							
				sCnt <= sCnt + 1;							--increase counter 
				RScnt_TRGword_FIFO_RDREQ <= '0';		-- not request TRG TCD info
				sDDL_FIFO_WE <= '1';					-- write to fifo
				
				CASE sCnt IS 
					WHEN 0 =>
						sDDL_FIFO_IN <= sHEADER_TOKEN; --As
					WHEN 1 =>
						sDDL_FIFO_IN <= sTRGWORD; --TRIGGER WORD
					WHEN 2 => 
						sDDL_FIFO_IN <= x"0" & sRS_CTR; --RHIC strobe counter
					WHEN 3 => 
						sDDL_FIFO_IN <= sID_VERSIONS; 
					WHEN 4 => 
						sDDL_FIFO_IN <= sRESERVED; 
					WHEN 5 => 
						sDDL_FIFO_IN <= sRESERVED; 
					WHEN 6 => 
						sDDL_FIFO_IN <= sRESERVED; 
					WHEN 7 => 
						sDDL_FIFO_IN <= sRESERVED; 
						sCnt <= 0;
						sFIBER_Cnt <= 0;						--start with fiber 0
						IF sTCD_ONLY_FLAG = '1' THEN 		--event with only TCD info
							sState <= ST_TCD_INFO;
						ELSE
							sState <= ST_FIBERS;
						END IF;
					WHEN OTHERS =>
						sCnt <= 0;
						sFIBER_Cnt <= 0;						--start with fiber 0
						IF sTCD_ONLY_FLAG = '1' THEN 		--event with only TCD info
							sState <= ST_TCD_INFO;
						ELSE
							sState <= ST_FIBERS;
						END IF;
				END CASE;
				
			WHEN ST_FIBERS => 
				CASE sCnt IS 
					WHEN 0 => -- initial address increment to point where the start marker should be
						sPAYLOAD_MEM_RADDR (sFIBER_Cnt) <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_RADDR (sFIBER_Cnt)) + 1); --memory address increase
						sSTART_ADD <= sPAYLOAD_MEM_RADDR (sFIBER_Cnt);
						sCnt <= 1;
						sDDL_FIFO_WE <= '0';
						sCountDownWord := '0';
						sSEEN_END_MARKER_FLAG <= '0';
					WHEN 1 => -- check for the start marker
						--ADD TIME BASE ESCAPE error in writing the header and not pressent ++++++++++++++ -- MISSING
						IF sPAYLOAD_MEM_OUT_PIPE_0 (sFIBER_Cnt) = x"15354" & sRD_SERIAL & '0' & STD_LOGIC_VECTOR(TO_UNSIGNED(sFIBER_Cnt,3)) THEN
							sCnt <= 2;
						END IF;
					WHEN 2 => -- write the fiber token (DDDDDDDD)
						IF sDDL_FIFO_FULL = '0' THEN
							sDDL_FIFO_IN <= sFIBER_TOKEN; --Ds START MARKER TOKEN FOR EACH FIBER
							sDDL_FIFO_WE <= '1';
							sCnt <= 3;
						END IF;
					WHEN 3 =>
						sDDL_FIFO_WE <= '0';
						sCnt <= 4;
					WHEN 4 => 
						sDDL_FIFO_IN <= sPAYLOAD_MEM_OUT (sFIBER_Cnt); -- WRITING TO DDL FIFO
						IF sDDL_FIFO_FULL = '0' THEN 					
							--Incrementing memory address
							IF ((sCountDownWord = '0') OR (sCountDownWord = '1' AND TO_INTEGER(UNSIGNED(sWordCnt)) > 9)) THEN --9 is the pipeline lenth
								sPAYLOAD_MEM_RADDR (sFIBER_Cnt) <= STD_LOGIC_VECTOR(UNSIGNED(sPAYLOAD_MEM_RADDR (sFIBER_Cnt)) + 1);
								IF (UNSIGNED(sWordCnt) > 2  OR UNSIGNED(sWordCnt) < 1) THEN
									sWordCnt <= STD_LOGIC_VECTOR(UNSIGNED(sWordCnt) - 1); --decresing counter 
								END IF;
								IF (sCountDownWord = '0') OR (TO_INTEGER(UNSIGNED(sWordCnt)) > 11) THEN
									sDDL_FIFO_WE <= '1';								
								ELSE 
									sDDL_FIFO_WE <= '0';
								END IF;
							ELSIF ((TO_INTEGER(UNSIGNED(sWordCnt)) <= 9) AND (sSEEN_END_MARKER_FLAG = '1')) THEN
								IF (sPAYLOAD_MEM_RADDR (sFIBER_Cnt) /= sEND_ADD) THEN --This should never happen, and should be consider as a flag to daq
									sPAYLOAD_MEM_RADDR (sFIBER_Cnt) <= sEND_ADD;
								END IF;
								sCnt <= 5;
								sDDL_FIFO_WE <= '0';
								sWordCnt <= (OTHERS => '0');
								sSEEN_END_MARKER_FLAG <= '0';
							END IF;	
							IF (sDDL_FIFO_WE_IN = '1' AND sDDL_FIFO_WE_PIPE(0) = '1' AND sCountDownWord = '0') THEN 
								sWordCnt <= STD_LOGIC_VECTOR(UNSIGNED(sWordCnt) + UNSIGNED(sDDL_FIFO_IN_DIN (18 DOWNTO 4)) + 9);   --saving the fiber lenght
								sEND_ADD <= STD_LOGIC_VECTOR(UNSIGNED(sSTART_ADD) + UNSIGNED(sDDL_FIFO_IN_DIN (18 DOWNTO 4)) + 2); --blank space and pipe header
								sCountDownWord := '1'; 										--flag to allow the count down 
							END IF;
						ELSE
							sDDL_FIFO_WE <= '0';
							IF (sDDL_FIFO_WE_IN = '1' AND sDDL_FIFO_WE_PIPE(0) = '1' AND sCountDownWord = '0') THEN 
								sWordCnt <= STD_LOGIC_VECTOR(UNSIGNED(sWordCnt) + UNSIGNED(sDDL_FIFO_IN_DIN (18 DOWNTO 4)) + 10);   --saving the fiber lenght
								sEND_ADD <= STD_LOGIC_VECTOR(UNSIGNED(sSTART_ADD) + UNSIGNED(sDDL_FIFO_IN_DIN (18 DOWNTO 4)) + 2); --blank space and pipe header
								sCountDownWord := '1'; 										--flag to allow the count down 
							END IF;
						END IF;
						IF sPAYLOAD_MEM_OUT (sFIBER_Cnt) = (x"1454E440" & '0' & STD_LOGIC_VECTOR(TO_UNSIGNED(sFIBER_Cnt,3))) THEN --CHECK FOR END MARKER 
							sSEEN_END_MARKER_FLAG <= '1';
							sDDL_FIFO_WE <= '0';
						END IF;				
					WHEN 5 => 
						sDDL_FIFO_WE <= '0';
						IF sFIBER_Cnt = 7 THEN -- all fibers done
							sCnt <= 0;
							sFIBER_Cnt <= 0;		-- reset fiber counter
							sState <= ST_TCD_INFO; --out of fibers state
						ELSE
							sFIBER_Cnt <= sFIBER_Cnt + 1;	--increment fiber number
							sCnt <= 0;
						END IF;
					
					WHEN OTHERS =>
						sCnt <= 0;
						sFIBER_Cnt <= 0;		-- reset fiber counter
						sState <= ST_TCD_INFO; --out of fibers state
				END CASE;
							
			WHEN ST_TCD_INFO =>
				IF sCnt /= 5 THEN
					sTCD_FIFO_Q 		<= TCD_FIFO_Q;  --SIGNALS TO BUFFER INPUT IN CASE OF BUSY DLL FIFO
					sTCD_FIFO_Q_buff 	<= sTCD_FIFO_Q; --IF BUSY THEN GOES TO STATE 5, 6 and then back to 2(normal)
				END IF;
				CASE sCnt IS 
					WHEN 0 => --check if TCD_FIFO is empty so only the start marker and end marker are written
						sDDL_FIFO_WE <= '0';
						sCnt <= 1;
						IF TCD_FIFO_EMPTY = '0' THEN
							sTCD_FIFO_RDREQ <= '1';
						ELSE 
							sTCD_EMPTY_FLAG <= '1';
							sTCD_FIFO_RDREQ <= '0';
						END IF;
					WHEN 1 => --write start marker for TCD commands (CCCCCCCC)
						IF sDDL_FIFO_FULL = '0' THEN --check for fifo full
							sDDL_FIFO_IN <= sTCD_TOKEN; --Cs
							sDDL_FIFO_WE <= '1';
							sCnt <= 2;
							IF sTCD_EMPTY_FLAG = '1' THEN --if empty from the begining
								sCnt <= 3;
							ELSIF TCD_FIFO_EMPTY = '0' THEN --if empty after getting one value
								sTCD_FIFO_RDREQ <= '1';
							ELSE 
								sTCD_FIFO_RDREQ <= '0';
							END IF;
						ELSE 
							sDDL_FIFO_WE <= '0';
							sTCD_FIFO_RDREQ <= '0';
						END IF;
						
					WHEN 2 => -- state for copying tcd data to ddl fifo
						IF sDDL_FIFO_FULL = '0' THEN --check for fifo full
							sDDL_FIFO_IN <= x"0000" & TCD_FIFO_Q;
							sDDL_FIFO_WE <= '1';
							sTCD_TRG_RCVD_REG <= STD_LOGIC_VECTOR(UNSIGNED(sTCD_TRG_RCVD_REG) + 1); --Increment Counter of triggers receiced
							IF TCD_FIFO_EMPTY = '0' THEN 
								sTCD_FIFO_RDREQ <= '1';
							ELSE 
								sCnt <= 3;						--TCD fifo empty
								sTCD_FIFO_RDREQ <= '0';
							END IF;
						ELSE 
							sDDL_FIFO_WE <= '0';
							sTCD_FIFO_RDREQ <= '0';
							sCnt <= 5;
						END IF;
						
					WHEN 3 => --write end marker
						IF sDDL_FIFO_FULL = '0' THEN
							sDDL_FIFO_IN <= sTCD_END_TOKEN; --Es
							sDDL_FIFO_WE <= '1';
							sCnt <= 4;
						ELSE 
							sDDL_FIFO_WE <= '0';
						END IF;
						
					WHEN 4 => -- end change state
						sDDL_FIFO_WE <= '0';
						sTCD_EMPTY_FLAG <= '0';
						IF sDDL_FIFO_FULL = '0' THEN --CHECKING FULL FLAG FOR TRAILER
							sState <= ST_TRAILER;
							sCnt <= 0;
						END IF;
					
					WHEN 5 => 
						IF sDDL_FIFO_FULL = '0' THEN
							sBUSY_WT <= sBUSY_WT + 1;
							IF sBUSY_WT > 12 THEN
								sDDL_FIFO_IN 		<= x"0000" & sTCD_FIFO_Q_buff; 
								sDDL_FIFO_WE 	<= '1';
								sCnt <= 2;	
								sBUSY_WT <= 0;
							END IF;
						END IF;
					
					WHEN OTHERS =>
						sDDL_FIFO_WE <= '0';
						sTCD_EMPTY_FLAG <= '0';
						IF sDDL_FIFO_FULL = '0' THEN 
							sState <= ST_TRAILER;
							sCnt <= 0;
						END IF;
				END CASE;
			
			WHEN ST_TRAILER =>
				sDDL_FIFO_WE 	<= '1';
				sCnt <= sCnt + 1;
				CASE sCnt IS 
					WHEN 0 => --write first data
						sDDL_FIFO_IN <= sRESERVED;
					WHEN 1 => --check if prev data was written and write following
						sDDL_FIFO_IN <= sEND_TOKEN; 	
						sState <= ST_IDLE;
						sCnt <= 0;
					WHEN OTHERS =>
						sState <= ST_IDLE;
						sCnt <= 0;
				END CASE;
					
			WHEN OTHERS => 
				sCnt <= 0;
				sState <= ST_IDLE;
		
		END CASE;
		
		IF Status_Counters_RST_REG = '1' THEN --clear status counter
			sTCD_TRG_RCVD_REG <= (OTHERS => '0');
		END IF;
		
	END IF;
	
END PROCESS;

PIPELINE : PROCESS (CLK80)
BEGIN
	IF RISING_EDGE(CLK80) THEN
		-- MEMORY ADDRESS
		sPAYLOAD_MEM_RADDR_PIPE <= sPAYLOAD_MEM_RADDR;
		PAYLOAD_MEM_RADDR 		<= sPAYLOAD_MEM_RADDR_PIPE;
		
		-- WE DDL FIFO													--!!!Change lenght of WE_PIPE accordingly with the proper delay
		IF (sState = ST_FIBERS) AND (sCnt = 4) AND sSEEN_END_MARKER_FLAG = '0' THEN 
			sDDL_FIFO_WE_PIPE(6) <= sDDL_FIFO_WE;
			sDDL_FIFO_WE_PIPE(5) <= sDDL_FIFO_WE_PIPE(6);
			sDDL_FIFO_WE_PIPE(4) <= sDDL_FIFO_WE_PIPE(5);
			sDDL_FIFO_WE_PIPE(3) <= sDDL_FIFO_WE_PIPE(4);
			sDDL_FIFO_WE_PIPE(2) <= sDDL_FIFO_WE_PIPE(3);
			sDDL_FIFO_WE_PIPE(1) <= sDDL_FIFO_WE_PIPE(2);
			sDDL_FIFO_WE_PIPE(0) <= sDDL_FIFO_WE_PIPE(1);
			sDDL_FIFO_WE_IN 		<= sDDL_FIFO_WE_PIPE(0);
		ELSE 
			sDDL_FIFO_WE_IN <= sDDL_FIFO_WE;
			sDDL_FIFO_WE_PIPE <= (OTHERS => '0');
		END IF;
		
		sDDL_FIFO_IN_DIN <= sDDL_FIFO_IN;
		
		-- OUTPUT OF THE FIBERS 
		sPAYLOAD_MEM_OUT_PIPE_1 	<= PAYLOAD_MEM_OUT;
		sPAYLOAD_MEM_OUT_PIPE_0 	<= sPAYLOAD_MEM_OUT_PIPE_1;
		sPAYLOAD_MEM_OUT 				<= sPAYLOAD_MEM_OUT_PIPE_0;
		
		
	END IF;
END PROCESS PIPELINE;

sID_VERSIONS <= x"00" & BoardID & Data_FormatV & FPGA_BuildN;
RD_SERIAL <= sRD_SERIAL;

TCD_FIFO_RDREQ <= sTCD_FIFO_RDREQ AND NOT TCD_FIFO_EMPTY; -- avoid droping one TCD COMMAND 
TCD_TRG_RCVD_REG <= sTCD_TRG_RCVD_REG;
SIU_PACKET_CNT_REG <= sSIU_PACKET_CNT_REG;
DDL_FIFO_EMPTY <= sDDL_FIFO_EMPTY;

END Data_Packer_arch;

