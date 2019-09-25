library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
    Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  refresh : in STD_LOGIC;
           RED_m : in  STD_LOGIC_VECTOR (2 downto 0);
           GRN_m : in  STD_LOGIC_VECTOR (2 downto 0);
           BLUE_m : in  STD_LOGIC_VECTOR (1 downto 0);
			  RED_b : in  STD_LOGIC_VECTOR (2 downto 0);
           GRN_b : in  STD_LOGIC_VECTOR (2 downto 0);
           BLUE_b : in  STD_LOGIC_VECTOR (1 downto 0);
			  RED_s : in  STD_LOGIC_VECTOR (2 downto 0);
           GRN_s : in  STD_LOGIC_VECTOR (2 downto 0);
           BLUE_s : in  STD_LOGIC_VECTOR (1 downto 0);
			  RED : out  STD_LOGIC_VECTOR (2 downto 0);
           GRN : out  STD_LOGIC_VECTOR (2 downto 0);
           BLUE : out  STD_LOGIC_VECTOR (1 downto 0);
			  sobreplatM : out STD_LOGIC;
			  sobreplatB : out STD_LOGIC);
end control;

architecture Behavioral of control is
signal sobreplatMint, p_sobreplatMint, sobreplatBint, p_sobreplatBint : STD_LOGIC;
signal p_RED,p_GRN : STD_LOGIC_VECTOR (2 downto 0);
signal p_BLUE : STD_LOGIC_VECTOR (1 downto 0);
signal aux,p_aux, auxb,p_auxb: STD_LOGIC;

begin
sobreplatM <= sobreplatMint;

	sinc: process(clk,reset)
	begin
		if(reset='1')then
			sobreplatMint <= '0';
			sobreplatBint <= '0';
			RED <= "000";
			GRN <= "000";
			BLUE <= "00";
			aux <= '0';
		elsif(rising_edge(clk))then
			sobreplatMint <= p_sobreplatMint;
			sobreplatBint <= p_sobreplatBint;
			RED <= p_RED;
			GRN <= p_GRN;
			BLUE <= p_BLUE;
			aux <= p_aux;
		end if;
	end process;

--MARIOS

	comb_sobreplataforma: process(RED_m,GRN_m,BLUE_m,RED_s,GRN_s,BLUE_s,sobreplatMint,refresh,aux)
	begin
		p_sobreplatMint <= sobreplatMint;
		p_aux <= aux;
		if(((RED_m = "111") and (GRN_m = "111") and (BLUE_m = "11") and (RED_s = "110") and (GRN_s = "010") and (BLUE_s = "01"))or
			((RED_m = "111") and (GRN_m = "111") and (BLUE_m = "11") and (RED_s = "111") and (GRN_s = "010") and (BLUE_s = "01")))then
			p_sobreplatMint <= '1';
			p_aux <= '1';
		elsif(((RED_m = "111") and (GRN_m = "111") and (BLUE_m = "11") and (RED_s = "000") and (GRN_s = "000") and (BLUE_s = "00")) and (aux='0'))then
			p_sobreplatMint <= '0';
		end if;
		if(refresh='1')then
			p_aux <= '0';
		end if;
	end process;
	
	comb_rgb_or: process(RED_m,GRN_m,BLUE_m,RED_s,GRN_s,BLUE_s)
	begin
		p_RED <= (RED_m or RED_s);
		p_GRN <= (GRN_m or GRN_s);
		p_BLUE <= (BLUE_m or BLUE_s);
	end process;

--BARRILES
	
comb_sobreplataformaB: process(RED_m,GRN_m,BLUE_m,RED_s,GRN_s,BLUE_s,sobreplatMint,refresh,aux)
	begin
		p_sobreplatBint <= sobreplatBint;
		p_auxb <= auxb;
		if(((RED_b = "100") and (GRN_b = "010") and (BLUE_b = "00") and (RED_s = "110") and (GRN_s = "010") and (BLUE_s = "01"))or
			((RED_b = "100") and (GRN_b = "010") and (BLUE_b = "00") and (RED_s = "111") and (GRN_s = "010") and (BLUE_s = "01")))then
			p_sobreplatBint <= '1';
			p_auxb <= '1';
		elsif(((RED_b = "100") and (GRN_b = "010") and (BLUE_b = "00") and (RED_s = "110") and (GRN_s = "010") and (BLUE_s = "01"))or
			((RED_b = "100") and (GRN_b = "010") and (BLUE_b = "00") and (RED_s = "111") and (GRN_s = "010") and (BLUE_s = "01")))then
			p_sobreplatBint <= '1';
			p_auxb <= '1';
		elsif(((RED_b = "100") and (GRN_b = "010") and (BLUE_b = "00") and (RED_s = "000") and (GRN_s = "000") and (BLUE_s = "00")) and (auxb='0'))then
			p_sobreplatBint <= '0';
		end if;
		if(refresh='1')then
			p_auxb <= '0';
		end if;
	end process;
	
comb_rgb_orB: process(RED_b,GRN_b,BLUE_b,RED_s,GRN_s,BLUE_s)
	begin
		p_RED <= (RED_b or RED_s);
		p_GRN <= (GRN_b or GRN_s);
		p_BLUE <= (BLUE_b or BLUE_s);
	end process;
end Behavioral;