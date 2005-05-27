-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: LIMIT_REGISTER.vhd,v 1.2 2005-05-27 16:00:30 petebleackley Exp $ $Name: not supported by cvs2svn $
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

 entity LIMIT_REGISTER is
	generic(CONST : std_logic := '1');
    Port ( LOAD : in std_logic_vector(15 downto 0);
           SET_VALUE : in std_logic;
           SHIFT_ALL : in std_logic;
           SHIFT_MOST : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic_vector(15 downto 0));
end entity LIMIT_REGISTER;

architecture RTL of LIMIT_REGISTER is
	signal SHIFT_LSBS: std_logic;
	signal SET_RESET: std_logic;
	signal ENABLE_MSB: std_logic;
	signal ENABLE_LSBS: std_logic;
	signal D :	std_logic_vector (15 downto 0);
	signal Q :	std_logic_vector (15 downto 0);
begin

-- control logic
	SET_RESET <= SET_VALUE or RESET;
	ENABLE_MSB <= SET_RESET or SHIFT_ALL;
	SHIFT_LSBS <= SHIFT_ALL or SHIFT_MOST;
	ENABLE_LSBS <= SET_RESET or SHIFT_LSBS;

-- outputs
	
	OUTPUT <= Q;


-- initialisation

INIT:	process(RESET,LOAD)
begin
	if RESET = '1' then
	D <= (others => CONST);
	else
	D <= LOAD;
	end if;
end process INIT;

-- storage

STORAGE : process (CLOCK)
	begin
		if CLOCK'event and CLOCK = '1' then
			if ENABLE_LSBS = '1' then
				if	SHIFT_LSBS = '1' then
					Q(14 downto 0) <= Q(13 downto 0) & CONST;
				else
					Q(14 downto 0) <= D(14 downto 0);
				end if;
			end if;
			if ENABLE_MSB = '1' then
				if SHIFT_ALL = '1' then
					Q(15) <= Q(14);
				else
					Q(15) <= D(15);
				end if;
			end if;
		end if;
	end process STORAGE;



end architecture RTL;

