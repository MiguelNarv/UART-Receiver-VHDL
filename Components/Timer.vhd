LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY Timer IS
	GENERIC(
	TICKS: integer:=10;
	BUSWIDTH: integer:=4
	);
	PORT(
	RST: IN std_logic;
	CLK: IN std_logic;
	SYN: OUT std_logic
	);
	
END Timer;

ARCHITECTURE Behavioral OF Timer IS
SIGNAL Cp, Cn: std_logic_vector(BUSWIDTH-1 DOWNTO 0):=(OTHERS=>'0');
BEGIN		
	
	Combinational: PROCESS(Cp)
	BEGIN				   
		IF Cp = std_logic_vector(to_unsigned(TICKS, Cp'length)) THEN
			Cn<=(OTHERS=>'0');
			SYN<='1';
		ELSE
			Cn<= std_logic_vector(unsigned(Cp) + 1);
			SYN<='0';	  
		END IF;
	END PROCESS Combinational;
	
	
	Sequential: PROCESS(RST,CLK)
	BEGIN		
		IF RST='0' THEN
			Cp<=(OTHERS=>'0');
		ELSIF CLK'event AND CLK='1' THEN
			Cp<=Cn;
		END IF;	
	END PROCESS Sequential;
	
end	Behavioral;