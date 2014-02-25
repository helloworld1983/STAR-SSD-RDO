LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Entity Declaration
ENTITY GlobalReset IS
  PORT (
    CLK            : IN  std_logic;     -- system clock
    DCM_LOCKED : IN std_logic;
    CLK_RST : OUT std_logic;
    GLOBAL_RST : OUT std_logic
    );
END GlobalReset;

-- Architecture body
ARCHITECTURE a OF GlobalReset IS
  CONSTANT CLK_RESET_DELAY_CNT : integer := 10000;
  CONSTANT GBL_RESET_DELAY_CNT : integer := 100;

  TYPE rstState_type IS (R0, R1, R2, R3, R4);
  SIGNAL rstState : rstState_type;

  SIGNAL rst : std_logic;
  
BEGIN

  rst <= '0';
  rst_sm: PROCESS (CLK, rst) IS
    VARIABLE rstCtr : integer RANGE 0 TO 16383 := 0;
  BEGIN  -- PROCESS rst_sm
    IF rst = '1' THEN                   -- asynchronous reset (active high)
      rstState <= R0;
      rstCtr := 0;
    ELSIF rising_edge(CLK) THEN  -- rising clock edge
      CLK_RST <= '0';
      GLOBAL_RST <= '1';
      
      CASE rstState IS
        WHEN R0 =>
          CLK_RST <= '1';
          rstCtr := CLK_RESET_DELAY_CNT;
          rstState <= R1;
        WHEN R1 =>
          CLK_RST <= '1';
          IF rstCtr = 0 THEN
            rstState <= R2;
          ELSE
            rstCtr := rstCtr + 1;
          END IF;
        WHEN R2 =>
          rstCtr :=  GBL_RESET_DELAY_CNT;
          IF DCM_LOCKED = '1' THEN
            rstState <= R3;
          END IF;
        WHEN R3 =>
          IF rstCtr = 0 THEN
            rstState <= R4;
          ELSE
            rstCtr := rstCtr + 1;
          END IF;
        WHEN R4 =>
          GLOBAL_RST <= '0';
          IF DCM_LOCKED = '0' THEN
            rstState <= R0;
          END IF;
        WHEN OTHERS => 
          rstState <= R0;
      END CASE;

      
    END IF;
  END PROCESS rst_sm;


  
END a;
