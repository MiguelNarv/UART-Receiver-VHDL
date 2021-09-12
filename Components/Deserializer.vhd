LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY Deserializer IS  
	GENERIC(
		BUSWIDTH: integer:=8	 
		);
	PORT (
		RST: IN std_logic;
		CLK: IN std_logic;
		SHF: IN std_logic;
        BIN: IN std_logic;
		DOUT: OUT std_logic_vector(BUSWIDTH-1 DOWNTO 0)
		);
END Deserializer;

ARCHITECTURE Behavioral OF Deserializer IS	 
SIGNAL Qn, Qp: std_logic_vector(BUSWIDTH-1 DOWNTO 0):=(OTHERS=>'0');
BEGIN 	
	
	
	Combinational:PROCESS(Qn, Bin,SHF,Qp)
	BEGIN
		
		IF SHF='1' THEN
			Qn<= Qp(BUSWIDTH-2 DOWNTO 0) & BIN;
		ELSE
			Qn<=Qp;
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

	
	
END Behavioral;	  

