----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    09:33:12 08/21/2013 
-- Design Name: 
-- Module Name:    LC_FPGA_Configuration - LC_FPGA_Configuration_Arch 
-- Project Name: 	 STAR HFT SSD
-- Target Devices: XILINX Virtex 6 (XC6VLX240T-FF1759)
-- Tool versions:  ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Date              Version         Author          Description
-- 08/21/2013        1.0             Luis Ardila     File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE ieee.numeric_std.ALL;

ENTITY LC_FPGA_Configuration IS
	PORT (
		CLK40       			: IN  STD_LOGIC;
      RST         			: IN  STD_LOGIC;
      -- Command Interface
		CONFIG_CMD_IN		 	: IN 	STD_LOGIC_VECTOR (15 DOWNTO 0);	--	This 16 bits are a control register that contains two signals, from 15 to 8 is the ST_RESET request -8 is fiber 0
		CONFIG_DATA_IN     	: IN  STD_LOGIC_VECTOR (15 DOWNTO 0);	-- This is the data to be configured
      CONFIG_DATA_IN_WE  	: IN  STD_LOGIC;								-- Data write enable
      CONFIG_BUSY 			: OUT STD_LOGIC;
      CONFIG_STATUS_OUT    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);	--	Puts status of the CONFIG
      -- Altera Configuration Interfase 
      LC_DATA       			: OUT STD_LOGIC;								
		LC_NCONFIG     		: OUT STD_LOGIC;
      LC_DCLK        		: OUT STD_LOGIC;
      LC_INIT_SWITCH			: OUT STD_LOGIC;
		LC_NSTATUS     		: IN 	STD_LOGIC;
      LC_CONF_DONE   		: IN 	STD_LOGIC;
      -- Test Connector
      TC          			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END LC_FPGA_Configuration;

ARCHITECTURE LC_FPGA_Configuration_Arch OF LC_FPGA_Configuration IS

	TYPE state_type IS (ST_IDLE, ST_PRESET, ST_RESET, ST_CONF_L, ST_CONF_H, ST_INIT_L, ST_INIT_H, ST_ABORT, ST_USER);
	SIGNAL sState     : state_type;


	CONSTANT WT_NCONFIG_LOW 	: INTEGER := 8000; 				--	200us 		Time to hold nConfig line down to ST_RESET the LC FPGA
	CONSTANT WT_RESET 			: INTEGER := 14000; 				--	350us			Time after NSTATUS Goes High to move into the next configuration state
	CONSTANT WT_CONF				: INTEGER := 16;					--	16 cycles	16 bits of data
	CONSTANT WT_INIT				: INTEGER := 10;					--	10 cycles	10 clock cycles after CONF_DONE is high
	CONSTANT WT_USER				: INTEGER := 14000;				--	350us 			wait 5 us in ST_USER mode until be able to go to ST_IDLE again and wait for another conf cycle

	SIGNAL sCnt						: INTEGER RANGE 0 TO 50000;
	SIGNAL sLC_Reseted		: STD_LOGIC := '0';
	SIGNAL sLC_configured		: STD_LOGIC := '0';
	SIGNAL sLC_config_abort		: STD_LOGIC := '0';
	SIGNAL sData_tempo			: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sNum_state				: STD_LOGIC_VECTOR (2 DOWNTO 0) 	:= (OTHERS => '0');

BEGIN


CONFIG_STATES : PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS CONFIG_STATES
      IF RST = '1' THEN                 							-- asynchronous global ST_RESET (active high)
			LC_DATA 				<= '1';
			LC_NCONFIG 			<= '1'; 										-- trying not to deconfigure LC while resetting RDO
			LC_DCLK 				<= '1';
			LC_INIT_SWITCH 	<= '1';										-- TDO line wired
			sLC_config_abort	<= '1';
			sLC_Reseted 		<= '0';
			CONFIG_BUSY 		<= '0';
			sState    	<= ST_IDLE;
      ELSIF rising_edge(CLK40) THEN  					-- rising clock edge
         
         CASE sState IS
				
				-- ST_IDLE waits until the next data is available, checks if we are at the begining or middle of transmission
            WHEN ST_IDLE =>	
					CONFIG_BUSY <= '0';				
					LC_DATA 		<= '1';
					LC_NCONFIG 	<= '1'; 
					LC_DCLK 		<= '1';
					sData_tempo 		<= CONFIG_DATA_IN;
					
					
					IF (LC_NSTATUS = '0' and sLC_config_abort = '0') THEN 
						sState <= ST_ABORT;
					ELSIF (LC_CONF_DONE = '1' and sLC_configured = '0') THEN
						sState <= ST_INIT_L;
						sCnt 	<= WT_INIT;
					ELSIF (CONFIG_CMD_IN  = x"0001" and sLC_Reseted = '0')THEN					--	IF command register is to ST_RESET then go to ST_PRESET state 
						sState <= ST_PRESET;
						sCnt 	<= WT_NCONFIG_LOW;
					ELSIF (CONFIG_CMD_IN  = x"0002" and CONFIG_DATA_IN_WE = '1') THEN				--	IF command register is to configure then go to CONF state 
						sState <= ST_CONF_L;
						sCnt 	<= WT_CONF;
					ELSE
						sState	<= ST_IDLE;									--	No new data: remain in ST_IDLE
					END IF;
					
				--	ST_PRESET force NCONFIG line low to ST_RESET the PFGA 
				WHEN ST_PRESET =>
				   CONFIG_BUSY <= '1';
					LC_NCONFIG 				<= '0';
					sCnt 						<= sCnt - 1;
					sLC_config_abort 		<= '0';
					LC_INIT_SWITCH <= '0';
               
					IF sCnt > 1 THEN
                  sState <= ST_PRESET;
               ELSIF LC_NSTATUS = '0' THEN
                  sCnt 	<= WT_RESET;
                  sState <= ST_RESET;
					ELSE
						sState <= ST_ABORT;
               END IF;
				
				-- ST_RESET: Asserts NCONFIG line and waits for NSTATUS to go high and the command register to go to data transmision mode x"0002"	
				WHEN ST_RESET =>
					CONFIG_BUSY <= '1';
					LC_NCONFIG 	<= '1';
					sLC_configured	<= '0';
					sCnt	<= sCnt - 1;
					IF (sCnt < 10 and LC_NSTATUS = '1') THEN
						sState <= ST_IDLE;
						sLC_Reseted <= '1';
					ELSIF sCnt < 5 THEN
						sState <= ST_ABORT;
					END IF;
				
				-- ST_CONF_L: Updates values in the DATA and DCLK lines 	
				WHEN ST_CONF_L =>
					CONFIG_BUSY <= '1';
					sLC_Reseted <= '0';
					LC_DATA	<= sData_tempo(0);
					sData_tempo 	<= '0' & sData_tempo (15 DOWNTO 1);
					LC_DCLK 		<= '0';
					IF LC_NSTATUS = '0' then
						sState <= ST_ABORT;
					ELSE
						sState 	<= ST_CONF_H;
					END IF; 
					
				-- ST_CONF_H: Positive DCLK cycle to write data and checks for CONF_DONE	
				WHEN ST_CONF_H =>
					CONFIG_BUSY <= '1';
					LC_DCLK 		<= '1';
					sCnt 		<= sCnt - 1;
					
					
					IF sCnt > 1 THEN 
						sState <= ST_CONF_L;
					ELSE 
						sState <= ST_IDLE;
					END IF;
					
				-- ST_INIT_L: Extra DCLK cycles	
				WHEN ST_INIT_L =>
					CONFIG_BUSY <= '1';
					LC_DCLK 	<= '0';
					IF LC_NSTATUS = '0' then
						sState <= ST_ABORT;
					ELSE
						sState 	<= ST_INIT_H;
					END IF;
					
				-- ST_INIT_H Extra DCLK cycles	
				WHEN ST_INIT_H =>
					CONFIG_BUSY <= '1';
					LC_DCLK 	<= '1';
					sCnt 		<= sCnt - 1;
					
					IF sCnt > 1 THEN 
						sState <= ST_INIT_L;
					ELSE 
						sState <= ST_USER;
						sCnt 	<= WT_USER;
					END IF;
					
				-- ST_USER: Extra wait before able to use	
				WHEN ST_USER =>
					CONFIG_BUSY <= '1';
					sCnt	<= sCnt - 1;
					sLC_configured	<= '1';
					
               
					IF sCnt > 1 THEN
                  sState <= ST_USER;
               ELSE
                  sState <= ST_IDLE;
						LC_INIT_SWITCH <= '1';
               END IF;
				
				WHEN ST_ABORT =>
					CONFIG_BUSY <= '0';
					sLC_config_abort <= '1';
					sLC_Reseted <= '0';
					if LC_NSTATUS = '0' then 
						sLC_configured	<= '0';
					else
						sLC_configured	<= '1';
					end if;
					IF CONFIG_CMD_IN  = x"0000" THEN											-- escape route in case CONF_DONE line is not asserted
						sState 				<= ST_IDLE;
					END IF;				
				WHEN OTHERS =>
					sState	<= ST_IDLE;
					
			END CASE;	
		END IF;
END PROCESS CONFIG_STATES;
	
	
	
	sNum_state 	<= b"000" WHEN sState = ST_IDLE 	ELSE
						b"001" WHEN sState = ST_PRESET ELSE
						b"010" WHEN sState = ST_RESET 	ELSE
						b"011" WHEN sState = ST_CONF_L ELSE
						b"100" WHEN sState = ST_CONF_H ELSE
						b"101" WHEN sState = ST_INIT_L ELSE
						b"110" WHEN sState = ST_USER ELSE
						b"111" WHEN sState = ST_ABORT 	ELSE b"000";
											
	CONFIG_STATUS_OUT <= '0' & sNum_state & b"000" & LC_NSTATUS & b"000" & sLC_configured & b"000" & sLC_config_abort;
	
END LC_FPGA_Configuration_Arch;

