module Leds_Blink_Top (
	input i_Clk,
	output o_LED_1,
	output o_LED_2,
	output o_LED_3,
	output o_LED_4);
	
	// Input Clock is 25MHz
	// Liczby w nawiasach, to parametry przekazywane jakby do modułu,
	// wskazują do ilu ma liczyć licznik aby zmienić diody
	Led_Blinks#(
				.g_limit_for_10Hz(1250000),
				.g_limit_for_5Hz(2500000),
				.g_limit_for_2Hz(6250000),
				.g_limit_for_1Hz(12500000)) MyLedBlinkInstante
		(.i_Clk(i_Clk),
		 .o_LED_1(),		// Można tak :)
		 .o_LED_2(o_LED_2),
		 .o_LED_3(o_LED_3),
		 .o_LED_4(o_LED_4));
		 
endmodule