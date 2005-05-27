 -- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: OUTPUT_UNIT.vhd,v 1.2 2005-05-27 16:00:30 petebleackley Exp $ $Name: not supported by cvs2svn $
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

 entity OUTPUT_UNIT is
    Port ( ENABLE : in std_logic;
           DATA : in std_logic;
           FOLLOW : in std_logic;
			  RESET :	in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
			  DATA_OUT : out std_logic;
           FOLLOW_COUNTER_TEST : out std_logic;
           SHIFT : out std_logic);
end OUTPUT_UNIT;

architecture RTL of OUTPUT_UNIT is
	signal OUTVALUE:	std_logic;
	signal DELAYED:	std_logic;
	signal NOFOLLOW:	std_logic;
	signal ACTIVE:	std_logic;
	signal FEEDBACK : std_logic;
begin

-- combinatorial logic

	ACTIVE <= ENABLE and not (FEEDBACK or RESET);
	OUTVALUE <= DATA xor FOLLOW;
	NOFOLLOW <= not FOLLOW;
	DATA_OUT <= ACTIVE and OUTVALUE;
	FOLLOW_COUNTER_TEST <= DELAYED;
	FEEDBACK <= DELAYED and NOFOLLOW;
	SHIFT <= FEEDBACK;
	SENDING <= ACTIVE;

-- sequential logic

FLIP_FLOP: process (CLOCK)
	begin
	if CLOCK'event and CLOCK = '1' then
		DELAYED <= ACTIVE;
	end if;
	end process FLIP_FLOP;

end RTL;
