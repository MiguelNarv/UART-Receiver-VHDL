LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY NOTGate IS
	PORT(
	A: IN std_logic;
	X: OUT std_logic
	);
END NOTGate;

ARCHITECTURE Dataflow OF NOTGate IS
BEGIN		
	
	X<= NOT A;
	
END	Dataflow;