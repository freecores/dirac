-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: FOLLOW_COUNTER.vhd,v 1.2 2005-05-27 16:00:30 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity FOLLOW_COUNTER is
    Port ( INCREMENT : in std_logic;
           TEST : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic);
end FOLLOW_COUNTER;

architecture RTL of FOLLOW_COUNTER is
	signal NUMBER : std_logic_vector(7 downto 0);
begin
	COUNT : process (CLOCK)
	begin
		if CLOCK'event and CLOCK = '1' then
			if RESET = '1' then
				NUMBER <= "00000000";
			elsif INCREMENT = '1' then
				NUMBER <= NUMBER + "00000001";
			elsif TEST = '1' then
				if NUMBER > "00000000" then
					NUMBER <= NUMBER - "00000001";
				end if;
			end if;
		end if;
	end process COUNT;

	GET_OUTPUT :	process (TEST,NUMBER)
	begin
	if TEST = '1' and NUMBER > "00000000" then
		OUTPUT <= '1';
	else
		OUTPUT <= '0';
	end if;
	end process GET_OUTPUT;


end RTL;


