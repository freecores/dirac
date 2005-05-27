-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: FIFO.vhd,v 1.2 2005-05-27 16:00:28 petebleackley Exp $ $Name: not supported by cvs2svn $
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
	generic (RANK :	integer range 0 to 16 :=8;
	WIDTH : integer range 1 to 16);
    Port ( WRITE_ENABLE : in std_logic;
           DATA_IN : in std_logic_vector(WIDTH - 1 downto 0);
           READ_ENABLE : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           DATA_OUT : out std_logic_vector(WIDTH - 1 downto 0);
           EMPTY : out std_logic);
end FIFO;

architecture RTL of FIFO is


	function TWO_TO_N(N:	integer) return integer is
	variable A:	integer;
	begin
	A := 1;
	for Z in 0 to N - 1 loop
	A := 2*A;
	end loop;
	return A;
	end function TWO_TO_N;
	signal WRITE_ADDRESS :	std_logic_vector (RANK - 1 downto 0);
	signal READ_ADDRESS :	std_logic_vector (RANK - 1 downto 0);
	type MATRIX is
	array (TWO_TO_N(RANK) - 1 downto 0) of std_logic_vector(WIDTH - 1 downto 0);
	signal GET_OUTPUT: MATRIX;

	signal EMPTY_OUT :	std_logic;


begin
-- Counters

COUNT: process (CLOCK)
	begin
	if (CLOCK'event and CLOCK = '1') then
		if (RESET = '1') then
			READ_ADDRESS <= (others => '0');
			WRITE_ADDRESS <= (others => '0');
		else
			if WRITE_ENABLE = '1' then
				WRITE_ADDRESS <= WRITE_ADDRESS + "1";
			end if;
			if READ_ENABLE = '1' and EMPTY_OUT = '0' then
				READ_ADDRESS <= READ_ADDRESS + "1";
			end if;
		end if;	
	end if;
end process COUNT;




ZEROVALUE : process (READ_ADDRESS, WRITE_ADDRESS)
begin
	if READ_ADDRESS = WRITE_ADDRESS then
	EMPTY_OUT <= '1';
	else
	EMPTY_OUT <= '0';
	end if;
end process ZEROVALUE;

EMPTY <= EMPTY_OUT;

SETDATA: process (CLOCK)
	begin
	if CLOCK'event and CLOCK = '1' then
	if WRITE_ENABLE = '1' then
		GET_OUTPUT(conv_integer(WRITE_ADDRESS)) <= DATA_IN;
	end if;
	end if;
	end process SETDATA;


	DATA_OUT <= GET_OUTPUT(conv_integer(READ_ADDRESS));


end RTL;

