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
	component D_TYPE
	port(D,CLOCK:	in std_logic;
	 Q:	out std_logic);
	end component D_TYPE;
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

FLIP_FLOP: D_TYPE
	port map(D => ACTIVE,
	CLOCK => CLOCK,
	Q => DELAYED);


end RTL;
