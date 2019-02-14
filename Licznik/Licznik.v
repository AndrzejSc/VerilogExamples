// Dwukierunkowy licznik z synchronicznym wpisem równoległym
// i zerowaniem asynchronicznym
module licznik 
	#( parameter LENGTH = 4)
	( input			i_Clk,
	  input			i_Reset,
	  input			i_Direction,	// kierunek zliczania
	  input			i_Load_Signal,	// Sygnał do ładowania do rejestru 
	  input [LENGTH-1:0] i_Load_Data,	// dane do wpisania
	  output reg [LENGTH-1:0] o_Counter	// Wyjscie licznika
	);
	
	
	always @(posedge i_Clk or negedge i_Reset)
	begin
		if(!i_Reset)		// jeśli reset = 0,
			o_Counter <= {LENGTH{1'b0}};
		else if (i_Load_Signal)		// Jeśli sygnał do wpisania do rej = 1
			o_Counter <= i_Load_Data;
		else
			if(i_Direction)		// Zliczanie w góre
				o_Counter <= o_Counter + 1;
			else o_Counter <= o_Counter - 1;

	end // always
	
endmodule