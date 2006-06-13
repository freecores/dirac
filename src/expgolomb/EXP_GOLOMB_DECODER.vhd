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

entity EXP_GOLOMB_DECODER is
    Port ( ENABLE : in std_logic;
           DATA_IN : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           READY : out std_logic;
           DATA_OUT : out std_logic_vector(31 downto 0));
end EXP_GOLOMB_DECODER;

architecture RTL of EXP_GOLOMB_DECODER is
	signal DATA_1 : std_logic_vector(31 downto 0);
	signal DATA_2 : std_logic_vector(31 downto 0);
	signal SUM : std_logic_vector(31 downto 0);
	signal NUMBITS_1 : std_logic_vector(4 downto 0);
	signal NUMBITS_2 : std_logic_vector(4 downto 0);
	signal MODE : std_logic;
	signal CALC_COMPLETE : std_logic;
begin

READ_DATA : process (CLOCK)
begin
	if CLOCK'event and CLOCK = '1' then		--WHEN CLOCK EDGE DETECTED
		if RESET = '1' then		--SET ALL REGISTERS TO ZERO
			DATA_1 <= (others => '0');
			DATA_2 <= (others => '0');
			NUMBITS_1 <= (others => '0');
			NUMBITS_2 <= (others => '0');
			DATA_OUT <= (others => '0');
			MODE <= '0';
			CALC_COMPLETE <= '0';
		elsif CALC_COMPLETE = '1' then
		  	DATA_1 <= (others => '0');
			DATA_2 <= (others => '0');
			NUMBITS_1 <= (others => '0');
			NUMBITS_2 <= (others => '0');
			MODE <= '0';
			CALC_COMPLETE <= '0';
		elsif (NUMBITS_2 = NUMBITS_1) and (MODE = '1') then --IF CALCULATION IS COMPLETE 
			DATA_OUT <= SUM;
			CALC_COMPLETE <= '1';
		elsif ENABLE = '1' then		--IF DATA IS BEING INPUT
			if MODE = '1' then		 --READ INPUT DATA INTO REGISTER DATA_2, AND COUNT THE NUMBER OF BITS READ IN
				DATA_2 <= DATA_2 (30 downto 0) & DATA_IN;
				NUMBITS_2 <= NUMBITS_2 + "00001";
			elsif DATA_IN = '1' then	 --DETECT END OF EXPONENT, SWITCH TO MODE 1, FOR READING DATA
				MODE <= '1';
			else			  --IN MODE 0 (FOR READING EXPONENT)
				DATA_1 <= DATA_1 (30 downto 0) & '1';
				NUMBITS_1 <= NUMBITS_1 + "00001";
			end if;
		end if;
end if;
end process READ_DATA;

SUM <= DATA_1 + DATA_2;
READY <= CALC_COMPLETE;

end RTL;
