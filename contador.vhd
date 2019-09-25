library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity contador is
	Generic (Nbit: INTEGER := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end contador;

architecture Behavioral of contador is
signal Q_int,p_Q_int: UNSIGNED (Nbit-1 downto 0);

begin
	Q <= STD_LOGIC_VECTOR (Q_int);

	sinc: process (clk,reset)
	begin
		if (reset = '1') then
			Q_int <= (others => '0');
		elsif (rising_edge(clk)) then
			Q_int <= p_Q_int;
		end if;
	end process;
		
	comb: process (enable,resets,Q_int)
	begin
		if (resets = '1') then
			p_Q_int <= (others => '0');
		elsif (enable = '1') then
			p_Q_int <= Q_int + 1;
		else 
			p_Q_int <= Q_int;
		end if;
	end process;
end Behavioral;