library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Freq_Pixe is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk_pixel : out  STD_LOGIC);
end Freq_Pixe;

architecture Behavioral of Freq_Pixe is
signal clk_pixel_int,p_clk_pixel: STD_LOGIC;

begin
	clk_pixel <= clk_pixel_int;
	p_clk_pixel <= not clk_pixel_int;

	div_frec:process(clk,reset)	
	begin
		if (reset='1') then			
			clk_pixel_int<='0';		
		elsif (rising_edge(clk)) then			
			clk_pixel_int<= p_clk_pixel;		
		end if;
	end process;
end Behavioral;