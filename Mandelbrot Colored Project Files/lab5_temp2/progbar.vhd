library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity progbar is
		port(	clk, reset : in std_logic;
				pixel_x, pixel_y : in std_logic_vector;
				
				del_bar_val : in std_logic_vector(9 downto 0);
				
				progbar_on : out std_logic;
				progbar_rgb : out std_logic_vector(2 downto 0)		
			);
end progbar;

architecture Behavioral of progbar is
	
	signal pix_x, pix_y: unsigned(9 downto 0);
	
	constant BAR_TOP : unsigned(9 downto 0) := to_unsigned(450, 10);
	constant BAR_BOTTOM : unsigned(9 downto 0) := BAR_TOP+10-1;
	constant BAR_LEFT : unsigned(9 downto 0) := to_unsigned(200, 10);
	
	signal bar_right: unsigned(9 downto 0);
	
--	constant bar_right: unsigned(9 downto 0):= BAR_LEFT+200;

--	constant BAR_TOP : integer := 450;
--	constant BAR_BOTTOM : integer := BAR_TOP+10-1;
--	constant BAR_LEFT : integer := 200;
--	
--	constant bar_right: integer:= BAR_LEFT+200;
	
	
begin
	pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);

	bar_right <= BAR_LEFT + unsigned(del_bar_val);
	
	progbar_on <= '1' when (BAR_TOP<=pix_y) and (pix_y<=BAR_BOTTOM) and
								  (BAR_LEFT<=pix_x) and (pix_x<=bar_right) else
						'0';
--	progbar_on <= '0';
	
	progbar_rgb <= "101";

end Behavioral;

