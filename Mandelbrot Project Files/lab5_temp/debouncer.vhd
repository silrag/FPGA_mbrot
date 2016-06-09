-- --==========================
-- Debouncer.vhd
-- Author: Umar Sharif
--=============================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--========================================================================
-- Note: Generics
-- k - width of the counter used to measure the debouncing period
-- DD - debouncing period in clock cycles
-- Values of generics given below assume that the clock frequency = 100 MHz
-- and thus clock period = 10 ns.

-- Option 1 (used for simulation):
	-- DD = 100, -- bouncing period < 1000 ns (condition: DD*10ns = 1000 ns)
	-- k=7 -- 2^7 > 100

-- Option 2 (used for synthesis, implementation, and experimental testing):
	-- DD = 10000000, -- bouncing period = 10 ms (condition: DD*10ns = 10ms)
	-- k=24 -- 2^24 > 10,000,000 (condition - 2^k > DD)
--========================================================================

entity debouncer is
	generic (
		-- generics k and DD used for simulation
		-- change them accordingly for synthesis, implementation, and experimental testing
		-- k : integer := 7;		
		-- DD : integer := 100	

		-- generics k and DD used for synthesis, implementation, and experimental testing
		-- change them accordingly for simulation
		k : integer := 24;		
		DD : integer := 10000000	
	); 
    port ( 
			-- inputs
			clk 	:	in 	std_logic;
			rst	:	in 	std_logic;
			input	:	in 	std_logic;
			
			-- outputs
			output	: 	out  std_logic
		); 
end debouncer;

architecture rtl of debouncer is

	-- intermediate signals 	
	signal set : std_logic;
	signal rst_count : std_logic;
	signal count : std_logic;
	signal counter_out : std_logic_vector(k-1 downto 0);
	signal xor_out : std_logic; 
	signal mux_out : std_logic; 
	signal output_sig : std_logic; 
	signal prev_input : std_logic; 
	signal DD_check : std_logic; 
	
begin
	-- D flip-flop
	D_FF1 : process (clk)
	begin
		if rising_edge(clk) then 
			prev_input <= input;
		end if;		
	end process;

	xor_out <= input xor prev_input;
	set <= xor_out and (not (count)); 

	-- Set reset D flip flop
	SR_D_FF : process (rst_count, clk)
	begin
		if(rst_count = '1') then
			count <= '0';
		elsif rising_edge (clk) then
			if(set = '1') then
				count <= '1';
			else
				count <= count;
			end if;
		end if;
	end process;

	mux_out <= input when count = '0' else output_sig;

	-- D flip-flop
	D_FF2 : process (clk)
	begin
		if rising_edge(clk) then 
			output_sig <= mux_out;
		end if;		
	end process;
	output <= output_sig;

	rst_count <= rst or DD_check;
	
	-- counter
	count_up : process (rst_count, clk)
	begin
		if(rst_count = '1') then
			counter_out <= (others => '0');
		elsif rising_edge(clk) then 
			if(count = '1') then
				counter_out <= counter_out + 1;
			end if;
		end if;		
	end process;
	
	-- check if count = DD-1
	DD_check <= '1' when (conv_integer(counter_out) = DD-1) else '0';
	
end rtl;