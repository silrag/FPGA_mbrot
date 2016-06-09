library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
		port (clk, reset : in std_logic;
				raddr, waddr : in std_logic_vector(8 downto 0);
				din : in std_logic_vector(600 downto 0);
				we : in std_logic;
				dout : out std_logic_vector(600 downto 0)
				);
end RAM;

architecture Behavioral of RAM is
	type ram_type is array (0 to (2**9)-1) of std_logic_vector(600 downto 0);
	
	signal mem : ram_type;
	signal raddr_ind : integer range 0 to (2**9)-1;
	signal waddr_ind : integer range 0 to (2**9)-1;

begin
	
--	waddr_ind <= to_integer(unsigned(waddr));
--	raddr_ind <= to_integer(unsigned(raddr));
	
	process(clk)
	begin
		 if rising_edge(clk) then
			if we='1' then
				waddr_ind <= to_integer(unsigned(waddr));
				mem(waddr_ind) <= din;
			end if;
			raddr_ind <= to_integer(unsigned(raddr));
			dout <= mem(raddr_ind);
		end if;
	end process;
	
	
end Behavioral;


---- A parameterized, inferable, true dual-port, dual-clock block RAM in VHDL.
-- 
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
-- 
--entity bram_tdp is
--generic (
--    DATA    : integer := 72;
--    ADDR    : integer := 10
--);
--port (
--    -- Port A
--    a_clk   : in  std_logic;
--    a_wr    : in  std_logic;
--    a_addr  : in  std_logic_vector(ADDR-1 downto 0);
--    a_din   : in  std_logic_vector(DATA-1 downto 0);
--    a_dout  : out std_logic_vector(DATA-1 downto 0);
--     
--    -- Port B
--    b_clk   : in  std_logic;
--    b_wr    : in  std_logic;
--    b_addr  : in  std_logic_vector(ADDR-1 downto 0);
--    b_din   : in  std_logic_vector(DATA-1 downto 0);
--    b_dout  : out std_logic_vector(DATA-1 downto 0)
--);
--end bram_tdp;
-- 
--architecture rtl of bram_tdp is
--    -- Shared memory
--    type mem_type is array ( (2**ADDR)-1 downto 0 ) of std_logic_vector(DATA-1 downto 0);
--    shared variable mem : mem_type;
--begin
-- 
---- Port A
--process(a_clk)
--begin
--    if(a_clk'event and a_clk='1') then
--        if(a_wr='1') then
--            mem(conv_integer(a_addr)) := a_din;
--        end if;
--        a_dout <= mem(conv_integer(a_addr));
--    end if;
--end process;
-- 
---- Port B
--process(b_clk)
--begin
--    if(b_clk'event and b_clk='1') then
--        if(b_wr='1') then
--            mem(conv_integer(b_addr)) := b_din;
--        end if;
--        b_dout <= mem(conv_integer(b_addr));
--    end if;
--end process;
-- 
--end rtl;