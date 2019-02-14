module Clocked_Logic(
	input i_Clock,
	input i_Switch1,
	output o_LED1
	)
	
	// Rejestry 1 bitowe o wartosci 0
	reg r_LED = 1'b0;				// Zapamietuje stan diody	
	reg r_Switch1 = 1'b0;			// Zapamiętuje wartosc swicha 1
	
	// Może być uzyte wewnątrz oraz poza blokiem always
	wire w_Switch1;
	
	// Instantiate Debounce Filter
	// Typ modułu (musi się zgadzać) _ Nazwa modułu
	// (mapujemy sygnały z modułu (do naszych aktualnych)
	Debounce_Switch Instance (
		.i_Clock(i_Clock),	// Clock, w nawiasie podajemy nazwę obiektu, 
							// do któego zostanie przypusany
		.i_Switch(i_Switch1),	// Wejscie, przycisk bansujący
		.o_Switch(w_Switch1));	// Swich po filtracji
	
	
	
	
	always @(posedge i_Clock)
	begin
		r_Switch1 <= w_Switch1;		// Zapusisuje aktualny stan diody
		
		if((w_Switch1 == 1b'0) && (r_Switch1 == 1b'1)) 
		begin
			r_LED <= ~r_LED;
		end	
	end
	
	assign o_LED1 = r_LED;
	
endmodule
	