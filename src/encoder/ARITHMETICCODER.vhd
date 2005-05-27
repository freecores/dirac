-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: ARITHMETICCODER.vhd,v 1.2 2005-05-27 16:00:30 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity ARITHMETICCODER is
    Port ( ENABLE : in std_logic;
           DATA_IN : in std_logic;
			  CONTEXT_ENABLE : in std_logic;
			  CONTEXT_IN : in std_logic_vector (5 downto 0);
			  RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic);
end ARITHMETICCODER;

architecture RTL of ARITHMETICCODER is
 
	component LIMIT_REGISTER
	generic(CONST: std_logic);
	port(	  LOAD : in std_logic_vector(15 downto 0);
           SET_VALUE : in std_logic;
           SHIFT_ALL : in std_logic;
           SHIFT_MOST : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic_vector(15 downto 0));
	end component LIMIT_REGISTER;
	component FOLLOW_COUNTER
	port	( INCREMENT : in std_logic;
           TEST : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic);
	end component FOLLOW_COUNTER;
	component CONVERGENCE_CHECK
	port	( HIGH_MSB : in std_logic;
           LOW_MSB : in std_logic;
           HIGH_SECONDBIT : in std_logic;
           LOW_SECONDBIT : in std_logic;
           CHECK : in std_logic;
           TRIGGER_OUTPUT : out std_logic;
           TRIGGER_FOLLOW : out std_logic);
	end component CONVERGENCE_CHECK;
	component ARITHMETIC_UNIT
	port	( DIFFERENCE : in std_logic_vector(15 downto 0);
           PROB : in std_logic_vector(9 downto 0);
			  LOW :	in std_logic_vector(15 downto 0);
           ENABLE : in std_logic;
			  RESET :	in std_logic;
           CLOCK : in std_logic;
           DIFFERENCE_OUT0 : out std_logic_vector(15 downto 0);
			  DIFFERENCE_OUT1 : out std_logic_vector(15 downto 0);
           RESULT_OUT0 : out std_logic_vector(15 downto 0);
			  RESULT_OUT1 : out std_logic_vector(15 downto 0);
           DATA_LOAD : out std_logic);
	end component ARITHMETIC_UNIT;
	component OUTPUT_UNIT
	port ( ENABLE : in std_logic;
           DATA : in std_logic;
           FOLLOW : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
			  DATA_OUT : out std_logic;
           FOLLOW_COUNTER_TEST : out std_logic;
           SHIFT : out std_logic);
	end component OUTPUT_UNIT;
	component INPUT_CONTROL
	generic( WIDTH : integer range 1 to 16);
	port( ENABLE : in std_logic;
           DATA_IN : in std_logic_vector(WIDTH - 1 downto 0);
           BUFFER_CONTROL : in std_logic;
           DEMAND : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic_vector(WIDTH - 1 downto 0));
	end component INPUT_CONTROL;
	component CONTEXT_MANAGER
	port (  CONTEXT_NUMBER : in std_logic_vector(5 downto 0);
           RESET : in std_logic;
           CLOCK : in std_logic;
           PROB : out std_logic_vector(9 downto 0));
	end component CONTEXT_MANAGER;
	signal HIGH_SET : std_logic;
	signal LOW_SET	: std_logic;
	signal SHIFT_ALL :	std_logic;
	signal DIFFERENCE_SHIFT_ALL :	std_logic;
	signal SHIFT_MOST :	std_logic;
	signal ZERO_INPUT :	std_logic;
	signal ARITHMETIC_UNIT_ENABLE :	std_logic;
	signal ARITHMETIC_UNIT_DATA_LOAD :	std_logic;
	signal CONVERGENCE_TEST :	std_logic;
	signal TRIGGER_OUTPUT : std_logic;
	signal FOLLOW_COUNTER_TEST :	std_logic;
	signal FOLLOW:	std_logic;
	signal DATA_LOAD: std_logic;
	signal OUTPUT_ACTIVE :	std_logic;
	signal CHECK :	std_logic;
	signal DELAYED_CHECK : std_logic;
	signal DATA_AVAILABLE :	std_logic;
	signal BUFFERED_DATA : std_logic;
	signal BUFFER_INPUT :	std_logic;
	signal NEWCONTEXT : std_logic;
	signal ARITHMETIC_UNIT_DIFFERENCE_OUT0 : std_logic_vector (15 downto 0);
	signal ARITHMETIC_UNIT_DIFFERENCE_OUT1 :	std_logic_vector(15 downto 0);
	signal DIFFERENCE_IN : std_logic_vector (15 downto 0);
	signal ARITHMETIC_UNIT_RESULT_OUT0 :	std_logic_vector (15 downto 0);
	signal ARITHMETIC_UNIT_RESULT_OUT1 : std_logic_vector (15 downto 0);
	signal DIFFERENCE_OUT : std_logic_vector (15 downto 0);
	signal HIGH_OUT : std_logic_vector (15 downto 0);
	signal LOW_OUT : std_logic_vector (15 downto 0);
	signal PROB : std_logic_vector (9 downto 0);
	signal CONTEXT_SELECT : std_logic_vector (5 downto 0);
	signal PROB_AVAILABLE : std_logic;
	signal BUFFERCONTEXT :	std_logic;
	signal DATA_IN2 : std_logic_vector(0 downto 0);
	signal BUFFERED_DATA2 : std_logic_vector(0 downto 0);

begin
-- input buffering
INBUFFER:	INPUT_CONTROL
	generic map(WIDTH => 1)
	port map(ENABLE => ENABLE,
	DATA_IN => DATA_IN2,
	BUFFER_CONTROL => BUFFER_INPUT,
	DEMAND => ARITHMETIC_UNIT_DATA_LOAD,
	RESET => RESET,
	CLOCK => CLOCK,
	SENDING => DATA_AVAILABLE,
	DATA_OUT => BUFFERED_DATA2);

	DATA_IN2(0) <= DATA_IN;
	BUFFERED_DATA <= BUFFERED_DATA2(0);

CONTEXT_BUFFER:	INPUT_CONTROL
	generic map(WIDTH => 6)
	port map(ENABLE => CONTEXT_ENABLE,
	DATA_IN => CONTEXT_IN,
	BUFFER_CONTROL =>	 BUFFERCONTEXT,
	DEMAND => DATA_LOAD,
	RESET => RESET,
	CLOCK => CLOCK,
	SENDING => NEWCONTEXT,
	DATA_OUT => CONTEXT_SELECT);
-- Specify the registers
HIGH: LIMIT_REGISTER
	generic map(CONST => '1')
	port map(  LOAD => ARITHMETIC_UNIT_RESULT_OUT0,
           SET_VALUE => HIGH_SET,
           SHIFT_ALL => SHIFT_ALL,
           SHIFT_MOST => SHIFT_MOST,
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => HIGH_OUT);

DIFFERENCE: LIMIT_REGISTER
	generic map(CONST => '1')
	port map(  LOAD => DIFFERENCE_IN,
           SET_VALUE => DATA_LOAD,
           SHIFT_ALL => DIFFERENCE_SHIFT_ALL,
           SHIFT_MOST => '0',
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => DIFFERENCE_OUT);

LOW: LIMIT_REGISTER
	generic map(CONST => '0')
	port map(  LOAD => ARITHMETIC_UNIT_RESULT_OUT1,
           SET_VALUE => LOW_SET,
           SHIFT_ALL => SHIFT_ALL,
           SHIFT_MOST => SHIFT_MOST,
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => LOW_OUT);

-- The arithmetic

ARITH: ARITHMETIC_UNIT
	port map(DIFFERENCE => DIFFERENCE_OUT,
           PROB => PROB,
			  LOW => LOW_OUT,
           ENABLE => ARITHMETIC_UNIT_ENABLE,
			  RESET => RESET,
           CLOCK => CLOCK,
           DIFFERENCE_OUT0 => ARITHMETIC_UNIT_DIFFERENCE_OUT0,
			  DIFFERENCE_OUT1 => ARITHMETIC_UNIT_DIFFERENCE_OUT1,
           RESULT_OUT0 => ARITHMETIC_UNIT_RESULT_OUT0,
			  RESULT_OUT1 => ARITHMETIC_UNIT_RESULT_OUT1,
           DATA_LOAD => ARITHMETIC_UNIT_DATA_LOAD);

--The convergence checks

CONVERGE: CONVERGENCE_CHECK
	port map(HIGH_MSB => HIGH_OUT(15),
           LOW_MSB => LOW_OUT(15),
           HIGH_SECONDBIT => HIGH_OUT(14),
           LOW_SECONDBIT => LOW_OUT(14),
           CHECK => CONVERGENCE_TEST,
           TRIGGER_OUTPUT => TRIGGER_OUTPUT,
           TRIGGER_FOLLOW => SHIFT_MOST);

--The Follow Counter

FC:	FOLLOW_COUNTER
	port map( INCREMENT => SHIFT_MOST,
           TEST => FOLLOW_COUNTER_TEST,
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => FOLLOW);

--The output unit

OUTPUT:	OUTPUT_UNIT
	port map(ENABLE => TRIGGER_OUTPUT,
           DATA => HIGH_OUT(15),
           FOLLOW => FOLLOW,
			  RESET => RESET,
           CLOCK => CLOCK,
           SENDING => OUTPUT_ACTIVE,
			  DATA_OUT => DATA_OUT,
           FOLLOW_COUNTER_TEST => FOLLOW_COUNTER_TEST,
           SHIFT => SHIFT_ALL);

	SENDING <= OUTPUT_ACTIVE;

-- Input logic

	DATA_LOAD <= DATA_AVAILABLE and ARITHMETIC_UNIT_DATA_LOAD;
	HIGH_SET <= ZERO_INPUT and DATA_LOAD;
	ZERO_INPUT <= not BUFFERED_DATA;
	LOW_SET <= BUFFERED_DATA and DATA_LOAD;

-- Control logic for DIFFERENCE register

	DIFFERENCE_SHIFT_ALL <= SHIFT_ALL or SHIFT_MOST;

-- Control logic for convergence check

	CHECK <= DIFFERENCE_SHIFT_ALL or DATA_LOAD;

CONVERGENCE_TEST_DELAY:	process (CLOCK)
	begin
	if CLOCK'event and CLOCK = '1' then
		DELAYED_CHECK <= CHECK;
	end if;
	end process CONVERGENCE_TEST_DELAY;

	CONVERGENCE_TEST <= DELAYED_CHECK or FOLLOW_COUNTER_TEST;

-- Control logic for arithmetic unit
	
	ARITHMETIC_UNIT_ENABLE <= PROB_AVAILABLE and not(OUTPUT_ACTIVE or DIFFERENCE_SHIFT_ALL or DATA_LOAD);

-- Control Logic for input control

	BUFFER_INPUT <= OUTPUT_ACTIVE or not ARITHMETIC_UNIT_DATA_LOAD;

-- Select the new difference value

NEWDIFF : process(BUFFERED_DATA,ARITHMETIC_UNIT_DIFFERENCE_OUT0,ARITHMETIC_UNIT_DIFFERENCE_OUT1)
	begin
		if(BUFFERED_DATA = '1') then
			DIFFERENCE_IN <= ARITHMETIC_UNIT_DIFFERENCE_OUT1;
		else
			DIFFERENCE_IN <= ARITHMETIC_UNIT_DIFFERENCE_OUT0;
		end if;
	end process NEWDIFF;

-- Select the context

PROBABILITY : CONTEXT_MANAGER
			port map(CONTEXT_NUMBER => CONTEXT_SELECT,
			RESET => RESET,
			CLOCK => CLOCK,
			PROB => PROB);

ISPROBAVAILABLE : process (CLOCK)
	begin
	if (CLOCK'event and CLOCK = '1') then
	if (RESET = '1' or (DATA_LOAD = '1' and NEWCONTEXT = '0')) then
		PROB_AVAILABLE <= '0';
	elsif (NEWCONTEXT = '1') then
		PROB_AVAILABLE <= '1';
	end if;
	end if;
end process ISPROBAVAILABLE;

	  BUFFERCONTEXT <= PROB_AVAILABLE and not ARITHMETIC_UNIT_DATA_LOAD;

--

end RTL;


