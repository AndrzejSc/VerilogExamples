// Generator szablonów do wyświetlenia na LCD
// Wszystkie szablony generowane są współbieżnie. 
// Wybór szablonu natępuje przez wejście i_Pattern następnie przez instrukcję case

// Szablony:
// Pattern 0: Wyłączony
// Pattern 1: Czerwony
// Pattern 2: Zielony
// Pattern 3: Niebieski
// Pattern 4: Szachownica czarno/biała
// Pattern 5: Kolorowe pasy
// Pattern 6: Biały box z ramkami 2px

// Note: Comment out this line when building in iCEcube2:
//'include "Sync_To_Count.v"

module Test_Pattern_Gen		// Generator szablonów do wyswietlenia
	#(parameter VIDEO_WIDTH = 3,		// Ilu bitowe jest wyjście koloru
	  parameter TOTAL_COLS 	= 800,
	  parameter TOTAL_ROWS	= 525,
	  parameter ACTIVE_COLS	= 640,
	  parameter ACTIVE_ROWS	= 480)
	( input 		i_Clk,
	  input [3:0]	i_Pattern,			// Wybór szablonu
	  input			i_HSync,
	  input			i_VSync,
	  output reg	o_HSync = 0,
	  output reg	o_VSync = 0,
	  output reg [VIDEO_WIDTH-1:0] o_Red_Video,
	  output reg [VIDEO_WIDTH-1:0] o_Grn_Video,
	  output reg [VIDEO_WIDTH-1:0] o_Blu_Video );
	  
	wire w_VSync, w_HSync;
	
	// 3 Tablice dla kazdego koloru osobno
	// [szerokosc tablicy-ile bitów] nazwa [głębokosc tablicy - ile elementow]
	// [3 bity - daje 7 możliwych szablonów] NAZWA [16 bitów]
	// Czyli 3 tablice 8x16b
 	wire [VIDEO_WIDTH-1:0] Pattern_Red [0:15];
	wire [VIDEO_WIDTH-1:0] Pattern_Grn [0:15];
	wire [VIDEO_WIDTH-1:0] Pattern_Blu [0:15];
	
	// Liczniki
	wire [9:0] w_Col_Count;
	wire [9:0] w_Row_Count;
	
	wire [6:0] w_Bar_Width;		// Szerokosc pasów w szablonie 5
	wire [2:0] w_Bar_Select;	// Który pas wyświetlamy
	
	Sync_To_Count #(.TOTAL_COLS (TOTAL_COLS),
					.TOTAL_ROWS (TOTAL_ROWS)) My_Sync_To_Count_Module
		(.i_Clk			(i_Clk),
		 .i_HSync		(i_HSync),
		 .i_VSync		(i_VSync),
		 .o_HSync		(w_HSync),
		 .o_VSync		(w_VSync),
		 .o_Col_Count	(w_Col_Count),
		 .o_Row_Count	(w_Row_Count)		
		);
		
	// Przepisanie dalej sygnałów synchronizacji	
	always @(posedge i_Clk)
	begin
		o_HSync <= i_HSync;
		o_VSync <= i_VSync;
	end //always
	
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 0: Disables the Test Pattern Generator
	/////////////////////////////////////////////////////////////////////////////
	assign Pattern_Blu [0] = 0;
	assign Pattern_Grn [0] = 0;
	assign Pattern_Red [0] = 0;
	
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 1: All Red
	/////////////////////////////////////////////////////////////////////////////
	assign Pattern_Blu [1] = 0;
	assign Pattern_Grn [1] = 0;
	assign Pattern_Red [1] = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ?
		{VIDEO_WIDTH{1'b1}} : 0;
	
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 2: All Green
	/////////////////////////////////////////////////////////////////////////////
	assign Pattern_Blu [2] = 0;
	assign Pattern_Grn [2] = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? 
		{VIDEO_WIDTH{1'b1}} : 0;
	assign Pattern_Red [2] = 0;
	
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 3: All Blue
	/////////////////////////////////////////////////////////////////////////////
	assign Pattern_Blu [3] = (w_Col_Count > ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ?
		{VIDEO_WIDTH{1'b1}} : 0;
	assign Pattern_Grn [3] = 0;
	assign Pattern_Red [3] = 0;
	
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 4: Szachownica czarno/biała
	/////////////////////////////////////////////////////////////////////////////
	// ^ - XOR
 	assign Pattern_Red [4] = w_Col_Count [5] ^ w_Row_Count[5] ? {VIDEO_WIDTH{1'b1}} : 0;
	assign Pattern_Grn [4] = Pattern_Red [4];
	assign Pattern_Red [4] = Pattern_Red [4];
	
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 5: Color Bars
	// Divides active area into 8 Equal Bars and colors them accordingly
	// Colors Each According to this Truth Table:
	// R G B  w_Bar_Select  Ouput Color
	// 0 0 0       0        Black
	// 0 0 1       1        Blue
	// 0 1 0       2        Green
	// 0 1 1       3        Turquoise
	// 1 0 0       4        Red
	// 1 0 1       5        Purple
	// 1 1 0       6        Yellow
	// 1 1 1       7        White
	/////////////////////////////////////////////////////////////////////////////			
	assign w_Bar_Width = ACTIVE_COLS / 8;
	
	// Liczymy, który pas wyświetlamy, w zależności od tego, w którym punkcie jestesmy
	assign w_Bar_Select = w_Col_Count < w_Bar_Select*1 ? 0 :	// Jeśli na początku ekranu, to pas nr 0,
						  w_Col_Count < w_Bar_Select*2 ? 1 :	// Pasek nr 1
						  w_Col_Count < w_Bar_Select*3 ? 2 :
						  w_Col_Count < w_Bar_Select*4 ? 3 :
						  w_Col_Count < w_Bar_Select*5 ? 4 :
						  w_Col_Count < w_Bar_Select*6 ? 5 :
						  w_Col_Count < w_Bar_Select*7 ? 6 : 7;

	// Przypisujemy wartosci do tablic poszczególnych kolorów, w zależnosci od tego,
	// w którym pasie jestesmy. Jeśli w pasie 1 lub 3,5,7 to tablica Blue = 1
	assign Pattern_Blu [5] = (w_Bar_Select == 1 || w_Bar_Select == 3 || w_Bar_Select == 5 ||
						      w_Bar_Select == 7) ? {VIDEO_WIDTH{1'b1}} : 0;
	
	// 1 dla paska nr 2,3,6,7
	assign Pattern_Grn [5] = (w_Bar_Select == 2 || w_Bar_Select == 3 || w_Bar_Select == 6 ||
							  w_Bar_Select == 7) ? {VIDEO_WIDTH{1'b1}} : 0;
							  
	// 1 dla paska nr 4,5,6,7
	assign Pattern_Red [5] = (w_Bar_Select == 4 || w_Bar_Select == 5 || w_Bar_Select ==6 ||
							  w_Bar_Select == 7) ? {VIDEO_WIDTH{1'b1}} : 0;
							  
	/////////////////////////////////////////////////////////////////////////////
	// Pattern 6: Black With White Border
	// Creates a black screen with a white border 2 pixels wide around outside.
	/////////////////////////////////////////////////////////////////////////////
	assign Pattern_Red [6] = (w_Row_Count <= 1 || w_Row_Count >= ACTIVE_ROWS -2 ||
							  w_Col_Count <= 1 || w_Col_Count >= ACTIVE_COLS -2) ?
							  {VIDEO_WIDTH{1'b1}} : 0;
	assign Pattern_Blu [6] = Pattern_Red [6];
	assign Pattern_Grn [6] = Pattern_Red [6];
	
	
	/////////////////////////////////////////////////////////////////////////////
	// Wybór pomiędzy szablonami na podstawie i_Pattern
	/////////////////////////////////////////////////////////////////////////////
	always @(posedge i_Clk)
	begin
		case (i_Pattern) 
			4'h0 :		// i_Pattern = 0;
			begin
				o_Blu_Video <= Pattern_Blu [0];
				o_Grn_Video <= Pattern_Grn [0];
				o_Red_Video <= Pattern_Red [0];
			end //case 4'h0

			4'h1 : 		//i_Pattern = 1;
			begin
				o_Blu_Video <= Pattern_Blu [1];
				o_Grn_Video <= Pattern_Grn [1];
				o_Red_Video <= Pattern_Red [1];
			end 		//case 4'h1
			
			4'h2 : 		//i_Pattern = 2;
			begin
				o_Blu_Video <= Pattern_Blu [2];
				o_Grn_Video <= Pattern_Grn [2];
				o_Red_Video <= Pattern_Red [2];
			end 		//case 4'h2
			
			4'h3 : 		//i_Pattern = 3;
			begin
				o_Blu_Video <= Pattern_Blu [3];
				o_Grn_Video <= Pattern_Grn [3];
				o_Red_Video <= Pattern_Red [3];
			end 		//case 4'h3
			
			4'h4 : 		//i_Pattern = 4;
			begin
				o_Blu_Video <= Pattern_Blu [4];
				o_Grn_Video <= Pattern_Grn [4];
				o_Red_Video <= Pattern_Red [4];
			end 		//case 4'h4
			
			4'h5 : 		//i_Pattern = 5;
			begin
				o_Blu_Video <= Pattern_Blu [5];
				o_Grn_Video <= Pattern_Grn [5];
				o_Red_Video <= Pattern_Red [5];
			end 		//case 4'h5
			
			4'h6 : 		//i_Pattern = 6;
			begin
				o_Blu_Video <= Pattern_Blu [6];
				o_Grn_Video <= Pattern_Grn [6];
				o_Red_Video <= Pattern_Red [6];
			end 		//case 4'h6
			
			4'h7 : 		//i_Pattern = 7;
			begin
				o_Blu_Video <= Pattern_Blu [7];
				o_Grn_Video <= Pattern_Grn [7];
				o_Red_Video <= Pattern_Red [7];
			end 		//case 4'h7
		endcase
	end	  
endmodule // Test_Pattern_Gen
