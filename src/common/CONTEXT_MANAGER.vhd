	 -- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: CONTEXT_MANAGER.vhd,v 1.3 2006-10-05 16:17:11 petebleackley Exp $ $Name: not supported by cvs2svn $
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CONTEXT_MANAGER is
    Port (	CONTEXT_NUMBER : in std_logic_vector(5 downto 0);
	 		SET : in std_logic;
			UPDATE : in std_logic;
			DATA_IN : in std_logic;
			HALVECOUNTS : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           PROB : out std_logic_vector(7 downto 0);
			  READY : out std_logic);
end CONTEXT_MANAGER;

architecture RTL of CONTEXT_MANAGER is
	
	type MATRIX is array (45 downto 0) of std_logic_vector(15 downto 0);
	signal PROBABILITY : MATRIX;																																																																					
	constant HALF : std_logic_vector(15 downto 0) := "0000000100000010";
	signal FRACTION : std_logic_vector(15 downto 0);
	signal FRACTION2 : std_logic_vector(15 downto 0);
	signal RESET_FLAGS : std_logic_vector (45 downto 0);
	signal NEWPROB : std_logic_vector(15 downto 0);
	signal RATIO : std_logic_vector(15 downto 0);
	signal UPDATE_PROB : std_logic;
	signal PROB_CHANGED : std_logic;
	signal LOAD_DATA : std_logic;
	signal OLD_CONTEXT : std_logic_vector (5 downto 0);
	signal READ_ADDRESS : std_logic_vector (5 downto 0);
	signal DATA_FETCHED : std_logic;
	signal CONTEXT_VALID : std_logic;
	signal DATA_READY : std_logic_vector (1 downto 0);

	component DIVIDER
	port ( NUMERATOR : in std_logic_vector(7 downto 0);
           DENOMINATOR : in std_logic_vector(7 downto 0);
			  RESET : in std_logic;
           CLOCK : in std_logic;
           QUOTIENT : out std_logic_vector(7 downto 0));
	end component DIVIDER;
	component UPDATER
	port 	( NUMERATOR : in std_logic_vector(7 downto 0);
           DENOMINATOR : in std_logic_vector(7 downto 0);
           ENABLE : in std_logic;
           DATA_IN : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           NUMERATOR_OUT : out std_logic_vector(7 downto 0);
           DENOMINATOR_OUT : out std_logic_vector(7 downto 0);
			  UPDATE : out std_logic);
	end component UPDATER;
	component HALVING_MANAGER
	port ( TRIGGER_HALVING : in std_logic;
           INPUT_READY : in std_logic;
           NUMERATOR_IN : in std_logic_vector(7 downto 0);
           DENOMINATOR_IN : in std_logic_vector(7 downto 0);
			  CONTEXT : in std_logic_vector(5 downto 0);
           RESET : in std_logic;
           CLOCK : in std_logic;
           NUMERATOR_OUT : out std_logic_vector(7 downto 0);
           DENOMINATOR_OUT : out std_logic_vector(7 downto 0);
           OUTPUT_READY : out std_logic);
	end component HALVING_MANAGER;

begin

FLAGS: process(CLOCK)
begin
	if (CLOCK'event and CLOCK='1') then
		if (RESET='1') then
			RESET_FLAGS <= (others => '1');
		elsif LOAD_DATA = '1' then
				RESET_FLAGS(conv_integer(OLD_CONTEXT)) <= '0';
		end if;
	end if;
end process FLAGS;

LOAD_DATA <= UPDATE_PROB and UPDATE;


MEMORY: process(CLOCK)
begin
	if (CLOCK'event and CLOCK='1') then
		if SET='1' then
			READ_ADDRESS <= CONTEXT_NUMBER;
		end if;
		if (LOAD_DATA = '1') then
			PROBABILITY(conv_integer(OLD_CONTEXT)) <=	NEWPROB;
		end if;
	end if;
end process MEMORY;
RATIO <= PROBABILITY(conv_integer(READ_ADDRESS));

CHOOSE_FRACTION : process (READ_ADDRESS,RESET_FLAGS,RATIO)
begin
	if (RESET_FLAGS(conv_integer(READ_ADDRESS))='1') then
		FRACTION <= HALF;
	else
		FRACTION <= RATIO;
	end if;
end process CHOOSE_FRACTION;


DIVISION : DIVIDER
	port map (NUMERATOR => FRACTION2(15 downto 8),
	DENOMINATOR => FRACTION2(7 downto 0),
	RESET => RESET,
	CLOCK => CLOCK,
	QUOTIENT => PROB);

PROBUPDATE : UPDATER
	port map (NUMERATOR => FRACTION2(15 downto 8),
	DENOMINATOR => FRACTION2(7 downto 0),
	ENABLE => PROB_CHANGED,
	DATA_IN => DATA_IN,
	RESET => RESET,
	CLOCK => CLOCK,
	NUMERATOR_OUT => NEWPROB(15 downto 8),
	DENOMINATOR_OUT => NEWPROB(7 downto 0),
	UPDATE => UPDATE_PROB);

REFRESH: HALVING_MANAGER
	port map (TRIGGER_HALVING => HALVECOUNTS,
	INPUT_READY => DATA_FETCHED,
	NUMERATOR_IN => FRACTION(15 downto 8),
	DENOMINATOR_IN => FRACTION(7 downto 0),
	CONTEXT => CONTEXT_NUMBER,
	RESET => RESET,
	CLOCK => CLOCK,
	NUMERATOR_OUT => FRACTION2(15 downto 8),
	DENOMINATOR_OUT => FRACTION2(7 downto 0),
	OUTPUT_READY => PROB_CHANGED);


DELAY_CONTEXT : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
			OLD_CONTEXT <= CONTEXT_NUMBER;
	end if;
end process DELAY_CONTEXT;


IS_DATA_READY : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			DATA_READY <= "00";
		else
			DATA_READY <= DATA_READY(0) & PROB_CHANGED;
		end if;
	end if;
end process IS_DATA_READY;

CONTEXT_LOADED : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			CONTEXT_VALID <= '0';
		elsif SET = '1' then
			CONTEXT_VALID <= '1';
		elsif UPDATE =	'1' then
			CONTEXT_VALID <= '0';
		end if;
	end if;
end process CONTEXT_LOADED;

DATA_FETCHED <= CONTEXT_VALID and not SET;


READY <= (DATA_READY(1) and DATA_READY (0));-- and not SET;

			
end RTL;
