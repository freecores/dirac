-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: ARITHMETICDECODER.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity ARITHMETICDECODER is
	generic (PROB :	std_logic_vector (9 downto 0) := "1010101010");
    Port ( ENABLE : in std_logic;
           DATA_IN : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic);
end ARITHMETICDECODER;

architecture RTL of ARITHMETICDECODER is
	component INPUT_CONTROL
	port(	  ENABLE : in std_logic;
           DATA_IN : in std_logic;
           BUFFER_CONTROL : in std_logic;
           DEMAND : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic);
	end component INPUT_CONTROL;
 	component STORAGE_REGISTER
	Port ( LOAD : in std_logic_vector(15 downto 0);
	 		  SHIFT_IN : in std_logic; 
           SET_VALUE : in std_logic;
           SHIFT_ALL : in std_logic;
           SHIFT_MOST : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic_vector(15 downto 0));
	end component STORAGE_REGISTER;
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
	component SYMBOL_DETECTOR
	port ( ENABLE : in std_logic;
           DATA_IN : in std_logic_vector (15 downto 0);
           THRESHOLD : in std_logic_vector (15 downto 0);
			  DATA_OUT : out std_logic);
	end component SYMBOL_DETECTOR;
	signal HIGH_SET : std_logic;
	signal LOW_SET	: std_logic;
	signal SHIFT_ALL :	std_logic;
	signal DIFFERENCE_SHIFT_ALL :	std_logic;
	signal SHIFT_MOST :	std_logic;
	signal ZERO_OUTPUT :	std_logic;
	signal ARITHMETIC_UNIT_ENABLE :	std_logic;
	signal CONVERGENCE_TEST :	std_logic;
	signal TRIGGER_INPUT : std_logic;
	signal TRIGGER_FOLLOW:	std_logic;
	signal DATA_LOAD: std_logic;
	signal GET_DATA :	std_logic;
	signal DATA_AVAILABLE :	std_logic;
	signal BUFFERED_DATA : std_logic;
	signal SYMBOL :	std_logic;
	signal HOLD : std_logic;
	signal DIFFERENCE_IN : std_logic_vector (15 downto 0);
	signal ARITHMETIC_UNIT_RESULT_OUT0 :	std_logic_vector (15 downto 0);
	signal ARITHMETIC_UNIT_RESULT_OUT1 :	std_logic_vector (15 downto 0);
	signal ARITHMETIC_UNIT_DIFFERENCE_OUT0 : std_logic_vector(15 downto 0);
	signal ARITHMETIC_UNIT_DIFFERENCE_OUT1 : std_logic_vector(15 downto 0);
	signal DIFFERENCE_VALUE : std_logic_vector (15 downto 0);
	signal HIGH_VALUE : std_logic_vector (15 downto 0);
	signal LOW_VALUE : std_logic_vector (15 downto 0);
	signal CURRENT_VALUE : std_logic_vector (15 downto 0);

begin
-- input buffering
INBUFFER:	INPUT_CONTROL
	port map(ENABLE => ENABLE,
	DATA_IN => DATA_IN,
	BUFFER_CONTROL => HOLD,
	DEMAND => GET_DATA,
	RESET => RESET,
	CLOCK => CLOCK,
	SENDING => DATA_AVAILABLE,
	DATA_OUT => BUFFERED_DATA);

-- Specify the registers
  HIGH:	STORAGE_REGISTER
	 port map( LOAD => ARITHMETIC_UNIT_RESULT_OUT0,
	 		  SHIFT_IN => '1',
           SET_VALUE => HIGH_SET,
           SHIFT_ALL => SHIFT_ALL,
           SHIFT_MOST => SHIFT_MOST,
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => HIGH_VALUE);

LOW:	STORAGE_REGISTER
	port map( LOAD => ARITHMETIC_UNIT_RESULT_OUT1,
	 		  SHIFT_IN => '0', 
           SET_VALUE => LOW_SET,
           SHIFT_ALL => SHIFT_ALL,
           SHIFT_MOST => SHIFT_MOST,
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => LOW_VALUE);

DIFFERENCE:	STORAGE_REGISTER
	port map( LOAD =>	DIFFERENCE_IN,
				SHIFT_IN => '1',
				SET_VALUE => DATA_LOAD,
				SHIFT_ALL => DIFFERENCE_SHIFT_ALL,
				SHIFT_MOST => '0',
				RESET => RESET,
				CLOCK => CLOCK,
				OUTPUT => DIFFERENCE_VALUE);

CURRENT:	STORAGE_REGISTER
	port map( LOAD => "0000000000000000",
	 		  SHIFT_IN => BUFFERED_DATA, 
           SET_VALUE => '0',
           SHIFT_ALL => SHIFT_ALL,
           SHIFT_MOST => SHIFT_MOST,
			  RESET => RESET,
           CLOCK => CLOCK,
           OUTPUT => CURRENT_VALUE);
-- The arithmetic

ARITH: ARITHMETIC_UNIT
	port map(DIFFERENCE => DIFFERENCE_VALUE,
           PROB => PROB,
			  LOW => LOW_VALUE,
           ENABLE => ARITHMETIC_UNIT_ENABLE,
			  RESET => RESET,
           CLOCK => CLOCK,
           DIFFERENCE_OUT0 => ARITHMETIC_UNIT_DIFFERENCE_OUT0,
			  DIFFERENCE_OUT1 => ARITHMETIC_UNIT_DIFFERENCE_OUT1,
           RESULT_OUT0 => ARITHMETIC_UNIT_RESULT_OUT0,
			  RESULT_OUT1 => ARITHMETIC_UNIT_RESULT_OUT1,
           DATA_LOAD => DATA_LOAD);

--The convergence checks

CONVERGE: CONVERGENCE_CHECK
	port map(HIGH_MSB => HIGH_VALUE(15),
           LOW_MSB => LOW_VALUE(15),
           HIGH_SECONDBIT => HIGH_VALUE(14),
           LOW_SECONDBIT => LOW_VALUE(14),
           CHECK => CONVERGENCE_TEST,
           TRIGGER_OUTPUT => TRIGGER_INPUT,
           TRIGGER_FOLLOW => TRIGGER_FOLLOW);

--The output unit

OUTPUT:	SYMBOL_DETECTOR
	port map(ENABLE => DATA_LOAD,
           DATA_IN => CURRENT_VALUE,
           THRESHOLD =>  ARITHMETIC_UNIT_RESULT_OUT1,
			  DATA_OUT => SYMBOL);

	SENDING <= DATA_LOAD;
	DATA_OUT <= SYMBOL;
-- Input logic

	HIGH_SET <= ZERO_OUTPUT and DATA_LOAD;
	ZERO_OUTPUT <= not SYMBOL;
	LOW_SET <= SYMBOL and DATA_LOAD;
	GET_DATA <= TRIGGER_INPUT or TRIGGER_FOLLOW;
	HOLD <= 	DATA_LOAD or not GET_DATA;

-- Control logic for DIFFERENCE register

	DIFFERENCE_SHIFT_ALL <= SHIFT_ALL or SHIFT_MOST;

-- Control logic for convergence check

--	CHECK <= DIFFERENCE_SHIFT_ALL or DATA_LOAD or RESET;

-- CONVERGENCE_TEST_DELAY:	D_TYPE
--	port map( D => CHECK,
--	CLOCK => CLOCK,
--	Q => CONVERGENCE_TEST);

  CONVERGENCE_TEST <= not DATA_LOAD;

-- Control logic for arithmetic unit
	
	ARITHMETIC_UNIT_ENABLE <=  GET_DATA nor DATA_LOAD;

-- Control Logic for input control
	SHIFT_ALL <= TRIGGER_INPUT and DATA_AVAILABLE;
	SHIFT_MOST <= TRIGGER_FOLLOW and DATA_AVAILABLE;

--Select new difference value
NEWDIFF : process(SYMBOL,ARITHMETIC_UNIT_DIFFERENCE_OUT0,ARITHMETIC_UNIT_DIFFERENCE_OUT1)
	begin
		if(SYMBOL = '1') then
			DIFFERENCE_IN <= ARITHMETIC_UNIT_DIFFERENCE_OUT1;
		else
			DIFFERENCE_IN <= ARITHMETIC_UNIT_DIFFERENCE_OUT0;
		end if;
	end process NEWDIFF;



end RTL;
