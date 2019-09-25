library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity barril is
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
			  empieza_b: in STD_LOGIC;
			  empieza_siguiente: out STD_LOGIC;
			  pixel_out: out STD_LOGIC_VECTOR(7 downto 0);
			  RGB_in: in STD_LOGIC_VECTOR(2 downto 0);
			  pintando: out STD_LOGIC);
			  
end barril;

architecture Behavioral of barril is
signal posx,p_posx : unsigned(9 downto 0);
signal posy,p_posy : unsigned(9 downto 0);
signal vy,p_vy : unsigned(3 downto 0);
type ESTADO_serie is (apagado,reposo,posUpdate,velUpdate);
signal estado,p_estado: ESTADO_serie;

--señales para contar refesh y decidir cuando cambiar de sprite para crear la animacion de movimiento
signal aux_s,p_aux_s : STD_LOGIC;											--señal que dice que sprite toca
signal Q_int,p_Q_int : unsigned(3 downto 0);								--numero maximo que se puede contar: 8
constant Qmax : unsigned(3 downto 0):=to_unsigned(15,4);				--cambiamos el sprite cada Qmax refresh

--gestionar la salida y comienzo del barril
signal p_aux_direccion,aux_direccion : STD_LOGIC; --
signal siguiente, p_siguiente : STD_LOGIC; --

--leer de memoria
signal aux_pixel: STD_LOGIC_VECTOR(7 downto 0);


constant acel : unsigned(3 downto 0):=to_unsigned(1,4);	--gravedad de 1 pixels/refresh^2
constant vx : unsigned(3 downto 0):=to_unsigned(2,4);	--desplazamiento de 2 pixels/refresh
constant vymax : unsigned(3 downto 0):=to_unsigned(8,4);		--caida maxima de 8 pixels/refresh


begin
	
	pixel_out <= aux_pixel;
	empieza_siguiente <= siguiente;
	
	sinc: process(clk,reset)	--proceso sincrono
	begin
		if(reset='1')then			--reset
			posx <= to_unsigned(700,10);
			posy <= to_unsigned(0,10);			
			vy <= to_unsigned(0,4);
			estado <= apagado;
			aux_direccion <= '1';
			siguiente <= '0';
			aux_s <= '0';
			Q_int <= (others => '0');
		elsif(rising_edge(clk))then	--llegada del flanco de reloj, actualizacion de las variables
			posx <= p_posx;
			posy <= p_posy;
			estado <= p_estado;
			vy <= p_vy;
			aux_direccion <= p_aux_direccion;
			siguiente <= p_siguiente;
			aux_s <= p_aux_s;
			Q_int <= p_Q_int;
		end if;
	end process;
	
	comb: process(eje_x, eje_y, posx, posy, RGB_in, aux_s)		--dibujar el cuadrado de barril o sprite 
	begin
		if(unsigned(eje_x)>=posx and unsigned(eje_x)<=(posx+15) and unsigned(eje_y)>=posy and unsigned(eje_y)<=(posy+15))then
			RGB_bh <= "10001000"; --pintamos barril de la hitbox
			pintando <='1';
		
			--calculamos la direccion de la memoria que toca pintar para el pixel actual
			if(aux_s='0')then		--imagen normal
				aux_pixel <= std_logic_vector(((16*(unsigned(eje_y)-posy))+(unsigned(eje_x)-posx)));
			else								--imagen espejo
				aux_pixel <= std_logic_vector(((16*(unsigned(eje_y)-posy))+16-(unsigned(eje_x)-posx)));
			end if;
			--traducimos el color almacenado en rom de 3 bits a 8 bits
			case RGB_in is
				when "100" =>	--rojo
					RGB_bs <= "11100000";
				when "110" =>	--amarillo
					RGB_bs <= "11111100";
				when others => 
					RGB_bs <= "00000000";
			end case;	
		--el resto de aqui es negro
		else
			RGB_bh <= "00000000";
			RGB_bs <= "00000000";
			aux_pixel <= (others => '0');
			pintando <='0';
			
		end if;
		--pintamos los pixeles de control de la hitbox
		if((unsigned(eje_x)=(posx) and unsigned(eje_y)=(posy+15))or(unsigned(eje_x)=(posx+15) and unsigned(eje_y)=(posy+15)))then
			RGB_bh <= "11111111";	--pixeles de control
		end if;


	end process;
	
	comb2: process(vy,refresh, estado, posx, posy,sobreplatB,LB,RB,aux_direccion, empieza_b,Q_int,aux_s)			--simulacion de la gravedad
	begin	
		p_vy <= vy;
		p_aux_direccion <= aux_direccion;
		p_aux_s <= aux_s;
		p_Q_int <= Q_int;
		-----------------------------
		if(LB='1')then
			p_aux_direccion <= '0';
		elsif(RB='1')then            --flags de dirección
			p_aux_direccion <= '1';
		end if;
		------------------------------
		
		case estado is
			
			when apagado =>
				--salidas
				p_posx <= posx; --mientras no se le diga lo contrario no salen en pantalla
				p_posy <= posy;
				--actualizacion de estados
				if(empieza_b='1') then   --cuidado con esta que es asincrona
					p_estado <= reposo;
					p_posx <= to_unsigned(10,10); -- si sale del reposo entonces se pone en la posicion incial
					p_posy <= to_unsigned(0,10);
				else
					p_estado <= apagado;
				end if;
					
			when reposo =>
				--salidas
				p_posx <= posx;
				p_posy <= posy;
				--actualizacion de estados
				if(posx>640) then
					p_estado <= apagado;   -- si se sale de pantalla vuelve al estado inicial
				elsif(refresh='1')then
					p_estado <= posUpdate;
				else
					p_estado <= reposo;
				end if;
			
			when posUpdate =>
				--salidas
				p_posx <= posx;
				if(LB='1')then
					p_posx <= posx-vx;
				elsif(RB='1')then
					p_posx <= posx+vx;
				end if;
				
				
				if(sobreplatB='0')then
						p_posy <= posy+vy;
				else
						p_posy <= posy-1;
				end if;
				--actualizacion de estados
				p_estado <= velUpdate;
			
			when velUpdate =>
				--salidas
				p_posx <= posx;
				p_posy <= posy;
				if(sobreplatB='1')then
					p_vy <= "0000";
				else
					if(vy<vymax)then
						p_vy <= vy+acel;
					else
						p_vy <= vymax;
					end if;				
				end if;
				--actualizacion de estados
				p_estado <= reposo;
				--otras variables que se actualizan cada refresh (las actualizamos aqui por ejemplo)
				------------------------------------------------------------------------------------
				if(Q_int=Qmax)then						--si vale Qmax, la proxima vale 0
					p_Q_int <= to_unsigned(0,4);
					p_aux_s <= NOT aux_s;				--alternamos los sprites cada Qmax refreshs
				else											--si no, sumamos 1
					p_Q_int <= Q_int + 1;
				end if;
				------------------------------------------------------------------------------------
		end case;
	end process;

-------------------------------------------------------------------------------------------------------
	comb3: process(p_aux_direccion,aux_direccion)  --aqui activa el siguiente barril
	begin
		if (p_aux_direccion = (not aux_direccion)) then     
			p_siguiente <= '1';
		else                                           
			p_siguiente <= '0';
		end if;
		
	end process;
	

end Behavioral;