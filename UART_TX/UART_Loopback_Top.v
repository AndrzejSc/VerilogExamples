module UART_Loopback_Top( 
	input i_Clk,
	input i_UART_RX,	// Dane odbierane 
	output o_UART_TX,	// Dane wysyłane
	
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
	
	wire [7:0] w_RX_Byte;
	wire w_RX_Data_Valid;
	wire w_TX_Serial, w_TX_Active;
	
	
	// Tworzymy instancje odbiornika UART
	UART_RX #(.CLKS_PER_BIT(217)) myUART_RX(
		.i_Clk(i_Clk),
		.i_RX_Serial(i_UART_RX),
		.o_RX_DV (w_RX_Data_Valid),
		.o_RX_Byte (w_RX_Byte)		
		);
	
	// Tworzymy instancje nadajnika UART
	UART_TX #(.CLKS_PER_BIT(217)) myUART_TX(
		.i_Clk(i_Clk),
		.i_TX_Data_Valid(w_RX_Data_Valid),
		.i_TX_Byte(w_RX_Byte),
		.o_TX_Active (w_TX_Active),
		.o_TX_Serial (w_TX_Serial),
		.o_TX_Done()	
	);
	
	assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1;
		
		
	
	
	
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

	
endmodule
