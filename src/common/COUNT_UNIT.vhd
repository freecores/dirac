-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: COUNT_UNIT.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity COUNT_UNIT is
    Port ( INCREMENT : in std_logic;
           DECREMENT : in std_logic;
			  RESET :	in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic;
           INCREMENT_CARRY : out std_logic;
           DECREMENT_CARRY : out std_logic);
end COUNT_UNIT;

architecture RTL of COUNT_UNIT is
	 component D_TYPE
	 port(D,CLOCK:	in std_logic;
	 Q:	out std_logic);
	 end component D_TYPE;
	 signal UPDATE:	std_logic :='0';
	 signal TOGGLE:	std_logic;
	 signal Q_VAL:	std_logic;
	 signal INVERSE:	std_logic;
	 signal NEWVAL : std_logic;
begin

-- combinatorial logic

	TOGGLE <= INCREMENT xor DECREMENT;
	INVERSE <= not Q_VAL;
	OUTPUT <= Q_VAL;
	INCREMENT_CARRY <= INCREMENT and not DECREMENT and Q_VAL;
	DECREMENT_CARRY <= DECREMENT and not INCREMENT and INVERSE;
	NEWVAL <= Q_VAL xor TOGGLE;
	UPDATE <= NEWVAL and not RESET;

	



-- The D_TYPE

FLIP_FLOP: D_TYPE
	port map(D => UPDATE,
	CLOCK => CLOCK,
	Q => Q_VAL);

end RTL;
