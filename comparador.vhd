library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparador is
	Generic (Nbit: INTEGER := 8;
				End_Of_Screen: INTEGER :=10;
				Start_Of_Pulse: INTEGER :=20;
				End_Of_Pulse: INTEGER :=30;
				End_Of_Line: INTEGER :=40);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (Nbit-1 downto 0);
			  
           O1 : out  STD_LOGIC;
           O2 : out  STD_LOGIC;
           O3 : out  STD_LOGIC);
end comparador;

architecture Behavioral of comparador is
signal O1_int,p_O1_int,O2_int,p_O2_int,O3_int,p_O3_int: STD_LOGIC;
signal aux: STD_LOGIC_VECTOR (Nbit-1 downto 0) := (others => '1');

begin
O1 <= O1_int;
O2 <= O2_int;
O3 <= O3_int;
aux <= (others => '1');
	sinc: process (clk,reset)
	begin
		if (reset = '1') then
			O1_int <= '0';
			O2_int <= '1';
			O3_int <= '0';
		elsif (rising_edge(clk)) then
			O1_int <= p_O1_int;
			O2_int <= p_O2_int;
			O3_int <= p_O3_int;
		end if;	
	end process;
	
	comb: process (data,aux)
	begin
		if(data=aux)then
			p_O1_int <= '0';
		elsif(unsigned(data)>(End_Of_Screen-1))then
			p_O1_int <= '1';
		else
			p_O1_int <= '0';
		end if;
		if(unsigned(data)>(Start_Of_Pulse-1) AND unsigned(data)<(End_Of_Pulse-1))then
			p_O2_int <= '0';
		else
			p_O2_int <= '1';
		end if;
		if(unsigned(data)=(End_Of_Line-1))then
			p_O3_int <= '1';
		else
			p_O3_int <= '0';
		end if;
	end process;
end Behavioral;