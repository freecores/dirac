-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: ARITHMETIC_UNIT.vhd,v 1.4 2006-10-05 16:17:11 petebleackley Exp $ $Name: not supported by cvs2svn $
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
use IEEE.NUMERIC_STD.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ARITHMETIC_UNIT is
    Port ( DIFFERENCE : in std_logic_vector(15 downto 0);
           PROB : in std_logic_vector(7 downto 0);
			  LOW :	in std_logic_vector(15 downto 0);
           ENABLE : in std_logic;
			  RESET :	in std_logic;
           CLOCK : in std_logic;
           DIFFERENCE_OUT0 : out std_logic_vector(15 downto 0);
			  DIFFERENCE_OUT1 : out std_logic_vector(15 downto 0);
           RESULT_OUT0 : out std_logic_vector(15 downto 0);
			  RESULT_OUT1 : out std_logic_vector(15 downto 0);
           DATA_LOAD : out std_logic :='1');
end ARITHMETIC_UNIT;

architecture RTL of ARITHMETIC_UNIT is

	signal LOW2 : std_logic_vector(16 downto 0);
	signal PRODUCT :	std_logic_vector (24 downto 0);
	signal PRODUCT2 :	 std_logic_vector (16 downto 0);
	signal RESULT :	std_logic_vector (16 downto 0);
	signal RESULT0 : std_logic_vector (16 downto 0);
	signal DIFFERENCE1 : std_logic_vector (16 downto 0);
	signal DIFFERENCE2 : std_logic_vector(16 downto 0);
	signal DIFFERENCE3 : std_logic_vector(16 downto 0);
	signal DIFFERENCE4 :	std_logic_vector(16 downto 0);
	signal DELAY1 : std_logic;
--	signal DELAY2 : std_logic;
	signal CALCULATE :	std_logic;
begin

-- The arithmetic
	DIFFERENCE2 <= ('0' & DIFFERENCE) + "00000000000000001";
MULTIPLY : process (CLOCK)
	begin
	if CLOCK'event and CLOCK = '1' then
		if ENABLE = '1' then
		PRODUCT <= DIFFERENCE2 * PROB;
		end if;
	end if;
end process MULTIPLY;

	PRODUCT2	<= PRODUCT(24 downto 8);
	RESULT <= LOW2 + PRODUCT2;
	RESULT_OUT1 <= RESULT(15 downto 0);
	RESULT0	<= (RESULT - "00000000000000001");
	RESULT_OUT0 <= RESULT0(15 downto 0);
	DIFFERENCE3 <= (PRODUCT2 - "00000000000000001");
	DIFFERENCE4 <= (DIFFERENCE1 - PRODUCT2);
	DIFFERENCE_OUT1 <= DIFFERENCE4(15 downto 0);
	DIFFERENCE_OUT0 <= DIFFERENCE3(15 downto 0);



-- Control logic
	CALCULATE <= ENABLE and not RESET;
	DATA_LOAD <= DELAY1;-- and DELAY2;

-- Sequential control logic

DELAYS: process (CLOCK)
	begin
	if CLOCK'event and CLOCK = '1' then
		DELAY1 <= CALCULATE;
--		DELAY2 <= DELAY1;
		if ENABLE = '1' then
			DIFFERENCE1 <= '0' & DIFFERENCE;
			LOW2 <= '0' & LOW;
		end if;

	end if;
end process DELAYS;




end RTL;
