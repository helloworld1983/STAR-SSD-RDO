----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013
-- Create Date:    14:25:57 12/12/2013 
-- Design Name: 
-- Module Name:    Status_Counters_TA - Status_Counters_TA_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: This souce gathers information about the status inside the Trigger Admin Block,
-- 				 it generates the status registers and acts on reset provided from other register
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 14:25:57 12/12/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--USE UNISIM.VComponents.all;

ENTITY Status_Counters_TA IS
PORT(
		CLK40							: IN STD_LOGIC;
		--
		RS_CTR     					: IN std_logic_vector (31 DOWNTO 0);  -- RHICstrobe counter
		EVT_TRG_TCD					: IN STD_LOGIC;
		TRIGGER_MODE 				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);  -- ONLY USING ONE OF THE 8 TRIGGER MODES (CHANNEL 0)
		ACQUIRE 						: IN STD_LOGIC;
		--Registers
		Status_Counters_RST_REG : IN STD_LOGIC;
		TCD_Level0_RCVD_REG		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		RHIC_STROBE_LSB_REG 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		RHIC_STROBE_MSB_REG 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		N_HOLDS_REG 				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		N_TESTS_REG 				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
END Status_Counters_TA;

ARCHITECTURE Status_Counters_TA_arch OF Status_Counters_TA IS
	
	SIGNAL sTCD_Level0_RCVD_REG	: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sRHIC_STROBE_LSB_REG 	: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sRHIC_STROBE_MSB_REG 	: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sN_HOLDS_REG 				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sN_TESTS_REG 				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sACQUIRE					: STD_LOGIC := '0';

BEGIN


--------------------------------------------------------------------------------
--Status Counters 
--------------------------------------------------------------------------------	

PROCESS (CLK40) IS
BEGIN
	IF Status_Counters_RST_REG = '1' THEN 
	
		sTCD_Level0_RCVD_REG	<= (OTHERS => '0');
		sRHIC_STROBE_LSB_REG <= (OTHERS => '0');
		sRHIC_STROBE_MSB_REG <= (OTHERS => '0');	
		sN_HOLDS_REG			<= (OTHERS => '0');
		sN_TESTS_REG 			<= (OTHERS => '0');		
		
	ELSIF rising_edge(CLK40) THEN
	
		-- TCD level 0
		IF EVT_TRG_TCD = '1' THEN 
			sTCD_Level0_RCVD_REG <= STD_LOGIC_VECTOR(UNSIGNED(sTCD_Level0_RCVD_REG) + 1);
		END IF;
		
		-- HOLDS and TESTS
		sACQUIRE <= ACQUIRE; 	
		IF (sACQUIRE = '0' AND ACQUIRE = '1') THEN 
			IF TRIGGER_MODE = b"00" THEN
				sN_HOLDS_REG <= STD_LOGIC_VECTOR(UNSIGNED(sN_HOLDS_REG) + 1);
			ELSIF TRIGGER_MODE = b"01" THEN
				sN_TESTS_REG <= STD_LOGIC_VECTOR(UNSIGNED(sN_HOLDS_REG) + 1);
			END IF;
		END IF;
		
		-- RHIC STROBE COUNTER
		sRHIC_STROBE_LSB_REG <= RS_CTR (15 DOWNTO 0);
		sRHIC_STROBE_MSB_REG <= RS_CTR (31 DOWNTO 16);
		
	END IF;		
END PROCESS;

TCD_Level0_RCVD_REG		<= sTCD_Level0_RCVD_REG;
RHIC_STROBE_LSB_REG 		<= sRHIC_STROBE_LSB_REG; 
RHIC_STROBE_MSB_REG 	   <= sRHIC_STROBE_MSB_REG;
N_HOLDS_REG 				<= sN_HOLDS_REG;
N_TESTS_REG 				<= sN_TESTS_REG;

END Status_Counters_TA_arch;

