library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mario is
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
end Mario;

architecture Behavioral of Mario is
signal posx,p_posx : unsigned(9 downto 0);
signal posy,p_posy : unsigned(9 downto 0);
signal vy,p_vy : unsigned(4 downto 0);
TYPE ESTADO_serie is (reposo,posUpdate,velUpdate);
SIGNAL estado,p_estado: ESTADO_serie;
signal jumping,p_jumping : STD_LOGIC;
signal goingUp,p_goingUp : STD_LOGIC;
signal sobreplatM_int,p_sobreplatM_int : STD_LOGIC;

--señales para contar refesh y decidir cuando cambiar de sprite para crear la animacion de movimiento
signal aux_s,p_aux_s : STD_LOGIC;											--señal que dice que sprite toca
signal Q_int,p_Q_int : unsigned(2 downto 0);					--numero maximo que se puede contar: 8
constant Qmax : unsigned(2 downto 0):=to_unsigned(7,3);	--cambiamos el sprite cada Qmax refresh

--señales para usar la memoria ram, donde estaran unos detras de otros los sprites de mario que alternados simulan el movimiento
signal pixel : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal RGB : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal orientacion,p_orientacion : STD_LOGIC;	--para que el sprite de mario mire a izq(0) o der(1)

constant acel : unsigned(4 downto 0):=to_unsigned(1,5);	--gravedad de 1 pixels/refresh^2
constant vx : unsigned(4 downto 0):=to_unsigned(4,5);		--desplazamiento de 4 pixels/refresh
constant vymax : unsigned(4 downto 0):=to_unsigned(8,5);		--caida maxima de 8 pixels/refresh

--constantes para saltar a las direcciones de la rom de cada sprite
constant andando : unsigned(11 downto 0):=to_unsigned(1024,12);
constant saltando : unsigned(11 downto 0):=to_unsigned(2048,12);
constant subiendo : unsigned(11 downto 0):=to_unsigned(3072,12);
--instancia de la rom que contiene todos los sprites de mario
COMPONENT mario1
	PORT (clka : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END COMPONENT;

begin
--instancia de la rom que contiene todos los sprites de mario     --direcciones de la memoria para cada sprite:
mario1_1 : mario1																	--Parado 	[0,1023]
PORT MAP (  clka => clk,														--Andando 	[1024,2047]
				addra => pixel,													--Saltando 	[2048,3071]
				douta => RGB);														--Subiendo 	[3072,4095]

	sinc: process(clk,reset)	--proceso sincrono
	begin
		if(reset='1')then			--reset
			posx <= to_unsigned(560,10);
			posy <= to_unsigned(411,10);
			goingUp <= '0';
			jumping <= '0';
			vy <= to_unsigned(0,5);
			estado <= reposo;
			orientacion <= '0';
			sobreplatM_int <= '0';
			aux_s <= '0';
			Q_int <= (others => '0');
		elsif(rising_edge(clk))then	--llegada del flanco de reloj, actualizacion de las variables
			posx <= p_posx;
			posy <= p_posy;
			estado <= p_estado;
			goingUp <= p_goingUp;
			jumping <= p_jumping;
			vy <= p_vy;
			orientacion <= p_orientacion;
			sobreplatM_int <= p_sobreplatM_int;
			aux_s <= p_aux_s;
			Q_int <= p_Q_int;
		end if;
	end process;
	
	comb: process(eje_x, eje_y, posx, posy, RGB, orientacion, aux_s,LB,RB,UB,escalera,Luigi,jumping)		--dibujar el cuadrado de mario
	begin
		--dibujamos el cuadrado rojo y el sprite en funcion de la esquina superior, posx y posy
		if(unsigned(eje_x)>=(posx+3) and unsigned(eje_x)<=(posx+28) and unsigned(eje_y)>=posy and unsigned(eje_y)<=(posy+31))then
			RGB_mh <= "11100000";
			--decidimos que sprite toca pasar en cada fotograma
			if(UB='1' and escalera='1')then			--subiendo las escaleras
				if(aux_s='0')then							--toca sprite de subiendo derecha
					pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+(unsigned(eje_x)-posx)+subiendo));		--subiendo	derecha
				else											--toca sprite de subiendo izq
					pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+31-(unsigned(eje_x)-posx)+subiendo));	--subiendo izquierda
				end if;
			elsif(jumping='1')then		--saltando
				if(orientacion='1')then		--imagen mirando hacia la derecha (la original)
					pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+(unsigned(eje_x)-posx)+saltando));	--saltando derecha
				else								--imagen mirando hacia la izquierda (hay que invertir las x)
					pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+31-(unsigned(eje_x)-posx)+saltando));	--saltando izquierda
				end if;
			elsif(LB='1' or RB='1')then				--si voy andando
				if(aux_s='0')then							--toca sprite de parado
					if(orientacion='1')then		--imagen mirando hacia la derecha (la original)
						pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+(unsigned(eje_x)-posx)));			--parado	derecha
					else								--imagen mirando hacia la izquierda (hay que invertir las x)
						pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+31-(unsigned(eje_x)-posx)));		--parado izquierda
					end if;
				else											--toca sprite de andando
					if(orientacion='1')then		--imagen mirando hacia la derecha (la original)
						pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+(unsigned(eje_x)-posx)+andando));	--andando derecha
					else								--imagen mirando hacia la izquierda (hay que invertir las x)
						pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+31-(unsigned(eje_x)-posx)+andando));	--andando izquierda
					end if;
				end if;
			else												--parado
				if(orientacion='1')then		--imagen mirando hacia la derecha (la original)
					pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+(unsigned(eje_x)-posx)));				--parado derecha
				else								--imagen mirando hacia la izquierda (hay que invertir las x)
					pixel <= std_logic_vector(((32*(unsigned(eje_y)-posy))+31-(unsigned(eje_x)-posx)));			--parado izquierda
				end if;
			end if;
			--traducimos el color almacenado en rom de 3 bits a 8 bits
			case RGB is
				when "000" =>	--negro
					RGB_ms <= "00000000";
				when "100" =>	--rojo
					if(Luigi='1')then
						RGB_ms <= "00011100";
					else
						RGB_ms <= "11100000";
					end if;
				when "110" =>	--amarillo
					RGB_ms <= "11111100";
				when others => 
					RGB_ms <= "00000011";
			end case;
		else
		--el resto que no es cuadrado, es negro (fondo del la capa del mario)
			RGB_mh <= "00000000";
			RGB_ms <= "00000000";
			pixel <= (others => '0');
		end if;
		--ahora sobreescribimos un par de pixeles como blancos, que los usaremos para el control (no hacen falta en el sprite)
		if((unsigned(eje_x)=(posx+3) and unsigned(eje_y)=(posy+31))or(unsigned(eje_x)=(posx+28) and unsigned(eje_y)=(posy+31)))then
			RGB_mh <= "11111111";
		end if;
	end process;
	
	comb2: process(resets,vy,refresh, estado, posx, posy,sobreplatM,sobreplatM_int,escalera,LB,RB,UB,goingUp,jumping,orientacion,aux_s,Q_int)	--movimientos del mario
	begin
		if(resets='1')then
			p_posx <= to_unsigned(560,10);
			p_posy <= to_unsigned(411,10);
			p_goingUp <= '0';
			p_jumping <= '0';
			p_vy <= to_unsigned(0,5);
			p_estado <= reposo;
			p_orientacion <= '0';
			p_sobreplatM_int <= '0';
			p_aux_s <= '0';
			p_Q_int <= (others => '0');
		else
			--mantenemos valores a no ser que luego los cambiemos abajo
			p_jumping <= jumping;
			p_goingUp <= goingUp;
			p_vy <= vy;
			p_orientacion <= orientacion;
			p_sobreplatM_int <= sobreplatM_int;
			p_aux_s <= aux_s;
			p_Q_int <= Q_int;
			----------orientacion del sprite
			--si pulso izquierda o derecha cambiamos la orientacion para dar la vuelta al sprite
			if(LB='1')then
				p_orientacion <= '0';
			elsif(RB='1')then
				p_orientacion <= '1';
			end if;
			-----------control de los estados de salto
			--si no estoy en un proceso de salto, estoy sobre la plataforma o lo estaba justo en el fotograma anterior, y pulso el boton
			if((jumping='0' and UB='1') and (sobreplatM='1' or sobreplatM_int='1'))then
				p_jumping <= '1';					--indico que estoy en un proceso de salto
				p_vy <= vymax;						--doy el impulso inicial de salto
				p_goingUp <= '1';					--indico que estoy subiendo
			--si estoy bajando y llego a la plataforma
			elsif(goingUp='0' and sobreplatM='1')then
				p_jumping <= '0';					--he acabado el salto
			end if;
			------------actualizacion de las posiciones y las velocidades
			--maquina de estados para calcular los movimientos
			case estado is
				when reposo =>
					--salidas
					p_posx <= posx;					
					p_posy <= posy;
					--actualizacion de estados
					if(refresh='1')then				
						p_estado <= posUpdate;	--cuando llega el refresh pasamos a cambiar la posicion
					else
						p_estado <= reposo;		--mantenemos fotograma hasta el refresh
					end if;
				when posUpdate =>
					--salidas
					--actualizacion de la posicion horizontal
					p_posx <= posx;				--mantenemos posx a no ser que luego la cambiemos
					--si pulso el boton de ir a la izquierda
					if(LB='1' and posx>1)then
						p_posx <= posx-vx;		--me muevo a la izq
					--si pulso el boton de ir a la derecha
					elsif(RB='1' and posx<609)then
						p_posx <= posx+vx;		--me muevo a la der
					end if;
					
					--actualizacion de la posicion vertical
					--si estoy delante de una escalera y pulso subir
					if(escalera='1' and UB='1')then
						p_posy <= posy-2;		--subo a una velocidad de 2 pixeles/refresh
					--si estoy bajando
					elsif(goingUp='0')then
						--si aun estoy en el aire
						if(sobreplatM='0')then
							p_posy <= posy+vy;	--sigo bajando
						--si ya he tocado suelo
						else
							p_posy <= posy-1;		--subo para no quedarme atascado en el suelo
						end if;
					--si no estoy bajando (estoy subiendo)
					else
						p_posy <= posy-vy;		--la velocidad es negativa, es decir, subo
					end if;
					--actualizacion de estados
					p_estado <= velUpdate;
				when velUpdate =>					--calculo la siguiente velocidad
					--salidas
					--mantengo la posicion
					p_posx <= posx;
					p_posy <= posy;
					--si estoy sobre la plataforma
					if(sobreplatM='1')then
						p_vy <= "00000";			--proxima velocidad es cero
						p_goingUp <= '0';			
					--si estoy en el aire y estoy bajando
					elsif(goingUp='0')then
						--si la velocidad aun no ha alcanzado el limite
						if(vy<vymax)then
							p_vy <= vy+acel;	--sigue acelerando
						--si la velocidad ya ha alcanzado el limite
						else
							p_vy <= vymax;			--se mantiene al limite
						end if;
					--si estoy en el aire y subiendo
					else
						--si la velocidad es aun mayor que la aceleracion
						if(vy>acel)then
							p_vy <= vy-acel;		--sigue decelerando
						--si en la siguiente deceleracion la velocidad se hara negativa
						else
							p_vy <= "00000";		--pongo la velocidad a 0
							p_goingUp <= '0';		--indico que ahora estoy bajando
						end if;
					end if;
					--actualizacion de estados
					p_estado <= reposo;
					--otras variables que se actualizan cada refresh (las actualizamos aqui por ejemplo)
					------------------------------------------------------------------------------------
					p_sobreplatM_int <= sobreplatM;
					if(Q_int=Qmax)then						--si vale Qmax, la proxima vale 0
						p_Q_int <= to_unsigned(0,3);
						p_aux_s <= NOT aux_s;				--alternamos los sprites cada Qmax refreshs
					else											--si no, sumamos 1
						p_Q_int <= Q_int + 1;
					end if;
					------------------------------------------------------------------------------------
			end case;
		end if;
	end process;
end Behavioral;