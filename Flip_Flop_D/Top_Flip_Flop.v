module Top_Flip_Flop 
	( input [15:0] 	i_Data_In,
	  input 		i_Clk,
	  input			i_Reset,
	  input			i_Wr,		// Sygnał do wpisania danych
	  input			i_A,
	  input			i_B,
	  input			i_C,
	  input			i_D,
	  output		o_E,
	  output [15:0] o_Data_Out
	
	);
	
	flip_flop #(.LENGTH(16)) my_Flip_Module
	(.i_Clk		(i_Clk),
	 .i_Data	(i_Data_In),
	 .i_Reset	(i_Reset),
	 .i_Enable	(i_Wr),
	 .o_Output	(o_Data_Out) );
	 
	 wire w_wynik;
	 // (a and b) xor not(c or d)
	 assign w_wynik = (i_A & i_B) ^ !( i_C || i_D);
	 assign o_E = w_wynik & o_Data_Out[4];
	 
endmodule