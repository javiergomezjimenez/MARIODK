library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_m is
    Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  refresh : in STD_LOGIC;
           RGB_mh : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_ms : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_sh : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_ss : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_outh : out  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_outs : out  STD_LOGIC_VECTOR (7 downto 0);
			  sobreplatM : out STD_LOGIC;
			  escalera : out STD_LOGIC);
end control_m;

architecture Behavioral of control_m is
	signal sobreplatMint, p_sobreplatMint, escaleraint, p_escaleraint : STD_LOGIC;
	signal p_RGB_outh : STD_LOGIC_VECTOR (7 downto 0);
	signal p_RGB_outs : STD_LOGIC_VECTOR (7 downto 0);
	signal aux_p,aux_e,p_aux_p,p_aux_e : STD_LOGIC;

	begin
	sobreplatM <= sobreplatMint;
	escalera <= escaleraint;

		sinc: process(clk,reset)
		begin
			if(reset='1')then
				sobreplatMint <= '0';
				escaleraint <= '0';
				RGB_outh <= "00000000";
				RGB_outs <= "00000000";
				aux_p <= '0';
				aux_e <= '0';
			elsif(rising_edge(clk))then
				sobreplatMint <= p_sobreplatMint;
				escaleraint <= p_escaleraint;
				RGB_outh <= p_RGB_outh;
				RGB_outs <= p_RGB_outs;
				aux_p <= p_aux_p;
				aux_e <= p_aux_e;
			end if;
		end process;

		comb_sobreplataforma: process(RGB_mh,RGB_sh,sobreplatMint,escaleraint,refresh,aux_p,aux_e)
		begin
			--calculamos si mario esta sobre plataforma o no
			p_sobreplatMint <= sobreplatMint;
			p_aux_p <= aux_p;
			if((RGB_mh = "11111111" and RGB_sh = "11001001")or(RGB_mh = "11111111" and RGB_sh = "11101001"))then
				p_sobreplatMint <= '1';
				p_aux_p <= '1';
			elsif((RGB_mh = "11111111" and RGB_sh = "00000000") and aux_p='0')then
				p_sobreplatMint <= '0';
			end if;
			
			--calculamos si mario esta en una esclera o no
			p_escaleraint <= escaleraint;
			p_aux_e <= aux_e;
			if(RGB_mh = "11100000" and RGB_sh = "00011111")then
				p_escaleraint <= '1';
				p_aux_e <= '1';
			elsif((RGB_mh = "11100000" and RGB_sh = "00000000") and aux_e='0')then
				p_escaleraint <= '0';
			end if;
			
			--nuevo fotograma, reseteamos los auxiliares
			if(refresh='1')then
				p_aux_p <= '0';
				p_aux_e <= '0';
			end if;
		end process;
		
		--juntamos la stage y el mario para conseguir el rgb de salida, uno para la hit box y otro para los sprites
		comb_rgb_h_or: process(RGB_mh,RGB_sh)
		begin
			p_RGB_outh <= (RGB_mh or RGB_sh);
		end process;
		comb_rgb_s_or: process(RGB_ms,RGB_ss)
		begin
			p_RGB_outs <= (RGB_ms or RGB_ss);
		end process;
	end Behavioral;