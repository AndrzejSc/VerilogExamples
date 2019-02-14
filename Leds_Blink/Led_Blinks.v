module Led_Blinks 
	#(	parameter g_limit_for_10Hz = 1250000, 
		parameter g_limit_for_5Hz  = 2500000,
		parameter g_limit_for_2Hz  = 6250000,
		parameter g_limit_for_1Hz  = 12500000		
		)
	(input i_Clk,
	output reg o_LED_1 = 1'b0,
	output reg o_LED_2 = 1'b0,
	output reg o_LED_3 = 1'b0,
	output reg o_LED_4 = 1'b0);
	
	reg [31:0] counter_10Hz = 0;
	reg [31:0] counter_5Hz = 0;
	reg [31:0] counter_2Hz = 0;
	reg [31:0] counter_1Hz = 0;
	
	// Code for diode blinks 10Hz
	always@(posedge i_Clk)
	begin
		if(counter_10Hz == g_limit_for_10Hz)
		begin
			o_LED_1 <= ~o_LED_1;
			counter_10Hz <= 0;
		end
		else counter_10Hz <=counter_10Hz + 1;
	end // for 10Hz
	
	// Code for diode blinks 5Hz
	always@(posedge i_Clk)
	begin
		if(counter_5Hz == g_limit_for_5Hz)
		begin
			o_LED_2 <= ~o_LED_2;
			counter_5Hz <= 0;
		end
		else counter_5Hz <=counter_5Hz + 1;
	end // for 5Hz
	
	// Code for diode blinks 2Hz
	always@(posedge i_Clk)
	begin
		if(counter_2Hz == g_limit_for_2Hz)
		begin
			o_LED_3 <= ~o_LED_3;
			counter_2Hz <= 0;
		end
		else counter_2Hz <=counter_2Hz + 1;
	end // for 2Hz
	
	// Code for diode blinks 1Hz
	always@(posedge i_Clk)
	begin
		if(counter_1Hz == g_limit_for_1Hz)
		begin
			o_LED_4 <= ~o_LED_4;
			counter_1Hz <= 0;
		end
		else counter_1Hz <=counter_1Hz + 1;
	end // for 1Hz
	
endmodule