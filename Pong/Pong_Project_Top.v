module Pong_Project_Top(
	input i_Clk,
	input i_UART_RX,
	
	// Przyciski jako wejścia
	input i_Switch_1,
	input i_Switch_2,
	input i_Switch_3,
	input i_Switch_4,
	
	// VGA Signals
	output o_VGA_HSync,
	output o_VGA_VSync,
	output o_VGA_Red_0,
	output o_VGA_Red_1,
	output o_VGA_Red_2,
	output o_VGA_Blu_0,
	output o_VGA_Blu_1,
	output o_VGA_Blu_2,
	output o_VGA_Grn_0,
	output o_VGA_Grn_1,
	output o_VGA_Grn_2);
	
	parameter c_VIDEO_WIDTH = 3;
	parameter c_TOTAL_COLS = 800;
	parameter c_TOTAL_ROWS = 525;
	parameter c_ACTIVE_COLS = 640;
	parameter c_ACTIVE_ROWS = 480;
	
	// Wspólne sygnały VGA
	wire [c_VIDEO_WIDTH-1:0] w_Red_Video_Pong, w_Red_Video_Porch;
	wire [c_VIDEO_WIDTH-1:0] w_Blu_Video_Pong, w_Blu_Video_Porch;
	wire [c_VIDEO_WIDTH-1:0] w_Grn_Video_Pong, w_Grn_Video_Porch;
	
	// Instancja odbiornika UART
	// 25 000 000/115200 = 217
	UART_RX #(.CLKS_PER_BIT(217)) 		My_UART_RX(
		.i_Clk			(i_Clk),
		.i_RX_Serial	(i_UART_RX),
		.o_RX_DV		(w_RX_DV),
		.o_RX_Byte		());
		
	
	// Instancje modułów debouncera dla 4 przyciskow
	Debounce_Switch		Switch_1
		(.i_Clk		(i_Clk),
		 .i_Switch	(i_Switch_1),
		 .o_Switch	(w_Switch_1));
		 
	Debounce_Switch		Switch_2
		(.i_Clk		(i_Clk),
		 .i_Switch	(i_Switch_2),
		 .o_Switch	(w_Switch_2));
		 
	Debounce_Switch		Switch_3
		(.i_Clk		(i_Clk),
		 .i_Switch	(i_Switch_3),
		 .o_Switch	(w_Switch_3));
		 
	Debounce_Switch		Switch_4
		(.i_Clk		(i_Clk),
		 .i_Switch	(i_Switch_4),
		 .o_Switch	(w_Switch_4));
		 
	// Instancja modułu TOP Pong	
	Pong_Top #(.c_TOTAL_COLS (c_TOTAL_COLS),
			   .c_TOTAL_ROWS (c_TOTAL_ROWS),
			   .c_ACTIVE_COLS(c_ACTIVE_COLS),
			   .c_ACTIVE_ROWS(c_ACTIVE_ROWS)) 	My_Pong_Top
		(.i_Clk 	(i_Clk),
		 .i_HSync	(w_HSync_VGA),
		 .i_VSync	(w_VSync_VGA),
		 .i_Game_Start		(w_RX_DV),
		 .i_Paddle_Up_P1	(w_Switch_1),
		 .i_Paddle_Dn_P1	(w_Switch_2),
		 .i_Paddle_Up_P2	(w_Switch_3),
		 .i_Paddle_Dn_P2	(w_Switch_4),
		 .o_HSync			(w_HSync_Pong),
		 .o_VSync			(w_VSync_Pong),
		 .o_Red_Video		(w_Red_Video_Pong),
		 .o_Blu_Video		(w_Blu_Video_Pong),
		 .o_Grn_Video		(w_Grn_Video_Pong));
		 
	// Instancja generatora sygnałów synchronizacji VGA
	VGA_Sync_Pulses #(
				.TOTAL_COLS	(c_TOTAL_COLS),
				.TOTAL_ROWS	(c_TOTAL_ROWS),
				.ACTIVE_COLS (c_ACTIVE_COLS),
				.ACTIVE_ROWS (c_ACTIVE_ROWS))		My_VGA_Sync_Pulses 
	   (.i_Clk		(i_Clk),
	    .o_HSync	(w_HSync_VGA),
		.o_VSync	(w_VSync_VGA),
		.o_Col_Count(),
		.o_Row_Count());
		 
	// Instancja modułu VGA_Sync_Porch
	VGA_Sync_Porch #(.VIDEO_WIDTH 	(c_VIDEO_WIDTH),
					 .TOTAL_COLS	(c_TOTAL_COLS),
					 .TOTAL_ROWS	(c_TOTAL_ROWS),
					 .ACTIVE_COLS	(c_ACTIVE_COLS),
					 .ACTIVE_ROWS	(c_ACTIVE_ROWS))		My_VGA_Sync_Porch
		(.i_Clk			(i_Clk),
		 .i_HSync		(w_HSync_Pong),
		 .i_VSync		(w_VSync_Pong),
		 .i_Red_Video	(w_Red_Video_Pong),
		 .i_Blu_Video	(w_Blu_Video_Pong),
		 .i_Grn_Video	(w_Grn_Video_Pong),
		 .o_HSync		(o_VGA_HSync),
		 .o_VSync		(o_VGA_VSync),
		 .o_Red_Video	(w_Red_Video_Porch),
		 .o_Blu_Video	(w_Blu_Video_Porch),
		 .o_Grn_Video	(w_Grn_Video_Porch));
		
	assign o_VGA_Red_0 = w_Red_Video_Porch[0];
	assign o_VGA_Red_1 = w_Red_Video_Porch[1];
	assign o_VGA_Red_2 = w_Red_Video_Porch[2];
	
	assign o_VGA_Blu_0 = w_Blu_Video_Porch[0];
	assign o_VGA_Blu_1 = w_Blu_Video_Porch[1];
	assign o_VGA_Blu_2 = w_Blu_Video_Porch[2];
	
	assign o_VGA_Grn_0 = w_Grn_Video_Porch[0];
	assign o_VGA_Grn_1 = w_Grn_Video_Porch[1];
	assign o_VGA_Grn_2 = w_Grn_Video_Porch[2];
		
endmodule