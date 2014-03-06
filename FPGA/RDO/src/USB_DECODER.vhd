----------------------------------------------------------------------------------
-- Company: Lawrence Berkeley National Laboratory
-- Engineer: Luis Ardila (leardila-perez@lbl.gov - leardilap@unal.edu.co)
-- Copyright (c) 2013 
-- Create Date:    13:40:46 09/11/2013 
-- Design Name: 
-- Module Name:    USB_DECODER - USB_DECODER_Arch 
-- Project Name: STAR HFT SSD
-- Target Devices: Virtex-6 (XC6VLX240T-FF1759)
-- Tool versions: ISE 13.4
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
-- Date        Version    Author    Description
-- 09/11/2013    1.0    Luis Ardila    File created with only fiber 0 routed
-- 11/11/2013           2.0     Luis Ardila             new quick version with pipe line architecture
-- 11/18/2013           2.1     Luis Ardila             Full new architecture changes in addresses and state machine
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.utilities.ALL;
USE work.SSD_pkg.ALL;

ENTITY USB_DECODER IS
   PORT (
      CLK40                       : IN  STD_LOGIC;
      RST                         : IN  STD_LOGIC;
--FTDI INTERFACE
      -- CMD FIFO
      CMD_FIFO_Q                  : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
      CMD_FIFO_EMPTY              : IN  STD_LOGIC;
      CMD_FIFO_RDREQ              : OUT STD_LOGIC;
      -- From FPGA to PC
      FIFO_Q                      : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface fifo data output port
      FIFO_EMPTY                  : OUT STD_LOGIC;  -- interface fifo "emtpy" signal
      FIFO_RDREQ                  : IN  STD_LOGIC;  -- interface fifo read request
      FIFO_RDCLK                  : IN  STD_LOGIC;  -- interface fifo read clock
--LC_INTERFACES
      --LC_Registers 
      LC_RST                      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      --CONFIG
      CONFIG_CMD_IN               : OUT FIBER_ARRAY_TYPE_16;
      CONFIG_DATA_IN              : OUT FIBER_ARRAY_TYPE_16;
      CONFIG_DATA_IN_WE           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      CONFIG_BUSY                 : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      CONFIG_STATUS_OUT           : IN  FIBER_ARRAY_TYPE_16;
      --JTAG
      JTAG_DATA_TDI               : OUT FIBER_ARRAY_TYPE_16;
      JTAG_DATA_WE                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      JTAG_BUSY                   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      JTAG_DATA_TDO               : IN  FIBER_ARRAY_TYPE_16;
      -- PIPE
      ADC_offset                  : OUT FIBER_ARRAY_TYPE_16;
      Zero_supr_trsh              : OUT FIBER_ARRAY_TYPE_16;
      ZST_Polarity                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      Pipe_Selector               : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      -- TCD Registers
      TCD_DELAY_Reg               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      TCD_EN_TRGMODES_Reg         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
      Forced_Triggers_Reg         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);  -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
      Status_Counters_RST_REG     : OUT STD_LOGIC;
      TCD_Level0_RCVD_REG         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      RHIC_STROBE_LSB_REG         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      RHIC_STROBE_MSB_REG         : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      N_HOLDS_REG                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      N_TESTS_REG                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      -- data packer status registers
      TCD_TRG_RCVD_REG            : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      SIU_PACKET_CNT_REG          : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      --BUSY_COMBINED
      BUSY_COMBINED               : IN  STD_LOGIC;
      --LC_Trigger_Handler
      TEST2HOLD_DELAY             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      --LC STATUS
      LC_STATUS_REG               : IN  FIBER_ARRAY_TYPE_16_8;
      LC_HYBRIDS_POWER_STATUS_REG : IN  FIBER_ARRAY_TYPE_16;
--GENERAL
      BoardID                     : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
      Data_FormatV                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      FPGA_BuildN                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      CalLVDS                     : OUT STD_LOGIC;
		DATA_BUFF_RST					 : OUT STD_LOGIC;
-- pedestal memory write port
      oPedMemWrite                : OUT PED_MEM_WRITE
      );
END USB_DECODER;

ARCHITECTURE USB_DECODER_Arch OF USB_DECODER IS

   COMPONENT fifo36x512
      PORT (
         rst    : IN  STD_LOGIC;
         wr_clk : IN  STD_LOGIC;
         rd_clk : IN  STD_LOGIC;
         din    : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
         wr_en  : IN  STD_LOGIC;
         rd_en  : IN  STD_LOGIC;
         dout   : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
         full   : OUT STD_LOGIC;
         empty  : OUT STD_LOGIC
         );
   END COMPONENT;


   SIGNAL sWt_cnt              : INTEGER                       := 0;
   SIGNAL sForced_Triggers_Reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

   -- signals state machine     
   TYPE state_type IS (IDLE, WT_FIFO_RD_REQ, INTERPRET_CMD, WT_BUSY, WT_FCD_TRG_BUSY, WAIT_DONE);
   SIGNAL sCMD_State  : state_type;
   SIGNAL sBusy       : STD_LOGIC := '0';
   SIGNAL sWRITE_FLAG : STD_LOGIC := '0';

   -- signals FIFO
   SIGNAL sDecoder_FIFO_IN    : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sDecoder_FIFO_EN    : STD_LOGIC                      := '0';
   SIGNAL sDecoder_FIFO_RDREQ : STD_LOGIC                      := '0';
   SIGNAL sDecoder_FIFO       : STD_LOGIC_VECTOR (35 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sDecoder_FIFO_FULL  : STD_LOGIC                      := '0';
   SIGNAL sDecoder_FIFO_EMPTY : STD_LOGIC                      := '0';

   -- signals WR registers
   SIGNAL sADC_offset          : FIBER_ARRAY_TYPE_16            := (OTHERS => (OTHERS => '0'));
   SIGNAL sZero_supr_trsh      : FIBER_ARRAY_TYPE_16            := (OTHERS => (OTHERS => '0'));
   SIGNAL sZST_Polarity        : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');
   SIGNAL sTEST2HOLD_DELAY     : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');
   SIGNAL sTCD_DELAY_Reg       : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sTCD_EN_TRGMODES_Reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sPipe_Selector       : STD_LOGIC_VECTOR (3 DOWNTO 0)  := (OTHERS => '0');
	SIGNAL LC_FPGA_STATUS		 : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');

   -- signals for single-port RAM
   SIGNAL sPedMemWrite      : PED_MEM_WRITE;
   SIGNAL sPedMemSelect     : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
   SIGNAL sPedMemWE         : STD_LOGIC;
   SIGNAL sPedMemAddrCnt    : UNSIGNED (13 DOWNTO 0)        := (OTHERS => '0');
   SIGNAL sPedMemAddrTemp   : STD_LOGIC_VECTOR (13 DOWNTO 0);
   SIGNAL sPedMemAddrUpdate : STD_LOGIC                     := '0';

   --LVDS re-calibration
   SIGNAL sCalLVDS     : STD_LOGIC := '0';

BEGIN

   Decoder_FIFO : fifo36x512
      PORT MAP (
         rst    => RST,
         wr_clk => CLK40,
         rd_clk => FIFO_RDCLK,
         din    => sDecoder_FIFO_IN,
         wr_en  => sDecoder_FIFO_EN,
         rd_en  => FIFO_RDREQ,
         dout   => FIFO_Q,
         full   => sDecoder_FIFO_FULL,
         empty  => FIFO_EMPTY
         );


   COMMAND_DECODER : PROCESS (CLK40, RST)
      VARIABLE ADDRESS      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0');
      VARIABLE CHANNEL      : INTEGER RANGE 0 TO 7           := 0;
      VARIABLE SUBCHANNEL   : INTEGER RANGE 0 TO 7           := 0;
      VARIABLE READ1_WRITE0 : STD_LOGIC                      := '0';
      VARIABLE counterV     : INTEGER RANGE 0 TO 65535       := 0;

   BEGIN  -- PROCESS
      IF RST = '1' THEN                 -- asynchronous reset (active low)
         sCMD_State <= IDLE;

         ---INITIALIZE ALL OUTPUTS
         LC_RST                  <= (OTHERS => '0');
         --CONFIG
         CONFIG_CMD_IN           <= (OTHERS => (OTHERS => '0'));
         CONFIG_DATA_IN          <= (OTHERS => (OTHERS => '0'));
         CONFIG_DATA_IN_WE       <= (OTHERS => '0');
         --JTAG
         JTAG_DATA_TDI           <= (OTHERS => (OTHERS => '0'));
         JTAG_DATA_WE            <= (OTHERS => '0');
         -- PIPE
         sADC_offset             <= (OTHERS => (OTHERS => '0'));
         sZero_supr_trsh         <= (OTHERS => (OTHERS => '0'));
         sZST_Polarity           <= (OTHERS => '0');  --DIFFERENCE                                                        
         sPipe_Selector          <= (OTHERS => '0');
         -- TCD Registers
         sTCD_DELAY_Reg          <= (OTHERS => '0');
         sTCD_EN_TRGMODES_Reg    <= (OTHERS => '0');  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
         sForced_Triggers_Reg    <= (OTHERS => '0');  -- 7 to 0 is usb trigger 8 to 15 is mode1 or 2 in usb trigger
         Status_Counters_RST_REG <= '0';
         --LC_Trigger_Handler
         sTEST2HOLD_DELAY        <= (OTHERS => '0');
         CMD_FIFO_RDREQ          <= '0';

      ELSIF rising_edge(CLK40) THEN     -- rising clock edge
         -- defaults:
         CMD_FIFO_RDREQ    <= '0';
         sDecoder_FIFO_EN  <= '0';
         CONFIG_DATA_IN_WE <= (OTHERS => '0');
         JTAG_DATA_WE      <= (OTHERS => '0');

         sPedMemAddrUpdate <= '0';
         sPedMemWE         <= '0';
         sPedMemWrite.WE   <= (OTHERS => '0');

         CASE sCMD_State IS
--                              //// wait for command fifo not empty
            WHEN IDLE =>
               IF CMD_FIFO_EMPTY = '0' THEN
                  CMD_FIFO_RDREQ <= '1';
                  sCMD_State     <= WT_FIFO_RD_REQ;
               END IF;

--                              //// clock cycle delay                                          
            WHEN WT_FIFO_RD_REQ =>
               sCMD_State <= INTERPRET_CMD;

--                              //// Interpret current command
            WHEN INTERPRET_CMD =>
                                        -- Nov 18 address is 12 bits
                                        -- 1st (MSB) nibble: Spare
                                        -- 2nd nibble: 0x1 for reading (DATA To PC) - 0x0 for writing (DATA TO RDO) 
                                        -- 3rd nibble, 4th nibble and 5th nibble: Address 

               READ1_WRITE0 := CMD_FIFO_Q (31);
               ADDRESS      := CMD_FIFO_Q (27 DOWNTO 16);
               CHANNEL      := TO_INTEGER(UNSIGNED(CMD_FIFO_Q (26 DOWNTO 24)));
               SUBCHANNEL   := TO_INTEGER(UNSIGNED(CMD_FIFO_Q (18 DOWNTO 16)));


               sCMD_State <= IDLE;
               sBusy      <= '0';

               CASE ADDRESS IS

                                                 --||| GENERAL           
                  WHEN x"000" =>                 -- SSD ID                     
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"5344";
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;

                  WHEN x"001" =>        -- BOARD ID                   
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"000" & BoardID;  --
                     ELSE               --WRITE
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"002" =>        -- FPGA BUILD NUMBER                  
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= FPGA_BuildN;
                     ELSE               --WRITE
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"003" =>  -- SIU data Format Version                    
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"00" & Data_FormatV;
                     ELSE               --WRITE
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                                        --||| STATUS    
                  WHEN x"010" =>        -- FIBER LINK STATUS
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"4444";  --TEMPORAL
                     ELSE               --WRITE
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"011" =>        -- LC FPGA STATUS
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
								sDecoder_FIFO_IN (15 DOWNTO 0) <= x"00" & LC_FPGA_STATUS;  --TEMPORAL see end of document
                     ELSE               --WRITE
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"012" =>        --CLEARS THE STATUS LATCH
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        NULL;           -- WRITE ONLY REGISTER
                     ELSE               --WRITE
                        NULL;  --sSTATUS_LATCH <= (OTHERS => '0'); -- TEMPORAL
                     END IF;

                                        --||| PEDESTAL PATTERN 
                  WHEN x"020" =>        															-- select fiber channel
                     IF READ1_WRITE0 = '1' THEN                     --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"000" & b"0" & sPedMemSelect;
                     ELSE  --WRITE                                                                      
                        sPedMemSelect <= CMD_FIFO_Q (2 DOWNTO 0);
                     END IF;
							
                  WHEN x"021" =>        																-- select write address
                     IF READ1_WRITE0 = '1' THEN                     --READ
                        sDecoder_FIFO_EN               <= '1';
                        -- read back the current write address
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= b"00" & STD_LOGIC_VECTOR (sPedMemAddrCnt);
                     ELSE               --WRITE
                        sPedMemAddrUpdate <= '1';
                        sPedMemAddrTemp   <= CMD_FIFO_Q (13 DOWNTO 0);
                     END IF;
							
                  WHEN x"022" =>        -- write the data
                     IF READ1_WRITE0 = '1' THEN                     --READ
                        NULL;				--write only register
                     ELSE  --WRITE                                                                      
                        sPedMemWE                                               <= '1';
                        sPedMemWrite.WE (TO_INTEGER (UNSIGNED (sPedMemSelect))) <= '1';
                        sPedMemWrite.DATA                                       <= CMD_FIFO_Q (8 DOWNTO 0);
                     END IF;
							
                  WHEN x"023" =>
                     IF READ1_WRITE0 = '1' THEN                     --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"FF23";  --TEMPORAL
                     ELSE  --WRITE                                                                      
                        NULL;           -- TEMPORAL READ AND WRITE REG 
                     END IF;
							
                  WHEN x"024" =>
                     IF READ1_WRITE0 = '1' THEN                     --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"FF24";  --TEMPORAL
                     ELSE  --WRITE                                                                      
                        NULL;           -- TEMPORAL READ AND WRITE REG 
                     END IF;

                                                 --||| STATUS COUNTERS
                  WHEN x"030" =>                 -- RESET STATUS COUNTERS
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        NULL;                    -- WRITE ONLY REGISTER
                     ELSE                        --WRITE
                        Status_Counters_RST_REG <= CMD_FIFO_Q (0);
                     END IF;

                  WHEN x"031" =>                 -- TCD TRIGGERS RECEIVED
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= TCD_TRG_RCVD_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;

                  WHEN x"032" =>                 -- TCD LEVEL 0 RECEIVED
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= TCD_Level0_RCVD_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;

                  WHEN x"033" =>                 -- SIU PACKET COUNTER
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= SIU_PACKET_CNT_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;

                  WHEN x"034" =>                 -- RHIC STROBE LSB
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= RHIC_STROBE_LSB_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;
                  WHEN x"035" =>                 -- RHIC STROBE MSB
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= RHIC_STROBE_MSB_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;
                  WHEN x"036" =>                 -- HOLD COUNTER
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= N_HOLDS_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;
                  WHEN x"037" =>                 -- TEST COUNTER
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= N_TESTS_REG;
                     ELSE                        --WRITE
                        NULL;                    -- READ ONLY REGISTER
                     END IF;

                                        --||| LVDS re-calibration
                  WHEN x"040" =>        -- LVDS re-calibration        
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"000" & b"000" & sCalLVDS;
                     ELSE  --WRITE                                                                      
                        sCalLVDS <= CMD_FIFO_Q (0);
                     END IF;
							
                                        --||| DAQ
                  WHEN x"080" =>        -- FIBER ENABLE       
                     IF READ1_WRITE0 = '1' THEN                     --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"FFFF";  --TEMPORAL
                     ELSE  --WRITE                                                                      
                        NULL;           -- TEMPORAL READ AND WRITE REG 
                     END IF;

                  WHEN x"081" =>        -- TEST TO HOLD DELAY 
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"00" & sTEST2HOLD_DELAY;
                     ELSE  --WRITE                                                                      
                        sTEST2HOLD_DELAY <= CMD_FIFO_Q (7 DOWNTO 0);
                     END IF;

                  WHEN x"082" =>        -- TCD DELAY  
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= sTCD_DELAY_Reg;
                     ELSE  --WRITE                                                                      
                        sTCD_DELAY_Reg <= CMD_FIFO_Q (15 DOWNTO 0);
                     END IF;


                  WHEN x"083" =>        -- ENABLE TCD TRIGGERS        
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= sTCD_EN_TRGMODES_Reg;
                     ELSE               --WRITE
                        sTCD_EN_TRGMODES_Reg <= CMD_FIFO_Q (15 DOWNTO 0);  -- 15-8 is TCD enable - 7-4 forced mode 1 - 3-0 forced mode 0
                     END IF;


                  WHEN x"084" =>                 -- FORCED TRIGGERS    
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        NULL;                    -- WRITE ONLY REGISTER
                     ELSE                        --WRITE
                        sForced_Triggers_Reg <= CMD_FIFO_Q (15 DOWNTO 0);
                        sCMD_State           <= WT_FCD_TRG_BUSY;
                     END IF;

                  WHEN x"085" =>                 -- DATA FORMAT
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"000" & sPipe_Selector;
                     ELSE                        --WRITE
                        sPipe_Selector <= CMD_FIFO_Q (3 DOWNTO 0);
                     END IF;

                  WHEN x"086" =>                 -- RESET DATA BUFFERS 
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        NULL;                    -- WRITE ONLY REGISTER
                     ELSE                        --WRITE
                        DATA_BUFF_RST  	<= CMD_FIFO_Q (0);
                     END IF;

                  WHEN x"087" =>        -- SIU BUFFER STATUS  
                     IF READ1_WRITE0 = '1' THEN  --READ         
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"EEEE";  --TEMPORAL
                     ELSE               --WRITE
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                                        --||| FIBER CHANNELS            
                  WHEN x"800" | x"900" | x"A00" | x"B00" | x"C00" | x"D00" | x"E00" | x"F00" =>  -- LC FPGA CONFIG CMD
                     IF READ1_WRITE0 = '1' THEN  --READ
                        NULL;           -- WRITE ONLY REGISTER
                     ELSE  --WRITE                                                                      
                        CONFIG_CMD_IN (CHANNEL) <= CMD_FIFO_Q (15 DOWNTO 0);
                        sBusy                   <= CONFIG_BUSY (CHANNEL);
                        sCMD_State              <= WT_BUSY;
                     END IF;

                  WHEN x"801" | x"901" | x"A01" | x"B01" | x"C01" | x"D01" | x"E01" | x"F01" =>  -- LC FPGA CONFIG DATA
                     IF READ1_WRITE0 = '1' THEN  --READ
                        NULL;           -- WRITE ONLY REGISTER
                     ELSE  --WRITE                                                                      
                        CONFIG_DATA_IN (CHANNEL)    <= CMD_FIFO_Q (15 DOWNTO 0);
                        CONFIG_DATA_IN_WE (CHANNEL) <= '1';
                        sBusy                       <= CONFIG_BUSY (CHANNEL);
                        sCMD_State                  <= WT_BUSY;
                     END IF;

                  WHEN x"802" | x"902" | x"A02" | x"B02" | x"C02" | x"D02" | x"E02" | x"F02" =>  -- LC FPGA CONFIG STATUS
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= CONFIG_STATUS_OUT (CHANNEL);
                     ELSE  --WRITE                                                                      
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"804" | x"904" | x"A04" | x"B04" | x"C04" | x"D04" | x"E04" | x"F04" =>  --JTAG
                     IF READ1_WRITE0 = '1' THEN  --READ
                        NULL;           -- WRITE ONLY REGISTER
                     ELSE  --WRITE                                                                      
                        JTAG_DATA_TDI (CHANNEL) <= CMD_FIFO_Q (15 DOWNTO 0);
                        JTAG_DATA_WE (CHANNEL)  <= '1';
                        sBusy                   <= JTAG_BUSY (CHANNEL);
                        sCMD_State              <= WT_BUSY;
                     END IF;

                  WHEN x"805" | x"905" | x"A05" | x"B05" | x"C05" | x"D05" | x"E05" | x"F05" =>  --LC JTAG RESET
                     IF READ1_WRITE0 = '1' THEN  --READ
                        NULL;           -- WRITE ONLY REGISTER
                     ELSE  --WRITE                                                                      
                        LC_RST (CHANNEL) <= CMD_FIFO_Q (0);
                     END IF;

                  WHEN x"808" | x"908" | x"A08" | x"B08" | x"C08" | x"D08" | x"E08" | x"F08" =>  --ADC OFFSET
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= sADC_offset (CHANNEL);
                     ELSE  --WRITE                                                                      
                        sADC_offset (CHANNEL) <= CMD_FIFO_Q (15 DOWNTO 0);
                     END IF;

                  WHEN x"809" | x"909" | x"A09" | x"B09" | x"C09" | x"D09" | x"E09" | x"F09" =>  --ZERO SUPRESSION THERSHOLD and POLARITY
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= b"000" & sZST_Polarity (CHANNEL) & b"00" & sZero_supr_trsh (CHANNEL)(9 DOWNTO 0);
                     ELSE  --WRITE                                                                      
                        sZero_supr_trsh (CHANNEL) <= x"0" & b"00" & CMD_FIFO_Q (9 DOWNTO 0);
                        sZST_Polarity (CHANNEL)   <= CMD_FIFO_Q (12);
                     END IF;

                  WHEN x"80A" | x"90A" | x"A0A" | x"B0A" | x"C0A" | x"D0A" | x"E0A" | x"F0A" =>  -- FIBER STATUS
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= x"DDD" & '0' & ADDRESS (10 DOWNTO 8);  --FIBER_STATUS(CHANNEL); --TEMPORAL
                     ELSE  --WRITE                                                                      
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"810" | x"910" | x"A10" | x"B10" | x"C10" | x"D10" | x"E10" | x"F10" |
                     x"811" | x"911" | x"A11" | x"B11" | x"C11" | x"D11" | x"E11" | x"F11" |
                     x"812" | x"912" | x"A12" | x"B12" | x"C12" | x"D12" | x"E12" | x"F12" |
                     x"813" | x"913" | x"A13" | x"B13" | x"C13" | x"D13" | x"E13" | x"F13" |
                     x"814" | x"914" | x"A14" | x"B14" | x"C14" | x"D14" | x"E14" | x"F14" |
                     x"815" | x"915" | x"A15" | x"B15" | x"C15" | x"D15" | x"E15" | x"F15" |
                     x"816" | x"916" | x"A16" | x"B16" | x"C16" | x"D16" | x"E16" | x"F16" |
                     x"817" | x"917" | x"A17" | x"B17" | x"C17" | x"D17" | x"E17" | x"F17" =>  -- LC STATUS 0-7
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= LC_STATUS_REG (CHANNEL)(SUBCHANNEL);
                     ELSE  --WRITE                                                                      
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN x"818" | x"918" | x"A18" | x"B18" | x"C18" | x"D18" | x"E18" | x"F18" =>  -- LC STATUS 8 (Hybrid Power Status)
                     IF READ1_WRITE0 = '1' THEN  --READ
                        sDecoder_FIFO_EN               <= '1';
                        sDecoder_FIFO_IN (15 DOWNTO 0) <= LC_HYBRIDS_POWER_STATUS_REG (CHANNEL);
                     ELSE  --WRITE                                                                      
                        NULL;           -- READ ONLY REGISTER
                     END IF;

                  WHEN OTHERS =>
                     NULL;
               END CASE;

--                              ////                                            
            WHEN WT_BUSY =>  --wait for busy lines to propagate back keep updating them
               CASE ADDRESS IS
                  WHEN x"800" | x"900" | x"A00" | x"B00" | x"C00" | x"D00" | x"E00" | x"F00" =>  --LC FPGA CONFIG CMD
                     sBusy                          <= CONFIG_BUSY (CHANNEL);
                     sDecoder_FIFO_IN (15 DOWNTO 0) <= CONFIG_STATUS_OUT (CHANNEL);

                  WHEN x"801" | x"901" | x"A01" | x"B01" | x"C01" | x"D01" | x"E01" | x"F01" =>  --LC FPGA CONFIG DATA
                     sBusy                          <= CONFIG_BUSY (CHANNEL);
                     sDecoder_FIFO_IN (15 DOWNTO 0) <= CONFIG_STATUS_OUT (CHANNEL);

                  WHEN x"804" | x"904" | x"A04" | x"B04" | x"C04" | x"D04" | x"E04" | x"F04" =>  --JTAG
                     sBusy                          <= JTAG_BUSY (CHANNEL);
                     sDecoder_FIFO_IN (15 DOWNTO 0) <= JTAG_DATA_TDO (CHANNEL);

                  WHEN OTHERS =>
                     NULL;
               END CASE;
               sWt_cnt <= sWt_cnt + 1;
               IF sWt_cnt > 2 THEN
                  sCMD_State <= WAIT_DONE;
                  sWt_cnt    <= 0;
               END IF;

--                              ////                                            
            WHEN WT_FCD_TRG_BUSY =>  --wait for busy lines to propagate back keep updating them
               sWt_cnt <= sWt_cnt + 1;
               sBusy   <= BUSY_COMBINED;
               IF sWt_cnt > 8 THEN
                  sCMD_State           <= WAIT_DONE;
                  sWt_cnt              <= 0;
                  sForced_Triggers_Reg <= sForced_Triggers_Reg (15 DOWNTO 8) & x"00";
               END IF;

--                              ////                                    
            WHEN WAIT_DONE =>
               CASE ADDRESS IS
                  WHEN x"084" =>        -- WAIT FOR PIPE BUSY TO GO LOW
                     sBusy       <= BUSY_COMBINED;
                     sWRITE_FLAG <= '0';

                  WHEN x"800" | x"900" | x"A00" | x"B00" | x"C00" | x"D00" | x"E00" | x"F00" =>  --LC FPGA CONFIG CMD
                     sBusy       <= CONFIG_BUSY (CHANNEL);
                     sWRITE_FLAG <= '0';

                  WHEN x"801" | x"901" | x"A01" | x"B01" | x"C01" | x"D01" | x"E01" | x"F01" =>  --LC FPGA CONFIG DATA
                     sBusy       <= CONFIG_BUSY (CHANNEL);
                     sWRITE_FLAG <= '0';

                  WHEN x"804" | x"904" | x"A04" | x"B04" | x"C04" | x"D04" | x"E04" | x"F04" =>  --JTAG
                     sBusy                          <= JTAG_BUSY (CHANNEL);
                     sDecoder_FIFO_IN (15 DOWNTO 0) <= JTAG_DATA_TDO (CHANNEL);
                     sWRITE_FLAG                    <= '1';

                  WHEN OTHERS =>
                     NULL;

               END CASE;

                                        -- wait for busy to go away
               IF sBusy = '0' THEN
                  sCMD_State <= IDLE;
                  IF sWRITE_FLAG = '1' THEN
                     sDecoder_FIFO_EN <= '1';
                  END IF;
               END IF;

--                              ////                                    
            WHEN OTHERS =>
               sCMD_State <= IDLE;

         END CASE;
      END IF;
   END PROCESS COMMAND_DECODER;

   ADC_offset                      <= sADC_offset;
   Zero_supr_trsh                  <= sZero_supr_trsh;
   ZST_Polarity                    <= sZST_Polarity;
   TCD_DELAY_Reg                   <= sTCD_DELAY_Reg;
   TEST2HOLD_DELAY                 <= sTEST2HOLD_DELAY;
   TCD_EN_TRGMODES_Reg             <= sTCD_EN_TRGMODES_Reg;
   Pipe_Selector                   <= sPipe_Selector;
   Forced_Triggers_Reg             <= sForced_Triggers_Reg;
   CalLVDS                         <= sCalLVDS;
   sDecoder_FIFO_IN (31 DOWNTO 16) <= CMD_FIFO_Q(31 DOWNTO 16);


   -- pedestal memory
   oPedMemWrite      <= sPedMemWrite;
   sPedMemWrite.CLK  <= CLK40;
   sPedMemWrite.ADDR <= STD_LOGIC_VECTOR (sPedMemAddrCnt);
   PED_MEM_ADDR_ADVANCE : PROCESS (CLK40, RST) IS
   BEGIN  -- PROCESS PED_MEM_ADDR_ADVANCE
      IF RST = '1' THEN                 -- asynchronous reset (active high)
         sPedMemAddrCnt <= (OTHERS => '0');
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
         -- due to the one clock cycle delay of sPedMemWE, the counter
         -- incrememts after the write of the data to memory
         IF sPedMemAddrUpdate = '1' THEN
            IF UNSIGNED(sPedMemAddrTemp) > 12287 THEN 
					sPedMemAddrCnt <= b"10" & x"FFF"; --12287
				ELSE
					sPedMemAddrCnt <= UNSIGNED (sPedMemAddrTemp);
				END IF;
         ELSIF sPedMemWE = '1' THEN
            IF sPedMemAddrCnt = 12287 THEN
               -- wrap around at the end of teh memory range
               sPedMemAddrCnt <= (OTHERS => '0');
            ELSE
               sPedMemAddrCnt <= sPedMemAddrCnt + 1;
            END IF;
         END IF;
      END IF;
   END PROCESS PED_MEM_ADDR_ADVANCE;
	
	LC_STATUS : FOR num IN 0 TO 7 GENERATE   --TEMPORAL
	LC_FPGA_STATUS (num) <= '1' WHEN CONFIG_STATUS_OUT (num) = x"0110" ELSE '0';  
	END GENERATE LC_STATUS;
	-- this signal was suposed to be a check of the constant status information 
	--sent by the LC_FPGA, it is wired temporary to the Configured status Register 
	-- of the LC that serves the same function.
	


END USB_DECODER_Arch;