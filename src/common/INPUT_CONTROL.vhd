-- ***** BEGIN LICENSE BLOCK *****
-- 
-- $Id: INPUT_CONTROL.vhd,v 1.1.1.1 2005-03-30 10:09:49 petebleackley Exp $ $Name: not supported by cvs2svn $
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

entity INPUT_CONTROL is
    Port ( ENABLE : in std_logic;
           DATA_IN : in std_logic;
           BUFFER_CONTROL : in std_logic;
           DEMAND : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           SENDING : out std_logic;
           DATA_OUT : out std_logic);
end INPUT_CONTROL;

architecture RTL of INPUT_CONTROL is
		component FIFO
		port(		 WRITE_ENABLE : in std_logic;
           DATA_IN : in std_logic;
           READ_ENABLE : in std_logic;
           RESET : in std_logic;
           CLOCK : in std_logic;
           DATA_OUT : out std_logic;
			  EMPTY : out std_logic);
		end component FIFO;
		signal FIFO_WRITE_ENABLE :	std_logic;
		signal FIFO_READ_ENABLE :	std_logic;
		signal FIFO_DATA_IN : std_logic;
		signal FIFO_DATA_OUT : std_logic;
		signal FIFO_EMPTY : std_logic;
		signal USE_BUFFER : std_logic;
		signal PUT_IN_BUFFER :	std_logic;
begin

STORAGE :	FIFO
			port map(WRITE_ENABLE => FIFO_WRITE_ENABLE,
			DATA_IN => FIFO_DATA_IN,
			READ_ENABLE => FIFO_READ_ENABLE,
			RESET => RESET,
			CLOCK => CLOCK,
			DATA_OUT => FIFO_DATA_OUT,
			EMPTY => FIFO_EMPTY);

	FIFO_WRITE_ENABLE <= ENABLE and USE_BUFFER;
	FIFO_DATA_IN <= DATA_IN and USE_BUFFER;
	FIFO_READ_ENABLE <= DEMAND	and USE_BUFFER;

	PUT_IN_BUFFER <= ENABLE and BUFFER_CONTROL;
	USE_BUFFER <= PUT_IN_BUFFER or not FIFO_EMPTY;

OUTPUT_SELECT:	process(USE_BUFFER,DEMAND,FIFO_DATA_OUT,ENABLE,DATA_IN)
begin
	if USE_BUFFER = '1' then
	SENDING <= DEMAND;
	DATA_OUT <= FIFO_DATA_OUT;
	else
	SENDING <= ENABLE;
	DATA_OUT <= DATA_IN;
	end if;
end process OUTPUT_SELECT;


end RTL;
