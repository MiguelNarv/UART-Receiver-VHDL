-----------------------------------------------------------------------------------------------------------------------	 

-- UART Receiver.
-- Miguel Gerardo Narváez González.
-- V1.0.
-- 09/12/21.	 

-- This file contains the UART receiver.  This receiver is able to receive up to 8 bits of serial data, 1 start bit, 
-- 1 or 2 stop bits, and optional 0 or 1 even parity bit.  When a data package is received, RCVREADY is set to high 
-- for 1 clock cicle. When parity is activated, RCVERROR will be high for 1 clock cicle if there is an error. 
-- UART configuration can be set in GENERIC section of the entity.	
-- The components used in this file must be included in the project's folder.  

-----------------------------------------------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


ENTITY UARTReceiver IS
	GENERIC(
	BAUDS: integer:=115200;  		
	FCLK: integer:=12000000;	--Clock frequency [Hz].
	DATAWIDTH: integer:=8; 	
	STARTBIT: integer:=1;
	STOPBIT: integer:=1;	 
	PARITYBIT: integer:=1	 --Even parity 1 or 0.
	);
	PORT(
	RST: IN std_logic;
	CLK: IN std_logic;
	RX: IN std_logic;
	RCV: OUT std_logic_vector (DATAWIDTH-1 DOWNTO 0);
	RCVREADY: OUT std_logic:='0';
	RCVERROR: OUT std_logic
	);
END ENTITY UARTReceiver;

ARCHITECTURE Structural OF UARTReceiver IS

COMPONENT FallingEdgeDetector IS
	PORT (
	XIN: IN std_logic;
	RST: IN std_logic;
	CLK: IN std_logic;
	XRE: OUT std_logic );
END COMPONENT;

COMPONENT Timer IS
	GENERIC(
	TICKS: integer:=10;
	BUSWIDTH: integer:=4
	);
	PORT(
	RST: IN std_logic;
	CLK: IN std_logic;
	SYN: OUT std_logic
	);
END COMPONENT;


COMPONENT LatchSR IS
	PORT (
	SET: IN std_logic;
	CLR: IN std_logic;
	RST: IN std_logic;
	CLK: IN std_logic;
    SOUT: OUT std_logic );	
END COMPONENT;	 

COMPONENT Deserializer IS
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
END COMPONENT;		

COMPONENT EvenParityChecker IS
	GENERIC(
	DATAWIDTH: integer:=9
	);
	PORT(
	DATA: IN std_logic_vector(DATAWIDTH-1 DOWNTO 0);
	ENABLE: IN std_logic;
	ERROR: OUT std_logic
	);
END COMPONENT;	  

COMPONENT ANDGate IS
	PORT(
	A: IN std_logic;
	B: IN std_logic;
	X: OUT std_logic
	);	
END COMPONENT; 

COMPONENT NOTGate IS
	PORT(
	A: IN std_logic;
	X: OUT std_logic
	);
END COMPONENT;	

COMPONENT DelayFlipFlops IS
	GENERIC(
	DELAY: integer:= 332;
	TCLK: integer:= 83	 
	);
	PORT (
	D: IN std_logic;
	RST: IN std_logic;
	CLK: IN std_logic;
  	Q: OUT std_logic:='0';
	Qn: OUT std_logic
	);
END COMPONENT;	 

COMPONENT LoadFlipFlop IS
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
END COMPONENT;

CONSTANT PackageWidth: integer:=(DATAWIDTH + PARITYBIT); 
-- TimeSpanRX declaration.
CONSTANT TimeSpanRX: integer:=FCLK/(9*BAUDS);
SIGNAL FEReset, FEDetected, STARTSignal, NOTSTARTSignal, BITSignal, BYTESignal, BYTESignalDelayed, EvenParityEnable: std_logic:='0';
SIGNAL DATASignal: std_logic_vector((DATAWIDTH + PARITYBIT)-1 DOWNTO 0):=(OTHERS=>'0');	
SIGNAL RCVSignal, RCVSignalRotated: std_logic_vector(DATAWIDTH-1 DOWNTO 0):=(OTHERS=>'0');

BEGIN
	
	
	-- Data bits from DATASignal are selected and assigned to RCVSignal.
	RCVSignal<=DATASignal(PackageWidth-1 DOWNTO 1) WHEN PARITYBIT=1 ELSE
		 DATASignal(PackageWidth-1 DOWNTO 0) ;
	
	-- RCVSignal is rotated so the incomming bits are placed in order from LSB to MSB.
	LSBTOMSB: FOR i IN 0 TO DATAWIDTH-1 GENERATE
  	RCVSignalRotated(i) <= RCVSignal(i);  
	END GENERATE;  	
	
	RCVREADY<=BYTESignalDelayed;
	
	-- EvenParityEnable controls U9 enable state depending on wheter parity bit is included or not.
	EvenParityEnable<= '1' WHEN (BYTESignalDelayed='1' AND PARITYBIT=1) ELSE
						'0';

	-- Transition from high to low of RX is detected by U1.
	U1: FallingEdgeDetector PORT MAP(XIN=>RX, RST=>FEReset, CLK=>CLK, XRE=>FEDetected);
	
	-- If a transition from high to low on RX is detected, NOTSTARTSignal is set to low.
	U2: NOTGate PORT MAP(A=>STARTSignal, X=>NOTSTARTSignal);
	
	-- If any of RST or NOTSTARTSignal signals are low, FEReset is set to low. Then, U1 is disabled.
	U3: ANDGate PORT MAP(A=>RST, B=>NOTSTARTSignal, X=>FEReset); 		
	
	-- After a transition is detected, STARTSignal is set to high. STARTSignal controls U5, U6, U8 and indicates when the process of receiving data is to begin.
	U4: LatchSR PORT MAP(SET=>FEDetected, CLR=>BYTESignalDelayed, RST=>RST, CLK=>CLK, SOUT=>STARTSignal);	  
	
	-- U5 starts counting and, based on BAUDS, BITSignal is set to high for 1 clock cicle. The pulse period depends on the time a bit is meant to be received (1/Bauds) [s].
	-- TimeSpanRx is added to give RX a 11% time tolerance respect of (1/BAUDS) [s] for cases in which emmiter does not accomplish exact timming requirements given by bauds. It can be modified in signal declaration section.
	U5: Timer GENERIC MAP(TICKS=>((FCLK/BAUDS)) + TimeSpanRx, BUSWIDTH=>integer(log2(real(FCLK/BAUDS)))+1) PORT MAP(RST=>STARTSignal, CLK=>CLK, SYN=>BITSignal); 
	
	-- U6 starts counting and, based on BAUDS and PackageWidth, BYTESignal is set to high for 1 clock cicle. The pulse period depends on the time a byte plus , and an optional parity bit are meant to be received ((DATAWIDTH+PARITYBIT)/Bauds) [s].
	-- TimeSpanRx is added to give RX a 11% time tolerance respect of (1/BAUDS) [s] for cases in which emmiter does not accomplish exact timming requirements given by bauds.  It can be modified in signal declaration section.
	U6: Timer GENERIC MAP(TICKS=>PackageWidth*((FCLK/BAUDS) + TimeSpanRx), BUSWIDTH=>integer(log2(real((FCLK*PackageWidth)/BAUDS)))+1) PORT MAP(RST=>STARTSignal, CLK=>CLK, SYN=>BYTESignal);	--TICKS=(FCLK [Hz] * Number of bits)/BAUDS
	
	-- U7 delays (DELAY/TCLK) (12) clock cicles BYTESignal. Different values of DELAY may lead to malfunctioning.
	U7:	DelayFlipFlops GENERIC MAP(DELAY=>996, TCLK=>83) PORT MAP(D=>BYTESignal, RST=>RST, CLK=>CLK, Q=>BYTESignalDelayed, Qn=>OPEN);
	
	-- U8 receives RX signal and every time BITSignal is high it gets the value of RX and places it in order on DATASignal. 
	U8: Deserializer GENERIC MAP(BUSWIDTH=>PackageWidth) PORT MAP(BIN=>RX, SHF=>BITSignal, RST=>STARTSignal, CLK=>CLK, DOUT=>DATASignal);
	
	-- U9 is enabled once a data package was received and a parity bit is considered, then if there is an error, RCVERROR is set to high for 1 clock cicle.
	U9: EvenParityChecker GENERIC MAP(DATAWIDTH=>PackageWidth) PORT MAP(DATA=>DATASignal, ENABLE=>EvenParityEnable, ERROR=>RCVERROR);	 
	
	-- U10 gets the value of RCVSignalRotated, which contains the data bits, every time a data package is received. RCV value is uptdated every time a new start bit is received. 
	U10: LoadFlipFlop GENERIC MAP(BUSWIDTH=>DATAWIDTH) PORT MAP(DIN=>RCVSignalRotated, LDR=>BYTESignalDelayed, RST=>RST, CLK=>CLK, DOUT=>RCV);
	

END ARCHITECTURE Structural;
