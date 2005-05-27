	 -- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: CONTEXT_MANAGER.vhd,v 1.1 2005-05-27 16:00:28 petebleackley Exp $ $Name: not supported by cvs2svn $
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
           RESET : in std_logic;
           CLOCK : in std_logic;
           PROB : out std_logic_vector(9 downto 0));
end CONTEXT_MANAGER;

architecture RTL of CONTEXT_MANAGER is
	type MATRIX is array (63 downto 0) of std_logic_vector(9 downto 0);
	signal PROBABILITY : MATRIX := ("1111111111","0011011010","1111000000",
	"1100110000","0111110000","1001111100","0000010000","0000110011","1100110011",
	"1101110111","0110011010","1000111000","0000001010","0000110011","1000110011",
	"0101011011","1110000000","0100111101","1000001010","1110011011","0000001010",
	"0101111000","1111000000","1111001101","0111001101","1101011100","0111110110",
	"0110000011","1111110110","0101000110","1110011010","1110101110","0111000011",
	"0110010110","1111001101","0011001101","1001100110","1100100101","0001100110",
	"1110011010","0100110011","1111001101","0111001101","0011101111","1110011010",
	"1111100011","0011001101","0101000000","1110000000","0011000000","1100000000",
	"0110101011","1010101011","1110011010","0110011010","1001110010","0101010101",
	"1000111001","0101010101","1100110011","0110011010","0100000000","1100000000",
	"1000000000");
begin
  OUTPUT : process (CLOCK)
  begin
  	if CLOCK'event and CLOCK = '1' then
		PROB <= PROBABILITY(conv_integer(CONTEXT_NUMBER));
	end if;
	end process OUTPUT;

end RTL;
