module UART_RX_TOP(
	input i_Clk,		// Main Clock
	input i_UART_RX,	// UART Data RX	
	// Display 1 - Upper digit
	output o_Segment1_A,
	output o_Segment1_B,
	output o_Segment1_C,
	output o_Segment1_D,
	output o_Segment1_E,
	output o_Segment1_F,
	output o_Segment1_G,
	
	// Display 2 - Lower digit
	output o_Segment2_A,
	output o_Segment2_B,
	output o_Segment2_C,
	output o_Segment2_D,
	output o_Segment2_E,
	output o_Segment2_F,
	output o_Segment2_G);
	
	wire [7:0] w_RX_Byte;	// From UART_Recieiver to 7 Segment Converter
	wire w_RX_DV;			// Informuje, czy mamy odebrany bit
	
	// Linie do poszczególnych segmentów wyświetlacza
	wire w_Segment1_A, w_Segment2_A;
	wire w_Segment1_B, w_Segment2_B;
	wire w_Segment1_C, w_Segment2_C;
	wire w_Segment1_D, w_Segment2_D;
	wire w_Segment1_E, w_Segment2_E;
	wire w_Segment1_F, w_Segment2_F;
	wire w_Segment1_G, w_Segment2_G;
	
	// Tworzymy instancje UART_Receivera
	// 25MHz / 115200 baud rate = 217
	UART_RX #(.CLKS_PER_BIT(217)) My_UART_RECEIVER 
	(.i_Clk(i_Clk),
	 .i_RX_Serial(i_RX_Serial),
	 .o_RX_DV(w_RX_DV),
	 .o_RX_Byte(w_RX_Byte)
	);
	
	// Tworzymy instancje konwertera Bin to 7Segment
	Binary_to_7Segment my7Converter_UP (
		.i_Clk (i_Clk),
		.i_Binary_Num(w_RX_Byte[7:4]),
		.o_Segment_A(w_Segment1_A),
		.o_Segment_B(w_Segment1_B),
		.o_Segment_C(w_Segment1_C),
		.o_Segment_D(w_Segment1_D),
		.o_Segment_E(w_Segment1_E),
		.o_Segment_F(w_Segment1_F),
		.o_Segment_G(w_Segment1_G));
		
	assign o_Segment1_A =~w_Segment1_A;
	assign o_Segment1_B =~w_Segment1_B;
	assign o_Segment1_C =~w_Segment1_C;
	assign o_Segment1_D =~w_Segment1_D;
	assign o_Segment1_E =~w_Segment1_E;
	assign o_Segment1_F =~w_Segment1_F;
	assign o_Segment1_G =~w_Segment1_G;
	
	Binary_to_7Segment my7Converter_DOWN (
		.i_Clk(i_Clk),
		.i_Binary_Num(w_RX_Byte[3:0]),
		.o_Segment_A(w_Segment2_A),
		.o_Segment_B(w_Segment2_B),
		.o_Segment_C(w_Segment2_C),
		.o_Segment_D(w_Segment2_D),
		.o_Segment_E(w_Segment2_E),
		.o_Segment_F(w_Segment2_F),
		.o_Segment_G(w_Segment2_G)
		);
		
	assign o_Segment2_A =~ w_Segment2_A;
	assign o_Segment2_B =~ w_Segment2_B;
	assign o_Segment2_C =~ w_Segment2_C;
	assign o_Segment2_D =~ w_Segment2_D;
	assign o_Segment2_E =~ w_Segment2_E;
	assign o_Segment2_F =~ w_Segment2_F;
	assign o_Segment2_G =~ w_Segment2_G;
	
	
endmodule // UART_RX_TOP