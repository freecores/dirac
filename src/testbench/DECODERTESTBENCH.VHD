-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: DECODERTESTBENCH.VHD,v 1.1 2006-09-06 18:41:06 petebleackley Exp $ $Name: not supported by cvs2svn $
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


entity DECODERTESTBENCH is
end DECODERTESTBENCH;

architecture BEHAVIOUR of DECODERTESTBENCH is

	component ARITHMETICDECODER
	port (ENABLE : in std_logic;
		DATA_IN : in std_logic;
		NEWCONTEXT : in std_logic;
		CONTEXT_SELECT : in std_logic_vector (5 downto 0);
		HALVECOUNTS : in std_logic;
		RESET : in std_logic;
		CLOCK : in std_logic;
		SENDING : out std_logic;
		DATA_OUT : out std_logic);
	end component ARITHMETICDECODER;
	component EXP_GOLOMB_DECODER
	port (	ENABLE : in std_logic;
		DATA_IN : in std_logic;
		RESET : in std_logic;
		CLOCK : in std_logic;
		READY : out std_logic;
		DATA_OUT : out std_logic_vector (31 downto 0));
	end component EXP_GOLOMB_DECODER;
	signal BYTES_INPUT : std_logic_vector (31 downto 0);
	type STATUS is (OFFSET,FIND_START,GET_SIZE,FEED_DATA,PAUSE,FINISHED);
	signal DECODER_STATE : STATUS := OFFSET;
	signal ENABLE_DECODER : std_logic;
	signal DECODER_DATA_IN : std_logic;
	signal NEWCONTEXT : std_logic;
	signal CONTEXT_SELECT : std_logic_vector (5 downto 0);
	signal HALVECOUNTS : std_logic;
	signal FLUSH : std_logic;
	signal RESET : std_logic;
	signal CLOCK : std_logic := '0';
	signal SENDING : std_logic;
	signal DATA_OUT : std_logic;
	signal GETCONTEXT : std_logic;
	signal EG_ENABLE : std_logic;
	signal EG_DATA_IN : std_logic;
	signal EG_READY : std_logic;
	signal INIT : std_logic := '1';
--	signal LAST_BYTE : integer;
--	signal AFTER_FLUSH : std_logic;
--	signal BITPOS2 : integer;
--	signal COMPDATA : integer;
	signal BYTES_TO_DECODE : std_logic_vector (31 downto 0);
	type CHARFILE is file of character;
	file HEADERFILE : CHARFILE open read_mode is "test1.hdr";
	file DIRACFILE : CHARFILE open read_mode is "test1.dr1";
	file CONTEXTFILE : CHARFILE open read_mode is "test1.ctx";
	file TARGETFILE : CHARFILE open read_mode is "test1.dr0";
	type INTARRAY is array (5 downto 0) of integer;
	constant PERIOD : time := 10 ns;
begin

UUT : ARITHMETICDECODER
	port map(ENABLE => ENABLE_DECODER,
		DATA_IN => DECODER_DATA_IN,
		NEWCONTEXT => NEWCONTEXT,
		CONTEXT_SELECT => CONTEXT_SELECT,
		HALVECOUNTS => HALVECOUNTS,
		RESET => RESET,
		CLOCK => CLOCK,
		SENDING => SENDING,
		DATA_OUT => DATA_OUT);
		
EGD : EXP_GOLOMB_DECODER
	port map(ENABLE => EG_ENABLE,
		DATA_IN => EG_DATA_IN,
		RESET => RESET,
		CLOCK => CLOCK,
		READY => EG_READY,
		DATA_OUT => BYTES_TO_DECODE);
		
		
	CLOCK <= not CLOCK after PERIOD/2;
	
--DELAY_FLUSH_SIGNAL : process (CLOCK)
--begin
--	if CLOCK'event and CLOCK = '1' then
--		AFTER_FLUSH <= FLUSH;
--	end if;
--end process DELAY_FLUSH_SIGNAL;
	
TESTBENCH : process (CLOCK)
variable SCAN : INTARRAY;
variable READPLACE : integer := 5;
variable BITPOSITION : integer;
variable DIRACDATA : integer;
variable DIRACREAD : character;
variable TARGETREAD : character;
variable PAUSECOUNT : integer;
begin
	if CLOCK'event and CLOCK='1' then
		if DECODER_STATE = OFFSET then
			if READPLACE = 0 then
				DECODER_STATE <= FIND_START;
				BITPOSITION := 0;
		--	elsif AFTER_FLUSH = '1' and READPLACE = 4 then
		--		SCAN(5) := LAST_BYTE;
			else
				if READPLACE < 5 and INIT = '1' then
					INIT <= '0';
				end if;
				read(TARGETFILE,TARGETREAD);
				SCAN(READPLACE) := character'pos(TARGETREAD);
				READPLACE := READPLACE - 1;
				
			end if;
		elsif DECODER_STATE = FIND_START then
			if SCAN (5 downto 1) = ( 16#42#, 16#42#, 16#43#, 16#44#, 16#AC# ) then
				--BITPOS2 <= BITPOSITION;
				--COMPDATA <= SCAN(0);
				DECODER_STATE <= GET_SIZE;
				if BITPOSITION = 0 then
					BITPOSITION := 128;
				end if;
			elsif SCAN(5 downto 1) = (16#42#, 16#42#, 16#43#, 16#44#, 16#D0# ) then
				DECODER_STATE <= FINISHED;
			elsif BITPOSITION = 0 then
				read(TARGETFILE,TARGETREAD);
				read(HEADERFILE,DIRACREAD);
				SCAN(0) := character'pos(TARGETREAD);
				DIRACDATA := character'pos(DIRACREAD);
				BITPOSITION := 128;
			else
				for I in 5 downto 1 loop
					if SCAN(I) > 127 then
						SCAN(I) := SCAN(I) - 128;
					end if;
					SCAN(I) := SCAN(I)*2;
					if SCAN(I-1) > 127 then
						SCAN(I) := SCAN(I) + 1;
					end if;
				end loop;
				if SCAN(0) > 127 then
					SCAN(0) := SCAN(0) - 128;
				end if;
				SCAN(0) := SCAN(0)*2;
				BITPOSITION := BITPOSITION/2;
			end if;
		elsif DECODER_STATE = GET_SIZE then
			if EG_READY = '1' then
				DECODER_STATE <= FEED_DATA;
				BITPOSITION := 128;
				EG_ENABLE <= '0';
				BYTES_INPUT <= (others => '0');
			elsif EG_ENABLE = '1' then
				EG_ENABLE <= '0';
			else
				if BITPOSITION = 128 then
					READ(HEADERFILE,DIRACREAD);
					DIRACDATA := character'pos(DIRACREAD);
				end if;
				if (DIRACDATA rem (BITPOSITION*2))/BITPOSITION = 1 then
					EG_DATA_IN <= '1';
				else
					EG_DATA_IN <= '0';
				end if;
				EG_ENABLE <= '1';
				if BITPOSITION = 1 then
					BITPOSITION := 128;
				else
					BITPOSITION := BITPOSITION/2;
				end if;
			end if;
		elsif DECODER_STATE = FEED_DATA then
			if FLUSH = '1' then
				DECODER_STATE <= OFFSET;
				ENABLE_DECODER <= '0';
			--	if BITPOSITION = 128 then
			--		READPLACE := 4;
			--	else
					READPLACE := 5;
			--	end if;
			elsif BITPOSITION = 0 then
				DECODER_STATE <= PAUSE;
				BYTES_INPUT <= BYTES_INPUT + 1;
				ENABLE_DECODER <= '0';
				PAUSECOUNT := 0;
			else
				if BITPOSITION = 128 then
					if BYTES_INPUT < BYTES_TO_DECODE then
						read(DIRACFILE,DIRACREAD);
						DIRACDATA := character'pos(DIRACREAD);
					else
						DIRACDATA := 0;
					end if;
				end if;
				if (DIRACDATA rem (BITPOSITION*2))/BITPOSITION = 1 then
					DECODER_DATA_IN <= '1';
				else
					DECODER_DATA_IN <= '0';
				end if;
				ENABLE_DECODER <= '1';
				BITPOSITION := BITPOSITION/2;
			end if;
		elsif DECODER_STATE = PAUSE then
			if FLUSH = '1' then
				DECODER_STATE <= OFFSET;
				READPLACE := 5;
			elsif PAUSECOUNT > 7 then
				DECODER_STATE <= FEED_DATA;
				BITPOSITION := 128;
			elsif SENDING = '1' then
				PAUSECOUNT := 0;
			else
				PAUSECOUNT := PAUSECOUNT+1;
			end if;
		else --DECODER_STATE = FINISHED;
			report "Finished" severity failure;
		end if;
	end if;
end process TESTBENCH;

RESET <= INIT or FLUSH;

GETCONTEXT <= (RESET or SENDING) and not NEWCONTEXT;

CONTEXT : process (CLOCK)
variable CONTEXTREAD : character;
variable CONTEXTDATA : integer;
variable READPOSITION : integer;
variable NUMBER_READ : integer :=0;
begin
	if CLOCK'event and CLOCK = '1' then
		if GETCONTEXT = '1' then
			read(CONTEXTFILE,CONTEXTREAD);
			NUMBER_READ := NUMBER_READ + 1;
			CONTEXTDATA := character'pos(CONTEXTREAD);
			if (CONTEXTDATA rem 2) = 1 then
				FLUSH <= '1';
			else
				FLUSH <= '0';
				if(CONTEXTDATA rem 4)/2 = 1 then
					HALVECOUNTS <= '1';
				else
					HALVECOUNTS <= '0';
				end if;
				READPOSITION := 128;
				for I in 5 downto 0 loop
					if (CONTEXTDATA rem (READPOSITION*2))/READPOSITION = 1 then
						CONTEXT_SELECT(I) <= '1';
					else
						CONTEXT_SELECT(I) <= '0';
					end if;
				READPOSITION := READPOSITION/2;
				end loop;
				NEWCONTEXT <= '1';
			end if;
		else
			NEWCONTEXT <= '0';
			FLUSH <= '0';
			HALVECOUNTS <= '0';
		end if;
	end if;
end process CONTEXT;


CHECK_RESULTS : process (CLOCK)
variable DATA : integer;
variable COMPARISON : integer;
variable COMP2 : integer;
--variable BITPOSITION : integer;
variable INDEX : integer;
variable COMPREAD : character;
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
		--	DATA := 0;
		--	BITPOSITION := BITPOS2;
		--	read(TARGETFILE,COMPREAD);
		--	COMPARISON := character'pos(COMPREAD);
		--	COMP2 := 0;
			INDEX := 128;
		elsif SENDING = '1' then
			if INDEX = 128 then
				DATA := 0;
				read(TARGETFILE,COMPREAD);
				COMPARISON := character'pos(COMPREAD);
				COMP2 := 0;
			end if;
			if DATA_OUT = '1' then
				DATA:=DATA+INDEX;
			end if;
			if (COMPARISON rem (INDEX*2))/INDEX = 1 then
				COMP2 := COMP2 + INDEX;
			end if;
			assert COMP2 = DATA report "Decoder has Diverged" severity failure;
			if INDEX = 1 then
		--		read(TARGETFILE,COMPREAD);
		--		COMPARISON := character'pos(COMPREAD);
		--		LAST_BYTE <= COMPARISON;
		--		COMP2 := 0;
		--		DATA := 0;
			--	BITPOSITION := 128;
				INDEX := 128;
			else
			--	BITPOSITION := BITPOSITION/2;
				INDEX := INDEX/2;
			end if;
		end if;
	end if;
end process CHECK_RESULTS;

end architecture BEHAVIOUR;

				
						
				
				
				
		
	
		