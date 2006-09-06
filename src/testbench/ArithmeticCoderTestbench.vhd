-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: ArithmeticCoderTestbench.vhd,v 1.5 2006-09-06 18:41:06 petebleackley Exp $ $Name: not supported by cvs2svn $
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
	PORT(
		ENABLE : IN std_logic;
		DATA_IN : IN std_logic;
		CONTEXT_ENABLE : in std_logic;
		CONTEXT_IN : in std_logic_vector (5 downto 0);
		HALVECOUNTS_IN : in std_logic;
		FLUSH : in std_logic;
		RESET : IN std_logic;
		CLOCK : IN std_logic;          
		SENDING : OUT std_logic;
		DATA_OUT : OUT std_logic;
		FLUSH_COMPLETE : out std_logic
		);
	END COMPONENT;
	component EXP_GOLOMB_COUNTER
	port( DATA_IN : in std_logic_vector (31 downto 0);
		TEST : in std_logic;
		RESET : in std_logic;
		CLOCK : in std_logic;
		COUNTING : out std_logic;
		DATA_OUT : out std_logic);
	end component EXP_GOLOMB_COUNTER;

	SIGNAL ENABLE :  std_logic;
	SIGNAL DATA_IN :  std_logic := '0';
	SIGNAL RESET :  std_logic := '1';
	SIGNAL CLOCK :  std_logic := '0';
	signal FLUSH : std_logic := '0';
	signal HALVECOUNTS : std_logic := '0';
	SIGNAL SENDING :  std_logic;
	SIGNAL DATA_OUT :  std_logic;
	signal TRANSMIT :	std_logic;
	signal DATA_TRANSFER :	std_logic;
	signal FLUSH_COMPLETE : std_logic;
	signal DATA_IN2 :	std_logic_vector (0 downto 0);
	signal BUFFERED2 : std_logic_vector (0 downto 0);
	signal FIFO_EMPTY : std_logic;
	signal BUFFERED : std_logic;
	constant PERIOD : time := 16 ns;
	signal CONTEXT_ENABLE : std_logic;
	signal DECODER_CONTEXT_ENABLE : std_logic;
	signal NUMBITS : std_logic_vector (31 downto 0) := "00000000000000000000000000000000";
	signal NEXTNUMBITS : std_logic_vector (31 downto 0);
	signal NUMBYTES : std_logic_vector (28 downto 0);
	signal CONTEXT_IN : std_logic_vector (5 downto 0) := "000000";
	signal DECODER_CONTEXT : std_logic_vector (5 downto 0) := "000000";
	signal BYTECOUNT : std_logic_vector (31 downto 0);
	signal EXP_GOLOMB_READY : std_logic;
	signal EXP_GOLOMB_DATA : std_logic;
	signal BYTE_INSERT : std_logic := '0';
	signal COMPVAL : character;
	signal SUPPRESS_READ : std_logic := '0';
	type ENCODER_STATUS is (INIT, INIT2, HEADERS, CODING, FLUSHING, EXP_GOLOMB, WRITE_DATA, FINISHED);
	signal STATE : ENCODER_STATUS := INIT;
	type RAM is array (65535 downto 0) of integer;
	signal STORAGE : RAM;
	type CHARFILE is file of character;
	file raw_data : CHARFILE open read_mode is "test1.dr0";
	file contexts : CHARFILE open read_mode is "test1.ctx";
	file coded_stream : CHARFILE open write_mode is "test1.drc";
	file comparison_data : CHARFILE open read_mode is "test1.dr1";
	type INTARRAY is array (7 downto 0) of integer;
	function CONTEXT_INTERPRET(CONTEXT : integer) return std_logic_vector is
	variable VALUE : std_logic_vector(5 downto 0);
	begin
		if CONTEXT >= 128 then
			VALUE(5) := '1';
		else
			VALUE(5) := '0';
		end if;
		if (CONTEXT mod 128) >= 64 then
			VALUE(4) := '1';
		else
			VALUE(4) := '0';
		end if;
		if (CONTEXT mod 64) >= 32 then
			VALUE(3) := '1';
		else
			VALUE(3) := '0';
		end if;
		if (CONTEXT mod 32) >= 16 then
			VALUE(2) := '1';
		else
			VALUE(2) := '0';
		end if;
		if (CONTEXT mod 16) >= 8 then
			VALUE(1) := '1';
		else
			VALUE(1) := '0';
		end if;
		if (CONTEXT mod 8) >= 4 then
			VALUE(0) := '1';
		else
			VALUE(0) := '0';
		end if;
		return VALUE;
	end function CONTEXT_INTERPRET;
BEGIN

	uut: arithmeticcoder 
	PORT MAP(
		ENABLE => ENABLE,
		DATA_IN => DATA_IN,
		CONTEXT_ENABLE => CONTEXT_ENABLE,
		CONTEXT_IN => CONTEXT_IN,
		HALVECOUNTS_IN => HALVECOUNTS,
		FLUSH => FLUSH,
		RESET => RESET,
		CLOCK => CLOCK,
		SENDING => TRANSMIT,
		DATA_OUT => DATA_TRANSFER,
		FLUSH_COMPLETE => FLUSH_COMPLETE
	);
	
	EGC: EXP_GOLOMB_COUNTER
	port map(
		DATA_IN => BYTECOUNT,
		TEST => FLUSH_COMPLETE,
		RESET => RESET,
		CLOCK => CLOCK,
		COUNTING => EXP_GOLOMB_READY,
		DATA_OUT => EXP_GOLOMB_DATA);
		
	

	CLOCK <= not CLOCK after PERIOD/2;
	
 --*** Test Bench - User Defined Section ***
   tb : PROCESS (CLOCK)
	variable POSITION : integer;
	variable EGPOSITION : integer;
	variable PLACE : integer;
	variable READVAL : character;
	variable WRITEVAL : integer;
	variable CONTEXT : integer;
	variable DATA : integer;
	variable COMPDATA : integer;
	variable THRESHOLD : integer;
	variable INDEX : integer range 0 to 536870911;
	variable READ_DATA : INTARRAY := (0,0,0,0,0,0,0,0); 
	variable DUMMY : character;
	
   BEGIN
		if CLOCK'event and CLOCK = '1' then
			if STATE = INIT then
				if READ_DATA = ( 16#4B#, 16#57#, 16#2D#, 16#44#, 16#49#, 16#52#, 16#41#, 16#43#) then
					STATE <= INIT2;
					RESET <= '0';
				else
					READ_DATA(7 downto 1) := READ_DATA(6 downto 0);
					read(raw_data,READVAL);
					READ_DATA(0) := character'pos(READVAL);
				end if;
			elsif STATE = INIT2 then
				if READ_DATA (7 downto 3) = ( 16#44#, 16#49#, 16#52#, 16#41#, 16#43#) then
					STATE <= HEADERS;
					WRITEVAL := 0;
					EGPOSITION := 128;
				else
					WRITEVAL := READ_DATA(7);
					write(coded_stream,character'val(WRITEVAL));
					READ_DATA(7 downto 1) := READ_DATA (6 downto 0);
				end if;
			elsif STATE = HEADERS then
				if READ_DATA (7 downto 3) = ( 16#42#, 16#42#, 16#43#, 16#44#, 16#AC# ) then
					STATE <= CODING;
					PLACE := 0;
					POSITION := 0;
					RESET <= '1';
					ENABLE <= '0';
					DATA_IN <= '0';
					CONTEXT_ENABLE <= '0';
					CONTEXT_IN <= "000000";
					HALVECOUNTS <= '0';
					FLUSH <= '0';
					if SUPPRESS_READ = '0' then
						read(comparison_data,DUMMY);
						COMPVAL <= DUMMY;
					end if;
				elsif READ_DATA (7 downto 3) = (16#42#, 16#42#, 16#43#, 16#44#, 16#D0# ) then
					STATE <= FINISHED;
				else
					if EGPOSITION = 128 then
						read(raw_data,READVAL);
						READ_DATA(2) := character'pos(READVAL);
					end if;
					if READ_DATA(7) > 127 then
						WRITEVAL := WRITEVAL + EGPOSITION;
					end if;

					for I in 7 downto 2 loop
						if READ_DATA(I) > 127 then
							READ_DATA(I) := (READ_DATA(I) -128) * 2;
						else
							READ_DATA(I) := READ_DATA(I) * 2;
						end if;
						if READ_DATA(I-1) > 127 then 
							READ_DATA(I) := READ_DATA(I) + 1;
						end if;
					end loop;
					if EGPOSITION = 1 then
						write(coded_stream,character'val(WRITEVAL));
						EGPOSITION := 128;
						WRITEVAL := 0;
					else
						EGPOSITION := EGPOSITION / 2;
					end if;
				end if;
			elsif STATE = CODING then
				if PLACE = 0 then
					RESET <= '0';
				end if;
				if PLACE mod 5 = 0 then
					read(contexts,READVAL);
					CONTEXT := character'pos(READVAL);
					CONTEXT_ENABLE <= '1';
					if CONTEXT mod 2 = 1 then
						CONTEXT_IN <= "000000";
						HALVECOUNTS <= '0';
						STATE <= FLUSHING;
						FLUSH <= '1';
					else 
						CONTEXT_IN <= CONTEXT_INTERPRET(CONTEXT); 
						if (CONTEXT mod 4) > 1 then
							HALVECOUNTS <= '1';
						else
							HALVECOUNTS <= '0';
						end if;
						FLUSH <= '0';
					end if;
				elsif PLACE mod 5 = 3 then
					if POSITION = 0 then
						POSITION := 128;
						READ(raw_data,READVAL);
						DATA := character'pos(READVAL);
					end if;
					if (DATA / POSITION) mod 2 = 1 then
						DATA_IN <= '1';
					else
						DATA_IN <= '0';
					end if;
					ENABLE <= '1';
					POSITION := POSITION / 2;
				else
					CONTEXT_ENABLE <= '0';
					ENABLE <= '0';
				end if;
				PLACE := PLACE + 1;
			elsif STATE = FLUSHING then
				if FLUSH = '1' then
					FLUSH <= '0';
					CONTEXT_ENABLE <= '0';
				end if;
				if FLUSH_COMPLETE = '1' then
					STATE <= EXP_GOLOMB;
					PLACE := 7;
					POSITION := 128;
					READ_DATA(7) := 0;
				end if;
			elsif STATE = EXP_GOLOMB then
				if EXP_GOLOMB_READY = '0' then
					STATE <= WRITE_DATA;
					INDEX := 0;
					if EGPOSITION /= 128 then
						write(coded_stream,character'val(WRITEVAL));
					end if;
					PLACE := 7;
				else
					if EXP_GOLOMB_DATA = '1' then
						WRITEVAL := WRITEVAL + EGPOSITION;
					end if;
					if EGPOSITION = 1 then
						EGPOSITION := 128;
						write(coded_stream,character'val(WRITEVAL));
						WRITEVAL := 0;
					else
						EGPOSITION := EGPOSITION / 2;
					end if;
				end if;
				
			elsif STATE  = WRITE_DATA then
				if INDEX = (conv_integer(NUMBYTES)-1) then
					STATE <= HEADERS;
					WRITEVAL := 0;
				else
					if PLACE < 3 then
						WRITEVAL := READ_DATA(7);
						write(coded_stream,character'val(WRITEVAL));
						READ_DATA (7 downto 3) := READ_DATA (6 downto 2);
						READ_DATA (2) := STORAGE(INDEX);
					else
						READ_DATA (PLACE) := STORAGE(INDEX);
						PLACE := PLACE - 1;
					end if;
					INDEX := INDEX + 1;
				end if;
			else --STATE = FINISHED
				if READ_DATA (7 downto 3) = (0, 0, 0, 0, 0) then
					report ("finished") severity failure;
				else
					WRITEVAL := READ_DATA(7);
					write(coded_stream,character'val(WRITEVAL));
					READ_DATA (7 downto 3) := READ_DATA (6 downto 3) & 0;
				end if;
			end if;
		end if;
			
			

   END PROCESS;


COUNT_BITS: process (CLOCK)
	begin
	if (CLOCK'event and CLOCK='1') then
		if RESET = '1' then
			NUMBITS <= "00000000000000000000000000000000";
		else
			if TRANSMIT = '1' then
				NUMBITS <= NUMBITS + "00000000000000000000000000000001";
			end if;
			if BYTE_INSERT = '1' then
				NUMBITS <= NUMBITS + "00000000000000000000000000001000";
			end if;
		end if;
	end if;
	end process;
	
NEXTNUMBITS <= NUMBITS + "00000000000000000000000000000111";

NUMBYTES <= NEXTNUMBITS (31 downto 3);
	
	BYTECOUNT <=  "0000000000000000" & NUMBYTES(15 downto 0);


WRITE_MEMORY: process(CLOCK)
	variable INCREMENT: integer;
	variable DATA : integer;
	variable COMPARISON : character;
	variable COMPDATA : integer;
	variable COMPDATA2 : integer;
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			INCREMENT := 128;
			BYTE_INSERT <= '0';
			if SUPPRESS_READ = '0' then
				COMPDATA := character'pos(COMPVAL);
			end if;
			COMPDATA2 := 0;
			DATA := 0;
		elsif TRANSMIT = '1' then
			if (COMPDATA rem (INCREMENT*2)) >= INCREMENT then
				COMPDATA2 := COMPDATA2 + INCREMENT;
			end if;
			if DATA_TRANSFER = '1' then
				DATA := DATA + INCREMENT;
			end if;
			assert COMPDATA2 = DATA report "ENCODER HAS DIVERGED" severity failure;
			if INCREMENT = 1 then
				STORAGE(conv_integer(NUMBYTES)-1) <= DATA;
				DATA := 0;
				INCREMENT := 128;
				read(comparison_data,COMPARISON);
				COMPDATA := character'pos(COMPARISON);
				COMPDATA2 := 0;
				if NUMBYTES >= "00000000000000000000000000100" then
					if STORAGE((conv_integer(NUMBYTES) -4) downto (conv_integer(NUMBYTES) - 1)) = (16#42#, 16#42#, 16#43#, 16#44#) then
						STORAGE(conv_integer(NUMBYTES)) <= 16#FF#;
						BYTE_INSERT <= '1';
					end if;
				end if;
			else
				INCREMENT := INCREMENT/2;
			end if;
		elsif FLUSH_COMPLETE = '1' then
			if INCREMENT /= 128 then 
				STORAGE(conv_integer(NUMBYTES)) <= DATA;
				if NUMBYTES >= "00000000000000000000000000100" then
					if STORAGE((conv_integer(NUMBYTES) -3) downto (conv_integer(NUMBYTES))) = (16#42#, 16#42#, 16#43#, 16#44#) then
						STORAGE(conv_integer(NUMBYTES)+1) <= 16#FF#;
						BYTE_INSERT <= '1';
					end if;
				end if;
				SUPPRESS_READ <= '0';
			else
				SUPPRESS_READ <= '1';
			end if;
		end if;
		if BYTE_INSERT = '1' then
			BYTE_INSERT <= '0';
		end if;
	end if;
end process WRITE_MEMORY;

END;
