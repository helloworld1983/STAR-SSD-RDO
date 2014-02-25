-- $Id: utilities_pkg.vhd 110 2012-10-16 17:57:48Z jschamba $
-------------------------------------------------------------------------------
-- Title      : Utilities Package
-- Project    : HFT PXL
-------------------------------------------------------------------------------
-- File       : utilities_pkg.vhd
-- Author     : Joachim Schambach (jschamba@physics.utexas.edu)
-- Company    : University of Texas at Austin
-- Created    : 2012-07-24
-- Last update: 2012-08-03
-- Platform   : Windows, Xilinx ISE 13.4
-- Target     : Virtex-6 (XC6VLX240T-FF1759)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Several utility functions
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-07-24  1.0      jschamba        Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;

PACKAGE utilities IS
  TYPE ladderArray_type IS ARRAY (1 TO 4,  -- 4 ladders
                                  1 TO 10,  -- 10 sensors
                                  1 TO 2) OF std_logic;  -- 2 outputs
  IMPURE FUNCTION svnversion_from_file(filename : IN string) RETURN std_logic_vector;
END PACKAGE utilities;

PACKAGE BODY utilities IS
  IMPURE FUNCTION svnversion_from_file(filename : IN string) RETURN std_logic_vector IS
--    FILE foo        : text IS IN filename;
    FILE foo        : text OPEN read_mode IS filename;
    VARIABLE xline  : line;
    VARIABLE inStr  : string(1 TO 100);
    VARIABLE i      : integer RANGE 1 TO 100;
    VARIABLE x      : integer                      := 0;
    VARIABLE done   : boolean                      := false;
    VARIABLE good   : boolean;
    VARIABLE smudge : std_logic_vector(1 DOWNTO 0) := "00";
  BEGIN
    readline(foo, xline);
--    FOR i IN 1 TO xline'length LOOP
    FOR i IN inStr'range LOOP
      read(xline, inStr(i), good);
      IF NOT good THEN
        EXIT;
      ELSIF inStr(i) = ':' THEN         -- mark if a range of revisions
        x         := 0;                 -- and report the later one
        smudge(0) := '1';
      ELSIF inStr(i) = 'M' THEN  -- mark if anything is modified from repository
        done      := true;  -- if we see this, it's also the end of the number!
        smudge(1) := '1';
      ELSIF NOT done THEN
        x := 10*x + character'pos(inStr(i))-character'pos('0');
      END IF;
    END LOOP;
    ASSERT false REPORT "svnversion="&inStr SEVERITY note;
    RETURN smudge & std_logic_vector(to_unsigned(x, 14));
  END FUNCTION;
END PACKAGE BODY utilities;
