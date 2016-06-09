--====================
-- RED component
-- Author: Umar Sharif
--====================

library ieee;
use ieee.std_logic_1164.all;

entity red is
    port ( 
			-- inputs
			clk 	: 	in 	std_logic;
			rst		:	in 	std_logic;
			input 	:	in 	std_logic;
			
			-- outputs
			output	: 	out  std_logic
		); 
end red;

architecture mixed of red is

	-- intermediate signals 
	signal prev_input : std_logic;
	
begin
	delay : process (rst, clk)
	begin
		if (rst = '1') then
			prev_input <= '0';
		elsif rising_edge(clk) then
			prev_input <= input;
		end if;
	end process;
	
	output <= input and (not prev_input);
end mixed;