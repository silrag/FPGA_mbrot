library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Datapath is
				port(	clk, reset, btnS : in std_logic;
						cx_init, cy_init, zx_init, zy_init, iter_init, ram_data_init,zx2_init, zy2_init,stop_init, del_bar_val_init, perc_val_init,toggle_init : in std_logic;
						cx_en, cy_en, zx_en, zy_en, zx2_en, zy2_en, iter_en, zxtemp_en, zytemp_en, ram_ind_en, ram_data_en, perc_val_en,del_bar_val_en, toggle_en : in std_logic;
						
						cx_f, cy_f, zmag_f, iter_f, stop_f,toggle_f : out std_logic;
						
						--external to RAM
						ram_ind : out std_logic_vector(8 downto 0);
						ram_data : out std_logic_vector(600 downto 0);
						
						--external datapath outputs
						perc_val : out std_logic_vector(9 downto 0);
						del_bar_val : out std_logic_vector(9 downto 0)
						
						);
end Datapath;

architecture Behavioral of Datapath is
	
	constant cx_init_val : std_logic_vector(31 downto 0) := "1110"&"0000000000000000000000000000";--(others=> '0');	-- -2
	constant cy_init_val : std_logic_vector(31 downto 0) := "1111"&"0000000000000000000000000000";--(others=> '0');	-- -1
	
--	constant cx_init_val : std_logic_vector(31 downto 0) := "0000"&"1111001100110011001100110011";--(others=> '0');	-- -2
--	constant cy_init_val : std_logic_vector(31 downto 0) := "0000"&"0000110011001100110011001100";--(others=> '0');	-- -1
	
	constant ONE : std_logic_vector(31 downto 0) := "0001"&"0000000000000000000000000000";--(others=> '0');	-- 1
	constant TWO : std_logic_vector(31 downto 0) := "0010"&"0000000000000000000000000000";--(others=> '0');	-- 2
	
	constant TWO_HUNDERED_Q9 : std_logic_vector(36 downto 0) := "011001000"&"0000000000000000000000000000";--(others=>'0');		--Q9.28
	constant TWO_HUNDERED_Q10 : std_logic_vector(37 downto 0) := "0011001000"&"0000000000000000000000000000";--(others=>'0');		--Q10.28
	
	constant FOUR_HUNDERED : std_logic_vector(8 downto 0) := "110010000";
	
	constant ITER_MAX : unsigned(6 downto 0) := to_unsigned(70, 7);
	
	constant cx_add : std_logic_vector(31 downto 0) := "00000000000101000111101011100001";	--0.005
	constant cy_add : std_logic_vector(31 downto 0) := "00000000000101000111101011100001";	--0.005
	--"00000000000101000111101011111100" --0.0050001
	
	signal cx : std_logic_vector(31 downto 0);
	signal cy : std_logic_vector(31 downto 0);
	
	signal zx : std_logic_vector(31 downto 0);
	signal zy : std_logic_vector(31 downto 0);
	
	signal zx2 : std_logic_vector(31 downto 0);
	signal zx2_temp : std_logic_vector(63 downto 0);
	signal zy2 : std_logic_vector(31 downto 0);
	signal zy2_temp : std_logic_vector(63 downto 0);
	
	signal zxtemp : std_logic_vector(31 downto 0);
	signal zytemp_intm0 : std_logic_vector(63 downto 0);
	signal zytemp_intm1 : std_logic_vector(63 downto 0);
	signal zytemp : std_logic_vector(31 downto 0);
	
	signal iter : unsigned(6 downto 0);
	
	signal zmag_temp : std_logic_vector(31 downto 0);
	
--	signal ram_ind : std_logic_vector(8 downto 0);
--	signal ram_data : std_logic_vector(600 downto 0);
	
	--enable, init
--	signal cx_init, cy_init, zx_init, zy_init, iter_init, ram_data_init : std_logic;
--	signal cx_en, cy_en, zx_en, zy_en, zx2_en, zy2_en, iter_en, zxtemp_en, zytemp_en, ram_ind_en, ram_data_en : std_logic;
	
	--flags
--	signal cx_f, cy_f, zmag_f, iter_f : std_logic;
	
	
	--ram ind
	signal ram_ind_intm0 : std_logic_vector(31 downto 0);
	signal ram_ind_intm1 : std_logic_vector(37 downto 0);
	signal ram_ind_intm2 : std_logic_vector(75 downto 0);
	signal ram_ind_intm3 : std_logic_vector(8 downto 0);
	
	--ram data
	signal ram_data_intm0 : std_logic_vector(31 downto 0);
	signal ram_data_intm1 : std_logic_vector(36 downto 0);
	signal ram_data_intm2 : std_logic_vector(73 downto 0);
	signal ram_data_ind : std_logic_vector(9 downto 0);
	signal ram_data_intm3 : std_logic_vector(600 downto 0);
	signal ram_data_intm4 : std_logic_vector(600 downto 0);
	signal ram_data_intm5 : std_logic_vector(600 downto 0);
	
	signal stop : std_logic;
	
	--Progress bar
	signal del_bar_intm0 : unsigned(9 downto 0);
	
	signal perc_val_intm : unsigned(9 downto 0);
	
	signal toggle_intm : std_logic;
	
begin
	
	--toggle for perc_val,del_bar
	process(clk,reset)
	begin
		if reset='1' then
			toggle_intm <= '0';
		elsif toggle_init='1' then
			toggle_intm <= '0';
		elsif rising_edge(clk) then
			if toggle_en='1' then
				toggle_intm <= toggle_intm xor '1';
			end if;
		end if;
	end process;
	toggle_f <= toggle_intm;
	
	--btn toggle
	process(clk,reset,stop_init,btnS)
	begin
		if reset='1' then
			stop <= '1';
		elsif stop_init='1' then
			stop <= '1';
		elsif rising_edge(clk) then
			if btnS='1' then
				stop <= stop xor '1';
			end if;
		end if;
	end process;
	stop_f <= stop;

	--prog bar
	process(clk,reset)
	begin
		if reset='1' then
			del_bar_intm0 <= (others=>'0');
		elsif del_bar_val_init='1' then
			del_bar_intm0 <= (others=> '0');
		elsif rising_edge(clk) then
			if del_bar_val_en='1' then
				del_bar_intm0 <= del_bar_intm0+1;
			end if;
		end if;
	end process;
	del_bar_val <= std_logic_vector(del_bar_intm0);
	
	--percentage val reg
	process(clk,reset)
	begin
		if reset='1' then
			perc_val_intm <= (others=> '0');
		elsif perc_val_init='1' then
			perc_val_intm <= (others => '0');
		elsif rising_edge(clk) then
			if perc_val_en='1' then
				if perc_val_intm/=999 then
					perc_val_intm <= perc_val_intm+5;
				end if;
			end if;
		end if;
	end process;
	perc_val <= std_logic_vector(perc_val_intm);
			
	
	--counters cx/cy
	process(clk,reset,cx_init)
	begin
		if reset='1' then
			cx <= cx_init_val;
		elsif cx_init='1' then
			cx <= cx_init_val;
		elsif rising_edge(clk) then
			if cx_en='1' then
				cx <= std_logic_vector(unsigned(cx) + unsigned(cx_add));
			end if;
		end if;	
	end process;
	process(clk,reset,cx_init)
	begin		
		if reset='1' then
			cy <= cy_init_val;
		elsif cy_init='1' then
			cy <= cy_init_val;
		elsif rising_edge(clk) then
			if cy_en='1' then
				cy <= std_logic_vector(unsigned(cy) + unsigned(cy_add));
			end if;
		end if;
	end process;
	
	cx_f <= '1' when signed(cx(31 downto 28))=1 else '0';
	cy_f <= '1' when signed(cy(31 downto 28))=1 else '0';
	
	--registers zx,zy
	process(clk,reset,zx_init)
	begin	
		if reset='1' then
			zx <= (others => '0');
--		elsif zx_init='1' then
--			zx <= (others => '0');
		elsif rising_edge(clk) then
			if zx_init='1' then
				zx <= (others => '0');
			elsif zx_en='1' then
				zx <= zxtemp;
			end if;
		end if;
	end process;	
	process(clk,reset,zy_init)
	begin
		if reset='1' then
			zy <= (others => '0');
--		elsif zy_init='1' then
--			zy <= (others => '0');
		elsif rising_edge(clk) then
			if zy_init='1' then
				zy <= (others => '0');
			elsif zy_en='1' then
				zy <= zytemp;
			end if;
		end if;
	end process;
		
	
	--registers zx2/zy2
	process(clk,reset)
	begin
		if reset='1' then
			zx2 <= (others => '0');
		elsif zx2_init='1' then
			zx2 <= (others => '0');
		elsif rising_edge(clk) then
			if zx2_en='1' then
				zx2 <= zx2_temp(59 downto 28);
			end if;
		end if;
	end process;
	process(clk,reset)
	begin
		if reset='1' then
			zy2 <= (others => '0');
		elsif zy2_init='1' then
			zy2 <= (others => '0');
		elsif rising_edge(clk) then
			if zy2_en='1' then
				zy2 <= zy2_temp(59 downto 28);
			end if;
		end if;
	end process;
	zx2_temp <= std_logic_vector(signed(zx)*signed(zx));
	zy2_temp <= std_logic_vector(signed(zy)*signed(zy));
	
	zmag_temp <= std_logic_vector(unsigned(zx2) + unsigned(zy2));
	zmag_f <= '1' when signed(zmag_temp(31 downto 28))>=4 else '0'; 
	
	--registers zxtemp/zytemp
	process(clk,reset)
	begin		
		if reset='1' then
			zxtemp <= (others => '0');
		elsif rising_edge(clk) then
			if zxtemp_en='1' then
				zxtemp <= std_logic_vector(unsigned(zx2) - unsigned(zy2) + unsigned(cx));
			end if;
		end if;
	end process;
	process(clk, reset)
	begin
		if reset='1' then
			zytemp <= (others => '0');
		elsif rising_edge(clk) then
			if zytemp_en='1' then
				--zytemp_intm0 <= std_logic_vector(signed(zx)*signed(TWO));
				--zytemp_intm0(59) <= zytemp_intm0(63);
				--zytemp_intm1 <= std_logic_vector(signed(zy)*signed(zytemp_intm0(59 downto 28)));
				--zytemp_intm1(59) <= zytemp_intm1(63);
				zytemp <= std_logic_vector(unsigned(zytemp_intm1(63)&zytemp_intm1(58 downto 28)) + unsigned(cy));
			end if;
		end if;
	end process;
	zytemp_intm0 <= std_logic_vector(signed(zx)*signed(TWO));
	zytemp_intm1 <= std_logic_vector(signed(zy)*signed(zytemp_intm0(63)&zytemp_intm0(58 downto 28)));
	
	--register iter
	process(clk,reset)
	begin
		if reset='1' then
			iter <= (others => '0');
		elsif iter_init='1' then
			iter <= (others => '0');
		elsif rising_edge(clk) then
			if iter_en='1' then
				iter <= iter + "01";
			end if;
		end if;
	end process;
	
	iter_f <= '1' when iter=ITER_MAX else '0';
	
	--RAM_IND
	process(clk,reset)
	begin
		if reset='1' then
			ram_ind <= (others => '0');
		elsif rising_edge(clk) then
			if ram_ind_en='1' then
				ram_ind <= ram_ind_intm3;
				--ram_ind <= 400 - 200*(cy+1);
			end if;
		end if;
	end process;
	
	--eq. = 400 - 200(cy+1)
	ram_ind_intm0 <= std_logic_vector(unsigned(cy) + unsigned(ONE));			
	ram_ind_intm1 <= (37 downto 32 => '0') & ram_ind_intm0;		--Q10.28 [37 downto 0],   append bits
	ram_ind_intm2 <= std_logic_vector(unsigned(ram_ind_intm1) * unsigned(TWO_HUNDERED_Q10));			--results in Q20.56  [75  downto 0]
	ram_ind_intm3 <= std_logic_vector(unsigned(FOUR_HUNDERED) - unsigned(ram_ind_intm2(64 downto 56)));			--9 integer bits
	
	--ram_data
	process(clk, reset,ram_data_init)
	begin
		if reset='1' then
			ram_data <= (others => '0');
--			ram_data_intm4 <= (others => '0');
		elsif ram_data_init='1' then
			ram_data <= (others => '0');
--			ram_data_intm4 <= (others => '0');
		elsif rising_edge(clk) then
			if ram_data_en ='1' then
				ram_data(to_integer(unsigned(ram_data_ind))) <= '1';
--				ram_data_intm5 <= (600 => '1', others=>'0');
--				ram_data_intm3 <= std_logic_vector(shift_right(unsigned(ram_data_intm5),to_integer(unsigned(ram_data_ind))));--(600 => '1', others=>'0') srl to_integer(unsigned(ram_data_ind));
--				ram_data_intm4 <= ram_data_intm4 or ram_data_intm3;
				
				--ram_data <= 200*(cx+2);
			end if;
		end if;
	end process;
	--ram_data <= ram_data_intm4;
	
	--eq. = 200(cx+2)
	ram_data_intm0 <= std_logic_vector(unsigned(cx) + unsigned(TWO));			
	ram_data_intm1 <= (36 downto 32 => '0') & ram_data_intm0;		--Q9.28 [36 downto 0],   append bits
	ram_data_intm2 <= std_logic_vector(unsigned(ram_data_intm1) * unsigned(TWO_HUNDERED_Q9));			--results in Q18.56  [73  downto 0]
	ram_data_ind <= ram_data_intm2(65 downto 56);
	


end Behavioral;

