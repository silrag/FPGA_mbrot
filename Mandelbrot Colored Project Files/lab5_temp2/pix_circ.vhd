library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

entity pong_graph_st is
   port(	clk : in std_logic;
			reset : in std_logic;
			video_on: in std_logic;
			pixel_x,pixel_y: in std_logic_vector(9 downto 0);
			sw : in std_logic_vector(7 downto 0);
			btnS : in std_logic;
			
			--ram_wr_cont : out std_logic;
			
			graph_rgb: out std_logic_vector(2 downto 0)
   );
end pong_graph_st;

architecture sq_ball_arch of pong_graph_st is
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
	
	 --TEXT
	 signal text_rgb : std_logic_vector(2 downto 0);
	 signal text_on :  std_logic;
	 
	 --RAM
	 signal raddr, waddr : std_logic_vector(7 downto 0);
	 signal din, dout : std_logic_vector(902 downto 0);
	 signal we : std_logic;
	 
	 --MAN_GRAPH
	 signal man_graph_on : std_logic;
	 signal man_graph_rgb : std_logic_vector(2 downto 0);
	 
	 --Datapath
	 signal cx_init, cy_init, zx_init, zy_init, iter_init, ram_data_init,zx2_init, zy2_init, stop_init,del_bar_val_init, perc_val_init,toggle_init : std_logic;
	 signal cx_en, cy_en, zx_en, zy_en, zx2_en, zy2_en, iter_en, zxtemp_en, zytemp_en, ram_ind_en, ram_data_en, perc_val_en, del_bar_val_en,toggle_en : std_logic;
	 signal cx_f, cy_f, zmag_f, iter_f, stop_f,toggle_f : std_logic;
	 signal perc_val, del_bar_val : std_logic_vector(9 downto 0);
	 
	 --PROG BAR
	 signal progbar_on : std_logic;
	 signal progbar_rgb : std_logic_vector(2 downto 0);
	 
	 --digits
	 signal perc_val_dig3,perc_val_dig2,perc_val_dig1,perc_val_dig0,sec_dig1, sec_dig0, hos_dig1 : std_logic_vector(3 downto 0);
	 
	 --Clock
	 signal clk_en : std_logic;
	 signal sec_out : std_logic_vector(6 downto 0);
	 signal hos_out : std_logic_vector(6 downto 0);
	
--	 --CLOCK
--	 signal sec_out : std_logic_vector(6 downto 0);
--	 signal hos_out : std_logic_vector(6 downto 0);
--	 signal min_out : std_logic_vector(6 downto 0);
--	 signal min_dig1, min_dig0, sec_dig1, sec_dig0, hos_dig1, hos_dig0 : std_logic_vector(3 downto 0);
--	 
--	 --TIME TEXT
--	 signal time_text_on : std_logic;
--	 signal time_text_rgb : std_logic_vector(2 downto 0);
--	 
--	 --DISP TEXT
--	 signal disp_text_on : std_logic;
--	 signal disp_text_rgb : std_logic_vector(2 downto 0);
--	 
--	 
--	 --registers
--	 signal score_reg, score_next, lives_reg, lives_next : unsigned(6 downto 0);
--	 signal score_dig1, score_dig0, lives_dig0: std_logic_vector(3 downto 0);
begin
	perc_val_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(perc_val) mod 10), 4));
	perc_val_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(perc_val) / 10) mod 10),4));
	perc_val_dig2 <= std_logic_vector(to_unsigned(to_integer((unsigned(perc_val) / 100) mod 10),4));
	perc_val_dig3 <= std_logic_vector(to_unsigned(to_integer((unsigned(perc_val) / 1000) mod 10),4));
	
	sec_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(sec_out) mod 10), 4));
	sec_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(sec_out) / 10) mod 10),4));
	hos_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(hos_out) / 10) mod 10),4));
	
--	score_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(score_reg) mod 10), 4));
--	score_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(score_reg) / 10) mod 10),4));
--	
--	lives_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(lives_reg) mod 10), 4));
--	
--	btnU <= btn(3);
--	btnD <= btn(2);
--	btnL <= btn(1);
--	btnR <= btn(0);
--	
--	sec_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(sec_out) mod 10), 4));
--	sec_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(sec_out) / 10) mod 10),4));
--	
--	min_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(min_out) mod 10), 4));
--	min_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(min_out) / 10) mod 10),4));
--	
--	hos_dig0 <= std_logic_vector(to_unsigned(to_integer(unsigned(hos_out) mod 10), 4));
--	hos_dig1 <= std_logic_vector(to_unsigned(to_integer((unsigned(hos_out) / 10) mod 10),4));
--	
--	CLK_OBJ: entity work.clock port map(clk=>clk,reset=>reset,min_out => min_out, sec_out=>sec_out, hos_out=>hos_out);
--	TIME_TEXT_OBJ: entity work.time_text port map(clk=>clk,reset=>reset,pixel_x=>pixel_x, pixel_y=>pixel_y,sw=>sw_time, min_dig0=>min_dig0, sec_dig1=>sec_dig1, sec_dig0=>sec_dig0, hos_dig1=>hos_dig1, hos_dig0=>hos_dig0, text_on=>time_text_on, text_rgb=>time_text_rgb);
--	--DISP_TEXT_OBJ: entity work.disp_text port map(clk=>clk,reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y, sw=>sw_time,score_dig1=>score_dig1, score_dig0=>score_dig0, lives_dig0=>lives_dig0, text_on=>disp_text_on, text_rgb=>disp_text_rgb);
--	DISP_TEXT_OBJ: entity work.disp_text port map(clk=>clk,reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y, sw=>sw_time,score_dig1=>sec_dig1, score_dig0=>sec_dig0, lives_dig0=>sec_dig0, text_on=>disp_text_on, text_rgb=>disp_text_rgb);
--	
--	FROG_OBJ: entity work.frogger port map(clk=>clk, reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y,sw=>sw,btn=>(btnU & btnD & btnL & btnR), frog_rgb=>frog_rgb, frog_on=>frog_on, disp_ctl=>open);
--	
	
	CLK_OBJ: entity work.clock port map(clk=>clk,reset=>reset,clk_en=>clk_en,min_out => open, sec_out=>sec_out, hos_out=>hos_out);
	
	RAM_COMP: entity work.ram port map(clk=>clk,reset=>reset,raddr=>raddr,waddr=>waddr,din=>din,we=>we,dout=>dout);
	
	DATAPATH_COMP: entity work.datapath port map(clk=>clk,reset=>reset,btnS=>btnS,cx_init=>cx_init,cy_init=>cy_init,zx_init=>zx_init,zy_init=>zy_init,iter_init=>iter_init,ram_data_init=>ram_data_init,zx2_init=>zx2_init, zy2_init=>zy2_init,stop_init=>stop_init,del_bar_val_init=>del_bar_val_init, perc_val_init=>perc_val_init,toggle_init=>toggle_init,
																cx_en=>cx_en,cy_en=>cy_en,zx_en=>zx_en,zy_en=>zy_en,zx2_en=>zx2_en,zy2_en=>zy2_en,iter_en=>iter_en,zxtemp_en=>zxtemp_en,zytemp_en=>zytemp_en,ram_ind_en=>ram_ind_en,ram_data_en=>ram_data_en,perc_val_en=>perc_val_en,del_bar_val_en=>del_bar_val_en,toggle_en=>toggle_en,
																cx_f=>cx_f,cy_f=>cy_f,zmag_f=>zmag_f,iter_f=>iter_f,stop_f=>stop_f,toggle_f=>toggle_f,
																ram_ind=>waddr,ram_data=>din,
																perc_val=>perc_val,del_bar_val=>del_bar_val);
	CONT_COMP: entity work.controller port map(clk=>clk,reset=>reset,cx_init=>cx_init,cy_init=>cy_init,zx_init=>zx_init,zy_init=>zy_init,iter_init=>iter_init,ram_data_init=>ram_data_init,zx2_init=>zx2_init, zy2_init=>zy2_init,del_bar_val_init=>del_bar_val_init, perc_val_init=>perc_val_init,toggle_init=>toggle_init,stop_init=>stop_init,
														  cx_en=>cx_en,cy_en=>cy_en,zx_en=>zx_en,zy_en=>zy_en,zx2_en=>zx2_en,zy2_en=>zy2_en,iter_en=>iter_en,zxtemp_en=>zxtemp_en,zytemp_en=>zytemp_en,ram_ind_en=>ram_ind_en,ram_data_en=>ram_data_en,perc_val_en=>perc_val_en,del_bar_val_en=>del_bar_val_en,clk_en=>clk_en,toggle_en=>toggle_en,
														  cx_f=>cx_f,cy_f=>cy_f,zmag_f=>zmag_f,iter_f=>iter_f,stop_f=>stop_f,toggle_f=>toggle_f,
														  ram_wr=>we);
	--ram_wr_cont <= we;
	TEXT_OBJ: entity work.text port map(clk=>clk,reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y, text_on=>text_on, text_rgb=>text_rgb,perc_val_dig3=>perc_val_dig3, perc_val_dig2=>perc_val_dig2, perc_val_dig1=>perc_val_dig1,perc_val_dig0=>perc_val_dig0,hos_dig1=>hos_dig1,sec_dig1=>sec_dig1,sec_dig0=>sec_dig0);
	
	MAN_GRAPH_OBJ: entity work.man_graph port map(clk=>clk,reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y,ram_out=>dout,ram_raddr=>raddr,sw=>sw, man_graph_on=>man_graph_on, man_graph_rgb=>man_graph_rgb);
	
	PROGBAR_COMP: entity work.progbar port map(clk=>clk,reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y,del_bar_val=>del_bar_val,progbar_on=>progbar_on,progbar_rgb=>progbar_rgb);
	
   ----------------------------------------------
   -- rgb multiplexing circuit
   ----------------------------------------------
	process(video_on,text_on, 
					text_rgb)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --blank
      else
			if progbar_on='1' then
				graph_rgb <= progbar_rgb;			
			elsif text_on='1' then
				graph_rgb <= text_rgb;			
			elsif man_graph_on='1' then
				graph_rgb <= man_graph_rgb;			
--			elsif text_on='1' then
--            graph_rgb <= text_rgb;
         else
            graph_rgb <= "111"; -- white background
         end if;
      end if;
   end process;
	
--   process(video_on,wall_on,paddle_on,sq_ball_on,
--           wall_rgb, paddle_rgb, ball_rgb)
--   begin
--      if video_on='0' then
--          graph_rgb <= "000"; --blank
--      else
--         if wall_on='1' then
--            graph_rgb <= wall_rgb;
--         elsif paddle_on='1' then
--            graph_rgb <= paddle_rgb;
--         elsif sq_ball_on='1' then
--            graph_rgb <= ball_rgb;
--         else
--            graph_rgb <= "111"; -- yellow background
--         end if;
--      end if;
--   end process;
end sq_ball_arch;