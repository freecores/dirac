-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: FIFO.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity FIFO is
	generic (RANK :	integer range 0 to 16 :=8);
    Port ( WRITE_ENABLE : in std_logic;
           DATA_IN : in std_logic;
           READ_ENABLE : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           DATA_OUT : out std_logic;
			  EMPTY : out std_logic);
end FIFO;

architecture RTL of FIFO is
	 component	ENABLEABLE_D_TYPE
	 port (DATA_IN : in std_logic;
	 		ENABLE : in std_logic;
			 CLK : in std_logic;
			 DATA_OUT:	out std_logic);
	end component ENABLEABLE_D_TYPE;
	component D_TYPE
	port(	 D : in std_logic;
           CLOCK : in std_logic;
           Q : out std_logic);
end component D_TYPE;
	component COUNT_UNIT
	port(		INCREMENT : in std_logic;
           DECREMENT : in std_logic;
			  RESET :	in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic;
           INCREMENT_CARRY : out std_logic;
           DECREMENT_CARRY : out std_logic);
end component COUNT_UNIT;
	function TWO_TO_N(N:	integer) return integer is
	variable A:	integer;
	begin
	A := 1;
	for Z in 0 to N - 1 loop
	A := 2*A;
	end loop;
	return A;
	end function TWO_TO_N;
	function ZERO_VALUE(ADDRESS:	std_logic_vector) return std_logic is
	begin
	for J in 0 to RANK - 1 loop
	if ADDRESS(J) = '1' then
	return '0';
	end if;
	end loop;
	return '1';
	end function ZERO_VALUE;

	signal READ_ADDRESS :	std_logic_vector (RANK - 1 downto 0);
	signal INC :	std_logic_vector (RANK - 1 downto 0);
	signal DEC : 	std_logic_vector (RANK - 1 downto 0);
	type MATRIX is
	array (RANK downto 0) of std_logic_vector (TWO_TO_N(RANK) -1 downto 0);
	signal GET_OUTPUT: MATRIX;
	signal NEWVAL :	std_logic_vector(TWO_TO_N(RANK) - 1 downto 0);
	signal INCREMENT :	std_logic;
	signal DECREMENT :	std_logic;
	signal TOGGLE :	std_logic;
	signal IS_EMPTY :	std_logic;
	signal ZERO :	std_logic;
	signal NEW_EMPTY : std_logic;
	signal EMPTY_OUT :	std_logic;
	signal NOWRITE :	std_logic;
	signal CHANGED_VALUE : std_logic;
	signal EMPTY_IF_READ :	std_logic;
	signal LOAD_ENABLE : std_logic;
begin
-- Storage registers


BUILD: for I in 0 to RANK -1 generate

LSB:	if I = 0 generate
COUNTER : COUNT_UNIT
	port map( INCREMENT => INCREMENT,
				DECREMENT => DECREMENT,
				RESET => RESET,
				CLOCK => CLOCK,
				OUTPUT => READ_ADDRESS(I),
				INCREMENT_CARRY => INC(I),
				DECREMENT_CARRY => DEC(I));

	end generate;

OTHER_BITS:	if I > 0 generate
COUNTER :	COUNT_UNIT
	port map( INCREMENT => INC(I-1),
				DECREMENT => DEC(I-1),
				RESET => RESET,
				CLOCK => CLOCK,
				OUTPUT => READ_ADDRESS(I),
				INCREMENT_CARRY => INC(I),
				DECREMENT_CARRY => DEC(I));
	end generate;

MULTIPLEX:	for Z in 0 to TWO_TO_N(I) - 1 generate
OUTPUT_SELECT: process(READ_ADDRESS(RANK - I - 1),GET_OUTPUT(RANK - I -1))
begin
	if READ_ADDRESS(RANK - I - 1) = '1' then
		GET_OUTPUT(RANK - I)(Z) <= GET_OUTPUT(RANK - I - 1)(2*Z + 1);
	else
		GET_OUTPUT(RANK - I)(Z) <= GET_OUTPUT(RANK - I - 1)(2*Z);
	end if;
end process OUTPUT_SELECT;
end generate;

STORAGE: if I = RANK - 1 generate
BITS:	for X in 0 to TWO_TO_N(RANK) - 1 generate
STORE:	ENABLEABLE_D_TYPE
			port map (DATA_IN => NEWVAL(X),
			ENABLE => LOAD_ENABLE,
			CLK => CLOCK,
			DATA_OUT => GET_OUTPUT(0)(X));
MOST_RECENT:	if X = 0 generate
	NEWVAL(X) <= DATA_IN and not RESET;
end generate;

OLDER_DATA: if X > 0 generate
	NEWVAL(X) <= GET_OUTPUT(0)(X-1) and not RESET;
end generate;
end generate;
end generate;


end generate;

LOAD_ENABLE <= WRITE_ENABLE or RESET;
INCREMENT <= WRITE_ENABLE and not (READ_ENABLE or EMPTY_OUT);
DECREMENT <= READ_ENABLE and not (WRITE_ENABLE or ZERO);

EMPTY_VALUE:	D_TYPE
	port map(D => IS_EMPTY,
				CLOCK => CLOCK,
				Q => EMPTY_OUT);

IS_EMPTY <= NEW_EMPTY or RESET;

SWITCH_EMPTY: process(TOGGLE,EMPTY_OUT,CHANGED_VALUE)
begin
	if(TOGGLE = '1') then
		NEW_EMPTY <= CHANGED_VALUE;
	else
		NEW_EMPTY <= EMPTY_OUT;
	end if;
end process SWITCH_EMPTY;

TOGGLE <= WRITE_ENABLE xor READ_ENABLE;
CHANGED_VALUE <= EMPTY_IF_READ and NOWRITE;
NOWRITE <= not WRITE_ENABLE;
EMPTY_IF_READ <= ZERO or EMPTY_OUT;


ZERO <= ZERO_VALUE(READ_ADDRESS);

EMPTY <= EMPTY_OUT;

DATA_OUT <= GET_OUTPUT(RANK)(0);



end RTL;
