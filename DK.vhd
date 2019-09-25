library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DK is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           LB : in  STD_LOGIC;
           RB : in  STD_LOGIC;
           UB : in  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (7 downto 0);
			  sw0 : in STD_LOGIC;
			  sw1 : in STD_LOGIC);
end DK;

architecture Behavioral of DK is
component VGA_driver is
	Port (  clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGB_in : in  STD_LOGIC_VECTOR (7 downto 0);
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RGB_out : out  STD_LOGIC_VECTOR (7 downto 0);
			  eje_x : out  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : out  STD_LOGIC_VECTOR (9 downto 0);
			  refresh : out STD_LOGIC);
end component;
component stage is
	Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  muerte: in STD_LOGIC;
			  eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
			  eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGB_sh : out  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_ss : out  STD_LOGIC_VECTOR (7 downto 0));
end component;
component Mario is
	Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  resets : in STD_LOGIC;
			  eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
			  eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  refresh : in STD_LOGIC;
			  sobreplatM : in STD_LOGIC;
			  escalera : in STD_LOGIC;
			  LB : in STD_LOGIC;
			  RB : in STD_LOGIC;
			  UB : in STD_LOGIC;
           RGB_mh : out  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_ms : out  STD_LOGIC_VECTOR (7 downto 0);
			  Luigi : in STD_LOGIC);
end component;
component control_m is
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
end component;
component control_b is
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
end component;
component barril is
	Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
			  eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  refresh : in STD_LOGIC;
			  sobreplatB : in STD_LOGIC;
			  LB : in STD_LOGIC;
			  RB : in STD_LOGIC;			  
           RGB_bh : out  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_bs : out  STD_LOGIC_VECTOR (7 downto 0);
			  empieza_b : in STD_LOGIC;
			  empieza_siguiente : out STD_LOGIC;
			  RGB_in: in STD_LOGIC_VECTOR (2 DOWNTO 0);
			  pixel_out: out STD_LOGIC_VECTOR (7 DOWNTO 0);
			  pintando: out STD_LOGIC);
end component;
COMPONENT barril_mem
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;


--señales de mario, stage, control_m y las globales
signal s_eje_x,s_eje_y: STD_LOGIC_VECTOR (9 downto 0);
signal s_RGB_mh,s_RGB_sh,s_RGB_outhm: STD_LOGIC_VECTOR (7 downto 0);
signal s_RGB_ms,s_RGB_ss,s_RGB_outsm: STD_LOGIC_VECTOR (7 downto 0);
signal s_reset_m,s_refresh,s_sobreplatM,s_escalera,s_muerte: STD_LOGIC;
--señal que se le pasa al vga, que sera en funcion de sw0, la s_RGB_outh o la s_RGB_outs del último barril
signal s_RGB_out: STD_LOGIC_VECTOR (7 downto 0);

--señales para barriles y sus controles. Para cada barril nuevo, duplicar y aumentar 1 numero del nombre de la señal
signal s_empieza: STD_LOGIC;
--Para el barril 1
signal s_RGB_bh1,s_RGB_bs1: STD_LOGIC_VECTOR (7 downto 0);
signal s_RGB_outh1,s_RGB_outs1: STD_LOGIC_VECTOR (7 downto 0);
signal s_sobreplatB1,s_muerte1,s_izquierda1,s_derecha1: STD_LOGIC;
signal s_empieza1: STD_LOGIC;
signal s_pintando_1: STD_LOGIC;
signal s_pixel_out_1: STD_LOGIC_VECTOR(7 downto 0);
--Para el barril 2
signal s_RGB_bh2,s_RGB_bs2: STD_LOGIC_VECTOR (7 downto 0);
signal s_RGB_outh2,s_RGB_outs2: STD_LOGIC_VECTOR (7 downto 0);
signal s_sobreplatB2,s_muerte2,s_izquierda2,s_derecha2: STD_LOGIC;
signal s_empieza2: STD_LOGIC;
signal s_pintando_2: STD_LOGIC;
signal s_pixel_out_2: STD_LOGIC_VECTOR(7 downto 0);
--Para el barril 3
signal s_RGB_bh3,s_RGB_bs3: STD_LOGIC_VECTOR (7 downto 0);
signal s_RGB_outh3,s_RGB_outs3: STD_LOGIC_VECTOR (7 downto 0);
signal s_sobreplatB3,s_muerte3,s_izquierda3,s_derecha3: STD_LOGIC;
signal s_empieza3: STD_LOGIC;
signal s_pintando_3: STD_LOGIC;
signal s_pixel_out_3: STD_LOGIC_VECTOR(7 downto 0);
--Para el barril 4
signal s_RGB_bh4,s_RGB_bs4: STD_LOGIC_VECTOR (7 downto 0);
signal s_RGB_outh4,s_RGB_outs4: STD_LOGIC_VECTOR (7 downto 0);
signal s_sobreplatB4,s_muerte4,s_izquierda4,s_derecha4: STD_LOGIC;
signal s_empieza4: STD_LOGIC;
signal s_pintando_4: STD_LOGIC;
signal s_pixel_out_4: STD_LOGIC_VECTOR(7 downto 0);
--Para el barril 5
signal s_RGB_bh5,s_RGB_bs5: STD_LOGIC_VECTOR (7 downto 0);
signal s_RGB_outh5,s_RGB_outs5: STD_LOGIC_VECTOR (7 downto 0);
signal s_sobreplatB5,s_muerte5,s_izquierda5,s_derecha5: STD_LOGIC;
signal s_empieza5: STD_LOGIC;
signal s_pintando_5: STD_LOGIC;
signal s_pixel_out_5: STD_LOGIC_VECTOR(7 downto 0);
--para pintar todos los barriles
signal s_RGB_in: STD_LOGIC_VECTOR(2 downto 0);
signal s_pixel: STD_LOGIC_VECTOR(7 DOWNTO 0); 
begin
-----------------------------------------------------------------------------------------------------------
s_RGB_out <= s_RGB_outs5 when sw0='1' else s_RGB_outh5;	--sw0 decide si mostrar las hit boxs o los sprites
-----------------------------------------------------------------------------------------------------------
VGA: VGA_driver
port map(  clk => clk,
           reset => reset,
			  RGB_in => s_RGB_out,
           VS => VS,
           HS => HS,
           RGB_out => RGB,
			  eje_x => s_eje_x,
           eje_y => s_eje_y,
			  refresh => s_refresh);
-----------------------------------------------------------------------------------------------------
s_muerte <= s_muerte1 or s_muerte2 or s_muerte3 or s_muerte4 or s_muerte5;		--or de todas las señales de muerte que salen de cada uno de los control_b
-----------------------------------------------------------------------------------------------------
Stage_1: stage
port map(  clk => clk,
			  reset => reset,
			  muerte => s_muerte,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  RGB_sh => s_RGB_sh,
           RGB_ss => s_RGB_ss);
----------------------------------------------------------------------------------------------------			  
s_reset_m <= s_muerte;	--s_muerte a su vez sera el or de las muertes de todos los barriles
----------------------------------------------------------------------------------------------------			  
Fontanero_1: Mario
port map(  clk => clk,
			  reset => reset,
			  resets => s_reset_m,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  refresh => s_refresh,
			  sobreplatM => s_sobreplatM,
			  escalera => s_escalera,
			  LB => LB,
			  RB => RB,
			  UB => UB,
           RGB_mh => s_RGB_mh,
			  RGB_ms => s_RGB_ms,
			  Luigi => sw1);
control_m1: control_m
port map(  clk => clk,
			  reset => reset,
			  refresh => s_refresh,
			  RGB_mh => s_RGB_mh,
			  RGB_ms => s_RGB_ms,
			  RGB_sh => s_RGB_sh,
			  RGB_ss => s_RGB_ss,
			  RGB_outh => s_RGB_outhm,
			  RGB_outs => s_RGB_outsm, 
			  sobreplatM => s_sobreplatM,
			  escalera => s_escalera);
--Aqui los barriles, conectados en serie, las salidas RGB a la entrada del siguiente
--Barril 1	  
control_b1: control_b
port map(  clk => clk,
			  reset => reset,
			  refresh => s_refresh,
			  RGB_bh => s_RGB_bh1,			--barril
			  RGB_bs => s_RGB_bs1,			
			  RGB_inh => s_RGB_outhm,		--salida del control anterior
			  RGB_ins => s_RGB_outsm,
			  RGB_outh => s_RGB_outh1,		--salida del control actual
			  RGB_outs => s_RGB_outs1,
			  sobreplatB => s_sobreplatB1,
			  izquierda => s_izquierda1,
			  derecha => s_derecha1,
			  muerte => s_muerte1);
------------------------------------------------------------------------------------------
s_empieza <= '1';
------------------------------------------------------------------------------------------
barril_1: barril
port map(  clk => clk,
			  reset => reset,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  refresh => s_refresh,
			  sobreplatB => s_sobreplatB1,
			  LB => s_izquierda1,
			  RB => s_derecha1,		  
           RGB_bh => s_RGB_bh1,
			  RGB_bs => s_RGB_bs1,
			  empieza_b => s_empieza,
			  empieza_siguiente => s_empieza1,
			  pixel_out =>s_pixel_out_1,
			  RGB_in =>s_RGB_in,
			  pintando=>s_pintando_1);
--Barril 2	  
control_b2: control_b
port map(  clk => clk,
			  reset => reset,
			  refresh => s_refresh,
			  RGB_bh => s_RGB_bh2,			--barril
			  RGB_bs => s_RGB_bs2,			
			  RGB_inh => s_RGB_outh1,		--salida del control anterior
			  RGB_ins => s_RGB_outs1,
			  RGB_outh => s_RGB_outh2,		--salida del control actual
			  RGB_outs => s_RGB_outs2,
			  sobreplatB => s_sobreplatB2,
			  izquierda => s_izquierda2,
			  derecha => s_derecha2,
			  muerte => s_muerte2);
barril_2: barril
port map(  clk => clk,
			  reset => reset,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  refresh => s_refresh,
			  sobreplatB => s_sobreplatB2,
			  LB => s_izquierda2,
			  RB => s_derecha2,		  
           RGB_bh => s_RGB_bh2,
			  RGB_bs => s_RGB_bs2,
			  empieza_b => s_empieza1,
			  empieza_siguiente => s_empieza2,
			  pixel_out =>s_pixel_out_2,
			  RGB_in =>s_RGB_in,
			  pintando=>s_pintando_2);
--Barril 3	  
control_b3: control_b
port map(  clk => clk,
			  reset => reset,
			  refresh => s_refresh,
			  RGB_bh => s_RGB_bh3,			--barril
			  RGB_bs => s_RGB_bs3,			
			  RGB_inh => s_RGB_outh2,		--salida del control anterior
			  RGB_ins => s_RGB_outs2,
			  RGB_outh => s_RGB_outh3,		--salida del control actual
			  RGB_outs => s_RGB_outs3,
			  sobreplatB => s_sobreplatB3,
			  izquierda => s_izquierda3,
			  derecha => s_derecha3,
			  muerte => s_muerte3);
barril_3: barril
port map(  clk => clk,
			  reset => reset,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  refresh => s_refresh,
			  sobreplatB => s_sobreplatB3,
			  LB => s_izquierda3,
			  RB => s_derecha3,		  
           RGB_bh => s_RGB_bh3,
			  RGB_bs => s_RGB_bs3,
			  empieza_b => s_empieza2,
			  empieza_siguiente => s_empieza3,
			  pixel_out =>s_pixel_out_3,
			  RGB_in =>s_RGB_in,
			  pintando =>s_pintando_3);
--Barril 4	  
control_b4: control_b
port map(  clk => clk,
			  reset => reset,
			  refresh => s_refresh,
			  RGB_bh => s_RGB_bh4,			--barril
			  RGB_bs => s_RGB_bs4,			
			  RGB_inh => s_RGB_outh3,		--salida del control anterior
			  RGB_ins => s_RGB_outs3,
			  RGB_outh => s_RGB_outh4,		--salida del control actual
			  RGB_outs => s_RGB_outs4,
			  sobreplatB => s_sobreplatB4,
			  izquierda => s_izquierda4,
			  derecha => s_derecha4,
			  muerte => s_muerte4);
barril_4: barril
port map(  clk => clk,
			  reset => reset,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  refresh => s_refresh,
			  sobreplatB => s_sobreplatB4,
			  LB => s_izquierda4,
			  RB => s_derecha4,		  
           RGB_bh => s_RGB_bh4,
			  RGB_bs => s_RGB_bs4,
			  empieza_b => s_empieza3,
			  empieza_siguiente => s_empieza4,
			  pixel_out =>s_pixel_out_4,
			  RGB_in =>s_RGB_in,
			  pintando=>s_pintando_4);
--Barril 5	  
control_b5: control_b
port map(  clk => clk,
			  reset => reset,
			  refresh => s_refresh,
			  RGB_bh => s_RGB_bh5,			--barril
			  RGB_bs => s_RGB_bs5,			
			  RGB_inh => s_RGB_outh4,		--salida del control anterior
			  RGB_ins => s_RGB_outs4,
			  RGB_outh => s_RGB_outh5,		--salida del control actual
			  RGB_outs => s_RGB_outs5,
			  sobreplatB => s_sobreplatB5,
			  izquierda => s_izquierda5,
			  derecha => s_derecha5,
			  muerte => s_muerte5);
barril_5: barril
port map(  clk => clk,
			  reset => reset,
			  eje_x => s_eje_x,
			  eje_y => s_eje_y,
			  refresh => s_refresh,
			  sobreplatB => s_sobreplatB5,
			  LB => s_izquierda5,
			  RB => s_derecha5,		  
           RGB_bh => s_RGB_bh5,
			  RGB_bs => s_RGB_bs5,
			  empieza_b => s_empieza4,
			  empieza_siguiente => s_empieza5,
			  pixel_out =>s_pixel_out_5,
			  RGB_in =>s_RGB_in,
			  pintando=>s_pintando_5);

--Memoria externa de los barriles
memoria_barril: barril_mem
PORT MAP (
    clka =>clk,
    addra =>s_pixel,      -- rellenar con los cables de las memorias despues
    douta =>s_RGB_in 
  );

--Prioridad de los barriles
prioridad: process(s_pintando_1,s_pintando_2,s_pintando_3,s_pintando_4,s_pintando_5,s_pixel_out_1,s_pixel_out_2,s_pixel_out_3,s_pixel_out_4,s_pixel_out_5)
begin
	
	if(s_pintando_1='1')then      --decide que barril tiene prioridad al leer de memoria
		s_pixel <= s_pixel_out_1;
	
	elsif(s_pintando_2='1')then
		s_pixel <= s_pixel_out_2;
	
	elsif(s_pintando_3='1')then
		s_pixel <= s_pixel_out_3;
	
	elsif(s_pintando_4='1')then
		s_pixel <= s_pixel_out_4;
	
	elsif(s_pintando_5='1')then
		s_pixel <= s_pixel_out_5;
	
	else
		s_pixel <="00000000";
	end if;
end process;
end Behavioral;