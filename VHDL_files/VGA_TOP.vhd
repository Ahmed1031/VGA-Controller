------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
-- VGA TOP ---------
entity VGA_Top is
    port (
	    CLOCK_50 : in std_logic;
	    KEY      : in std_logic_vector ( 3 downto 0 );  
		 SW       : in std_logic_vector ( 17 downto 0 );    
         -- VGA ports --
		 VGA_R       : out std_logic_vector ( 7 downto 0 );  
		 VGA_G       : out std_logic_vector ( 7 downto 0 );
		 VGA_B       : out  std_logic_vector ( 7 downto 0 );
		 VGA_HS      : out std_logic;
		 VGA_VS      : out std_logic;
		 VGA_CLK     : out std_logic;
		 VGA_BLANK_N : out std_logic;
		 VGA_SYNC_N  : out std_logic);
		 	  
end VGA_Top;
-------------------------------------------------------
architecture video_processing of  VGA_Top is 
--
   constant Ha: INTEGER := 96;  --Hpulse
	constant Hb: INTEGER := 144; --Hpulse+HBP
	constant Hc: INTEGER := 784; --Hpulse+HBP+Hactive
	constant Hd: INTEGER := 800; --Hpulse+HBP+Hactive+HFP
	constant Va: INTEGER := 2;   --Vpulse
	constant Vb: INTEGER := 35;  --Vpulse+VBP
	constant Vc: INTEGER := 515; --Vpulse+VBP+Vactive
	constant Vd: INTEGER := 525; --Vpulse+VBP+Vactive+VFP
	signal clk_25mhz, pll_locked : std_logic;
	-----------------------------------------
	component vga_pll2 is
                 port(
							areset : IN STD_LOGIC;  
							inclk0 : IN STD_LOGIC; 
							c0     : OUT STD_LOGIC; 
							locked : OUT STD_LOGIC 
							);
	end component;
	-----------------------------------------

  begin 
  
  
   -- VGA CLOCK PLL --
	U2_PLL : vga_pll2
	        port map (
			            areset => not(KEY(0)),
	                  inclk0 => CLOCK_50,
	                  c0     => clk_25mhz,
                     locked => pll_locked
							);
	---------------------------------------						
	-- VGA Controller --						  
	U1_VGA : entity work.vga_demo
        generic map (
         Ha => Ha,
			Hb => Hb,
			Hc => Hc,
			Hd => Hd,
			Va => Va,
			Vb => Vb,
			Vc => Vc,
			Vd => Vd		
        )
        port map (
            pixel_clk_i  => clk_25mhz,
            red_switch   => SW(0),
            green_switch => SW(1),
			   blue_switch  => SW(2),
			   pixel_clk_o  => VGA_CLK,
			   Hsync        => VGA_HS,
			   Vsync        => VGA_VS,
				R            => VGA_R,
			   G            => VGA_G,
			   B            => VGA_B,
			   nblanck      => VGA_BLANK_N,
            nsync        => VGA_SYNC_N); 			
			
end video_processing; 			
			
			
			
			
		
	
