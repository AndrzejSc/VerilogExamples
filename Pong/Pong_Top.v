module Pong_Top 
  #(parameter c_TOTAL_COLS = 800,
	parameter c_TOTAL_ROWS = 525,
	parameter c_ACTIVE_COLS = 640,
	parameter c_ACTIVE_ROWS = 480)
   (input		i_Clk,
    input		i_HSync,
	input		i_VSync,
	input		i_Game_Start,		// Game Start Button
	
	// Paddle controllers for player 1 and 2
	input		i_Paddle_Up_P1,		
	input		i_Paddle_Dn_P1,	
    input		i_Paddle_Up_P2,
	input		i_Paddle_Dn_P2,
	
	// Output Video
	output reg		o_HSync,
	output reg 		o_VSync,
	output [3:0] 	o_Red_Video,
    output [3:0]	o_Blu_Video,
	output [3:0]	o_Grn_Video
   );
   
   // Lokalne parametery
   parameter 	c_GAME_WIDTH 	= 40;
   parameter 	c_GAME_HEIGHT 	= 30;
   parameter 	c_SCORE_LIMIT	= 9;
   parameter 	c_PADDLE_HEIGHT= 6;
   parameter 	c_PADDLE_COL_P1= 0;					// Położenie paletki 1
   parameter 	c_PADDLE_COL_P2= c_GAME_WIDTH - 1;	// Położenie paletki 2
   
   // Stany maszyny
   parameter 	IDLE	 = 3'b000;
   parameter 	RUNNING = 3'b001;
   parameter 	P1_WINS = 3'b010;
   parameter 	P2_WINS = 3'b011;
   parameter 	CLEANUP = 3'b100;
   
   reg [2:0] 	r_SM_Main = IDLE;
   
   wire			w_HSync, w_VSync;
   wire [9:0] 	w_Col_Count, w_Row_Count;
   
   wire			w_Draw_Paddle_P1, w_Draw_Paddle_P2;
   wire [5:0]	w_Paddle_Y_P1, w_Paddle_Y_P2;
   wire 		w_Draw_Ball, w_Draw_Any;
   wire [5:0]	w_Ball_X, w_Ball_Y;
   
   reg [3:0]	r_P1_Score = 0;	
   reg [3:0]	r_P2_Score = 0;
   
   // Liczniki podzielonych pixeli, aby posługiwać się ekranem o wymiarach 40x30
   wire [5:0]	w_Col_Count_Div, w_Row_Count_Div;
   
   // Instancja generatora sygnałów HSync i VSync
   Sync_To_Count #(
		.TOTAL_COLS(c_TOTAL_COLS),
		.TOTAL_ROWS(c_TOTAL_ROWS))		My_Sync_To_Count_Module
	   (.i_Clk		(i_Clk),
	    .i_HSync	(i_HSync),
		.i_VSync	(i_VSync),
		.o_HSync	(w_HSync),
		.o_VSync	(w_VSync),
		.o_Col_Count(w_Col_Count),
		.o_Row_Count(w_Row_Conut));
		
		
	//
	always @(posedge i_Clk)
	begin
		o_HSync <= w_HSync;
		o_VSync <= w_VSync;
	end // always
	
	// Dzielimy wartosci Col_Cout oraz Row_Count przez 16, czyli odrzucamy 4 najmlodsze bity
	// inaczej: przesuwamy o 4 bity w prawo. Mamy liczniki aktualnych komórek dla rozmiaru 40x30
	assign w_Col_Count_Div = w_Col_Count[9:4];
	assign w_Row_Count_Div = w_Row_Count[9:4];
   
	// Istancja kontrolera paletki1 + rysowanie
	Pong_Paddle_Ctrl #(
			.c_PLAYER_PADDLE_X	(c_PADDLE_COL_P1),
			.c_GAME_HEIGHT 		(c_GAME_HEIGHT))			Paddle_P1
		   (.i_Clk				(i_Clk),
		    .i_Col_Count_Div	(w_Col_Count_Div),
			.i_Row_Count_Div	(w_Row_Count_Div),
			.i_Paddle_Up		(i_Paddle_Up_P1),
			.i_Paddle_Dn		(i_Paddle_Dn_P1),
			.o_Draw_Paddle		(w_Draw_Paddle_P1), // Sygnał : Rysuj mnie tutej!
			.o_Paddle_Y			(w_Paddle_Y_P1));
			
	// Istancja kontrolera paletki2 + rysowanie
	Pong_Paddle_Ctrl #(
			.c_PLAYER_PADDLE_X	(c_PADDLE_COL_P2),
			.c_GAME_HEIGHT 		(c_GAME_HEIGHT))			Paddle_P2
		   (.i_Clk				(i_Clk),
		    .i_Col_Count_Div	(w_Col_Count_Div),
			.i_Row_Count_Div	(w_Row_Count_Div),
			.i_Paddle_Up		(i_Paddle_Up_P2),
			.i_Paddle_Dn		(i_Paddle_Dn_P2),
			.o_Draw_Paddle		(w_Draw_Paddle_P2), // Sygnał : Rysuj mnie tutej!
			.o_Paddle_Y			(w_Paddle_Y_P2));
			
	// Instancja kontrolera piłki oraz rysowacza
	Pong_Ball_Ctrl	My_Pong_Ball_Controller
		(.i_Clk				(i_Clk),
		 .i_Game_Active		(w_Game_Active),
		 .i_Col_Count_Div	(w_Col_Count_Div),
		 .i_Row_Count_Div	(w_Row_Count_Div),
		 .o_Draw_Ball		(w_Draw_Ball),		// Sygnał : Rysuj mnie tutej!
		 .o_Ball_X			(w_Ball_X),
		 .o_Ball_Y			(w_Ball_Y));
		 
	// Maszyna stanu
	always @(posedge i_Clk)
	begin
		case (r_SM_Main)
			IDLE: 
			begin
				if(i_Game_Start == 1'b1)
				r_SM_Main <= RUNNING;
			end //case IDLE
			
			RUNNING:
			begin
				// Player 1 side
				if(w_Ball_X == 0 &&
					(w_Ball_Y < w_Paddle_Y_P1 || w_Ball_Y > w_Paddle_Y_P1 + c_PADDLE_HEIGHT))
					r_SM_Main <= P2_WINS;
					
				// Player 2 side
				else if (w_Ball_X == c_GAME_WIDTH-1 &&
					(w_Ball_Y < w_Paddle_Y_P2 || w_Ball_Y > w_Paddle_Y_P2 + c_PADDLE_HEIGHT))
					r_SM_Main <= P1_WINS;
			end // case RUNNING
			
			P1_WINS:
			begin
				if(r_P1_Score == c_SCORE_LIMIT-1)
					r_P1_Score <= 0;
				else 
					begin
					r_P1_Score <= r_P1_Score + 1;
					r_SM_Main <= CLEANUP;
					end // else
			end // case P1_WINS
			
			P2_WINS:
			begin
				if(r_P2_Score == c_SCORE_LIMIT-1)
					r_P2_Score <= 0;
				else 
					begin
					r_P2_Score <= r_P2_Score + 1;
					r_SM_Main <= CLEANUP;
					end // else
			end //case P2_WINS
			
			CLEANUP:
				r_SM_Main <= IDLE;	
		endcase 
	end // always
	
	// Przypisanie sygnałów 
	assign w_Game_Active = (r_SM_Main == RUNNING)? 1'b1 : 1'b0;
	assign w_Draw_Any = w_Draw_Ball | w_Draw_Paddle_P1 | w_Draw_Paddle_P2;
	
	// Przypisanie kolorów. Jeśli mamy coś do rysowania to dajemy 1 na kolorki
	assign o_Red_Video = w_Draw_Any? 4'b1111 : 4'b0000;
	assign o_Blu_Video = w_Draw_Any? 4'b1111 : 4'b0000;
	assign o_Grn_Video = w_Draw_Any? 4'b1111 : 4'b0000;
   
  
endmodule