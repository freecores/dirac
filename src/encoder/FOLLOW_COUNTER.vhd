-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: FOLLOW_COUNTER.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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
	component COUNT_UNIT
	port(INCREMENT:	in std_logic;
	DECREMENT:	in std_logic;
	RESET : in std_logic;
	CLOCK:	in std_logic;
	OUTPUT: out std_logic;
	INCREMENT_CARRY: out std_logic;
	DECREMENT_CARRY: out std_logic);
	end component COUNT_UNIT;
	signal A,B,C,D,E,F,G,H:	std_logic;
	signal AB,CD,EF,GH:	std_logic;
	signal AD,EH:	std_logic;
	signal NONZERO:	std_logic;
	signal INC0,INC1,INC2,INC3,INC4,INC5,INC6,INC7: std_logic;
	signal DEC0,DEC1,DEC2,DEC3,DEC4,DEC5,DEC6,DEC7:	std_logic;
	signal DECREMENT:	std_logic;
begin

-- detect non-zero result

	AB <= A or B;
	CD <= C or D;
	EF <= E or F;
	GH <= G or H;

	AD <= AB or CD;
	EH <= EF or GH;

	NONZERO <= 	AD or EH;

-- Output

	OUTPUT <= DECREMENT;

-- Feedback

	DECREMENT <= TEST and NONZERO;

-- Sequential arithmetic

COUNT0:	COUNT_UNIT
	port map(INCREMENT => INCREMENT,
	DECREMENT => DECREMENT,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => A,
	INCREMENT_CARRY => INC0,
	DECREMENT_CARRY => DEC0);

COUNT1:	COUNT_UNIT
	port map(INCREMENT => INC0,
	DECREMENT => DEC0,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => B,
	INCREMENT_CARRY => INC1,
	DECREMENT_CARRY => DEC1);

COUNT2:	COUNT_UNIT
	port map(INCREMENT => INC1,
	DECREMENT => DEC1,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => C,
	INCREMENT_CARRY => INC2,
	DECREMENT_CARRY => DEC2);

COUNT3:	COUNT_UNIT
	port map(INCREMENT => INC2,
	DECREMENT => DEC2,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => D,
	INCREMENT_CARRY => INC3,
	DECREMENT_CARRY => DEC3);

COUNT4:	COUNT_UNIT
	port map(INCREMENT => INC3,
	DECREMENT => DEC3,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => E,
	INCREMENT_CARRY => INC4,
	DECREMENT_CARRY => DEC4);

COUNT5:	COUNT_UNIT
	port map(INCREMENT => INC4,
	DECREMENT => DEC4,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => F,
	INCREMENT_CARRY => INC5,
	DECREMENT_CARRY => DEC5);

COUNT6:	COUNT_UNIT
	port map(INCREMENT => INC5,
	DECREMENT => DEC5,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => G,
	INCREMENT_CARRY => INC6,
	DECREMENT_CARRY => DEC6);

COUNT7:	COUNT_UNIT
	port map(INCREMENT => INC6,
	DECREMENT => DEC6,
	RESET => RESET,
	CLOCK => CLOCK,
	OUTPUT => H,
	INCREMENT_CARRY => INC7,
	DECREMENT_CARRY => DEC7);


end RTL;
