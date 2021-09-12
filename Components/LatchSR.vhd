LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY LatchSR IS
  PORT (
  		SET: IN std_logic;
		CLR: IN std_logic;
		RST: IN std_logic;
		CLK: IN std_logic;
        SOUT: OUT std_logic );
END LatchSR;

ARCHITECTURE Behavioral OF LatchSR IS
SIGNAL Qn, Qp: std_logic:='0';

BEGIN 
	
	Combinational:PROCESS(SET,CLR,Qp) 
	VARIABLE SETCLR: std_logic_vector(1 DOWNTO 0):="00";
	BEGIN  	   
		
		SETCLR:=SET&CLR; --Active low for CLR.
		SOUT<=Qp;
		IF SETCLR="10" THEN
			Qn<='1';
		ELSIF SETCLR="01" THEN
			Qn<='0';	   
		ELSE
			Qn<=Qp;
		END IF;		
		
	END PROCESS Combinational;
	
	
	Sequential:PROCESS(CLK,RST)
	BEGIN	  
		
		IF RST='0' THEN 
			Qp<='0';	
		ELSIF CLK'event AND CLK='1' THEN
			Qp<=Qn;
		END IF;
		
	END PROCESS Sequential;

END Behavioral;
