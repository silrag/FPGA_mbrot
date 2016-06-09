library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity man_graph is
		port(	clk, reset : in std_logic;
				pixel_x, pixel_y : in std_logic_vector;
				ram_out : in std_logic_vector(902 downto 0);
				sw : in std_logic_vector(7 downto 0);
				
				ram_raddr : out std_logic_vector(7 downto 0);
				man_graph_on : out std_logic;
				man_graph_rgb : out std_logic_vector(2 downto 0)		
			);
end man_graph;

architecture Behavioral of man_graph is
	
	signal pix_x, pix_y: unsigned(9 downto 0);
	
	constant g_top : unsigned(7 downto 0) := to_unsigned(40, 8);
	constant g_left : unsigned(9 downto 0) := to_unsigned(20, 10);
	
	constant THREE : unsigned(9 downto 0) := to_unsigned(3, 10);
	
	signal col : unsigned(19 downto 0);
	signal ram_col : unsigned(9 downto 0);
	signal ram_bit : std_logic;
	
--	signal graph_region_on;
	
	
begin
	
	pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);	

	man_graph_on <= '1' when (40<=pix_y) and (pix_y<=240) and
										(20<=pix_x) and (pix_x<=320) else
								'0'; 

	ram_raddr <= std_logic_vector(pix_y(7 downto 0) - g_top(7 downto 0));
	col <= unsigned(pix_x - g_left)*THREE;
	ram_col <= col(9 downto 0);
--	ram_bit <= ram_out(to_integer(ram_col));
--	ram_bit <= ram_out(to_integer(ram_col)) when ram_col<=600 else '0';

	
	man_graph_rgb <= ram_out(to_integer(ram_col)) & ram_out(to_integer(ram_col+1)) & ram_out(to_integer(ram_col+2));
	
--	man_graph_rgb <= "100" when ram_bit='1' else		--Red
--							"010";				--Green
--	process(ram_bit, sw)
--	begin
--		if ram_bit='1' then
--			if sw(7)='1' then
--				man_graph_rgb <= "110";		--Yellow
--			elsif sw(6)='1' then
--				man_graph_rgb <= "001";		--Blue
--			elsif sw(5)='1' then
--				man_graph_rgb <= "010";		--Green
--			elsif sw(4)='1' then
--				man_graph_rgb <= "011";		--Cyan
--			elsif sw(3)='1' then
--				man_graph_rgb <= "100";		--Red
--			elsif sw(2)='1' then
--				man_graph_rgb <= "111";		--White
--			elsif sw(1)='1' then
--				man_graph_rgb <= "100";		--Red
--			else
--				man_graph_rgb <= "000";		--Black
--			end if;
--		else
--			if sw(7)='1' then
--				man_graph_rgb <= "001";		--Blue
--			elsif sw(6)='1' then
--				man_graph_rgb <= "100";		--Red
--			elsif sw(5)='1' then
--				man_graph_rgb <= "000";		--Black
--			elsif sw(4)='1' then
--				man_graph_rgb <= "111";		--White
--			elsif sw(3)='1' then
--				man_graph_rgb <= "000";		--Black
--			elsif sw(2)='1' then
--				man_graph_rgb <= "001";		--Blue
--			elsif sw(1)='1' then
--				man_graph_rgb <= "110";		--Yellow
--			else
--				man_graph_rgb <= "111";		--White
--			end if;
--		end if;
--	end process;


end Behavioral;

