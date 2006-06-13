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

entity EXP_GOLOMB_COUNTER is
    Port ( DATA_IN : in std_logic_vector(31 downto 0);
           TEST : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           COUNTING : out std_logic;
           DATA_OUT : out std_logic);
end EXP_GOLOMB_COUNTER;

architecture RTL of EXP_GOLOMB_COUNTER is
signal DATA2 : std_logic_vector (32 downto 0);
signal LOG : std_logic_vector (5 downto 0);
signal OUT_ADDRESS : std_logic_vector( 5 downto 0); 
signal UPDOWN : std_logic;
signal OUTPUT_ACTIVE : std_logic;
begin

DATA2 <= ('0' & DATA_IN) + "000000000000000000000000000000001";

LOGARITHM : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
		if DATA2(32) = '1' then
			LOG <= "100000";
		elsif DATA2(31) = '1' then
			LOG <= "011111";
		elsif DATA2(30) = '1' then
			LOG <= "011110";
		elsif DATA2(29) = '1' then
			LOG <= "011101";
		elsif DATA2(28) = '1' then
			LOG <= "011100";
		elsif DATA2(27) = '1' then
			LOG <= "011011";
		elsif DATA2(26) = '1' then
			LOG <= "011010";
		elsif DATA2(25) = '1' then
			LOG <= "011001";
		elsif DATA2(24) = '1' then
			LOG <= "011000";
		elsif DATA2(23) = '1' then
			LOG <= "010111";
		elsif DATA2(22) = '1' then
			LOG <= "010110";
		elsif DATA2(21) = '1' then
			LOG <= "010101";
		elsif DATA2(20) = '1' then
			LOG <= "010100";
		elsif DATA2(19) = '1' then
			LOG <= "010011";
		elsif DATA2(18) = '1' then
			LOG <= "010010";
		elsif DATA2(17) = '1' then
			LOG <= "010001";
		elsif DATA2(16) = '1' then
			LOG <= "010000";
		elsif DATA2(15) = '1' then
			LOG <= "001111";
		elsif DATA2(14) = '1' then
			LOG <= "001110";
		elsif DATA2(13) = '1' then
			LOG <= "001101";
		elsif DATA2(12) = '1' then
			LOG <= "001100";
		elsif DATA2(11) = '1' then
			LOG <= "001011";
		elsif DATA2(10) = '1' then
			LOG <= "001010";
		elsif DATA2(9) = '1' then
			LOG <= "001001";
		elsif DATA2(8) = '1' then
			LOG <= "001000";
		elsif DATA2(7) = '1' then
			LOG <= "000111";
		elsif DATA2(6) = '1' then
			LOG <= "000110";
		elsif DATA2(5) = '1' then
			LOG <= "000101";
		elsif DATA2(4) = '1' then
			LOG <= "000100";
		elsif DATA2(3) = '1' then
			LOG <= "000011";
		elsif DATA2(2) = '1' then
			LOG <= "000010";
		elsif DATA2(1) = '1' then
			LOG <= "000001";
		else
			LOG <= "000000";
		end if;
	end if;
end process LOGARITHM;


MODE : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			OUTPUT_ACTIVE <= '0';
		elsif TEST = '1' then
			OUTPUT_ACTIVE <= '1';
		elsif OUT_ADDRESS = "000000" then
			OUTPUT_ACTIVE <= '0';
		end if;
	end if;
end process MODE;


OUTPUT: process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then
		if RESET = '1' then
			UPDOWN <= '0';
			OUT_ADDRESS <= "000000";
			DATA_OUT <= '0';
		elsif OUTPUT_ACTIVE = '1' then
			if UPDOWN = '0' then
				if OUT_ADDRESS = LOG then
					DATA_OUT <= '1';
					UPDOWN <= '1';
				else
					DATA_OUT <= '0';
					OUT_ADDRESS <= OUT_ADDRESS + "000001";
				end if;
			else
				OUT_ADDRESS <= OUT_ADDRESS - "000001";
				DATA_OUT	<= DATA2(conv_integer(OUT_ADDRESS));
			end if;
		end if;
	end if;
end process OUTPUT;

COUNTING <= OUTPUT_ACTIVE;				 
			

end RTL;
