-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: STORAGE_REGISTER.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity STORAGE_REGISTER is
    Port ( LOAD : in std_logic_vector(15 downto 0);
	 		  SHIFT_IN : in std_logic; 
           SET_VALUE : in std_logic;
           SHIFT_ALL : in std_logic;
           SHIFT_MOST : in std_logic;
			  RESET : in std_logic;
           CLOCK : in std_logic;
           OUTPUT : out std_logic_vector(15 downto 0));
end entity STORAGE_REGISTER;

architecture RTL of STORAGE_REGISTER is
	component STORE_BLOCK
	port(LOAD_IN, SHIFT_IN, SHIFT, ENABLE, CLK:	in std_logic;
	OUTPUT:	out std_logic);
	end component STORE_BLOCK;
	signal SHIFT_LSBS: std_logic;
	signal SET_RESET: std_logic;
	signal ENABLE_MSB: std_logic;
	signal ENABLE_LSBS: std_logic;
	signal D0,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15:	std_logic;
	signal Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15:	std_logic;
begin

-- control logic
	SET_RESET <= SET_VALUE or RESET;
	ENABLE_MSB <= SET_RESET or SHIFT_ALL;
	SHIFT_LSBS <= SHIFT_ALL or SHIFT_MOST;
	ENABLE_LSBS <= SET_RESET or SHIFT_LSBS;

-- outputs
	
	OUTPUT(0) <= Q0;
	OUTPUT(1) <= Q1;
	OUTPUT(2) <= Q2;
	OUTPUT(3) <= Q3;
	OUTPUT(4) <= Q4;
	OUTPUT(5) <= Q5;
	OUTPUT(6) <= Q6;
	OUTPUT(7) <= Q7;
	OUTPUT(8) <= Q8;
	OUTPUT(9) <= Q9;
	OUTPUT(10) <= Q10;
	OUTPUT(11) <= Q11;
	OUTPUT(12) <= Q12;
	OUTPUT(13) <= Q13;
	OUTPUT(14) <= Q14;
	OUTPUT(15) <= Q15;

-- initialisation

INIT:	process(RESET,LOAD)
begin
	if RESET = '1' then
	D0 <= '0';
	D1 <= '0';
	D2 <= '0';
	D3 <= '0';
	D4 <= '0';
	D5 <= '0';
	D6 <= '0';
	D7 <= '0';
	D8 <= '0';
	D9 <= '0';
	D10 <= '0';
	D11 <= '0';
	D12 <= '0';
	D13 <= '0';
	D14 <= '0';
	D15 <= '0';
	else
	D0 <= LOAD(0);
	D1 <= LOAD(1);
	D2 <= LOAD(2);
	D3 <= LOAD(3);
	D4 <= LOAD(4);
	D5 <= LOAD(5);
	D6 <= LOAD(6);
	D7 <= LOAD(7);
	D8 <= LOAD(8);
	D9 <= LOAD(9);
	D10 <= LOAD(10);
	D11 <= LOAD(11);
	D12 <= LOAD(12);
	D13 <= LOAD(13);
	D14 <= LOAD(14);
	D15 <= LOAD(15);
	end if;
end process INIT;

-- storage

	STORE0: STORE_BLOCK
	port map(LOAD_IN => D0,
				SHIFT_IN => SHIFT_IN,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q0);

	STORE1: STORE_BLOCK
	port map(LOAD_IN => D1,
				SHIFT_IN => Q0,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q1);

	STORE2: STORE_BLOCK
	port map(LOAD_IN => D2,
				SHIFT_IN => Q1,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q2);

	STORE3: STORE_BLOCK
	port map(LOAD_IN => D3,
				SHIFT_IN => Q2,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q3);

	STORE4: STORE_BLOCK
	port map(LOAD_IN => D4,
				SHIFT_IN => Q3,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q4);

	STORE5: STORE_BLOCK
	port map(LOAD_IN => D5,
				SHIFT_IN => Q4,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q5);

	STORE6: STORE_BLOCK
	port map(LOAD_IN => D6,
				SHIFT_IN => Q5,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q6);

  	STORE7: STORE_BLOCK
	port map(LOAD_IN => D7,
				SHIFT_IN => Q6,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q7);

 	STORE8: STORE_BLOCK
	port map(LOAD_IN => D8,
				SHIFT_IN => Q7,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q8);

	STORE9: STORE_BLOCK
	port map(LOAD_IN => D9,
				SHIFT_IN => Q8,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q9);

	STORE10: STORE_BLOCK
	port map(LOAD_IN => D10,
				SHIFT_IN => Q9,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q10);

 	STORE11: STORE_BLOCK
	port map(LOAD_IN => D11,
				SHIFT_IN => Q10,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q11);

  	STORE12: STORE_BLOCK
	port map(LOAD_IN => D12,
				SHIFT_IN => Q11,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q12);

	STORE13: STORE_BLOCK
	port map(LOAD_IN => D13,
				SHIFT_IN => Q12,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q13);

	STORE14: STORE_BLOCK
	port map(LOAD_IN => D14,
				SHIFT_IN => Q13,
				SHIFT => SHIFT_LSBS,
				ENABLE => ENABLE_LSBS,
				CLK => CLOCK,
				OUTPUT => Q14);

	STORE15: STORE_BLOCK
	port map(LOAD_IN => D15,
				SHIFT_IN => Q14,
				SHIFT => SHIFT_ALL,
				ENABLE => ENABLE_MSB,
				CLK => CLOCK,
				OUTPUT => Q15);



end architecture RTL;

