-- ***** BEGIN LICENSE BLOCK *****
-- 
-- 
--  Version: MPL 1.1/GPL 2.0/LGPL 2.1
-- 
--  The contents of this file are subject to the Mozilla Public License
--  Version 1.1 (the "License"); you may not use this file except in compliance
--  with the License. You may obtain a copy of the License at
--  http://www.mozilla.org/MPL/
-- 
--  Software distributed under the License is distributed on an "AS IS" basis,
--  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
--  the specific language governing rights and limitations under the License.
-- 
--  The Original Code is BBC Research and Development code.
-- 
--  The Initial Developer of the Original Code is the British Broadcasting
--  Corporation.
--  Portions created by the Initial Developer are Copyright (C) 2006.
--  All Rights Reserved.
-- 
--  Contributor(s): Peter Bleackley (Original author)
-- 
--  Alternatively, the contents of this file may be used under the terms of
--  the GNU General Public License Version 2 (the "GPL"), or the GNU Lesser
--  Public License Version 2.1 (the "LGPL"), in which case the provisions of
--  the GPL or the LGPL are applicable instead of those above. If you wish to
--  allow use of your version of this file only under the terms of the either
--  the GPL or LGPL and not to allow others to use your version of this file
--  under the MPL, indicate your decision by deleting the provisions above
--  and replace them with the notice and other provisions required by the GPL
--  or LGPL. If you do not delete the provisions above, a recipient may use
--  your version of this file under the terms of any one of the MPL, the GPL
--  or the LGPL.
-- * ***** END LICENSE BLOCK ***** */

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HALVING_MANAGER is
    Port ( TRIGGER_HALVING : in std_logic;
           INPUT_READY : in std_logic;
           NUMERATOR_IN : in std_logic_vector(9 downto 0);
           DENOMINATOR_IN : in std_logic_vector(9 downto 0);
			  CONTEXT : in std_logic_vector(5 downto 0);
           RESET : in std_logic;
           CLOCK : in std_logic;
           NUMERATOR_OUT : out std_logic_vector(9 downto 0);
           DENOMINATOR_OUT : out std_logic_vector(9 downto 0);
           OUTPUT_READY : out std_logic);
end HALVING_MANAGER;

architecture RTL of HALVING_MANAGER is
	type COUNTARRAY is array(45 downto 0) of std_logic_vector(2 downto 0);
	signal SHIFTS : COUNTARRAY;
	signal NUMERATOR : std_logic_vector (9 downto 0);
	signal DENOMINATOR : std_logic_vector (9 downto 0);
	signal NUMERATOR2 : std_logic_vector (9 downto 0);
	signal DENOMINATOR2 : std_logic_vector (9 downto 0);
	signal DENOMINATOR_INCREMENT : std_logic_vector (9 downto 0);
	signal GREATER_THAN_16 : std_logic;
	signal PERFORM_HALVING : std_logic;
	signal AFTER_TRIGGER : std_logic;
	signal LOAD : std_logic;
	signal CALCULATE_VALUES : std_logic;

begin

COUNT_HALVING_EVENTS : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			SHIFTS <= (others => "000");
		elsif TRIGGER_HALVING = '1' then
			for I in 0 to 45 loop
				if SHIFTS(I) /= "111" then
					SHIFTS(I) <= SHIFTS(I) + "001";
				end if;
			end loop;
		elsif CALCULATE_VALUES = '1' then
			SHIFTS(conv_integer(CONTEXT)) <= SHIFTS(conv_integer(CONTEXT)) - "001";
		elsif GREATER_THAN_16 = '0' and LOAD = '0' and INPUT_READY = '1' then
			SHIFTS(conv_integer(CONTEXT)) <= "000";
		end if;
	end if;
end process COUNT_HALVING_EVENTS;

NUMERATOR2 <= ('0' & NUMERATOR (9 downto 1)) + "0000000001";
DENOMINATOR2 <= ('0' & DENOMINATOR(9 downto 1)) + DENOMINATOR_INCREMENT;

HALVE_COUNTS :	 process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET = '1' then
			NUMERATOR <= "0000000001";
			DENOMINATOR <= "0000000010";
		elsif CALCULATE_VALUES = '1' then
			NUMERATOR <= NUMERATOR2;
			DENOMINATOR <= DENOMINATOR2;
		elsif LOAD = '1' then
			NUMERATOR <= NUMERATOR_IN;
			DENOMINATOR <= DENOMINATOR_IN;
		end if;
	end if;
end process HALVE_COUNTS;

HALVING_PERMITTED : process (DENOMINATOR)
begin
	if DENOMINATOR > "0000010000" then
		GREATER_THAN_16 <= '1';
	else
		GREATER_THAN_16 <= '0';
	end if;
end process HALVING_PERMITTED;

HALVING_ACTIVE : process (INPUT_READY, SHIFTS, CONTEXT, GREATER_THAN_16)
begin
	if INPUT_READY = '1' and (SHIFTS(conv_integer(CONTEXT)) > "000") then
		PERFORM_HALVING <= GREATER_THAN_16;
	else
		PERFORM_HALVING <= '0';
	end if;
end process HALVING_ACTIVE;			

SELECT_OUTPUT : process (NUMERATOR_IN, DENOMINATOR_IN, NUMERATOR, DENOMINATOR, TRIGGER_HALVING, PERFORM_HALVING, LOAD)
begin
	if (LOAD and (TRIGGER_HALVING nor PERFORM_HALVING)) = '1' then
		NUMERATOR_OUT <= NUMERATOR_IN;
		DENOMINATOR_OUT <= DENOMINATOR_IN;
	else
		NUMERATOR_OUT <= NUMERATOR;
		DENOMINATOR_OUT <= DENOMINATOR;
	end if;
end process SELECT_OUTPUT;

DELAY_TRIGGER : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			AFTER_TRIGGER <= '0';
		else
			AFTER_TRIGGER <= INPUT_READY;
		end if;
	end if;
end process DELAY_TRIGGER;

CHOOSE_DENOMINATOR_INCREMENT : process (NUMERATOR, DENOMINATOR)
begin
	if (NUMERATOR (0) = '1') and (DENOMINATOR (0) = '0') then
		DENOMINATOR_INCREMENT <= "0000000001";
	else
		DENOMINATOR_INCREMENT <= "0000000010";
	end if;
end process CHOOSE_DENOMINATOR_INCREMENT;

LOAD <= INPUT_READY and not AFTER_TRIGGER;

CALCULATE_VALUES <= PERFORM_HALVING and AFTER_TRIGGER;

OUTPUT_READY <= INPUT_READY and (PERFORM_HALVING nor TRIGGER_HALVING);		 

end RTL;
