library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
	port (	clk	: in std_logic;
				--reset	: in std_logic;
				sw : in std_logic_vector(7 downto 0);
				btn : in std_logic;
				
				hsync	: out std_logic;
				vsync	: out std_logic;
				rgb	: out std_logic_vector(2 downto 0)
			);
end top;

architecture Behavioral of top is

signal video_on : std_logic;
signal p_tick : std_logic;
signal pixel_x : std_logic_vector(9 downto 0);
signal pixel_y : std_logic_vector(9 downto 0);
signal rgb_reg, rgb_next : std_logic_vector(2 downto 0);

signal btnS : std_logic;
signal btn_intm : std_logic;

signal reset : std_logic;

begin
	reset <= '0';
	
	--debouncer
	debounce_mod: entity work.debouncer port map(clk=>clk, rst=>reset, input=>btn, output=>btn_intm);
	
	--RED
	red_mod : entity work.red port map (clk=>clk, rst=>reset, input=>btn_intm, output=>btnS);
	
	VGA_SYNC_MOD: entity work.vga_sync port map(clk=>clk, reset=>reset, hsync=>hsync, vsync=>vsync, video_on=>video_on, p_tick=>p_tick, pixel_x=>pixel_x, pixel_y=>pixel_y);
	--PIX_CIRC: entity work.pong_graph_st port map(clk=>clk, reset=>reset,btn=>(btnU & btnD & btnL & btnR), video_on=>video_on, pixel_x=>pixel_x, pixel_y=>pixel_y, sw=>sw(0), sw_time=>sw(2 downto 1), graph_rgb=>rgb_next);
	PIX_CIRC: entity work.pong_graph_st port map(clk=>clk, reset=>reset, btnS=>btnS, video_on=>video_on, pixel_x=>pixel_x, pixel_y=>pixel_y, sw=>sw, graph_rgb=>rgb_next);
	
	--rgb_buffer
	process(clk, reset)
	begin
		if rising_edge(clk) then
			if p_tick='1' then
			rgb_reg <= rgb_next;
			end if;
		end if;
	end process;
	
	rgb <= rgb_reg;
	
end Behavioral;

