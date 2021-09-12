LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY LoadFlipFlop IS  
		GENERIC(
		BUSWIDTH: integer:=8	
		);
		PORT (
		RST: IN std_logic;
		CLK: IN std_logic;
		LDR: IN std_logic;
        DIN: IN std_logic_vector(BUSWIDTH-1 DOWNTO 0);
		DOUT: OUT std_logic_vector(BUSWIDTH-1 DOWNTO 0)
		);
END LoadFlipFlop;

ARCHITECTURE Behavioral OF LoadFlipFlop IS	 
SIGNAL Qn, Qp: std_logic_vector(BUSWIDTH-1 DOWNTO 0):=(OTHERS=>'0');
BEGIN 	
	
	
	Combinational:PROCESS(Qp, LDR, DIN)
	BEGIN
		
		IF LDR='1' THEN
			Qn<=DIN;
		ELSE
			Qn<= Qp;
		END IF;
		DOUT<=Qp;  
		
	END PROCESS;
	
	
	Sequential:PROCESS(CLK,RST)	
	
	BEGIN	  
		
		IF RST='0' THEN
		
			Qp<=(others=>'0');	 
		
		ELSIF CLK'event AND CLK='1' THEN   
			
			Qp<=Qn;
		
		END IF;
		
	END PROCESS Sequential;
	--Faltó la AND generica
	
	
END Behavioral;	  

