-- Listing 13.6
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
entity text is
   port(
      clk, reset: in std_logic;
      pixel_x, pixel_y: in std_logic_vector(9 downto 0);
      --score_dig1, score_dig0, lives_dig0: in std_logic_vector(3 downto 0);
		--sw : in std_logic_vector(1 downto 0);
		
		--digits
		perc_val_dig3,perc_val_dig2,perc_val_dig1,perc_val_dig0, hos_dig1,sec_dig1,sec_dig0 : std_logic_vector(3 downto 0);
		
      text_on: out std_logic;
      text_rgb: out std_logic_vector(2 downto 0)
   );
end text;

architecture arch of text is
   signal pix_x, pix_y: unsigned(9 downto 0);
   signal rom_addr: std_logic_vector(10 downto 0);
	
   signal char_addr, char_addr_t, char_addr_p, char_addr_s: std_logic_vector(6 downto 0);
   signal row_addr, row_addr_t, row_addr_p, row_addr_s: std_logic_vector(3 downto 0);
   signal bit_addr, bit_addr_t, bit_addr_p, bit_addr_s: std_logic_vector(2 downto 0);
	
   signal font_word: std_logic_vector(7 downto 0);
   signal font_bit: std_logic;
	
   signal title_on, perc_on, sec_on : std_logic;
	
	signal perc_val_dig3_conv : std_logic_vector(6 downto 0);
   
begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   -- instantiate font rom
   font_unit: entity work.font_rom  port map(clk=>clk, addr=>rom_addr, data=>font_word);
	
	
	---------------THE MANDELBROT SET----------------
--	title_on <=
--      '1' when pix_y(9 downto 5)=0 and
--               0<= pix_x(9 downto 4) and pix_x(9 downto 4)<=15  else				--pix_x(9 downto 5)<16		--9 downto 4
--      '0';
	title_on <=
      '1' when pix_y(9 downto 5)=0 and
               11<= pix_x(9 downto 4) and pix_x(9 downto 4)<=28  else				--pix_x(9 downto 5)<16		--9 downto 4
      '0';																							--13 - 31
   row_addr_t <= std_logic_vector(pix_y(4 downto 1));
   bit_addr_t <= std_logic_vector(pix_x(3 downto 1));
	   with pix_x(8 downto 4) select
     char_addr_t <=
			 "1010100" when "01011",	--T
			 "1001000" when "01100",	--H
			 "1000101" when "01101",	--E
			 "0000000" when "01110",	--
			 "1001101" when "01111",	--M
			 "1000001" when "10000",	--A
			 "1001110" when "10001",	--N
			 "1000100" when "10010",	--D
			 "1000101" when "10011",	--E
			 "1001100" when "10100",	--L
			 "1000010" when "10101",	--B
			 "1010010" when "10110",	--R
			 "1001111" when "10111",	--O
			 "1010100" when "11000",	--T
			 "0000000" when "11001",	--
			 "1010011" when "11010",	--S
			 "1000101" when "11011",	--E
			 "1010100" when "11100",	--T
			 "0110000" when others;	--
	
	------------------Percentage value------------------------
	perc_on <=
      '1' when pix_y(9 downto 4)=28 and
               8<= pix_x(9 downto 3) and pix_x(9 downto 3)<=13  else				
      '0';																								 
			 
	row_addr_p <= std_logic_vector(pix_y(3 downto 0));
   bit_addr_p <= std_logic_vector(pix_x(2 downto 0));
   with pix_x(6 downto 3) select
     char_addr_p <=
        "1010011" when "0000", -- S x53
        "1100011" when "0001", -- c x63
        "1101111" when "0010", -- o x6f
        "1110010" when "0011", -- r x72
        "1100101" when "0100", -- e x65
        "0111010" when "0101", -- : x3a
        "011" & "0000" when "0110", -- digit 10
        "011" & "0000" when "0111", -- digit 1
        perc_val_dig3_conv when "1000",
        "011"&perc_val_dig2 when "1001",	--dig2
        "011"&perc_val_dig1 when "1010", -- B gig1
        "0101110" when "1011", -- a x61 .
        "011"&perc_val_dig0 when "1100", -- l x6c dig0
        "0100101" when "1101", -- l x6c %
        "0111010" when "1110", -- :
        "0000000" when others;
	perc_val_dig3_conv <= "011"&"0001" when unsigned(perc_val_dig3)=1 else
								 "0000000";
	-------------------SECONDS------------------------------
	sec_on <=
      '1' when pix_y(9 downto 4)=28 and
               65<= pix_x(9 downto 3) and pix_x(9 downto 3)<=70  else				
      '0';																								 
			 
	row_addr_s <= std_logic_vector(pix_y(3 downto 0));
   bit_addr_s <= std_logic_vector(pix_x(2 downto 0));
   with pix_x(6 downto 3) select
     char_addr_s <=
        "1010011" when "0000", --
        "011"&sec_dig1 when "0001", -- c x63	dig2
        "011"&sec_dig0 when "0010", -- o x6f	dig1
        "0101110" when "0011", -- r x72	.
        "011"&hos_dig1 when "0100", -- e x65	dig0
        "0000000" when "0101", -- : x3a	space
        "1110011" when "0110", --		s
        "011" & "0010" when "0111",
        "0000000" when "1000",
        "011"&"0011" when "1001",
        "011"&"0100" when "1010", -- B gig1
        "0101110" when "1011", -- a x61 .
        "011"&"0101" when "1100", -- l x6c dig0
        "0100101" when "1101", -- l x6c %
        "0111010" when "1110", -- :
        "0000000" when others;	  
--        "0000000" when "00000", --
--        "1011001" when "00001", -- Y x53
--        "1001111" when "00010", -- O x63
--        "1010101" when "00011", -- U x6f
--        "0000000" when "00100", -- 
--        "1010111" when "00101",-- W x65
--        "1001111" when "00110", -- O x3a
--        "1001110" when "00111",  -- N
--        "0000000" when "01000",
--        "0000000" when "01001",
--        "0000000" when "01010", 
--        "0000000" when "01011", 
--        "0000000" when "01100", 
--        "0000000" when "01101", 
--        "0000000" when "01110",
--        "011"&"0000" when "01111",
--		  "001"&"0001" when others;
--   with pix_x(7 downto 4) select
--     char_addr_t <=
--        "0000000" when "0000", --
--        "1011001" when "0001", -- Y x53
--        "1001111" when "0010", -- O x63
--        "1010101" when "0011", -- U x6f
--        "0000000" when "0100", -- 
--        "1010111" when "0101",-- W x65
--        "1001111" when "0110", -- O x3a
--        "1001110" when "0111",  -- N
--        "0000000" when "1000",
--        "0000000" when "1001",
--        "0000000" when "1010", 
--        "0000000" when "1011", 
--        "0000000" when "1100", 
--        "0000000" when "1101", 
--        "0000000" when "1110",
--        "011"&"0000" when others;
	
--	title_on <=
--      '1' when pix_y(9 downto 7)=0 and
--         (3<= pix_x(9 downto 6) and pix_x(9 downto 6)<=6) else
--      '0';
--   row_addr_t <= std_logic_vector(pix_y(6 downto 3));
--   bit_addr_t <= std_logic_vector(pix_x(5 downto 3));
--   with pix_x(8 downto 6) select
--     char_addr_t <=
--        "1010000" when "011", -- P x50
--        "1001111" when "100", -- O x4f
--        "1001110" when "101", -- N x4e
--        "1000111" when others; --G x47
	
--	title_on <= '1' when pix_y(9 downto 5)=0 and
--               pix_x(9 downto 4)<16 else
--      '0';
--   row_addr_t <= std_logic_vector(pix_y(4 downto 1));
--   bit_addr_t <= std_logic_vector(pix_x(3 downto 1));
--   with pix_x(7 downto 4) select
--     char_addr_t <=
--        "1010011" when "0000", -- S x53
--        "1100011" when "0001", -- c x63
--        "1101111" when "0010", -- o x6f
--        "1110010" when "0011", -- r x72
--        "1100101" when "0100", -- e x65
--        "0111010" when "0101", -- : x3a
--        "011" & "0001" when "0110", -- digit 10
--        "011" & "0001" when "0111", -- digit 1
--        "0000000" when "1000",
--        "0000000" when "1001",
--        "1000010" when "1010", -- B x42
--        "1100001" when "1011", -- a x61
--        "1101100" when "1100", -- l x6c
--        "1101100" when "1101", -- l x6c
--        "0111010" when "1110", -- :
--        "01100" & "01" when others;

--	---------------YOU WIN---------------------------
--   win_on <=
--      '1' when pix_y(9 downto 4)=2 and
--               pix_x(9 downto 3)<8 and sw="01" else
--      '0';
--   row_addr_w <= std_logic_vector(pix_y(3 downto 0));
--   bit_addr_w <= std_logic_vector(pix_x(2 downto 0));
--   with pix_x(6 downto 3) select
--     char_addr_w <=
--        "0000000" when "0000", --
--        "1011001" when "0001", -- Y x53
--        "1001111" when "0010", -- O x63
--        "1010101" when "0011", -- U x6f
--        "0000000" when "0100", -- 
--        "1010111" when "0101",-- W x65
--        "1001111" when "0110", -- O x3a
--        "1001110" when "0111",  -- N
--        "0000000" when "1000",
--        "0000000" when "1001",
--        "0000000" when "1010", 
--        "0000000" when "1011", 
--        "0000000" when "1100", 
--        "0000000" when "1101", 
--        "0000000" when "1110",
--        "0000000" when others;
--	----------YOU LOSE-------------------------------	  
--	over_on <=
--      '1' when pix_y(9 downto 4)=2 and
--               pix_x(9 downto 3)<9 and (sw="10" or sw="11") else
--      '0';
--   row_addr_o <= std_logic_vector(pix_y(3 downto 0));
--   bit_addr_o <= std_logic_vector(pix_x(2 downto 0));
--   with pix_x(6 downto 3) select
--     char_addr_o <=
--        "0000000" when "0000", --
--        "1011001" when "0001", -- Y x53
--        "1001111" when "0010", -- O x63
--        "1010101" when "0011", -- U x6f
--        "0000000" when "0100", -- 
--        "1001100" when "0101",-- L x65
--        "1001111" when "0110", -- O x3a
--        "1010011" when "0111",  -- S
--        "1010100" when "1000",  -- T
--        "0000000" when "1001",
--        "0000000" when "1010", 
--        "0000000" when "1011", 
--        "0000000" when "1100", 
--        "0000000" when "1101", 
--        "0000000" when "1110",
--        "0000000" when others;
--	----------Score: dd-------------------------------	  
--	score_on <=
--      '1' when pix_y(9 downto 4)=1 and
--               pix_x(9 downto 3)<10 and sw="00" else
--      '0';
--   row_addr_s <= std_logic_vector(pix_y(3 downto 0));
--   bit_addr_s <= std_logic_vector(pix_x(2 downto 0));
--   with pix_x(6 downto 3) select
--     char_addr_s <=
--        "0000000" when "0000", --
--        "1010011" when "0001", -- S x53
--        "1100011" when "0010", -- C x63
--        "1101111" when "0011", -- O x6f
--        "1110010" when "0100", -- R
--        "1100101" when "0101",-- E x65
--        "0111010" when "0110", -- :
--        "0000000" when "0111",  --
--        "011"&score_dig1 when "1000",  -- dig1
--        "011"&score_dig0 when "1001",  -- dig0
--        "0000000" when "1010", 
--        "0000000" when "1011", 
--        "0000000" when "1100", 
--        "0000000" when "1101", 
--        "0000000" when "1110",
--        "0000000" when others;
------------Lives: dd-------------------------------	  
--	lives_on <=
--      '1' when pix_y(9 downto 4)=2 and
--               pix_x(9 downto 3)<10 and sw="00" else
--      '0';
--   row_addr_l <= std_logic_vector(pix_y(3 downto 0));
--   bit_addr_l <= std_logic_vector(pix_x(2 downto 0));
--   with pix_x(6 downto 3) select
--     char_addr_l <=
--        "0000000" when "0000", --
--        "1001100" when "0001", -- L x53
--        "1101001" when "0010", -- i x63
--        "1110110" when "0011", -- v x6f
--        "1100101" when "0100", -- e
--        "1110011" when "0101",-- s x65
--        "0111010" when "0110", -- :
--        "0000000" when "0111",  --
--        "0110000" when "1000",  -- dig1
--        "011"&lives_dig0 when "1001",  -- dig0
--        "0000000" when "1010", 
--        "0000000" when "1011", 
--        "0000000" when "1100", 
--        "0000000" when "1101", 
--        "0000000" when "1110",
--        "0000000" when others;
	

		
   ---------------------------------------------
   -- mux for font ROM addresses and rgb
   ---------------------------------------------
	
   process(font_bit)
   begin
			text_rgb <= "111";  -- background, White
			if title_on='1' then
				char_addr <= char_addr_t;
				row_addr <= row_addr_t;
				bit_addr <= bit_addr_t;
				if font_bit='1' then
					text_rgb <= "000";
				end if;
			elsif sec_on='1' then
				char_addr <= char_addr_s;
				row_addr <= row_addr_s;
				bit_addr <= bit_addr_s;
				if font_bit='1' then
					text_rgb <= "000";
				end if;
			else		--if perc_on='1' then
				char_addr <= char_addr_p;
				row_addr <= row_addr_p;
				bit_addr <= bit_addr_p;
				if font_bit='1' then
					text_rgb <= "000";
				end if;
			end if;
			
--      text_rgb <= "111";  -- background, White
--      if score_on='1' then
--         char_addr <= char_addr_s;
--         row_addr <= row_addr_s;
--         bit_addr <= bit_addr_s;
--         if font_bit='1' then
--            text_rgb <= "111";
--         end if;
--      elsif win_on='1' then
--         char_addr <= char_addr_w;
--         row_addr <= row_addr_w;
--         bit_addr <= bit_addr_w;
--         if font_bit='1' then
--            text_rgb <= "111";
--         end if;
--      elsif lives_on='1' then
--         char_addr <= char_addr_l;
--         row_addr <= row_addr_l;
--         bit_addr <= bit_addr_l;
--         if font_bit='1' then
--            text_rgb <= "111";
--         end if;
--      else 			--over_on='1' then
--         char_addr <= char_addr_o;
--         row_addr <= row_addr_o;
--         bit_addr <= bit_addr_o;
--         if font_bit='1' then
--            text_rgb <= "111";
--         end if;
--      end if;
   end process;
	
   text_on <= title_on or perc_on or sec_on;
   ---------------------------------------------
   -- font rom interface
   ---------------------------------------------
   rom_addr <= char_addr & row_addr;
   font_bit <= font_word(to_integer(unsigned(not bit_addr)));
end arch;