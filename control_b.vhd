library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_b is
    Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  refresh : in STD_LOGIC;          
			  RGB_bh : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_bs : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_inh : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_ins : in  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_outh : out  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_outs : out  STD_LOGIC_VECTOR (7 downto 0);
			  sobreplatB : out STD_LOGIC;
			  izquierda: out STD_LOGIC;
			  derecha: out STD_LOGIC;
			  muerte: out STD_LOGIC);

end control_b;

architecture Behavioral of control_b is
signal sobreplatBint, p_sobreplatBint : STD_LOGIC;
signal p_RGB_outh : STD_LOGIC_VECTOR (7 downto 0);
signal p_RGB_outs : STD_LOGIC_VECTOR (7 downto 0);
signal aux_b,p_aux_b,aux_muerte,p_aux_muerte, muerte_int, p_muerte_int, derecha_int, p_derecha_int, izquierda_int, p_izquierda_int: STD_LOGIC;

begin

sobreplatB <= sobreplatBint;
muerte <= muerte_int;
derecha <= derecha_int;
izquierda <= izquierda_int;

	sinc: process(clk,reset)
	begin
		if(reset='1')then			
			sobreplatBint <= '0';
			RGB_outh <= "00000000";
			RGB_outs <= "00000000";
			aux_b <= '0';
			aux_muerte <= '0';
			muerte_int <= '0';
			derecha_int <= '1';
			izquierda_int <= '0';
			
		elsif(rising_edge(clk))then			
			sobreplatBint <= p_sobreplatBint;
			RGB_outh <= p_RGB_outh;
			RGB_outs <= p_RGB_outs;
			aux_b <= p_aux_b;
			aux_muerte <= p_aux_muerte;
			muerte_int <= p_muerte_int;
			izquierda_int <= p_izquierda_int;
			derecha_int <= p_derecha_int;
		
		end if;
	end process;


	

--BARRILES
	
comb_sobreplataformaB: process(RGB_bh,RGB_inh,sobreplatBint,refresh,aux_b,aux_muerte,derecha_int,muerte_int,izquierda_int)
	begin
		p_sobreplatBint <= sobreplatBint;
		p_aux_b <= aux_b;
		p_aux_muerte <= aux_muerte;
		p_muerte_int <= muerte_int;
		p_derecha_int <= derecha_int;
		p_izquierda_int <= izquierda_int;
		
		--muerte de mario (detectamos el rojo con el marron)
		if(RGB_bh = "10001000" and RGB_inh = "11100000")then
			
			p_muerte_int <= '1'; -- controla la muerte si rojo se mezcla con marron
			p_aux_muerte <= '1';
			
		elsif(aux_muerte='0')then
			p_muerte_int <= '0';		
		end if;	
		
		--detectamos las plataformas y decidimos izq o derecha
		if(RGB_bh = "11111111" and RGB_inh = "11101001")then
			p_sobreplatBint <= '1';
			p_aux_b <= '1';
			p_derecha_int <= '1';   -- plataforma roja/ barril derecha
			p_izquierda_int <= '0';
			
		elsif (RGB_bh = "11111111" and RGB_inh = "11001001")then
			p_sobreplatBint <= '1';
			p_aux_b <= '1';
			p_izquierda_int <= '1'; -- plataforma roja/ barril izquierda
			p_derecha_int <= '0';
			
		elsif((RGB_bh = "11111111" and RGB_inh = "00000000") and aux_b='0')then
			p_sobreplatBint <= '0'; -- en el aire
			--mantenemos izq o derecha mientras caemos para simular la inercia y para movernos siempre y no cada dos refreshs
			
		elsif(RGB_bh = "11111111" and aux_b='0')then-- cuando es cian(escaleras), rojo(mario), blanco(pixels de control de mario)
		
			p_sobreplatBint <= '0'; --cero porque si detecta alguno de estos colores es que no esta justo sobre la plataforma, 
											--y en caso de que no estorbaran estos colores, estarian detectando negro ambos, y tocaria bajar
		end if;
		
		---------------------------------------------------------------------------------------------------------------------------
		if(refresh='1')then
			p_aux_b <= '0';
			p_aux_muerte <= '0';
		end if;

		
	end process;
	
comb_rgb_orB: process(RGB_bh,RGB_inh,RGB_bs,RGB_ins)
	begin
		p_RGB_outh <= (RGB_bh or RGB_inh);
		p_RGB_outs <= (RGB_bs or RGB_ins);
	end process;
end Behavioral;