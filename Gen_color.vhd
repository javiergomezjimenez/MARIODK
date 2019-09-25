library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Gen_color is
    Port ( blank_h : in  STD_LOGIC;
           blank_v : in  STD_LOGIC;
           RGB_in : in  STD_LOGIC_VECTOR (7 downto 0);
           RGB_out : out  STD_LOGIC_VECTOR (7 downto 0));
end Gen_color;

architecture Behavioral of Gen_color is

begin
gen_color: process(blank_h, blank_v, RGB_in)
begin
	if (blank_h = '1' or blank_v = '1') then
		RGB_out <= (others => '0');
	else
		RGB_out <= RGB_in;
	end if;
end process;
end Behavioral;