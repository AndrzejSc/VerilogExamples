module Clocked_Logic (
	input i_Clk,
	input i_Switch_1,		// Button
	output o_LED_1;)		// Led	
	
	reg r_LED_1 = 1'b0;
	reg r_Switch_1 = 1'b0;
	
	
	
	
	
	
	// Wykonywany gdy zadzieje się coś z listy wrazliwosci
	// Zawiera najczesciej kod sekwencyjny
	always @(posedge i_Clk)
		begin
			// <= - używane dla przypisania cos do rejestrów
			r_Switch_1 <= i_Switch_1; 		// Tworzymy rejestr
			
			// jesli akutalna swich 1 = 1 i poprzednia wartosc r_Switch_1 = 0
			// to mamy opadajace zbocze na Sw1
			if( i_Switch_1 == 1'b0 && r_Switch_1 == 1'b1)
				begin
					r_LED_1 <= ~r_LED_1; 		// Toggle the LED
			end
		end
		
		
	assign o_LED_1 = r_LED_1;

endmodule