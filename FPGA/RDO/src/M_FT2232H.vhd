-- $Id: M_FT2232H.vhd 162 2013-03-19 14:41:55Z jschamba $
-------------------------------------------------------------------------------
-- Title      : FTDI FT2232H Mini Module Interface on Motherboard
-- Project    : HFT PXL
-------------------------------------------------------------------------------
-- File       : M_FT2232H.vhd
-- Author     : Joachim Schambach
-- Company    : University of Texas
-- Created    : 2012-12-29
-- Last update: 2014-02-27
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Interface to the FT2232HQ USB minimodule on motherboard.
--              Protocol uses first 32bit word as "header" to determine
--              if READ or WRITE (from electronics to PC) and how many words
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-12-29  1.0      jschamba        Created
-- 2014-01-21  1.1      thorsten        init resync if expected AAAA is missing
-- 2014-02-26  1.2      thorsten        added wait states due to USB comm error
-- 2014-02-26  1.3      thorsten        changed read statemachine to ensure
--                                      sLatchData is issued when sRxf_n is
--                                      back high. The write FSM stared to
--                                      early and saw the sRxf_n still low;
--                                      aborting the write cycle
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY M_FT2232H IS
   PORT (
      CLK            : IN  STD_LOGIC;   -- 50MHz clock input
      RESET          : IN  STD_LOGIC;   -- Active high reset
      -- FT2232H signals
      D_in           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   -- FIFO Data bus in
      D_out          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- FIFO Data bus out
      D_T            : OUT STD_LOGIC;   -- FIFO Data bus enable
      -- "C" Port
      RXF_n          : IN  STD_LOGIC;   -- Read enable
      TXE_n          : IN  STD_LOGIC;   -- Write enable
      RD_n           : OUT STD_LOGIC;   -- Read from USB FIFO
      WR_n           : OUT STD_LOGIC;   -- Write to USB FIFO
      SIWU           : OUT STD_LOGIC;   -- Send Immediate/Wake Up
      CLKOUT         : IN  STD_LOGIC;   -- Sync USB FIFO clock
      OE_n           : OUT STD_LOGIC;   -- Output enable (for sync FIFO)
      -- From FPGA to PC
      FIFO_Q         : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface fifo data output port
      FIFO_EMPTY     : IN  STD_LOGIC;   -- interface fifo "emtpy" signal
      FIFO_RDREQ     : OUT STD_LOGIC;   -- interface fifo read request
      FIFO_RDCLK     : OUT STD_LOGIC;   -- interface fifo read clock
      -- From PC to FPGA
      CMD_FIFO_Q     : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);  -- interface command fifo data out port
      CMD_FIFO_EMPTY : OUT STD_LOGIC;  -- interface command fifo "emtpy" signal
      CMD_FIFO_RDREQ : IN  STD_LOGIC    -- interface command fifo read request
      );
END M_FT2232H;

ARCHITECTURE rtl OF M_FT2232H IS
   CONSTANT ZERO_18 : STD_LOGIC_VECTOR(17 DOWNTO 0) := "00" & x"0000";

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

   --

   SIGNAL sClkout            : STD_LOGIC;
   SIGNAL sSiwu              : STD_LOGIC;
   SIGNAL sRd_n              : STD_LOGIC;  -- Read from FIFO
   SIGNAL sWr_n              : STD_LOGIC;  -- Write to FIFO
   SIGNAL sRxf_n             : STD_LOGIC;  -- Read Enable
   SIGNAL sTxe_n             : STD_LOGIC;  -- Write Enable
   SIGNAL ssRxf_n            : STD_LOGIC;  -- Read Enable
   SIGNAL ssTxe_n            : STD_LOGIC;  -- Write Enable
   -- The KEEP ATTRIBUTE prevents ISE from palcing the signals into the LUT and thus
   -- negating the intention the pipeline the signal to ease the timing
   ATTRIBUTE KEEP            : STRING;
   ATTRIBUTE KEEP OF sRxf_n  : SIGNAL IS "TRUE";
   ATTRIBUTE KEEP OF sTxe_n  : SIGNAL IS "TRUE";
   ATTRIBUTE KEEP OF ssRxf_n : SIGNAL IS "TRUE";
   ATTRIBUTE KEEP OF ssTxe_n : SIGNAL IS "TRUE";

   SIGNAL sOe_n         : STD_LOGIC;    -- Output Enable
   --
   SIGNAL sCmdFifoWrClk : STD_LOGIC;
   SIGNAL sCmdFifoD     : STD_LOGIC_VECTOR(35 DOWNTO 0);
   SIGNAL sRcvdData     : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL sCmdFifoWrreq : STD_LOGIC;
   SIGNAL sCmdFifoFull  : STD_LOGIC;
   SIGNAL sLatchData    : STD_LOGIC;
   SIGNAL sRdCtr        : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL sWrCtr        : STD_LOGIC_VECTOR(17 DOWNTO 0);
   SIGNAL byteCtr       : INTEGER RANGE 0 TO 3;

   TYPE rdState_type IS (
      RdStateIni0,
      RdStateIni1,
      RdStateIni1a,
      RdStateIni1b,
      RdStateIni2,
      RdStateIni3,
      RdStateIni4,
      RdStateIni5,
      RdStateIni5a,
      RdStateIni5b,
      RdStateIni6,
      RdStateIni7a,
      RdStateIni7b,
      RdStateIni8,
      RdState0,
      RdState1,
      RdState1a,
      RdState1b,
      RdState2,
      RdState3
      );
   SIGNAL rdState : rdState_type;

   TYPE wrState_type IS (
      WrState0,
      WrState1,
      WrState2,
      WrState2b,
      WrState3,
      WrState4
      );
   SIGNAL wrState : wrState_type;

-------------------------------------------------------------------------------
BEGIN

--------------------------------------------------------------------------------
-- Bidir I/O control
--------------------------------------------------------------------------------

   -- Ctrl Bus (C) buffers:
   -- C(0) : RXFn (I)
   -- C(1) : TXEn (I)
   -- C(2) : RD_n (O)
   -- C(3) : WR_n (O)
   -- C(4) : SIWU (O)
   -- C(5) : CLKOUT (I), only in sync FIFO mode
   -- C(6) : OE_n (O)
   -- C(7) : not connected

   -- inputs
   Sync : PROCESS (CLK) IS
   BEGIN
      IF rising_edge(CLK) THEN
         -- register the input signals to avoid metastability
         sRxf_n  <= ssRxf_n;
         sTxe_n  <= ssTxe_n;
         ssRxf_n <= RXF_n;
         ssTxe_n <= TXE_n;
      END IF;
   END PROCESS Sync;
   sClkout <= CLKOUT;                   -- only in "sync FIFO" config

   -- outputs
   RD_n <= sRd_n;  -- Read from channel A FIFO when nRD is low
   WR_n <= sWr_n;  -- Write to channel A FIFO when nWR is low
   SIWU <= sSiwu;                       -- Used as "Send Immediate"
   OE_n <= sOe_n;                       -- only in "sync FIFO" config

   -- logic starts here

   -- AD Bus buffers: Bi-directional
   D_T <= sOE_n;

   -- output FIFO word one byte at a time
   WITH sWrCtr(1 DOWNTO 0) SELECT
      D_out <=
      FIFO_Q(7 DOWNTO 0)   WHEN "00",
      FIFO_Q(15 DOWNTO 8)  WHEN "11",
      FIFO_Q(23 DOWNTO 16) WHEN "10",
      FIFO_Q(31 DOWNTO 24) WHEN OTHERS;

   -- event FIFO clock
   FIFO_RDCLK <= CLK;

   -- cmd FIFO
   sCmdFifoWrClk <= CLK;
   cmd_fifo : fifo36x512
      PORT MAP (
         rst    => RESET,
         wr_clk => sCmdFifoWrClk,
         rd_clk => CLK,
         din    => sCmdFifoD,
         wr_en  => sCmdFifoWrreq,
         rd_en  => CMD_FIFO_RDREQ,
         dout   => CMD_FIFO_Q,
         full   => sCmdFifoFull,
         empty  => CMD_FIFO_EMPTY
         );
   sCmdFifoD(35 DOWNTO 32) <= "0000";   -- not used

   -----------------------------------------------------------------------------
   -- Read process, driven by RXFn going low
   -----------------------------------------------------------------------------
   rd_process : PROCESS (CLK, RESET) IS
   BEGIN  -- PROCESS rd_process
      IF RESET = '1' THEN               -- asynchronous reset (active hi)
--      rdState                <= RdState0;
         rdState                <= RdStateIni0;
         sRd_n                  <= '1';
         sCmdFifoD(31 DOWNTO 0) <= (OTHERS => '0');
         SRcvdData              <= (OTHERS => '0');
         sCmdFifoWrreq          <= '0';
         byteCtr                <= 0;
         sLatchData             <= '0';
         sRdCtr                 <= (OTHERS => '0');

      ELSIF rising_edge(CLK) THEN       -- rising clock edge
         sCmdFifoWrreq <= '0';          -- default
         sLatchData    <= '0';


         CASE rdState IS
            WHEN RdStateIni0 =>
               sRd_n <= '1';
               IF sRxf_n = '0' THEN
                  -- wait for "Read Ready" low
                  rdState <= RdStateIni1;
               END IF;

            WHEN RdStateIni1 =>
               sRd_n   <= '0';          -- read it
               rdState <= RdStateIni1a;

            WHEN RdStateIni1a =>        -- make sure RD_N > 30ns
               sRd_n   <= '0';          -- read it
               rdState <= RdStateIni1b;

            WHEN RdStateIni1b =>        -- make sure RD_N > 30ns
               sRd_n   <= '0';          -- read it
               rdState <= RdStateIni2;

            WHEN RdStateIni2 =>
               sRcvdData(31 DOWNTO 24) <= D_IN;  -- latch byte
               sRcvdData(23 DOWNTO 0)  <= sRcvdData(31 DOWNTO 8);  -- shift it
               sRd_n                   <= '1';

               IF (sRxf_n = '0') THEN
                  rdState <= RdStateIni3;
               ELSIF D_IN(7 DOWNTO 1) = "1010101" THEN
                  rdState <= RdStateIni4;
               ELSE
                  rdState <= RdStateIni0;
               END IF;

            WHEN RdStateIni3 =>
               sRd_n <= '1';
               -- wait for "Read Ready" to go back high
               IF sRxf_n = '0' THEN
                  rdState <= RdStateIni3;
               ELSIF sRcvdData(31 DOWNTO 25) = "1010101" THEN  -- AA or AB
                  rdState <= RdStateIni4;
               ELSE
                  rdState <= RdStateIni0;
               END IF;

            WHEN RdStateIni4 =>
               sRd_n <= '1';
               IF sRxf_n = '0' THEN
                  -- wait for "Read Ready" low
                  rdState <= RdStateIni5;
               END IF;

            WHEN RdStateIni5 =>
               sRd_n   <= '0';          -- read it
               rdState <= RdStateIni5a;

            WHEN RdStateIni5a =>        -- make sure RD_N > 30ns
               sRd_n   <= '0';          -- read it
               rdState <= RdStateIni5b;

            WHEN RdStateIni5b =>        -- make sure RD_N > 30ns
               sRd_n   <= '0';          -- read it
               rdState <= RdStateIni6;


            WHEN RdStateIni6 =>
               sRcvdData(31 DOWNTO 24) <= D_IN;  -- latch byte
               sRcvdData(23 DOWNTO 0)  <= sRcvdData(31 DOWNTO 8);  -- shift it
               sRd_n                   <= '1';

               IF (sRxf_n = '0') AND (D_IN = x"aa") THEN
                  -- latch 32bit word
                  byteCtr <= 0;
                  rdState <= RdStateIni7a;
               ELSIF sRxf_n = '0' THEN
                  rdState <= RdStateIni7b;
               ELSIF D_IN = x"aa" THEN
                  -- latch 32bit word
                  byteCtr <= 0;
                  rdState <= RdStateIni8;
               ELSE
                  rdState <= RdStateIni0;
               END IF;

            WHEN RdStateIni7a =>
               sRd_n <= '1';
               -- wait for "Read Ready" to go back high
               IF sRxf_n = '0' THEN
                  rdState <= RdStateIni7a;
               ELSIF sRcvdData(31 DOWNTO 24) = x"aa" THEN
                  sLatchData <= '1';
                  rdState    <= RdState0;
               ELSE
                  sLatchData <= '1';
                  rdState    <= RdStateIni0;
               END IF;

            WHEN RdStateIni7b =>
               sRd_n <= '1';
               -- wait for "Read Ready" to go back high
               IF sRxf_n = '0' THEN
                  rdState <= RdStateIni7b;
               ELSIF sRcvdData(31 DOWNTO 24) = x"aa" THEN
                  rdState <= RdState0;
               ELSE
                  rdState <= RdStateIni0;
               END IF;

            WHEN RdStateIni8 =>
               IF sRxf_n = '0' THEN
                  rdState <= RdStateIni8;
               ELSE
                  sLatchData <= '1';
                  rdState    <= RdState0;
               END IF;

            WHEN RdState0 =>
               sRd_n <= '1';
               IF (sRxf_n = '0') AND (sCmdFifoFull = '0') THEN
                  -- wait for "Read Ready" low
                  rdState <= RdState1;
               END IF;

            WHEN RdState1 =>
               sRd_n   <= '0';          -- read it
               rdState <= RdState1a;

            WHEN RdState1a =>           -- make sure RD_N > 30ns
               sRd_n   <= '0';          -- read it
               rdState <= RdState1b;

            WHEN RdState1b =>           -- make sure RD_N > 30ns
               sRd_n   <= '0';          -- read it
               rdState <= RdState2;

            WHEN RdState2 =>
               sRcvdData(31 DOWNTO 24) <= D_IN;  -- latch byte
               sRcvdData(23 DOWNTO 0)  <= sRcvdData(31 DOWNTO 8);  -- shift it
               sRd_n                   <= '1';

               -- If "Read Ready" still low, wait in the next state,
               -- otherwise, continue to next byte
               IF sRxf_n = '1' THEN
                  IF byteCtr = 3 THEN
                     -- latch 32bit word
                     sLatchData <= '1';
                     byteCtr    <= 0;
                  ELSE
                     byteCtr <= byteCtr + 1;
                  END IF;
                  rdState <= RdState0;
               ELSE
                  rdState <= RdState3;
               END IF;

            WHEN RdState3 =>
               sRd_n <= '1';
               -- wait for "Read Ready" to go back high
               IF sRxf_n = '1' THEN
                  IF byteCtr = 3 THEN
                     -- latch 32bit word
                     sLatchData <= '1';
                     byteCtr    <= 0;
                  ELSE
                     byteCtr <= byteCtr + 1;
                  END IF;
                  rdState <= RdState0;
               ELSE
                  rdState <= RdState3;
               END IF;

            WHEN OTHERS =>
               -- shouldn't happen
               rdState <= RdStateIni0;
         END CASE;


         IF sLatchData = '1' THEN
            sCmdFifoD(31 DOWNTO 0) <= sRcvdData;
            IF (sRcvdData(31 DOWNTO 16) = x"AAAA") AND (sRdCtr = x"00") THEN
               -- start new "Read" transaction
               sCmdFifoWrreq <= '0';
               sRdCtr        <= sRcvdData(7 DOWNTO 0);
            ELSIF ((sRdCtr = x"00") AND NOT (sRcvdData(31 DOWNTO 16) = x"AAAB")) THEN
               -- "Read" transaction finished
               sRdCtr        <= sRdCtr;
               sCmdFifoWrreq <= '0';
               -- this should never happen try to find sync again
               rdState       <= RdStateIni0;
            ELSE
               -- "Read" transaction
               IF sRdCtr = x"00" THEN
                  sRdCtr        <= sRdCtr;
                  sCmdFifoWrreq <= '0';
               ELSE
                  sRdCtr        <= sRdCtr - 1;
                  sCmdFifoWrreq <= '1';                  
               END IF;
            END IF;
         END IF;

      END IF;
   END PROCESS rd_process;

   -----------------------------------------------------------------------------
   -- Write process, driven by TXEn going low
   -----------------------------------------------------------------------------
   wr_process : PROCESS (CLK, RESET) IS
   BEGIN  -- PROCESS write_process
      IF RESET = '1' THEN               -- asynchronous reset (active high)
         sOE_n      <= '1';             -- default to input
         sWr_n      <= '1';
         sSiwu      <= '1';
         sWrCtr     <= (OTHERS => '0');
         FIFO_RDREQ <= '0';
         wrState    <= WrState0;

      ELSIF rising_edge(CLK) THEN
         sOE_n      <= '0';             -- default to ouput
         sWr_n      <= '1';
         sSiwu      <= '1';
         FIFO_RDREQ <= '0';

         CASE wrState IS
            WHEN WrState0 =>
               sOE_n <= '1';            -- input while waiting
               IF (sRcvdData(31 DOWNTO 16) = x"AAAB") AND (sRdCtr = x"00") AND (sLatchData = '1') THEN
                  -- write counter is 32bit words to write times 4
                  sWrCtr  <= sRcvdData(15 DOWNTO 0) & "00";
                  wrState <= WrState1;
               END IF;

            WHEN WrState1 =>
               IF sRxf_n = '0' THEN
                  -- back to reading again
                  wrState <= WrState0;
               ELSIF sWrCtr = ZERO_18 THEN
                  -- if 0 words are requested, also back to reading again
                  wrState <= WrState0;
               ELSIF FIFO_EMPTY = '0' THEN
                  -- otherwise, wait for FIFO not empty
                  FIFO_RDREQ <= '1';
                  wrState    <= wrState2;
               END IF;

            WHEN WrState2 =>
               sOE_n <= '0';
               IF sRxf_n = '0' THEN
                  -- back to reading again
                  wrState <= WrState0;
               ELSIF sTxe_n = '0' THEN
                  -- wait for TX Enable low
                  wrState <= WrState2b;
               END IF;

            WHEN WrState2b =>
               wrState <= WrState3;

            WHEN WrState3 =>
               sOE_n <= '0';
               sWr_n <= '0';            -- indicate next byte ready
               IF sTxe_n = '1' THEN
                  -- wait for TX Enable to go high (write accepted)
                  sWrCtr  <= sWrCtr - 1;
                  wrState <= WrState4;
               END IF;

            WHEN WrState4 =>
               IF sWrCtr = ZERO_18 THEN
                  -- Finished with all requested WRITES
                  sSiwu   <= '0';       -- "Send Immediate"
                  wrState <= WrState0;
               ELSIF sWrCtr(1 DOWNTO 0) = "00" THEN
                  -- get next FIFO word
                  wrState <= wrState1;
               ELSE
                  -- next byte write
                  wrState <= WrState2;
               END IF;

            WHEN OTHERS =>
               -- should never happen
               wrState <= WrState0;
         END CASE;

      END IF;
   END PROCESS wr_process;

END rtl;
