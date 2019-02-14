module Debounce_Switch (
	input i_Clk,
	input i_Switch,			// Sygnał, który chcemy zdebansować
	output o_Switch);		// Sygnał zdebansowany	
	
	reg r_State = 1'b0;			// Przefiltrowana zmienna
	reg [17:0] r_Count = 0;		// 18 bitowa zmienna, do zliczania max do 262144
	
	// Stała 
	parameter c_DEBOUNCE_LIMIT = 250000; // 10ms at 25MHz
	
	
	always @(posedge i_Clk)
	begin
		// Dla tego ifa nie dajemy begin i end, bo polecenie jest w  tylko 1 linijce
		// Jeśli zmienił akutalnie przycisk ma inną wartość niż zapisany w rejestrze r_State
		// oraz upłyneło mniej niż 10ms, to czekaj (r_Count+1)
		if(i_Switch !== r_State && r_Count < c_DEBOUNCE_LIMIT)
			r_Count <= r_Count + 1;		// Counter, 
			
			
		// Jesli upłyną czas, to zapisz aktualny stan przycisku do r_State	
		else if(r_Count == c_DEBOUNCE_LIMIT)
			begin
			r_Count <= 0;
			r_State <= i_Switch;
			 end
			
		// Zeruj licznik	
		else
			r_Count <= 0;
	
	end
	
	assign o_Switch = r_State;
endmodule // Debounce_Switch