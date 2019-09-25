library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stage is

	Port (  clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  muerte: in STD_LOGIC;
			  eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
			  eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
           RGB_sh : out  STD_LOGIC_VECTOR (7 downto 0);
			  RGB_ss : out  STD_LOGIC_VECTOR (7 downto 0));
end stage;

architecture Behavioral of stage is

signal VIDAS, P_VIDAS : unsigned (1 downto 0); --Nº DE VIDAS 
signal aux, p_aux : STD_LOGIC;

--señales para usar la memoria ram, donde estaran unos detras de otros los sprites de mario que alternados simulan el movimiento
signal pixel : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal RGB : STD_LOGIC_VECTOR(2 DOWNTO 0);
--constantes para saltar a las direcciones de la rom de cada sprite
constant barriles : unsigned(11 downto 0):=to_unsigned(1024,12);
constant DK : unsigned(11 downto 0):=to_unsigned(2048,12);
constant castillo : unsigned(11 downto 0):=to_unsigned(3072,12);
constant corazon : unsigned(11 downto 0):=to_unsigned(3680,12);

COMPONENT sprites
	PORT (clka : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END COMPONENT;

begin
--instancia de la rom que contiene todos los sprites de la stage  --direcciones de la memoria para cada sprite:
	stages_1 : sprites																--Pauline 	[0,1023]
	PORT MAP (  clka => clk,														--barriles 	[1024,2047]
					addra => pixel,													--DK			[2048,3071]
					douta => RGB);														--castillo	[3072,3679]
																							--corazon	[3680,3935]
	
	sinc: process(clk,reset)	--proceso síncrono
	begin
		if(reset = '1')then			--reset
			VIDAS <= to_unsigned(3,2);
			aux <= '0';
		elsif( rising_edge(clk) )then	--llegada del flanco de reloj, actualizacion de las variables
			VIDAS <= P_VIDAS;
			aux <= p_aux;
		end if;
	end process;
	
	
	comb: process(eje_x, eje_y, aux, muerte, VIDAS, RGB)
	begin
	--------------------------------------------------------------------------------------------------------
	-- HAY DOS VECTORES QUE SE VAN MODIFICANDO: SH (HIT BOX PARA CONTROL) Y EL SS (PARA MOSTRARLO BONITO) --
	--------------------------------------------------------------------------------------------------------
	
	--------------------FONDO----------------------------
	
	RGB_ss <= "00000000";
	RGB_sh <= "00000000";
	
	
		--------------------PLATAFORMAS---------------------------- SE INDICAN LAS ESQUINAS PARA LOS SPRITES
	
	--BARRA DE LA DERECHA	
	if(((unsigned(eje_y)>80) AND (unsigned(eje_y)<97)) AND((unsigned(eje_x)>=0)AND(unsigned(eje_x)<561)))then
		RGB_ss <= "11101001";
		RGB_sh <= "11101001";
	end if;
	if(((unsigned(eje_y)>272) AND (unsigned(eje_y)<288))AND((unsigned(eje_x)>=0)AND(unsigned(eje_x)<561)))then		
		RGB_ss <= "11101001";
		RGB_sh <= "11101001";
	end if;
	if(((unsigned(eje_y)>464)AND (unsigned(eje_y)<481))AND((unsigned(eje_x)>=0) AND(unsigned(eje_x)<641)))then
		RGB_ss <= "11101001";
		RGB_sh <= "11101001";
	end if;
	--BARRA DE LA IZQUIERDA
	if(((unsigned(eje_y)>176) AND (unsigned(eje_y)<193)) AND((unsigned(eje_x)>79) AND(unsigned(eje_x)<641)))then
		RGB_ss <= "11001001";
		RGB_sh <= "11001001";
	end if;
	if(((unsigned(eje_y)>368)    AND (unsigned(eje_y)<385)) AND((unsigned(eje_x)>79) AND(unsigned(eje_x)<641)))THEN
		RGB_ss <= "11001001";
		RGB_sh <= "11001001";
	end if;
	--PLATAFORMA INICIAL (Castillo)
	if(((unsigned(eje_y)>444) and (unsigned(eje_y)<465)) and ((unsigned(eje_x)>559) and (unsigned(eje_x)<592))) then
		--calculamos la direccion de la memoria que toca pintar para el pixel actual
				pixel <= std_logic_vector(((32*(unsigned(eje_y)-446))+(unsigned(eje_x)-560)+castillo));--sumamos "castillo", la direccion de memoria donde empieza su sprite
			case RGB is					 -- esquina superior izquierda -> [560,445] tamaÑo -> (19*32)
				when "100" =>	--rojo
					RGB_ss <= "01100100";
				when others => 
					RGB_ss <= "00000000";
			end case; 
		--dentro del castillo, no pintamos todo entero de hit box, dejamos unos pixeles por debajo para que no haya conflictos con el barril
		if (unsigned(eje_y)<462) then
			rgb_sh <= "11001001";
		end if;
	end if;	
	
	------------------------ DONKEY KONG, BARRILES AMONTONADOS Y P. PAULINE ----------------------------
	--------------------------------------------------------------------------------------------------
	if ((unsigned(eje_y)>47) AND (unsigned(eje_y)<81)) THEN
		
		IF ((unsigned(eje_x)>51)AND(unsigned(eje_x)<85)) THEN
		--calculamos la direccion de la memoria que toca pintar para el pixel actual
			pixel <= std_logic_vector(((32*(unsigned(eje_y)-48))+(unsigned(eje_x)-52)+barriles));--sumamos "barriles", la direccion de memoria donde empieza su sprite
			case RGB is						-- ESQUINA SUPERIOR IZQUIERDA -> [52,48]-- BARRILES AMONTONADOS (CUADRADO 32*32)
				when "100" =>	--rojo
					RGB_ss <= "11001100";
				when "110" =>	--amarillo
					RGB_ss <= "10001000";
				when others => 
					RGB_ss <= "00000000";
			end case;
			--RGB_sh <= "10001001";
		end if;
		
		if ((unsigned(eje_x)>93)AND(unsigned(eje_x)<127)) THEN
		--calculamos la direccion de la memoria que toca pintar para el pixel actual
			pixel <= std_logic_vector(((32*(unsigned(eje_y)-48))+(unsigned(eje_x)-93)+DK));--sumamos "DK", la direccion de memoria donde empieza su sprite
			case RGB is						-- ESQUINA SUPERIOR IZQUIERDA -> [94,48]-- DONKEY KONG (CUADRADO 32*32)
				when "100" =>	--rojo
					RGB_ss <= "10101001";
				when "111" =>	--blanco
					RGB_ss <= "11111111";
				when others => 
					RGB_ss <= "00000000";
			end case;
			--RGB_sh <= "10101001";
		end if;
		
		if ((unsigned(eje_x)>9)AND(unsigned(eje_x)<43)) THEN
			--calculamos la direccion de la memoria que toca pintar para el pixel actual
				pixel <= std_logic_vector(((32*(unsigned(eje_y)-53))+(unsigned(eje_x)-11)));--el sprite de pauline empieza en la direccion 0 de la memoria
			case RGB is					 -- ESQUINA SUPERIOR IZQUIERDA -> [10,48]-- PRINCESA PAULINE (CUADRADO 32*32)
				when "101" =>	--magenta
					RGB_ss <= "11100011";
				when "110" =>	--amarillo
					RGB_ss <= "11111100";
				when "111" =>	--blanco
					RGB_ss <= "11111111";
				when others => 
					RGB_ss <= "00000000";
			end case;
			RGB_sh <= "10100011";
		END IF;
	END IF;
	
	
	------------------------ESCALERAS----------------------------
	--ESCALERA PRIMERA	
	if (((unsigned(eje_y)> 384) AND (unsigned(eje_y)< (465))) AND ((unsigned(eje_x)> 99) AND (unsigned(eje_x)< (125)))) THEN
			RGB_sh <= "00011111";
			IF NOT  --RECTÁNGULO CYAN MENOS LOS 
						--HUECOS NEGROS
			(  ((((unsigned(eje_y)>384) AND (unsigned(eje_y)<393))) or
				(((unsigned(eje_y)>395) AND (unsigned(eje_y)<405))) or
				(((unsigned(eje_y)>407) AND (unsigned(eje_y)<417))) or
				(((unsigned(eje_y)>419) AND (unsigned(eje_y)<429))) or
				(((unsigned(eje_y)>431) AND (unsigned(eje_y)<441))) or
				(((unsigned(eje_y)>443) AND (unsigned(eje_y)<453))) or
				(((unsigned(eje_y)>455) AND (unsigned(eje_y)<465)))) AND
				(((unsigned(eje_x)> 101) AND (unsigned(eje_x)<123))))THEN 
				
				RGB_ss <= "00011111"; 
			END IF;	
	end if;
	--ESCALERA SEGUNDA		
	if (((unsigned(eje_y)> 287) AND (unsigned(eje_y)< (369))) AND ((unsigned(eje_x)> 400) AND (unsigned(eje_x)<(426)))) THEN
			RGB_sh <= "00011111";
			IF NOT  --RECTÁNGULO CYAN MENOS LOS 
						--HUECOS NEGROS
			(  ((((unsigned(eje_y)>287) AND (unsigned(eje_y)<297)))  OR
				(((unsigned(eje_y)>299) AND (unsigned(eje_y)<309))) OR 
				(((unsigned(eje_y)>311) AND (unsigned(eje_y)<321))) OR
				(((unsigned(eje_y)>323) AND (unsigned(eje_y)<333))) OR 
				(((unsigned(eje_y)>335) AND (unsigned(eje_y)<345))) OR
				(((unsigned(eje_y)>347) AND (unsigned(eje_y)<357))) OR 
				(((unsigned(eje_y)>359) AND (unsigned(eje_y)<369)))) AND
				((unsigned(eje_x)> 402) AND (unsigned(eje_x)<424)))THEN 
				
				RGB_ss <= "00011111"; 
			END IF;	
	end if;
	--ESCALERA TERCERA	
	if(((unsigned(eje_y)> 192) AND (unsigned(eje_y)< (273))) AND ((unsigned(eje_x)> 99) AND (unsigned(eje_x)< (125)))) THEN
			RGB_sh <= "00011111";
			IF NOT  --RECTÁNGULO CYAN MENOS LOS 
						--HUECOS NEGROS
			(  ((((unsigned(eje_y)>192)  AND (unsigned(eje_y)<201)))  or
				(((unsigned(eje_y)>203) AND (unsigned(eje_y)<213))) or
				(((unsigned(eje_y)>215) AND (unsigned(eje_y)<225))) or
				(((unsigned(eje_y)>227) AND (unsigned(eje_y)<237))) or
				(((unsigned(eje_y)>239) AND (unsigned(eje_y)<249))) or
				(((unsigned(eje_y)>251) AND (unsigned(eje_y)<261))) or
				(((unsigned(eje_y)>263) AND (unsigned(eje_y)<273)))) AND
				(((unsigned(eje_x)> 101) AND (unsigned(eje_x)<123))))THEN 
			
				RGB_ss <= "00011111";
				END IF;	
	end if;
	--ESCALERA CUARTA			
	if (((unsigned(eje_y)> 96) AND (unsigned(eje_y)< (177))) AND ((unsigned(eje_x)> 400) AND (unsigned(eje_x)< (426)))) THEN 
			RGB_sh <= "00011111";
			IF NOT  --RECTÁNGULO CYAN MENOS LOS 
						--HUECOS NEGROS
			(  ((((unsigned(eje_y)>96)  AND (unsigned(eje_y)<105)))  OR
				(((unsigned(eje_y)>107) AND (unsigned(eje_y)<117))) OR 
				(((unsigned(eje_y)>119) AND (unsigned(eje_y)<129))) OR
				(((unsigned(eje_y)>131) AND (unsigned(eje_y)<141))) OR 
				(((unsigned(eje_y)>143) AND (unsigned(eje_y)<153))) OR
				(((unsigned(eje_y)>155) AND (unsigned(eje_y)<165))) OR 
				(((unsigned(eje_y)>167) AND (unsigned(eje_y)<177)))) AND
				((unsigned(eje_x)> 402) AND (unsigned(eje_x)<424)))THEN
			
				RGB_ss <= "00011111";
				END IF;	
	end if;
		
		--ESCALERA ROTA		
	if (((unsigned(eje_y)> 192) AND (unsigned(eje_y)< (273))) AND ((unsigned(eje_x)> 480) AND (unsigned(eje_x)< (506)))) THEN
			IF NOT  --RECTÁNGULO CYAN MENOS LOS 
						--HUECOS NEGROS (AMPLIAMOS EL DE EN MEDIO PARA QUE SE ROMPA LA ESCALERA)
			(  (((unsigned(eje_y)>221) AND (unsigned(eje_y)<255)) AND ((unsigned(eje_x)> 480)   AND (unsigned(eje_x)<506)))  OR --CUADRADO GRANDE
				(((((unsigned(eje_y)>192 )  AND (unsigned(eje_y)<201))) OR
				(((unsigned(eje_y)>203) AND (unsigned(eje_y)<213))) OR 
				(((unsigned(eje_y)>215) AND (unsigned(eje_y)<225))) OR
				(((unsigned(eje_y)>239) AND (unsigned(eje_y)<249))) OR
				(((unsigned(eje_y)>251) AND (unsigned(eje_y)<261))) OR 
				(((unsigned(eje_y)>263) AND (unsigned(eje_y)<273)))) AND 
				((unsigned(eje_x)> 482) AND (unsigned(eje_x)<504)))) THEN 
				RGB_ss <= "00011111"; 
			END IF;	
			IF NOT  --RECTÁNGULO CYAN Y LE QUITAMOS 
						--EL HUECO NEGRO GRANDE Y ROMPEMOS EL RECTÁNGULO EN DOS 
			(((unsigned(eje_y)>215) AND (unsigned(eje_y)<261)) AND ((unsigned(eje_x)> 480)   AND (unsigned(eje_x)<506)))  
			 THEN 
				RGB_sh <= "00011111";
			end if;
	END IF;
	IF --MINI PLATAFORMA ENCIMA DEL ÚLTIMO ESCALÓN DE ABAJO PARA QUE MARIO PUEDA SALTAR
		(((unsigned(eje_y)> 260) AND (unsigned(eje_y)< (262))) AND ((unsigned(eje_x)> 480) AND (unsigned(eje_x)< (506)))) THEN
				RGB_sh <= "11101001";
							
	END IF;
	
	------------------------ VIDAS ----------------------------
	P_VIDAS <= VIDAS;
	P_AUX <= AUX;
	IF ( MUERTE = '1' AND AUX ='0' ) THEN
		IF(VIDAS>0)THEN
			P_VIDAS <= VIDAS-1;
		ELSE
			P_VIDAS <= (OTHERS => '0');
		END IF;
		P_AUX <= '1';
	ELSIF ( MUERTE = '0' ) THEN
		P_AUX <= '0';
	END IF;
	if(((unsigned(eje_y)>9) AND (unsigned(eje_y)<27)) AND ((unsigned(eje_x)>489) AND (unsigned(eje_x)<507)) AND VIDAS>2 )then
		--calculamos la direccion de la memoria que toca pintar para el pixel actual
				pixel <= std_logic_vector(((16*(unsigned(eje_y)-10))+(unsigned(eje_x)-490)+corazon));--sumamos "corazon", la direccion de memoria donde empieza su sprite
			case RGB is					 -- esquina superior derecha; tamaÑo -> (16*16)
				when "000" =>	
					RGB_ss <= "00000000";
				when others => 
					RGB_ss <= "11100000";
			end case;	
	end if;
	if(((unsigned(eje_y)>9)  AND (unsigned(eje_y)<27)) AND ((unsigned(eje_x)>515)AND(unsigned(eje_x)<533)) AND VIDAS>1 )then
		--calculamos la direccion de la memoria que toca pintar para el pixel actual
				pixel <= std_logic_vector(((16*(unsigned(eje_y)-10))+(unsigned(eje_x)-516)+corazon));--sumamos "corazon", la direccion de memoria donde empieza su sprite
			case RGB is					 -- esquina superior derecha; tamaÑo -> (16*16)
				when "000" =>	
					RGB_ss <= "00000000";
				when others => 
					RGB_ss <= "11100000";
			end case;	
	end if;
	if(((unsigned(eje_y)>9) AND (unsigned(eje_y)<27)) AND ((unsigned(eje_x)>541) AND(unsigned(eje_x)<559)) AND VIDAS>0 )then 
		--calculamos la direccion de la memoria que toca pintar para el pixel actual
				pixel <= std_logic_vector(((16*(unsigned(eje_y)-10))+(unsigned(eje_x)-542)+corazon));--sumamos "corazon", la direccion de memoria donde empieza su sprite
			case RGB is					 -- esquina superior derecha; tamaÑo -> (16*16)
				when "000" =>	
					RGB_ss <= "00000000";
				when others => 
					RGB_ss <= "11100000";
			end case;	
	END IF;

	------------------------ GAME OVER ----------------------------
	
	IF (VIDAS = 0) THEN  --CAMBIO TODA LA PANTALLA Y LA PONGO DE UN SOLO COLOR
		RGB_ss <= "11111111";		--
		IF (((unsigned(eje_y)> 179 )  AND (unsigned(eje_y)< 301))  AND ((unsigned(eje_x)> 239) AND (unsigned(eje_x)< 401))) THEN
		RGB_ss <= "11100000"; -- ESQUINA SUPERIOR IZQUIERDA PARA SPRITE -> [240, 224]; TAMAÑO (160*120)
		END IF;
	END IF;
	end process;
end Behavioral;