---------------------------
-- Testbench for VGA TOP --
-- VGA Testing : 640 x 480 resolution
------------------------------------- 
-- input clock CLOCK_50 : 50Mhz 
-- VGA Clock   : 25.174Mhz
--------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_arith.ALL; 
USE std.env.stop;

ENTITY tb_VGA_TOP IS
END tb_VGA_TOP;

ARCHITECTURE testing_vga OF tb_VGA_TOP IS 
COMPONENT VGA_Top
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
			 
END COMPONENT;
--------------------------------
SIGNAL clktb, vga_hs_tb, vga_vs_tb, vga_blank_tb, vga_sunc_tb :  std_logic;
SIGNAL vga_clk_tb    :  std_logic; 
SIGNAL key_tb     :  std_logic_vector(3 downto 0);
SIGNAL vga_r_tb   :  std_logic_vector(7 downto 0);
SIGNAL sw_tb      :  std_logic_vector(17 downto 0);
SIGNAL vga_b_tb   :  std_logic_vector(7 downto 0);
SIGNAL vga_g_tb   :  std_logic_vector(7 downto 0);
CONSTANT CLOCK_TP : time:= 20 ns;
CONSTANT Ha: INTEGER := 96; --Hpulse
CONSTANT	Hb: INTEGER := 144; --Hpulse+HBP
CONSTANT	Hc: INTEGER := 784; --Hpulse+HBP+Hactive
CONSTANT	Hd: INTEGER := 800; --Hpulse+HBP+Hactive+HFP
CONSTANT	Va: INTEGER := 2; --Vpulse
CONSTANT	Vb: INTEGER := 35; --Vpulse+VBP
CONSTANT	Vc: INTEGER := 515; --Vpulse+VBP+Vactive
CONSTANT	Vd: INTEGER := 525; --Vpulse+VBP+Vactive+VFP
-----------------------------------------------------

BEGIN


-------------------------------------------------
key_tb(0) <= '1','0' after 5us, '1' after 11us;

sw_tb(3 downto 0) <= "0000";
-- Instantiate the Unit Under Test (UUT)
	
uut: VGA_Top PORT MAP(
			          CLOCK_50 => clktb,
					  KEY      => key_tb,
					  SW       => sw_tb,
					  VGA_R    => vga_r_tb,
					  VGA_G    => vga_g_tb,
					  VGA_B    => vga_b_tb,
					  VGA_HS   => vga_hs_tb,
					  VGA_VS   => vga_vs_tb,
					  VGA_CLK  => vga_clk_tb,
					  VGA_BLANK_N => vga_blank_tb, 
					  VGA_SYNC_N  => vga_sunc_tb);
--------------------------------------------------
--------------------------------------------------
-- Horizontal Sync Verification
--------------------------------------------------
h_sync_check : process
    variable pixel_count : integer := 0;
    variable line_count  : integer := 0;
begin
    wait until falling_edge(vga_hs_tb);
	 -- Count pixel clocks while HSYNC is low
    while vga_hs_tb = '0' loop
        wait until rising_edge(vga_clk_tb);
        pixel_count := pixel_count + 1;
    end loop;
	 ---------------------------------------
	 -- Count pixel clocks while HSYNC is High
	 wait until rising_edge(vga_hs_tb);
    while vga_hs_tb = '1' loop
        wait until rising_edge(vga_clk_tb);
        pixel_count := pixel_count + 1;
    end loop;
	 -------------------------------
    wait until falling_edge(vga_hs_tb);
	 pixel_count := pixel_count;
	 -- Detect falling edge of HSYNC (start of new line)
    if pixel_count = Hd  then
        report "Line " & integer'image(line_count) &
               " completed with " & integer'image(pixel_count) & " pixels";

    -- Check against expected horizontal total
    if pixel_count /= Hd then
            report "<< ERROR: Horizontal pixel count mismatch. Expected >>" &
                   integer'image(Hd) & " got " & integer'image(pixel_count)
                   severity error;
        end if;

        pixel_count := 0;
        line_count  := line_count + 1;
    end if;
end process;

--------------------------------------------------
-- Vertical Sync Verification
--------------------------------------------------
v_sync_check : process
    variable frame_lines : integer := 0;
begin
    wait until falling_edge(vga_vs_tb); -- start of vertical sync

    frame_lines := 0;
    report "Vertical sync detected: starting frame";

    -- Count lines until next VSYNC pulse
    while vga_vs_tb = '0' loop
        wait until rising_edge(vga_hs_tb);
        frame_lines := frame_lines + 1;
    end loop;

    report "Frame completed with " & integer'image(frame_lines) & " lines";

    -- Check against expected vertical total
    if frame_lines /= Vd then
        report "ERROR: Vertical line count mismatch. Expected " &
               integer'image(Vd) & " got " & integer'image(frame_lines)
               severity error;
    end if;
end process;
-------------------------
vga_frame_complete: process
begin
    wait until vga_vs_tb = '0';
	 wait until vga_vs_tb = '1';
    report "## -- >> Simulation stopped: VGA Frame complete <<-- ##";
    stop;
  
end process;
-------------------------- 
-- Synchronous Clock = 5Mhz
Clock_gen : process
begin
    wait for CLOCK_TP/2;
    clktb <= '0';
    wait for CLOCK_TP/2;
    clktb <= '1';
end process;
end;   