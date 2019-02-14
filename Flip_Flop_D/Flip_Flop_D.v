// przerzutniki o parametryzowanej długości słowa
// wejściowego. Na rejestrach równoległych

module flip_flop 
	#( parameter LENGTH = 8)
	 ( input 				i_Clk,
	   input [LENGTH-1:0]	i_Data,
	   input				i_Reset,
	   input				i_Enable,
	   output reg [LENGTH-1:0] o_Output
	);
	
	
	always @(posedge i_Clk or posedge i_Reset)
	begin
		if(i_Reset) o_Output <= {LENGTH{1'b0}};
		else if (i_Enable) o_Output <= i_Data;
	
	end // always
	
endmodule