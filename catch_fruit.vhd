library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_fruit_catch is
	port
	(
		fpga_clk_50 : in std_logic;
		
		--pushbuttons to move left, pause, select, move right, respectively
		key : in std_logic_vector(3 downto 0);
		--switches to reset game
		sw : in std_logic_vector(3 downto 0);
		--leds to show health
		led : out std_logic_vector(3 downto 0);
		
		--vga rgb
		vga_r : out std_logic_vector(7 downto 0);
		vga_g : out std_logic_vector(7 downto 0);
		vga_b : out std_logic_vector(7 downto 0);
		
		vga_hs : out std_logic;
		vga_vs : out std_logic;
		
		vga_clk : out std_logic;
		vga_sync_n : out std_logic;
		vga_blank_n : out std_logic	
	);
end vga_fruit_catch;

architecture rtl of vga_fruit_catch is
	--constants
	constant screen_w : integer := 640;
	constant screen_l : integer := 480;
	
	constant fruit_size : integer := 16;
	
	constant font_scale : integer := 2;
	constant countdown_scale : integer := 8;
	
	--type of game state
	type game_state_type is
	(
		game_start,
		game_playing,
		game_paused,
		countdown,
		game_over
	);
	
	--fruit arrays
	type fruit_pos_array is array (0 to 4) of integer range -200 to screen_w;
	type fruit_kind_array is array (0 to 4) of integer range 0 to 3;
	
	--font type
	type font_row_type is array (0 to 7) of std_logic_vector(7 downto 0);
	constant font_a : font_row_type := ("00111100",
													"01000010",
													"10000001",
													"11111111",
													"10000001",
													"10000001",
													"10000001",
													"10000001");
													
	constant font_b : font_row_type := ("11111100",
													"10000010",
													"10000001",
													"11111110",
													"10000001",
													"10000001",
													"10000001",
													"11111111");
													
	constant font_c : font_row_type := ("01111110",
													"10000001",
													"10000000",
													"10000000",
													"10000000",
													"10000000",
													"10000001",
													"01111110");
													
	constant font_d : font_row_type := ("11111100",
													"10000010",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000010",
													"11111100");
													
	constant font_e : font_row_type := ("11111111",
													"10000000",
													"10000000",
													"11111111",
													"10000000",
													"10000000",
													"10000000",
													"11111111");
													
	constant font_f : font_row_type := ("11111111",
													"10000000",
													"10000000",
													"11111111",
													"10000000",
													"10000000",
													"10000000",
													"10000000");
													
	constant font_g : font_row_type := ("01111110",
													"10000001",
													"10000000",
													"10001110",
													"10010001",
													"10000001",
													"10000001",
													"01111110");
													
	constant font_h : font_row_type := ("10000001",
													"10000001",
													"10000001",
													"11111111",
													"10000001",
													"10000001",
													"10000001",
													"10000001");
													
	constant font_i : font_row_type := ("11111111",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"11111111");
													
	constant font_j : font_row_type := ("11111111",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"11011000",
													"00110000");
													
	constant font_k : font_row_type := ("10000001",
													"10000110",
													"10011000",
													"11100000",
													"11100000",
													"10011000",
													"10000110",
													"10000001");
													
	constant font_l : font_row_type := ("10000000",
													"10000000",
													"10000000",
													"10000000",
													"10000000",
													"10000000",
													"10000000",
													"11111111");
													
	constant font_m : font_row_type := ("10000001",
													"11000011",
													"10100101",
													"10011001",
													"10000001",
													"10000001",
													"10000001",
													"10000001");
													
	constant font_n : font_row_type := ("11000001",
													"10100001",
													"10100001",
													"10010001",
													"10001001",
													"10000101",
													"10000101",
													"10000011");
													
	constant font_o : font_row_type := ("01111110",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"01111110");
													
	constant font_p : font_row_type := ("11111110",
													"10000001",
													"10000001",
													"11111110",
													"10000000",
													"10000000",
													"10000000",
													"10000000");
													
	constant font_q : font_row_type := ("01111110",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000101",
													"10000010",
													"01111101");
													
	constant font_r : font_row_type := ("11111110",
													"10000001",
													"10000001",
													"11111110",
													"11100000",
													"10011000",
													"10000110",
													"10000001");
													
	constant font_s : font_row_type := ("01111110",
													"10000001",
													"10000000",
													"01111110",
													"00000001",
													"00000001",
													"10000001",
													"01111110");
													
	constant font_t : font_row_type := ("11111111",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"00011000",
													"00011000");
													
	constant font_u : font_row_type := ("10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"10000001",
													"01111110");
													
	constant font_v : font_row_type := ("10000001",
													"10000001",
													"10000001",
													"01000010",
													"01000010",
													"00100100",
													"00100100",
													"00011000");
													
	constant font_w : font_row_type := ("10000001",
													"10000001",
													"10000001",
													"01000010",
													"01011010",
													"01011010",
													"00100100",
													"00100100");
													
	constant font_x : font_row_type := ("10000001",
													"01000010",
													"00100100",
													"00011000",
													"00011000",
													"00100100",
													"01000010",
													"10000001");
													
	constant font_y : font_row_type := ("10000001",
													"10000001",
													"01000010",
													"00100100",
													"00011000",
													"00011000",
													"00011000",
													"00011000");
													
	constant font_z : font_row_type := ("11111111",
													"00000010",
													"00000100",
													"00001000",
													"00010000",
													"00100000",
													"01000000",
													"11111111");
													
	constant font_0 : font_row_type := ("00011000",
													"00100100",
													"01000010",
													"01000010",
													"01000010",
													"01000010",
													"00100100",
													"00011000");
	
	constant font_1 : font_row_type := ("00011000",
													"00111000",
													"01011000",
													"10011000",
													"00011000",
													"00011000",
													"00011000",
													"11111111");
													
	constant font_2 : font_row_type := ("01111110",
													"10000001",
													"10000001",
													"00000110",
													"00001000",
													"00110000",
													"01000000",
													"11111111");
	
	constant font_3 : font_row_type := ("01111110",
													"10000001",
													"00000001",
													"11111110",
													"00000001",
													"00000001",
													"10000001",
													"01111110");
													
	constant font_4 : font_row_type := ("10000001",
													"10000001",
													"10000001",
													"11111111",
													"00000001",
													"00000001",
													"00000001",
													"00000001");	
		
	constant font_5 : font_row_type := ("11111111",
													"10000000",
													"10000000",
													"11110000",
													"00001111",
													"00000001",
													"00000001",
													"11111110");
											
	constant font_6 : font_row_type := ("01111110",
													"10000001",
													"10000000",
													"11111110",
													"10000001",
													"10000001",
													"10000001",
													"01111110");
													
	constant font_7 : font_row_type := ("11111111",
													"00000001",
													"00000010",
													"00000100",
													"00001000",
													"00010000",
													"00100000",
													"01000000");

	constant font_8 : font_row_type := ("01111110",
													"10000001",
													"10000001",
													"01111110",
													"10000001",
													"10000001",
													"10000001",
													"01111110");
													
	constant font_9 : font_row_type := ("01111110",
													"10000001",
													"10000001",
													"01111111",
													"00000001",
													"00000001",
													"10000001",
													"01111110");													
													
	constant font_question : font_row_type := ("01111110",
															 "10000001",
															 "10000001",
															 "00000110",
															 "00011000",
															 "00011000",
															 "00000000",
															 "00011000");
													
	constant font_hyphen : font_row_type := ("00000000",
														  "00000000",
														  "00000000",
														  "00111100",
														  "00000000",
														  "00000000",
														  "00000000",
														  "00000000");												
	
	function get_font(c : character) return font_row_type is
	begin
		case c is
			when 'A' => return font_a;
			when 'B' => return font_b;
			when 'C' => return font_c;
			when 'D' => return font_d;
			when 'E' => return font_e;
			when 'F' => return font_f;
			when 'G' => return font_g;
			when 'H' => return font_h;
			when 'I' => return font_i;
			when 'J' => return font_j;
			when 'K' => return font_k;
			when 'L' => return font_l;
			when 'M' => return font_m;
			when 'N' => return font_n;
			when 'O' => return font_o;
			when 'P' => return font_p;
			when 'Q' => return font_q;
			when 'R' => return font_r;
			when 'S' => return font_s;
			when 'T' => return font_t;
			when 'U' => return font_u;
			when 'V' => return font_v;
			when 'W' => return font_w;
			when 'X' => return font_x;
			when 'Y' => return font_y;
			when 'Z' => return font_z;
			when '0' => return font_0;
			when '1' => return font_1;
			when '2' => return font_2;
			when '3' => return font_3;
			when '4' => return font_4;
			when '5' => return font_5;
			when '6' => return font_6;
			when '7' => return font_7;
			when '8' => return font_8;
			when '9' => return font_9;
			when '?' => return font_question;
			when '-' => return font_hyphen;
			when others =>
				return("00000000",
						"00000000",
						"00000000",
						"00000000",
						"00000000",
						"00000000",
						"00000000",
						"00000000");
		end case;
	end function;
	
	function digit_char(d : integer) return character is
	begin
		case d is
			when 0 => return '0';
			when 1 => return '1';
			when 2 => return '2';
			when 3 => return '3';
			when 4 => return '4';
			when 5 => return '5';
			when 6 => return '6';
			when 7 => return '7';
			when 8 => return '8';
			when 9 => return '9';
			when others => return '0';
		end case;
	end function;
	
	procedure draw_char(
		constant c : in character;
		constant pos_x : in integer;
		constant pos_y : in integer;
		signal px : in integer;
		signal py : in integer;
		signal red : out std_logic_vector(7 downto 0);
		signal green : out std_logic_vector(7 downto 0);
		signal blue : out std_logic_vector(7 downto 0)
	) is
		variable row_v : integer;
		variable col_v : integer;
		--makes it so "get_font(c)" won't be typed so much
		variable f : font_row_type;
	begin
		if(px >= pos_x and px < pos_x + 16 and
			py >= pos_y and py < pos_y + 16) then
				row_v := (py - pos_y)/font_scale;
				col_v := (px - pos_x)/font_scale;
				
				f := get_font(c);

				if(f(row_v)(7-col_v) = '1') then
					red   <= x"FF";
					green <= x"FF";
					blue  <= x"FF";
				end if;
		end if;
	end procedure;
	
	--implemented after pause overlay's "CLICK KEY1 TO CONTINUE" hard coding
	procedure draw_text(
		constant msg : in string;
		constant pos_x : in integer;
		constant pos_y : in integer;
		signal px : in integer;
		signal py : in integer;
		signal red : out std_logic_vector(7 downto 0);
		signal green : out std_logic_vector(7 downto 0);
		signal blue : out std_logic_vector(7 downto 0)
		) is
	begin
		for i in msg'range loop
		draw_char(
			msg(i),
			pos_x + (i - msg'low) * 18,
			pos_y,
			px,
			py,
			red,
			green,
			blue
		);
		end loop;
	end procedure;
	
	--game state
	signal game_state : game_state_type := game_start;
	
	--player signals
	signal basket_x : integer range 0 to screen_w - 1 := 285;
	signal basket_y : integer range 0 to screen_l - 1 := 390;
	
	--fruit signals
	signal fruit_x : fruit_pos_array := (80, 200, 320, 440, 560);
	signal fruit_y : fruit_pos_array := (-40, -80, -120, -160, -200);
	signal fruit_kind : fruit_kind_array := (0, 1, 2, 0, 1);
	
	--linear-feedback shift register for randomizer
	signal lfsr : std_logic_vector(15 downto 0) := x"1234";
	
	--score
	signal score : integer := 0;
	--lives
	signal lives : integer range 0 to 4 := 4;
	
	--countdown
	signal countdown_timer : integer range 0 to 60 := 0;
	signal countdown_stage : integer range 0 to 3 := 0;
	
	--used for the vga being on or not
	signal video_on : std_logic;
	
	--makes it so key2 stays high when it is clicked until key1 is clicked
	signal key1_prev : std_logic := '1';
	signal key2_prev : std_logic := '1';
	
	--helps maintain movement
	signal tick_counter : integer range 0 to 833333 := 0;
	signal game_tick : std_logic := '0';
	
	--25mhz pixel clock
	signal pixel_clk : std_logic := '0';
	
	signal font_row : integer range 0 to 7;
	signal font_col : integer range 0 to 7;
	
	--current screen position
	signal pixel_x : integer range 0 to 799 := 0;
	signal pixel_y : integer range 0 to 524 := 0;
	
begin
	process(fpga_clk_50)
	begin
		if(rising_edge(fpga_clk_50)) then
			pixel_clk <= not pixel_clk;
		end if;
	end process;
	
	process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			if(pixel_x = 799) then
				pixel_x <= 0;
				
				if(pixel_y = 524) then
					pixel_y <= 0;
				else
					pixel_y <= pixel_y + 1;
				end if;
			else
				pixel_x <= pixel_x + 1;
			end if;
		end if;
	end process;
	
	--vga
	vga_hs <= '0' when
		(pixel_x >= 656 and pixel_x < 752)
	else
		'1';
	
	vga_vs <= '0' when
		(pixel_y >= 490 and pixel_y < 492)
	else
		'1';
		
	vga_clk <= pixel_clk;
	vga_sync_n <= '0';
	vga_blank_n <= '1';
	
	video_on <= '1' when
		(pixel_x < 640 and pixel_y < 480)
	else
		'0';
	
	--background rendering
	process(pixel_x, pixel_y, video_on)
	begin
		if(video_on = '1') then
			--sky
			vga_r <= x"52";
			vga_g <= x"DB";
			vga_b <= x"FF";
			
			--grass ground
			if(pixel_y >= 340) then
				vga_r <= x"3F";
				vga_g <= x"9B";
				vga_b <= x"0B";
			end if;
			
			--grass blades on top
			-- blade 1
			if((pixel_x = 70 and pixel_y >= 385 and pixel_y <= 400) or
				(pixel_x = 69 and pixel_y >= 392 and pixel_y <= 405)) then
					vga_r <= x"7C";
					vga_g <= x"FC";
					vga_b <= x"00";
			end if;

			-- blade 2
			if((pixel_x = 170 and pixel_y >= 390 and pixel_y <= 410) or
				(pixel_x = 169 and pixel_y >= 398 and pixel_y <= 418)) then
					vga_r <= x"7C";
					vga_g <= x"FC";
					vga_b <= x"00";
			end if;

			-- blade 3
			if((pixel_x = 450 and pixel_y >= 392 and pixel_y <= 412) or
				(pixel_x = 449 and pixel_y >= 400 and pixel_y <= 420)) then
					vga_r <= x"7C";
					vga_g <= x"FC";
					vga_b <= x"00";
			end if;

			-- blade 4
			if((pixel_x = 560 and pixel_y >= 388 and pixel_y <= 408) or
				(pixel_x = 559 and pixel_y >= 396 and pixel_y <= 416)) then
					vga_r <= x"7C";
					vga_g <= x"FC";
					vga_b <= x"00";
			end if;

			--bottom grass blades
			-- blade 5
			if((pixel_x = 250 and pixel_y >= 435 and pixel_y <= 460) or
				(pixel_x = 249 and pixel_y >= 445 and pixel_y <= 470)) then
					vga_r <= x"7C";
					vga_g <= x"FC";
					vga_b <= x"00";
			end if;

			-- blade 6
			if((pixel_x = 510 and pixel_y >= 430 and pixel_y <= 455) or
				(pixel_x = 509 and pixel_y >= 440 and pixel_y <= 470)) then
					vga_r <= x"7C";
					vga_g <= x"FC";
					vga_b <= x"00";
			end if;
			
			--tree trunk
			if(pixel_x >= 280 and pixel_x <= 340 and
				pixel_y >= 220 and pixel_y <= 420) then
					vga_r <= x"31";
					vga_g <= x"0E";
					vga_b <= x"00";
			end if;
			
			--tree leaves
			--main portion
			if(pixel_x >= 180 and pixel_x <= 440 and
				pixel_y >= 80 and pixel_y <= 240) then
					vga_r <= x"00";
					vga_g <= x"77";
					vga_b <= x"00";
			end if;
			
			--top portion
			if(pixel_x >= 240 and pixel_x <= 380 and
				pixel_y >= 30 and pixel_y <= 120) then
					vga_r <= x"00";
					vga_g <= x"77";
					vga_b <= x"00";
			end if;
			
			--banana
			if(pixel_x >= 220 and pixel_x <= 235 and
				pixel_y >= 160 and pixel_y <= 175) then
					vga_r <= x"FF";
					vga_g <= x"FF";
					vga_b <= x"00";
			end if;
			
			--orange
			if(pixel_x >= 320 and pixel_x <= 335 and
				pixel_y >= 120 and pixel_y <= 135) then
					vga_r <= x"FF";
					vga_g <= x"77";
					vga_b <= x"00";
			end if;
			
			--apple
			if(pixel_x >= 350 and pixel_x <= 365 and
				pixel_y >= 180 and pixel_y <= 195) then
					vga_r <= x"FF";
					vga_g <= x"00";
					vga_b <= x"33";
			end if;
			
			--cloud
			if((pixel_x >= 500 and pixel_x <= 620 and
				pixel_y >= 70 and pixel_y <= 110) or
				(pixel_x >= 540 and pixel_x <= 590 and
				pixel_y >= 40 and pixel_y <= 70)) then
					vga_r <= x"FF";
					vga_g <= x"FF";
					vga_b <= x"FF";
			end if;
			
			--basket body (top left corner as starting point)
			if(pixel_x >= basket_x and pixel_x <= basket_x + 50 and
			   pixel_y >= basket_y and pixel_y <= basket_y + 25) then
					vga_r <= x"D2";
					vga_g <= x"B4";
					vga_b <= x"8C";
			end if;

			--left handle connection
			if(pixel_x >= basket_x - 6 and pixel_x <= basket_x + 8 and
			   pixel_y >= basket_y - 4 and pixel_y <= basket_y + 4) then
					vga_r <= x"D2";
					vga_g <= x"B4";
					vga_b <= x"8C";
			end if;

			--right handle connection
			if(pixel_x >= basket_x + 42 and pixel_x <= basket_x + 56 and
			   pixel_y >= basket_y - 4 and pixel_y <= basket_y + 4) then
					vga_r <= x"D2";
					vga_g <= x"B4";
					vga_b <= x"8C";
			end if;

			--left handle leg
			if(pixel_x >= basket_x - 4 and pixel_x <= basket_x - 1 and
			   pixel_y >= basket_y - 28 and pixel_y <= basket_y - 4) then
					vga_r <= x"EF";
					vga_g <= x"E2";
					vga_b <= x"C0";
			end if;

			--right handle leg
			if(pixel_x >= basket_x + 51 and pixel_x <= basket_x + 54 and
			   pixel_y >= basket_y - 28 and pixel_y <= basket_y - 4) then
					vga_r <= x"EF";
					vga_g <= x"E2";
					vga_b <= x"C0";
			end if;

			--handle top
			if(pixel_x >= basket_x - 1 and pixel_x <= basket_x + 51 and
			   pixel_y >= basket_y - 30 and pixel_y <= basket_y - 26) then
					vga_r <= x"EF";
					vga_g <= x"E2";
					vga_b <= x"C0";
			end if;

			--basket design stripe 1
			if(pixel_x >= basket_x and
			   pixel_x <= basket_x + 50 and
			   pixel_y >= basket_y and
			   pixel_y <= basket_y + 25 and
			   pixel_x >= basket_x + 2 and
			   pixel_x <= basket_x + 12 and
			   pixel_x - (basket_x + 2) =
			   pixel_y - (basket_y + 6)) then
					vga_r <= x"A0";
					vga_g <= x"7A";
					vga_b <= x"4E";
			end if;

			--basket design stripe 2
			if(pixel_x >= basket_x and
			   pixel_x <= basket_x + 50 and
			   pixel_y >= basket_y and
			   pixel_y <= basket_y + 25 and
			   pixel_x >= basket_x + 14 and
			   pixel_x <= basket_x + 24 and
			   pixel_x - (basket_x + 14) =
			   pixel_y - (basket_y + 6)) then
					vga_r <= x"A0";
					vga_g <= x"7A";
					vga_b <= x"4E";
			end if;

			--basket design stripe 3
			if(pixel_x >= basket_x and
			   pixel_x <= basket_x + 50 and
			   pixel_y >= basket_y and
			   pixel_y <= basket_y + 25 and
			   pixel_x >= basket_x + 26 and
			   pixel_x <= basket_x + 36 and
			   pixel_x - (basket_x + 26) =
			   pixel_y - (basket_y + 6)) then
					vga_r <= x"A0";
					vga_g <= x"7A";
					vga_b <= x"4E";
			end if;

			--basket design stripe 4
			if(pixel_x >= basket_x and
			   pixel_x <= basket_x + 50 and
			   pixel_y >= basket_y and
			   pixel_y <= basket_y + 25 and
			   pixel_x >= basket_x + 38 and
			   pixel_x <= basket_x + 48 and
			   pixel_x - (basket_x + 38) =
			   pixel_y - (basket_y + 6)) then
					vga_r <= x"A0";
					vga_g <= x"7A";
					vga_b <= x"4E";
			end if;
			
			--score tracker up to 999
			draw_text("SCORE- ", 20, 440, pixel_x, pixel_y, vga_r, vga_g, vga_b);
			
			draw_char(
				digit_char((score/100) mod 10), 126, 440, pixel_x, pixel_y, vga_r, vga_g, vga_b
			);

			draw_char(
				digit_char((score/10) mod 10), 144, 440, pixel_x, pixel_y, vga_r, vga_g, vga_b
			);

			draw_char(
				digit_char(score mod 10), 162, 440, pixel_x, pixel_y, vga_r, vga_g, vga_b
			);
			
			--fruit
			for i in 0 to 4 loop
				if(pixel_x >= fruit_x(i) and
					pixel_x <= fruit_x(i) + fruit_size and
					pixel_y >= fruit_y(i) and
					pixel_y <= fruit_y(i) + fruit_size) then
						case fruit_kind(i) is
							when 0 =>
							--apple
							vga_r <= x"FF";
							vga_g <= x"00";
							vga_b <= x"33";

							when 1 =>
							--orange
							vga_r <= x"FF";
							vga_g <= x"77";
							vga_b <= x"00";

							when 2 =>
							--banana
							vga_r <= x"FF";
							vga_g <= x"FF";
							vga_b <= x"00";
							
							when others =>
							--bomb
							vga_r <= x"45";
							vga_g <= x"45";
							vga_b <= x"45";
						end case;
					end if;
				end loop;
					
			
			--start, paused (key2), and countdown (key1) overlay
			if(game_state = game_start or
				game_state = game_paused or
				game_state = countdown or
				game_state = game_over) then
					if(pixel_x >= 180 and pixel_x <= 440 and
						pixel_y >= 30 and pixel_y <= 240) then
							vga_r <= x"00";
							vga_g <= x"00";
							vga_b <= x"00";
					end if;
					
					if(game_state = game_start) then
						--start overlay
						draw_text("KEY3 - LEFT", 202, 85, pixel_x, pixel_y, vga_r, vga_g, vga_b);
						draw_text("KEY2 - PAUSE", 202, 115, pixel_x, pixel_y, vga_r, vga_g, vga_b);
						draw_text("KEY1 - START", 202, 145, pixel_x, pixel_y, vga_r, vga_g, vga_b);
						draw_text("KEY0 - RIGHT", 202, 175, pixel_x, pixel_y, vga_r, vga_g, vga_b);
					
					elsif(game_state = game_paused) then
						--paused overlay
						--PAUSED title
						--P
						if(pixel_x >= 257 and pixel_x < 273 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 257)/font_scale;
							
								if(font_p(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--A
						if(pixel_x >= 275 and pixel_x < 291 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 275)/font_scale;
								
								if(font_a(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--U
						if(pixel_x >= 293 and pixel_x < 309 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 293)/font_scale;
								
								if(font_u(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--S
						if(pixel_x >= 311 and pixel_x < 327 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 311)/font_scale;
								
								if(font_s(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--E
						if(pixel_x >= 329 and pixel_x < 345 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 329)/font_scale;
								
								if(font_e(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--D
						if(pixel_x >= 347 and pixel_x < 363 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 347)/font_scale;
								
								if(font_d(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
							
						--CLICK
						--C
						if(pixel_x >= 224 and pixel_x < 240 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 224)/font_scale;

								if(font_c(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--L
						if(pixel_x >= 242 and pixel_x < 258 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 242)/font_scale;

								if(font_l(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--I
						if(pixel_x >= 260 and pixel_x < 276 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 260)/font_scale;

								if(font_i(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--C
						if(pixel_x >= 278 and pixel_x < 294 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 278)/font_scale;

								if(font_c(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--K
						if(pixel_x >= 296 and pixel_x < 312 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 296)/font_scale;

								if(font_k(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--KEY1
						--K
						if(pixel_x >= 330 and pixel_x < 346 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 330)/font_scale;

								if(font_k(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--E
						if(pixel_x >= 348 and pixel_x < 364 and
							pixel_y >= 140 and pixel_y < 156) then
							 font_row <= (pixel_y - 140)/font_scale;
							 font_col <= (pixel_x - 348)/font_scale;

							 if(font_e(font_row)(7-font_col) = '1') then
								  vga_r <= x"FF";
								  vga_g <= x"FF";
								  vga_b <= x"FF";
							 end if;
						end if;

						--Y
						if(pixel_x >= 366 and pixel_x < 382 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 366)/font_scale;

								if(font_y(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;

						--1
						if(pixel_x >= 384 and pixel_x < 400 and
							pixel_y >= 140 and pixel_y < 156) then
								font_row <= (pixel_y - 140)/font_scale;
								font_col <= (pixel_x - 384)/font_scale;

								if(font_1(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--TO
						--T
						if(pixel_x >= 212 and pixel_x < 228 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 212)/font_scale;

								if(font_t(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--O
						if(pixel_x >= 230 and pixel_x < 246 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 230)/font_scale;

								if(font_o(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--CONTINUE
						--C
						if(pixel_x >= 266 and pixel_x < 282 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 266)/font_scale;

								if(font_c(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--O
						if(pixel_x >= 284 and pixel_x < 300 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 284)/font_scale;

								if(font_o(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--N
						if(pixel_x >= 302 and pixel_x < 318 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 302)/font_scale;

								if(font_n(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--T
						if(pixel_x >= 320 and pixel_x < 336 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 320)/font_scale;

								if(font_t(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--I
						if(pixel_x >= 338 and pixel_x < 354 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 338)/font_scale;

								if(font_i(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--N
						if(pixel_x >= 356 and pixel_x < 372 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 356)/font_scale;

								if(font_n(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--U
						if(pixel_x >= 374 and pixel_x < 390 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 374)/font_scale;

								if(font_u(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--E
						if(pixel_x >= 392 and pixel_x < 408 and
							pixel_y >= 160 and pixel_y < 176) then
								font_row <= (pixel_y - 160)/font_scale;
								font_col <= (pixel_x - 392)/font_scale;

								if(font_e(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
					
					elsif(game_state = countdown) then
						--countdown overlay
						--READY?
						--R
						if(pixel_x >= 257 and pixel_x < 273 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 257)/font_scale;
							
								if(font_r(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--E
						if(pixel_x >= 275 and pixel_x < 291 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 275)/font_scale;
								
								if(font_e(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--A
						if(pixel_x >= 293 and pixel_x < 309 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 293)/font_scale;
								
								if(font_a(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--D
						if(pixel_x >= 311 and pixel_x < 327 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 311)/font_scale;
								
								if(font_d(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--Y
						if(pixel_x >= 329 and pixel_x < 345 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 329)/font_scale;
								
								if(font_y(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--?
						if(pixel_x >= 347 and pixel_x < 363 and
							pixel_y >= 50 and pixel_y < 66) then
								font_row <= (pixel_y - 50)/font_scale;
								font_col <= (pixel_x - 347)/font_scale;
								
								if(font_question(font_row)(7-font_col) = '1') then
									vga_r <= x"FF";
									vga_g <= x"FF";
									vga_b <= x"FF";
								end if;
						end if;
						--3 2 1 starts red and turns green in 1 second intervals
						--3
						if(pixel_x >= 190 and pixel_x < 254 and
							pixel_y >= 120 and pixel_y < 184) then
								font_row <= (pixel_y - 120)/countdown_scale;
								font_col <= (pixel_x - 190)/countdown_scale;

								if(font_3(font_row)(7-font_col) = '1') then
									if(countdown_stage >= 1) then
										vga_r <= x"00";
										vga_g <= x"FF";
										vga_b <= x"00";
									else
										vga_r <= x"FF";
										vga_g <= x"00";
										vga_b <= x"00";
									end if;
								end if;
						end if;
						--2
						if(pixel_x >= 278 and pixel_x < 342 and
							pixel_y >= 120 and pixel_y < 184) then
								font_row <= (pixel_y - 120)/countdown_scale;
								font_col <= (pixel_x - 278)/countdown_scale;
								
								if(font_2(font_row)(7-font_col) = '1') then
									if(countdown_stage >= 2) then
										vga_r <= x"00";
										vga_g <= x"FF";
										vga_b <= x"00";
									else
										vga_r <= x"FF";
										vga_g <= x"00";
										vga_b <= x"00";
									end if;
								end if;
						end if;
						--1
						if(pixel_x >= 366 and pixel_x < 430 and
							pixel_y >= 120 and pixel_y < 184) then
								font_row <= (pixel_y - 120)/countdown_scale;
								font_col <= (pixel_x - 366)/countdown_scale;

								if(font_1(font_row)(7-font_col) = '1') then
									if(countdown_stage >= 3) then
										vga_r <= x"00";
										vga_g <= x"FF";
										vga_b <= x"00";
									else
										vga_r <= x"FF";
										vga_g <= x"00";
										vga_b <= x"00";
									end if;
								end if;
						end if;
					
					elsif(game_state = game_over) then
						draw_text(
							"GAME OVER", 228, 50, pixel_x, pixel_y, vga_r, vga_g, vga_b
						);
						
						draw_text(
							"CLICK KEY1", 220, 140, pixel_x, pixel_y, vga_r, vga_g, vga_b
						);
						draw_text(
							"TO RESTART", 220, 160, pixel_x, pixel_y, vga_r, vga_g, vga_b
						);
						
					end if;
			end if;	
			
		--black everywhere else	
		else
			vga_r <= x"00";
			vga_g <= x"00";
			vga_b <= x"00";
		end if;
	end process;
	
	--display for lives on leds
	with lives select
		led <= "1111" when 4,
				"0111" when 3,
				"0011" when 2,
				"0001" when 1,
				"0000" when others;
	
	game_proc : process(fpga_clk_50)
	begin
		if(rising_edge(fpga_clk_50)) then
			--updates pseudo-random generator
			if(game_tick = '1') then
				lfsr <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
			end if;
			
			--key1 to start game
			if(key1_prev = '1' and key(1) = '0') then
				if(game_state = game_start) then
					game_state <= game_playing;
				end if;
			end if;
			
			--key2 to pause button
			if(key2_prev = '1' and key(2) = '0') then
				if(game_state = game_playing) then
					game_state <= game_paused;
				end if;
			end if;
			
			--select button
			if(key1_prev = '1' and key(1) = '0') then
				if(game_state = game_paused) then
					countdown_timer <= 0;
					countdown_stage <= 0;
					game_state <= countdown;
				end if;
			end if;
			
			--restart button
			if(key1_prev = '1' and key(1) = '0') then
				if(game_state = game_over) then
					game_state <= game_start;
					
					lives <= 4;
					score <= 0;
					
					basket_x <= 285;
					basket_y <= 390;
					
					fruit_x <= (100, 220, 340, 460, 580);
					fruit_y <= (-40, -80, -120, -160, -200);
					fruit_kind <= (0, 1, 2, 0, 1);
					
				end if;
			end if;
			
			if(game_tick = '1') then
				if(game_state = countdown) then
					if(countdown_timer = 60) then
						countdown_timer <= 0;
						
						if(countdown_stage < 3) then
							countdown_stage <= countdown_stage + 1;
						else
							game_state <= game_playing;
						end if;
					else
						countdown_timer <= countdown_timer + 1;
					end if;
				end if;
			end if;
			
			--player movement
			if(game_state = game_playing and game_tick = '1') then
				for i in 0 to 4 loop
					fruit_y(i) <= fruit_y(i) + 4;

					if (fruit_y(i) + fruit_size >= basket_y) and
					(fruit_y(i) <= basket_y + 25) and
					(fruit_x(i) + fruit_size >= basket_x) and
					(fruit_x(i) <= basket_x + 50) then

					if fruit_kind(i) = 3 then
						if lives = 1 then
							lives <= 0;
							game_state <= game_over;
						else
							lives <= lives - 1;
						end if;
					else
						score <= score + 1;
					end if;

					fruit_y(i) <= -16;

					fruit_x(i) <=	to_integer(unsigned(lfsr(8 downto 0))) mod (screen_w - fruit_size);

					fruit_kind(i) <= to_integer(unsigned(lfsr(3 downto 0))) mod 4;
					end if;

					if fruit_y(i) > screen_l then
						fruit_y(i) <= -16;

						fruit_x(i) <= to_integer(unsigned(lfsr(12 downto 4))) mod (screen_w - fruit_size);

						fruit_kind(i) <= to_integer(unsigned(lfsr(6 downto 3))) mod 4;
					end if;
				end loop;
				
				if(key(3) = '0') then
					if(basket_x > 6) then
						basket_x <= basket_x - 4;
					end if;
				end if;
				
				if(key(0) = '0') then
					if(basket_x < screen_w - 57) then
						basket_x <= basket_x + 4;
					end if;
				end if;
			end if;
			
			key1_prev <= key(1);
			key2_prev <= key(2);
			
		end if;
	end process;
	
	tick_proc : process(fpga_clk_50)
	begin
		if(rising_edge(fpga_clk_50)) then
			if(tick_counter = 833333) then
				tick_counter <= 0;
				game_tick <= '1';
			else
				tick_counter <= tick_counter + 1;
				game_tick <= '0';
			end if;
		end if;
	end process;
	
end rtl;
