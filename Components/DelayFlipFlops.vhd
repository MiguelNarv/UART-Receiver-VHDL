LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


ENTITY DelayFlipFlops IS  
		GENERIC(
		DELAY: integer:= 332;	--DELAY [ns] múltiplo de TCLK.
		TCLK: integer:= 83	 --Periodo del reloj [ns].
		);
		PORT (
  		D: IN std_logic;
		RST: IN std_logic;
		CLK: IN std_logic;
      	Q: OUT std_logic:='0';
		Qn: OUT std_logic
		);
END DelayFlipFlops;

ARCHITECTURE Behavioral OF DelayFlipFlops IS
BEGIN 	
	
	
	Sequential:PROCESS(CLK,RST)	
	VARIABLE Dffq: std_logic_vector((DELAY/TCLK)-1 DOWNTO 0):=(OTHERS=>'0');
	BEGIN	  
		
		IF RST='0' THEN
			Dffq:=(others=>'0');  
			Q<='0';	 
			Qn<='1';
		ELSIF CLK'event AND CLK='1' THEN   
			Dffq:=Dffq((DELAY/TCLK)-2 DOWNTO 0) & D;	
			Q<=Dffq((DELAY/TCLK)-1); 
			Qn<= NOT Dffq((DELAY/TCLK)-1);
		END IF;
		
	END PROCESS Sequential;
	
END Behavioral;	  

