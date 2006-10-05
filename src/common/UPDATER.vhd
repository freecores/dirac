-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: UPDATER.vhd,v 1.2 2006-10-05 16:17:11 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity UPDATER is
    Port ( NUMERATOR : in std_logic_vector(7 downto 0);
           DENOMINATOR : in std_logic_vector(7 downto 0);
           ENABLE : in std_logic;
           DATA_IN : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           NUMERATOR_OUT : out std_logic_vector(7 downto 0);
           DENOMINATOR_OUT : out std_logic_vector(7 downto 0);
			  UPDATE : out std_logic);
end UPDATER;

architecture RTL of UPDATER is
	signal NUMERATOR1 : std_logic_vector(7 downto 0);
	signal NUMERATOR2 : std_logic_vector(7 downto 0);
	signal NUMERATOR3 : std_logic_vector(7 downto 0);
	signal NUMERATOR4	: std_logic_vector(7 downto 0);
	signal DENOMINATOR2 : std_logic_vector(7 downto 0);
	signal HALVE_VALUES : std_logic;
	signal UPDATE_SWITCH : std_logic;
begin

DELAY_NUMERATOR : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			NUMERATOR1<="00000001";
		else
			NUMERATOR1<=NUMERATOR;
		end if;
	end if;
end process DELAY_NUMERATOR;

INCREMENT_NUMERATOR : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			NUMERATOR2 <= "00000001";
		else
			NUMERATOR2 <= NUMERATOR + "00000001";
		end if;
	end if;
end process INCREMENT_NUMERATOR;

HALVE_NUMERATOR : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			NUMERATOR3 <= "00000001";
		else
				NUMERATOR3 <= ('0' & NUMERATOR(7 downto 1)) + "00000001";
		end if;
	end if;
end process HALVE_NUMERATOR;

INCREMENT_AND_HALVE_NUMERATOR : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			NUMERATOR4 <= "00000001";
		else
			NUMERATOR4 <= ('0' & NUMERATOR(7 downto 1)) + "00000001" + ("0000000" & NUMERATOR(0));
		end if;
	end if;
end process INCREMENT_AND_HALVE_NUMERATOR;
	
INCREMENT_DENOMINATOR : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			DENOMINATOR2 <= "00000010";
		else
			DENOMINATOR2 <= DENOMINATOR + "00000001";
		end if;
	end if;
end process INCREMENT_DENOMINATOR;

HALVE_DENOMINATOR : process (DENOMINATOR)
begin
	if (DENOMINATOR = "11111111") then
		HALVE_VALUES <= '1';
	else
		HALVE_VALUES <= '0';
	end if;
end process HALVE_DENOMINATOR;

OUTPUT_NUMERATOR : process(NUMERATOR1,NUMERATOR2,NUMERATOR3,NUMERATOR4,DENOMINATOR,DATA_IN,HALVE_VALUES)
begin
	if HALVE_VALUES='1' then
		if DATA_IN='1' then
			NUMERATOR_OUT <= NUMERATOR3;
		else
			NUMERATOR_OUT <= NUMERATOR4;
		end if;
	else
		if DATA_IN='1' then
			NUMERATOR_OUT <= NUMERATOR1;
		else
			NUMERATOR_OUT <= NUMERATOR2;
		end if;
	end if;
end process OUTPUT_NUMERATOR;

UPDATE_SWITCH <= DATA_IN xor NUMERATOR(0);

OUTPUT_DENOMINATOR : process(DENOMINATOR,DENOMINATOR2,UPDATE_SWITCH,HALVE_VALUES)
begin
	if HALVE_VALUES='1' then
		if UPDATE_SWITCH = '1' then
			DENOMINATOR_OUT <= "10000010";
		else
			DENOMINATOR_OUT <= "10000001";
		end if;
	else
		DENOMINATOR_OUT<=DENOMINATOR2;
	end if;
end process OUTPUT_DENOMINATOR;

OUTPUT_READY : process (CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		if RESET='1' then
			UPDATE <= '0';
		else
			UPDATE <=  ENABLE;
		end if;
	end if;
end process OUTPUT_READY;

end RTL;
