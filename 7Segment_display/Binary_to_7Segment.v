module Binary_to_7Segment (
	input i_Clk,
	input [3:0] i_Binary_Num,		// Liczba 4 bitowa, wejście
	output o_Segment_A,
	output o_Segment_B,
	output o_Segment_C,
	output o_Segment_D,
	output o_Segment_E,
	output o_Segment_F,
	output o_Segment_G);
	
	reg [6:0] r_Hex_Encoding = 7'h00;		// 7 bitowy rejestr o wartosci 00
	
	always @(posedge i_Clk)
	begin
		case (i_Binary_Num)
			4'b0000: 	r_Hex_Encoding <= 7'h7E;	// 0111 1110 - 0
			4'b0001:	r_Hex_Encoding <= 7'h30;	// 0110 0000 - 1
			4'b0010:	r_Hex_Encoding <= 7'h6D;	// 0111 1001 - 2
			4'b0011:	r_Hex_Encoding <= 7'h79;	// 0011 0011 - 3
			4'b0100:	r_Hex_Encoding <= 7'h33;	// 0011 0011 - 4
			4'b0101:	r_Hex_Encoding <= 7'h5B;	// 0101 1011 - 5
			4'b0110:	r_Hex_Encoding <= 7'h5F;	// 0101 1111 - 6
			4'b0111:	r_Hex_Encoding <= 7'h70;	// 0111 0000 - 7
			4'b1000:	r_Hex_Encoding <= 7'h7F;	// 0111 1111 - 8
			4'b1001:	r_Hex_Encoding <= 7'h7B;	// 0111 1011 - 9
			4'b1010:	r_Hex_Encoding <= 7'h77;	// 0111 0111 - 10 - A
			4'b1011:	r_Hex_Encoding <= 7'h1F;	// 0001 1111 - 11 - B
			4'b1100:	r_Hex_Encoding <= 7'h4E;	// 0100 1110 - 12 - C
			4'b1101:	r_Hex_Encoding <= 7'h3D;	// 0011 1101 - 13 - D
			4'b1110:	r_Hex_Encoding <= 7'h4F;	// 0100 1111 - 14 - E
			4'b1111:	r_Hex_Encoding <= 7'h47;	// 0100 0111 - 15 - F
		endcase
	end // always @(posedge i_Clk)
	
	// r_Hex_Encoding[7] jest nieuztwany - bo potrzebujemy tylko 7 lini do wyswietlacza
	assign o_Segment_A = r_Hex_Encoding[6];
	assign o_Segment_B = r_Hex_Encoding[5];
	assign o_Segment_C = r_Hex_Encoding[4];
	assign o_Segment_D = r_Hex_Encoding[3];
	assign o_Segment_E = r_Hex_Encoding[2];
	assign o_Segment_F = r_Hex_Encoding[1];
	assign o_Segment_G = r_Hex_Encoding[0];
	
endmodule