LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY FallingEdgeDetector IS
	PORT (
	XIN: IN std_logic;
	RST: IN std_logic;
	CLK: IN std_logic;
	XRE: OUT std_logic );
END FallingEdgeDetector;

ARCHITECTURE Behavioral OF FallingEdgeDetector IS
SIGNAL Xn, Xp: std_logic_vector(3 DOWNTO 0):=(OTHERS=>'0');
BEGIN 
	
	Combinational:PROCESS(Xp,XIN)
	BEGIN 
		Xn(0)<=XIN;
		Xn(1)<=Xp(0);
		Xn(2)<=Xp(1);
		Xn(3)<=Xp(2);
		XRE<= ((NOT Xp(0)) AND (NOT Xp(1)) AND (NOT Xp(2)) AND (Xp(3)));	
	END PROCESS Combinational;
	
	
	Sequential:PROCESS(CLK,RST)
	BEGIN	 
		
		IF RST='0' THEN 
			Xp<=(OTHERS=>'0');
		ELSIF CLK'event AND CLK='1' THEN
			Xp<=Xn;
		END IF;	 
		
	END PROCESS Sequential;

END Behavioral;
