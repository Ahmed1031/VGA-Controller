-- VGA Demo --
----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
----------------------------------------------------------
ENTITY vga_demo IS
GENERIC (
	Ha: INTEGER := 96; --Hpulse
	Hb: INTEGER := 144; --Hpulse+HBP
	Hc: INTEGER := 784; --Hpulse+HBP+Hactive
	Hd: INTEGER := 800; --Hpulse+HBP+Hactive+HFP
	Va: INTEGER := 2; --Vpulse
	Vb: INTEGER := 35; --Vpulse+VBP
	Vc: INTEGER := 515; --Vpulse+VBP+Vactive
	Vd: INTEGER := 525); --Vpulse+VBP+Vactive+VFP
PORT (
	pixel_clk_i    : IN STD_LOGIC; --25Mhz from PLL
	red_switch, green_switch, blue_switch: IN STD_LOGIC;
	pixel_clk_o    : out STD_LOGIC; --25Mhz out for VGA
	Hsync, Vsync   : OUT STD_LOGIC;
	R, G, B        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	nblanck, nsync : OUT STD_LOGIC);
END vga_demo;
-------------------------------------------------------
ARCHITECTURE vga_architecture OF vga_demo IS
SIGNAL Hactive, Vactive, dena: STD_LOGIC :='0';
SIGNAL intensity : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL registered_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL address   : STD_LOGIC_VECTOR(18 DOWNTO 0);
SIGNAL flag      : STD_LOGIC:='0';
-----------------------------------------
component imag_rom1 IS
	PORT
	(
		address  : IN STD_LOGIC_VECTOR (18 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;
-------------------------------------------------------
-- Part 1: CONTROL GENERATOR
-------------------------------------------------------
-- Static signals for DACs:
begin
	nblanck <= '1'; --no direct blanking
	nsync   <= '0'; --no sync on green
   pixel_clk_o <= pixel_clk_i; 
	---------------------------

--------------------------------------------	
-- VGA image ROM --
-- address : 19-bit
-- Depth   : 307200
	U3_ROM : imag_rom1	
PORT MAP (
         clock => NOT(pixel_clk_i),
		 address => address,
		 q       => intensity);
---------------------------	
--------------------------------------------------
-- Horizontal signals generation: 
---------------------------------
HORIZONTAL_SIGNALS : PROCESS (pixel_clk_i)
VARIABLE Hcount: INTEGER RANGE 0 TO Hd;
 BEGIN
   IF (pixel_clk_i'EVENT AND pixel_clk_i='1') THEN
	
       Hcount := Hcount + 1;
		 
    IF (Hcount = Ha) THEN
	 
       Hsync <= '1';
		 
    ELSIF (Hcount = Hb) THEN
	 
       Hactive <= '1';
		 
    ELSIF (Hcount = Hc) THEN
	 
       Hactive <= '0';
		 
    ELSIF (Hcount = Hd) THEN
	 
	 
       Hsync <= '0';
		 
       Hcount := 0;
		 
    END IF;
	 
 END IF;
 
END PROCESS;
------------------------------
--Vertical signals generation:
------------------------------
VERTICAL_SIGNALS:PROCESS (Hsync)
  VARIABLE Vcount: INTEGER RANGE 0 TO Vd;
   BEGIN
      IF (Hsync'EVENT AND Hsync='0') THEN
		
          Vcount := Vcount + 1;
			 
      IF (Vcount = Va) THEN
		
          Vsync <= '1';
			 
       ELSIF (Vcount = Vb) THEN
		 
              Vactive <= '1';
				  
       ELSIF (Vcount = Vc) THEN
		 
              Vactive <= '0';
				  
       ELSIF (Vcount = Vd) THEN
		 
              Vsync <= '0';
				  
             Vcount := 0;
				 
       END IF;
		 
       END IF;
END PROCESS;
-----------------------------
---Display enable generation:
dena <= Hactive AND Vactive;
-------------------------------------------------------
--Part 2: IMAGE GENERATOR
-------------------------------------------------------
IMAGE_GENERATOR : PROCESS (Vsync, pixel_clk_i)
-------------------------------------------------------
VARIABLE pixel_counter: INTEGER RANGE 0 TO 307205;
   BEGIN
       IF (Vsync ='0') THEN
		 
           pixel_counter := 0;
           
       ELSIF (pixel_clk_i'EVENT AND pixel_clk_i ='1') THEN
		 
           -- IF (Hactive = '1') THEN
			  IF (dena = '1') THEN
			  
               R <= intensity;
					G <= intensity;
					B <= intensity;
					
               pixel_counter := pixel_counter + 1;
			 ELSE
			     R <= (OTHERS => '0');
			     G <= (OTHERS => '0');
			     B <= (OTHERS => '0');
			 END IF;
             
      END IF;
  address <= conv_std_logic_vector(pixel_counter, 19);
		  
END PROCESS;
------------------------------------------------------
--Create image:
------------------------------------------------------
--PROCESS (dena, flag, registered_data)
--  BEGIN
--     IF (Hactive = '1') THEN
--       	R <= (registered_data);
--			G <= (registered_data);
--			B <= (registered_data);
--       ELSE
--			R <= (OTHERS => '1');
--			G <= (OTHERS => '1');
--			B <= (OTHERS => '1');
--     END IF;
--    
--END PROCESS;
		  
END vga_architecture;