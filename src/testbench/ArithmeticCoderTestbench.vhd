-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: ArithmeticCoderTestbench.vhd,v 1.3 2005-05-27 16:00:30 petebleackley Exp $ $Name: not supported by cvs2svn $
-- *
-- * Version: MPL 1.1/GPL 2.0/LGPL 2.1
-- *
-- * The contents of this file are subject to the Mozilla Public License
-- * Version 1.1 (the "License"); you may not use this file except in compliance
-- * with the License. You may obtain a copy of the License at
-- * http://www.mozilla.org/MPL/
-- *
-- * Software distributed under the License is distributed on an "AS IS" basis,
-- * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
-- * the specific language governing rights and limitations under the License.
-- *
-- * The Original Code is BBC Research and Development code.
-- *
-- * The Initial Developer of the Original Code is the British Broadcasting
-- * Corporation.
-- * Portions created by the Initial Developer are Copyright (C) 2004.
-- * All Rights Reserved.
-- *
-- * Contributor(s): Peter Bleackley (Original author)
-- *
-- * Alternatively, the contents of this file may be used under the terms of
-- * the GNU General Public License Version 2 (the "GPL"), or the GNU Lesser
-- * Public License Version 2.1 (the "LGPL"), in which case the provisions of
-- * the GPL or the LGPL are applicable instead of those above. If you wish to
-- * allow use of your version of this file only under the terms of the either
-- * the GPL or LGPL and not to allow others to use your version of this file
-- * under the MPL, indicate your decision by deleting the provisions above
-- * and replace them with the notice and other provisions required by the GPL
-- * or LGPL. If you do not delete the provisions above, a recipient may use
-- * your version of this file under the terms of any one of the MPL, the GPL
-- * or the LGPL.
-- * ***** END LICENSE BLOCK ***** */

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
--	generic(
--	PROB :	std_logic_vector (9 downto 0));
	PORT(
		ENABLE : IN std_logic;
		DATA_IN : IN std_logic;
		CONTEXT_ENABLE : in std_logic;
		CONTEXT_IN : in std_logic_vector (5 downto 0);
		RESET : IN std_logic;
		CLOCK : IN std_logic;          
		SENDING : OUT std_logic;
		DATA_OUT : OUT std_logic
		);
	END COMPONENT;
	component ARITHMETICDECODER
	port (ENABLE : in std_logic;
           DATA_IN : in std_logic;
           NEWCONTEXT :	in std_logic;
           CONTEXT_SELECT : in std_logic_vector (5 downto 0);
           RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic);
        end component ARITHMETICDECODER;
        component FIFO
        generic (RANK :	integer range 0 to 16;
        	WIDTH : integer range 1 to 16);
        port (	WRITE_ENABLE :	in std_logic;
        	DATA_IN:	in std_logic_vector (WIDTH - 1 downto 0);
        	READ_ENABLE :	in std_logic;
        	RESET :	in std_logic;
        	CLOCK : in std_logic;
       	DATA_OUT :	out std_logic_vector (WIDTH - 1 downto 0);
        	EMPTY :	out std_logic);
        	end component FIFO;
	SIGNAL ENABLE :  std_logic;
	SIGNAL DATA_IN :  std_logic := '0';
	SIGNAL RESET :  std_logic;
	SIGNAL CLOCK :  std_logic := '0';
	SIGNAL SENDING :  std_logic;
	SIGNAL DATA_OUT :  std_logic;
	signal TRANSMIT :	std_logic;
	signal DATA_TRANSFER :	std_logic;
	signal DATA_IN2 :	std_logic_vector (0 downto 0);
	signal BUFFERED2 : std_logic_vector (0 downto 0);
--	signal FINISHED : std_logic := '0';
	signal FIFO_EMPTY : std_logic;
	signal BUFFERED : std_logic;
	constant PERIOD : time := 10 ns;
	signal CONTEXT_ENABLE : std_logic;
	signal DECODER_CONTEXT_ENABLE : std_logic;
	signal CONTEXT : std_logic_vector (5 downto 0) := "000000";
	signal DECODER_CONTEXT : std_logic_vector (5 downto 0) := "000000";
	file TESTDATA :	text open read_mode is "testseq";
	file RESULTS :	text open write_mode is "results";
	type TABLE is array (30 downto 0) of std_logic_vector (5 downto 0);
	constant NCONTEXT0 : TABLE := ("111101","111011","111001","110111",
	"110101","110011","110001","101111","101101","101011","101001",
	"100111","100101","100011","100001","011111","011101","011011",
	"011001","010111","010101","010011","010001","001111","001101",
	"001011","001001","000111","000101","000011","000001");
	constant NCONTEXT1 : TABLE := ("111110","111100","111010","111000",
	"110110","110100","110010","110000","101110","101100","101010",
	"101000","100110","100100","100010","100000","011110","011100",
	"011010","011000","010110","010100","010010","010000","001110",
	"001100","001010","001000","000110","000100","000010");

BEGIN

	uut: arithmeticcoder 
--	generic map(
--	PROB => "1110010000")
	PORT MAP(
		ENABLE => ENABLE,
		DATA_IN => DATA_IN,
		CONTEXT_ENABLE => CONTEXT_ENABLE,
		CONTEXT_IN => CONTEXT,
		RESET => RESET,
		CLOCK => CLOCK,
		SENDING => TRANSMIT,
		DATA_OUT => DATA_TRANSFER
	);

	CLOCK <= not CLOCK after PERIOD/2;
	
	DECODER:	ARITHMETICDECODER
	port map(	ENABLE => TRANSMIT,
	DATA_IN => DATA_TRANSFER,
	NEWCONTEXT => DECODER_CONTEXT_ENABLE,
	CONTEXT_SELECT => DECODER_CONTEXT,
	RESET => RESET,
	CLOCK => CLOCK,
	SENDING => SENDING,
	DATA_OUT => DATA_OUT);
 --*** Test Bench - User Defined Section ***
   tb : PROCESS
	variable GETLINE : line;
	variable INDATA : std_logic;
   BEGIN
		for COUNT in 0 to 5242880 loop
		wait until CLOCK'event and CLOCK = '1';
		if (COUNT < 5242900) then
			if COUNT = 0 then 
				RESET <= '1';
				ENABLE <= '0';
				DATA_IN <= '0';
				CONTEXT_ENABLE <='0';
			elsif COUNT = 1 then
				RESET <= '0';
				CONTEXT_ENABLE <= '1';
			elsif COUNT mod 5 = 0 then
				CONTEXT_ENABLE <= '1';
				ENABLE <= '0';
			elsif	(COUNT - 4) mod 5 = 0 then
			
				if (COUNT - 4)	mod 160 = 0 then
					if not endfile(TESTDATA) then
					readline(TESTDATA,GETLINE);
					end if;
				end if;
				read(GETLINE,INDATA);
				DATA_IN <= INDATA;
				ENABLE <= '1';
				if (CONTEXT > "011110") then
					CONTEXT <= "000000";
				else
					if (INDATA = '1') then
						CONTEXT <= NCONTEXT1(conv_integer(CONTEXT));
					else
						CONTEXT <= NCONTEXT0(conv_integer(CONTEXT));
					end if;
				end if;
			else
				ENABLE <= '0';
				CONTEXT_ENABLE <= '0';
			end if;
		elsif (COUNT = 5242900) then
			ENABLE <= '1';
			DATA_IN <= '1';
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
	
TESTBUFFER :	FIFO
	generic map(RANK => 11,
	WIDTH => 1)
	port map	(WRITE_ENABLE => ENABLE,
	DATA_IN => DATA_IN2,	
	READ_ENABLE => SENDING,
	RESET => RESET,
	CLOCK => CLOCK,
	DATA_OUT => BUFFERED2,
	EMPTY => FIFO_EMPTY);
	
	DATA_IN2(0) <= DATA_IN;
	BUFFERED <= BUFFERED2(0);

FIND_ERROR : postponed process (SENDING, DATA_OUT, BUFFERED)
	begin
	assert (( SENDING /= '1') or (DATA_OUT = BUFFERED))
	report "DIVERGENGE!!!"	severity failure;
	end process FIND_ERROR;		

-- *** End Test Bench - User Defined Section ***

COUNT_BITS: process (CLOCK, TRANSMIT)
	variable BITS_SENT : integer range 0 to 1048576 := 0;
	begin
	if (CLOCK'event and CLOCK='1' and TRANSMIT='1') then
	BITS_SENT := BITS_SENT+1;
	end if;
	end process;


	
CHOOSE_DECODER_CONTEXT:	process(CLOCK)
	begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			DECODER_CONTEXT <= "000000";
			DECODER_CONTEXT_ENABLE <= '1';
		elsif SENDING = '1' then
			if DECODER_CONTEXT > "011110" then
				DECODER_CONTEXT <= "000000";
			elsif DATA_OUT = '1' then
				DECODER_CONTEXT <= NCONTEXT1(conv_integer(DECODER_CONTEXT));
			else
				DECODER_CONTEXT <= NCONTEXT0(conv_integer(DECODER_CONTEXT));
			end if;
			DECODER_CONTEXT_ENABLE <= '1';
		else
			DECODER_CONTEXT_ENABLE <= '0';
		end if;
	end if;
end process CHOOSE_DECODER_CONTEXT;



END;
