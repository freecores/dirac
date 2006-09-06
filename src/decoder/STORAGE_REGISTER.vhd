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

	signal Q:	std_logic_vector(15 downto 0);
begin


-- outputs
	
	OUTPUT <= Q;

-- storage

	STORE: process (CLOCK)
	begin
		if CLOCK'event and CLOCK = '1' then
			if RESET = '1' then
				Q <= (others => '0');
			elsif SET_VALUE = '1' then
				Q <= LOAD;
			elsif SHIFT_ALL = '1' then
				Q <= Q(14 downto 0) & SHIFT_IN;
			elsif SHIFT_MOST = '1' then
				Q <= Q(15) & Q(13 downto 0) & SHIFT_IN;
			end if;
		end if;
	end process STORE;


end architecture RTL;

