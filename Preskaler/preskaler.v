// Preskaler. Liczy od COUNT w dół i na wyjsciu daje
// impuls = 1, na czas 1 cyklu i_Clk

module preskaler 
	#( parameter LENGTH = 4,
	   parameter COUNT = 5)
	 (input			i_Clk,
	  input			i_Reset,
	  output		o_Pulse	 
	 );
	 
	 reg [LENGTH-1] r_counter;
	 
	 always @(posedge i_Clk or negedge i_Reset)
	 begin
		if (!i_Reset)	// Jeśli reset = 0
			r_counter <= {LENGTH{1'b0}};
		else if (o_Pulse)
			r_counter <= LENGTH;
			
		else r_counter <= r_counter - 1;
	 end // always
	 
	 assign o_Pulse = (r_counter == 0) ? 1'b1 : 1'b0;
endmodule