module Pong_Ball_Ctrl 
	#(parameter c_GAME_WIDTH = 40,
	  parameter c_GAME_HEIGHY = 30)
	 (input			i_Clk,
	  input			i_Game_Active,
	  input			i_Col_Count_Div,
	  input			i_Row_Count_Div,
	  output reg 	o_Draw_Ball,
	  output reg [5:0] o_Ball_X = 0,
	  output reg [5:0] o_Ball_Y = 0);
	  
	  
	  // Prędkosc poruszania sie piłki
	  // 50 ms
	  parameter c_BALL_SPEED = 1250000;
	  
	  reg [5:0] r_Ball_X_Prev = 0;
	  reg [5:0] r_Ball_Y_Prev = 0;
	  reg [31:0] r_Ball_Count = 0;
	  
	  
	always @(posedge i_Clk)
	begin
		// Jeśli gra nie jest aktywan
		if( i_Game_Active == 1'b0)
		begin
			// Ustawiamy pozycję początkowa piłki
			o_Ball_X 	<= c_GAME_WIDTH /2;
			o_Ball_Y	<= c_GAME_HEIGHY /2;
			r_Ball_X_Prev <= c_GAME_WIDTH/2 +1;
			r_Ball_Y_Prev <= c_GAME_HEIGHY/2 -1;
		end // i_Game_Active == 1
		
		// Jeśli gra jest aktywna. Zwiększaj za każdym razem licznik piłki.
		// Jeśli licznik == limit, to zrób ruch
		else 
		begin
			if(r_Ball_Count < c_BALL_SPEED) r_Ball_Count <= r_Ball_Count +1;
			else
			begin		
				r_Ball_Count <= 0;
				
				// Zapisz aktuale położenie piłki
				r_Ball_X_Prev <= o_Ball_X;
				r_Ball_Y_Prev <= o_Ball_Y;
				
				//Jeśli poprzednie położenie < aktualne to przesuwamy w prawo
				// Przesuwamy dopóki nie natrafimy na sciane.
				// Jeśli poprzednie położneie > aktualne, przesuwamy w lewo
				if((r_Ball_X_Prev < o_Ball_X && o_Ball_X == c_GAME_WIDTH-1) || 
				   (r_Ball_X_Prev > o_Ball_X && o_Ball_X != 0))
				   o_Ball_X <= o_Ball_X - 1;
				else o_Ball_X <= o_Ball_X + 1;

				if((r_Ball_Y_Prev < o_Ball_Y && o_Ball_Y == c_GAME_HEIGHY-1) ||
				   (r_Ball_Y_Prev > o_Ball_Y && o_Ball_Y !=0))
				   o_Ball_Y <= o_Ball_Y - 1;
				else o_Ball_Y <= o_Ball_Y + 1;
				
			end // r_Ball_Count == c_BALL_SPEED
			
		end // else
	
	end // always
	
	// Rysuj
	always @(posedge i_Clk)
	begin
		if(i_Col_Count_Div == o_Ball_X && i_Row_Count_Div == o_Ball_Y)
		o_Draw_Ball <= 1'b1;
		else o_Draw_Ball <= 1'b0;
	end
	
	
endmodule