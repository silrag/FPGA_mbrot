library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Controller is
		port(	clk, reset : in std_logic;
				cx_f, cy_f, zmag_f, iter_f,stop_f, toggle_f : in std_logic;
				
				ram_wr : out std_logic;
				cx_init, cy_init, zx_init, zy_init, iter_init, ram_data_init,zx2_init, zy2_init,stop_init,del_bar_val_init, perc_val_init,toggle_init : out std_logic;
				cx_en, cy_en, zx_en, zy_en, zx2_en, zy2_en, iter_en, zxtemp_en, zytemp_en, ram_ind_en, ram_data_en, perc_val_en,del_bar_val_en,clk_en,toggle_en : out std_logic
			);
						
end Controller;

architecture Behavioral of Controller is
	type state_type is (s_init,s_forcy1,s_forcy2,s_forcy3,s_forcx1,s_delay1,s_delay1_5,s_delay2,s_delay3,s_while1,s_while2,s_while3,s_done);
	
	signal state_reg, state_next : state_type;
	
	
begin
	
	process(clk,reset)
	begin
		if reset='1' then
			state_reg <= s_init;
		elsif rising_edge(clk) then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg,cx_f,cy_f,zmag_f,iter_f)
	begin
		state_next <= state_reg;
		cy_init <= '0';
		cx_init <= '0';
		cy_en <= '0';
		cx_en <= '0';
		zx_init <= '0';
		zy_init <= '0';
		iter_init <= '0';
		zxtemp_en <= '0';
		zytemp_en <= '0';
		zx_en <= '0';
		zy_en <= '0';
		zx2_en <= '0';
		zy2_en <= '0';
		iter_en <= '0';
		ram_data_en <= '0';
		ram_ind_en <= '0';
		ram_wr <= '0';
		ram_data_init <= '0';
		
		zx2_init <= '0';
		zy2_init <= '0';
		
		perc_val_en <= '0';
		del_bar_val_en <= '0';
		
		clk_en <= '1';
		stop_init <= '0';
		
		del_bar_val_init <= '0';
		perc_val_init <= '0';
		
		toggle_init <= '0';
		toggle_en <= '0';
		
		case state_reg is
				when s_init =>
									cy_init <= '1';
									cx_init <= '1';
									
									zx2_init <= '1';
									zy2_init <= '1';
									
									del_bar_val_init <='1';
									perc_val_init <= '1';
									
									toggle_init <= '1';
									clk_en <= '0';
									
									stop_init <= '1';
									state_next <= s_forcy1;
				when s_forcy1 =>
									if stop_f='0' then
										cy_en <= '1';
										if cy_f='1' then
											state_next <= s_done;
										else
											if toggle_f='1' then
												perc_val_en <= '1';
												del_bar_val_en <= '1';
											end if;
											state_next <= s_forcx1;
											ram_data_init <= '1';
										end if;
									else
										clk_en <= '0';
									end if;
				when s_forcy2 =>
									ram_ind_en <= '1';
									state_next <= s_forcy3;
				when s_forcy3 =>
									ram_wr <= '1';
									state_next <= s_forcy1;
									cx_init <= '1';
									toggle_en <= '1';
--									state_next <= s_done;
				when s_forcx1 =>
									cx_en <= '1';
									if cx_f='1' then
										state_next <= s_forcy2;
									else
										zx_init <= '1';
										zy_init <= '1';
										iter_init <= '1';
										state_next <= s_delay1;
									end if;
				when s_delay1 =>
									ram_ind_en <= '1';
									state_next <= s_delay1_5;
				when s_delay1_5 =>
									zx2_en <= '1';
									zy2_en <= '1';
									state_next <= s_delay2;
				when s_delay2 =>
									if zmag_f='1' then
										if zmag_f='1' then
											state_next <= s_forcx1;
										else
											state_next <= s_while3;
										end if;
									else
										if iter_f='1' then
											if zmag_f='1' then
												state_next <= s_forcx1;
											else
												state_next <= s_while3;
											end if;
										else
											state_next <= s_while1;
										end if;
									end if;										
				when s_delay3 =>
									state_next <= s_forcx1;
				when s_while1 =>
									zxtemp_en <= '1';
									zytemp_en <= '1';
									state_next <= s_while2;
				when s_while2 =>
									zx_en <= '1';
									zy_en <= '1';
									iter_en <= '1';
									state_next <= s_delay1;
				when s_while3 =>
									ram_data_en <= '1';
									state_next <= s_delay3;
				when s_done =>
									clk_en <= '0';
									if stop_f='1' then
										state_next <= s_init;
									end if;
				
			end case;
		end process;

end Behavioral;

