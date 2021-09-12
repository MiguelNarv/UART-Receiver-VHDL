LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ANDgate IS
	PORT(
	A: IN std_logic;
	B: IN std_logic;
	X: OUT std_logic
	);
END ANDgate;

ARCHITECTURE Dataflow OF ANDgate IS
BEGIN		
	
	X<=A AND B;
	
END	Dataflow;