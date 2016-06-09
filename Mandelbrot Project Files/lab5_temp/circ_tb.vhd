
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY circ_tb IS
END circ_tb;
 
ARCHITECTURE behavior OF circ_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pong_graph_st
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         video_on : IN  std_logic;
         pixel_x : IN  std_logic_vector(9 downto 0);
         pixel_y : IN  std_logic_vector(9 downto 0);
         sw : IN  std_logic_vector(7 downto 0);
         btnS : IN  std_logic;
			
--			ram_wr_cont : OUT std_logic;
         graph_rgb : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal video_on : std_logic := '1';
   signal pixel_x : std_logic_vector(9 downto 0) := (others => '0');
   signal pixel_y : std_logic_vector(9 downto 0) := (others => '0');
   signal sw : std_logic_vector(7 downto 0) := (others => '0');
   signal btnS : std_logic := '0';

 	--Outputs
   signal graph_rgb : std_logic_vector(2 downto 0);
	signal ram_wr_cont : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pong_graph_st PORT MAP (
          clk => clk,
          reset => reset,
          video_on => video_on,
          pixel_x => pixel_x,
          pixel_y => pixel_y,
          sw => sw,
          btnS => btnS,
--			 ram_wr_cont => ram_wr_cont,
          graph_rgb => graph_rgb
        );

--   -- Clock process definitions
--   clk_process :process
--   begin
--		clk <= '0';
--		wait for clk_period/2;
--		clk <= '1';
--		wait for clk_period/2;
--   end process;

	clk <= not clk after clk_period;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      --wait for 100 ns;	

      --wait for clk_period;
		wait until ram_wr_cont='1';

      -- insert stimulus here 

      --wait;
   end process;

END;
