library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_driver is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGB_in : in  STD_LOGIC_VECTOR (7 downto 0);
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RGB_out : out  STD_LOGIC_VECTOR (7 downto 0);
			  eje_x : out  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : out  STD_LOGIC_VECTOR (9 downto 0);
			  refresh : out STD_LOGIC);
end VGA_driver;

architecture Behavioral of VGA_driver is
component Freq_Pixe is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk_pixel : out  STD_LOGIC);
end component;
component contador is
	Generic (Nbit: INTEGER := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end component;
component comparador is
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
end component;
component Gen_color is
    Port ( blank_h : in  STD_LOGIC;
           blank_v : in  STD_LOGIC;
           RGB_in : in  STD_LOGIC_VECTOR (7 downto 0);
           RGB_out : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

signal en_x,en_y,rs_x,rs_y,s_blank_h,s_blank_v: STD_LOGIC;
signal s_eje_x,s_eje_y: STD_LOGIC_VECTOR (9 downto 0);

begin
eje_x <= s_eje_x;
eje_y <= s_eje_y;
refresh <= rs_y;

Freq_Pixe_1: Freq_Pixe
port map(	clk => clk,
				reset => reset,
				clk_pixel => en_x);
conth: contador
generic map(Nbit => 10)
port map(	clk => clk,
				reset => reset,
				enable => en_x,
				resets => rs_x,
				Q => s_eje_x);
contv: contador
generic map(Nbit => 10)
port map(	clk => clk,
				reset => reset,
				enable => en_y,
				resets => rs_y,
				Q => s_eje_y);
comph: comparador
generic map(Nbit => 10,
				End_Of_Screen => 639,
				Start_Of_Pulse => 655,
				End_Of_Pulse => 751,
				End_Of_Line => 799)
port map(	clk => clk,
				reset => reset,
				data => s_eje_x,
				O1 => s_blank_h,
				O2 => HS,
				O3 => rs_x);
compv: comparador
generic map(Nbit => 10,
				End_Of_Screen => 479,
				Start_Of_Pulse => 489,
				End_Of_Pulse => 491,
				End_Of_Line => 520)
port map(	clk => clk,
				reset => reset,
				data => s_eje_y,
				O1 => s_blank_v,
				O2 => VS,
				O3 => rs_y);
gen_color_1: Gen_color
port map(	blank_h => s_blank_h,
				blank_v => s_blank_v,
				RGB_in => RGB_in,
				RGB_out => RGB_out);

en_y <= rs_x AND en_x;
end Behavioral;