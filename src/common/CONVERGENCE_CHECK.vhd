-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: CONVERGENCE_CHECK.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity CONVERGENCE_CHECK is
    Port ( HIGH_MSB : in std_logic;
           LOW_MSB : in std_logic;
           HIGH_SECONDBIT : in std_logic;
           LOW_SECONDBIT : in std_logic;
           CHECK : in std_logic;
           TRIGGER_OUTPUT : out std_logic;
           TRIGGER_FOLLOW : out std_logic);
end CONVERGENCE_CHECK;

architecture RTL of CONVERGENCE_CHECK is
	signal MSB_AND :	std_logic;
	signal MSB_NOR :	std_logic;
	signal MSB_EQ : std_logic;
	signal MSB_XOR : std_logic;
	signal INV : std_logic;
	signal SECOND_BIT_01: std_logic;
	signal STRADDLE:	std_logic;
begin

	MSB_AND <= HIGH_MSB and LOW_MSB;
	MSB_NOR <= HIGH_MSB nor LOW_MSB;
	MSB_EQ <= MSB_AND or MSB_NOR;
	MSB_XOR <= not MSB_EQ;
	
	INV <= not HIGH_SECONDBIT;
	SECOND_BIT_01 <= INV and LOW_SECONDBIT;
	STRADDLE <= MSB_XOR and SECOND_BIT_01;

	TRIGGER_OUTPUT <= CHECK and MSB_EQ;
	TRIGGER_FOLLOW <= CHECK and STRADDLE;


end RTL;
