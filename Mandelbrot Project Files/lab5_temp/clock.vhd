library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock is
		port(clk : in std_logic;
			  reset	: in std_logic;
			  
			  clk_en : in std_logic;
			  
			  min_out : out std_logic_vector(6 downto 0);
			  sec_out : out std_logic_vector(6 downto 0);
			  hos_out : out std_logic_vector(6 downto 0)			  
			);
end clock;

architecture Behavioral of clock is
		--produce 10 milli sec tick
		
		constant PERIOD : unsigned(19 downto 0) := to_unsigned(1024000, 20);		--10 msec constant
		constant HOS_MAX : unsigned(6 downto 0) := to_unsigned(99, 7);
		constant SEC_MAX : unsigned(6 downto 0) := to_unsigned(59, 7);
		
		--constant TOS_MAX : unsigned(
		
		signal count : unsigned(19 downto 0);
		signal tick : std_logic;
		signal min, sec, hos, min_next, sec_next, hos_next : unsigned(6 downto 0);
		
begin
	min_out <= std_logic_vector(min);
	sec_out <= std_logic_vector(sec);
	hos_out <= std_logic_vector(hos);			--hos 1st dig = tenths of a sec.
	
	process(clk, reset)
	begin
		if reset='1' then
			count <= (others => '0');
		elsif rising_edge(clk) then
			if clk_en='1' then
				if count=PERIOD then
					count <= (others => '0');
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
	
	tick <= '1' when count=PERIOD else '0';		--10 msec tick
	
	--registers
	process(clk, reset)
	begin
		if reset='1' then 
			min <= (others => '0');
			sec <= (others => '0');
			hos <= (others => '0');
		elsif rising_edge(clk) then
			min <= min_next;
			sec <= sec_next;
			hos <= hos_next;
		end if;
	end process;
	
	--timer
	process(tick, hos, sec, min)
	begin
		hos_next <= hos;
		sec_next <= sec;
		min_next <= min;
		if rising_edge(tick) then
			hos_next <= hos+1;
			if hos_next=HOS_MAX then
				hos_next <= (others => '0');
				sec_next <= sec+1;
				if sec_next=SEC_MAX then
					sec_next <= (others => '0');
					min_next <= min+1;
				end if;
			end if;
		end if;
	end process;
							


end Behavioral;

