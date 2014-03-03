----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013
-- Create Date:    13:20:57 11/19/2013 
-- Design Name: 
-- Module Name:    TCD_SIMU - TCD_SIMU_arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 13:20:57 11/19/2013    1.0    Luis Ardila    File created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--USE UNISIM.VComponents.all;

ENTITY TCD_SIMU IS
PORT (
	Busy_Combined				: IN 	std_logic;
	oRS         				: OUT  std_logic;         -- TCD RHIC strobe
	oRSx5       				: OUT  std_logic;         -- TCD data clock
	oTCD_DATA   				: OUT  std_logic_vector (3 DOWNTO 0)   -- TCD data
	);
END TCD_SIMU;

ARCHITECTURE TCD_SIMU_arch OF TCD_SIMU IS

	signal RS : std_logic := '0';
   signal RSx5 : std_logic := '0';
   signal TCD_DATA : std_logic_vector(3 downto 0) := (others => '0');
	CONSTANT TCD_RS_PERIOD    : time := 106 ns;   -- ~9.4 MHz RHICstrobe
   CONSTANT TCD_RS5_PERIOD   : time := 21.2 ns;  -- 5 x RHICstrobe frequency
	
BEGIN

oRS       <= RS;      
oRSx5     <= RSx5;      
oTCD_DATA <= TCD_DATA;


-- TCD Data strobe
  RSx5 <= NOT RSx5 AFTER TCD_RS5_PERIOD/2;

-- asymetric RHICstrobe:
  rhicstrobe_process : PROCESS
  BEGIN
    RS <= '1';
    WAIT FOR TCD_RS_PERIOD*2/5;
    RS <= '0';
    WAIT FOR TCD_RS_PERIOD*3/5;
  END PROCESS;
  
-- Stimulus process
tcd_proc : PROCESS
  -- procedure to create a trigger frame
    PROCEDURE trg_frame (
      TRG_CMD, DAQ_CMD       : IN  std_logic_vector (3 DOWNTO 0);
      TOKEN                  : IN  std_logic_vector (11 DOWNTO 0);
      SIGNAL TCD_RS, TCD_RS5 : IN  std_logic;
      SIGNAL TCD_DATA        : OUT std_logic_vector (3 DOWNTO 0)) IS
    BEGIN  -- PROCEDURE trg_frame
      -- Make sure we are on the rising edge of a RHICstrobe
      WAIT UNTIL (rising_edge(TCD_RS));
      TCD_DATA <= TRG_CMD;              -- trigger cmd
      WAIT FOR TCD_RS5_PERIOD;
      TCD_DATA <= DAQ_CMD;              -- DAQ cmd
      WAIT FOR TCD_RS5_PERIOD;
      TCD_DATA <= TOKEN(11 DOWNTO 8);   -- token[11:8]
      WAIT FOR TCD_RS5_PERIOD;
      TCD_DATA <= TOKEN(7 DOWNTO 4);    -- token[7:4]
      WAIT FOR TCD_RS5_PERIOD;
      TCD_DATA <= TOKEN(3 DOWNTO 0);    -- token[3:0]
      WAIT FOR TCD_RS5_PERIOD;
      TCD_DATA <= x"0";                 -- back to 0
    END PROCEDURE trg_frame;
	 
BEGIN
 
	 WAIT FOR 1500 us;
	 WAIT UNTIL rising_edge(RS);
	 trg_frame(x"F", x"5", x"121", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"122", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"123", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"124", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"125", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"126", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"127", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"128", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"129", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"12A", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"12B", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"12C", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"12D", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"12E", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"5", x"12F", RS, RSx5, TCD_DATA);
	 WAIT FOR 1500 us;
	 WAIT UNTIL rising_edge(RS);
	 WAIT FOR TCD_RS_PERIOD*5;
	 WAIT UNTIL Busy_Combined = '0';
	 WAIT UNTIL rising_edge(RS);
	 WAIT FOR TCD_RS_PERIOD*5;
	 trg_frame(x"4", x"2", x"123", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"3", x"123", RS, RSx5, TCD_DATA);
    WAIT FOR TCD_RS_PERIOD*20;
	 WAIT UNTIL Busy_Combined = '0';
	 trg_frame(x"4", x"2", x"124", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"3", x"124", RS, RSx5, TCD_DATA);
	 WAIT FOR TCD_RS_PERIOD*20;
	 WAIT UNTIL Busy_Combined = '0';
	 trg_frame(x"4", x"2", x"125", RS, RSx5, TCD_DATA);
	 trg_frame(x"F", x"3", x"125", RS, RSx5, TCD_DATA);
	 WAIT FOR TCD_RS_PERIOD*20;
	 WAIT UNTIL Busy_Combined = '0';
	 trg_frame(x"4", x"2", x"126", RS, RSx5, TCD_DATA);
	
END PROCESS;

END TCD_SIMU_arch;

