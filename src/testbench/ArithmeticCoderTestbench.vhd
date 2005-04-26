
-- VHDL Test Bench Created from source file arithmeticcoder.vhd -- 13:44:22 01/05/2005
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use STD.textio.all;

ENTITY arithmeticcoder_ArithmeticCoderTestbench_vhd_tb IS
END arithmeticcoder_ArithmeticCoderTestbench_vhd_tb;

ARCHITECTURE behavior OF arithmeticcoder_ArithmeticCoderTestbench_vhd_tb IS 

	COMPONENT arithmeticcoder
		generic(
	PROB :	std_logic_vector (9 downto 0));
	PORT(
		ENABLE : IN std_logic;
		DATA_IN : IN std_logic;
		RESET : IN std_logic;
		CLOCK : IN std_logic;          
		SENDING : OUT std_logic;
		DATA_OUT : OUT std_logic
		);
	END COMPONENT;
	component ARITHMETICDECODER
	generic(
	PROB :	std_logic_vector (9 downto 0));
	port (ENABLE : in std_logic;
           DATA_IN : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic);
        end component ARITHMETICDECODER;
 
	SIGNAL ENABLE :  std_logic;
	SIGNAL DATA_IN :  std_logic := '0';
	SIGNAL RESET :  std_logic;
	SIGNAL CLOCK :  std_logic := '0';
	SIGNAL SENDING :  std_logic;
	SIGNAL DATA_OUT :  std_logic;
	signal TRANSMIT :	std_logic;
	signal DATA_TRANSFER :	std_logic;
	constant PERIOD : time := 10 ns;
	file TESTDATA :	text is in "raw_data";
	file RESULTS :	text is out "results";

BEGIN

	uut: arithmeticcoder 
	generic map(
	PROB => "1110010000")
	PORT MAP(
		ENABLE => ENABLE,
		DATA_IN => DATA_IN,
		RESET => RESET,
		CLOCK => CLOCK,
		SENDING => TRANSMIT,
		DATA_OUT => DATA_TRANSFER
	);

	CLOCK <= not CLOCK after PERIOD/2;
	
	DECODER:	ARITHMETICDECODER
	generic map( 
	PROB => "1110010000")
	port map(	ENABLE => TRANSMIT,
	DATA_IN => DATA_TRANSFER,
	RESET => RESET,
	CLOCK => CLOCK,
	SENDING => SENDING,
	DATA_OUT => DATA_OUT);
 --*** Test Bench - User Defined Section ***
   tb : PROCESS
	variable GETLINE : line;
	variable INDATA : std_logic;
   BEGIN
		for COUNT in 0 to 4194307 loop
		wait until CLOCK'event and CLOCK = '1';
		if COUNT = 0 then 
			RESET <= '1';
			ENABLE <= '0';
			DATA_IN <= '0';
		elsif COUNT = 1 then
			RESET <= '0';

		elsif	(COUNT - 2) mod 4 = 0 then
			if (COUNT < 4194307) then
				if (COUNT - 2)	mod 128 = 0 then
					readline(TESTDATA,GETLINE);
				end if;
				read(GETLINE,INDATA);
				DATA_IN <= INDATA;
				ENABLE <= '1';
			else
				DATA_IN <= '1';
				ENABLE <= '1';
			end if;

		elsif COUNT < 4194307 then
			ENABLE <= '0';
		else
      	wait; -- will wait forever
      	end if;
		end loop;
   END PROCESS;

	OUTPUT :	process
	variable OUTLINE :	line;
	begin
	for WRITTEN in 0 to 1048576 loop
		wait until CLOCK'event and CLOCK = '1' and SENDING = '1';
		if WRITTEN = 1048576 then
			report "Process Complete" severity failure;
			wait;
		else
			write(OUTLINE,DATA_OUT);
			if (WRITTEN mod 32) = 31 then
				writeline(RESULTS,OUTLINE);
			end if;
		end if;
	end loop;
	end process;
	

-- *** End Test Bench - User Defined Section ***

COUNT_BITS: process (CLOCK, TRANSMIT)
	variable BITS_SENT : integer range 0 to 1048576 := 0;
	begin
	if (CLOCK'event and CLOCK='1' and TRANSMIT='1') then
	BITS_SENT := BITS_SENT+1;
	end if;
	end process;
END;
