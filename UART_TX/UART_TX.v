// Parametr CLKS_PER_BIT:
// CLKS_PER_BIT = Freq of clock / Freq of UART_TX
// ex. (25MHz) 25 000 000 / 115200 = 217


module UART_TX 
	# (parameter CLKS_PER_BIT = 217)

	( input 		i_Clk,
	  input 		i_TX_Data_Valid,	// Flaga, Data Valid - Flaga mówiąca czy mamy wysyłać
	  input [7:0] 	i_TX_Byte,	// Bajt do wysłania
	  output 		o_TX_Active,
	  output reg 	o_TX_Serial,
	  output 		o_TX_Done	  
	  );
	  
	  // Stany maszyny
	  parameter IDLE 			= 3'b000;
	  parameter TX_START_BIT	= 3'b001;
	  parameter TX_DATA_BITS	= 3'b010;
	  parameter TX_STOP_BIT		= 3'b011;
	  parameter CLEANUP			= 3'b100;
	  
	  reg [2:0]	r_SM_Main		= 0;
	  reg [7:0] r_Clock_Count	= 0;
	  reg [2:0] r_Bit_Index		= 0;
	  reg [7:0] r_TX_Data		= 0;	// Bufor pośredniczący, który zapisuje, to co mamy wysłać
	  reg		r_TX_Done		= 0;
	  reg		r_TX_Active		= 0;
	  
	  
	  always @(posedge i_Clk)
	  begin
	  
		case (r_SM_Main)
		IDLE: 					// Stan bezczynny - oczekiwanie na i_TX_DV = 1
			begin
				o_TX_Serial		<= 1'b1;		// W stanie bezczynnym linia TX = 1
				r_TX_Done		<= 1'b0;
				r_Clock_Count	<= 0;
				r_Bit_Index		<= 0;
				
				if(i_TX_Data_Valid == 1'b1) 	// Jeśli na wejsciu mamy Data_Valid = 1, to zaczynamy nadawac
				begin							// Zaczynamy transmisje
					r_TX_Active	<= 1'b1;
					r_TX_Data	<= i_TX_Byte;	// Zapisujemy otrzymay bajt do bufora
					r_SM_Main	<= TX_START_BIT;	
				end // i_TX_DV == 1'b0
				
				else 	//i_TX_Data_Valid != 1
					r_SM_Main <= IDLE;
			end // case IDLE
			
		TX_START_BIT:			// Wysyłamy bit startu = 0
			begin
				o_TX_Serial	<= 1'b0;
				
				// Czekamy 1 pełny czas trwania 1 bity (CLKS_PER_BIT)
				if(r_Clock_Count < CLKS_PER_BIT-1)
					begin
						r_Clock_Count 	<= r_Clock_Count + 1;
						r_SM_Main		<= TX_START_BIT;
					end // r_Clock_Count < CLKS_PER_BIT-1
				else // r_Clock_Count == CLKS_PER_BIT-1
					r_Clock_Count <= 0;
					r_SM_Main <= TX_DATA_BITS;
			end // case TX_START_BIT
			
		TX_DATA_BITS:
			begin
				o_TX_Serial <= r_TX_Data [r_Bit_Index];
				
				if(r_Clock_Count < CLKS_PER_BIT-1)
				begin
					r_Clock_Count <= r_Clock_Count + 1;
					r_SM_Main <= TX_DATA_BITS;	
				end	//r_Clock_Count < CLKS_PER_BIT-1
				
				else // r_Clock_Count = CLKS_PER_BIT-1
				begin			
					r_Clock_Count <= 0;
		
					if( r_Bit_Index < 7)		// Sprawdzamy czy wszystkie bity zostały wysłane
					begin
						r_Bit_Index <= r_Bit_Index + 1;
						r_SM_Main <= TX_DATA_BITS;
					end	// if r_Bit_Index < 7
					
					else // r_Bit_Index == 7
					begin
						r_Bit_Index <= 0;
						r_SM_Main <= TX_STOP_BIT;
					end	// else r_Bit_Index == 7
				end	// else r_Clock_Count = CLKS_PER_BIT-1
			end // case TX_DATA_BITS
			
		TX_STOP_BIT:			// Wysyłamy bit stopu
			begin
				o_TX_Serial <= 1'b1;		// Stan 1 na wyjściu
				
				if(r_Clock_Count < CLKS_PER_BIT-1)
				begin	
					r_Clock_Count <= r_Clock_Count + 1;
					r_SM_Main <= TX_STOP_BIT;
				end // r_Clock_Count < CLKS_PER_BIT-1
			
				else // r_Clock_Count == CLKS_PER_BIT-1
				begin
					// Kończymy transmisje, ustawiamy flagi
					r_TX_Done 		<= 1'b1;
					r_TX_Active		<= 1'b0;
					r_Clock_Count 	<= 0;
					r_SM_Main 		<= CLEANUP;
				end // else r_Clock_Count == CLKS_PER_BIT-1
			end // case TX_STOP_BIT
	  
		CLEANUP:
			begin
				r_TX_Done <= 1'b1;
				r_SM_Main <= IDLE;
			end // case CLEANUP
			
		default:
			r_SM_Main <= IDLE;
		endcase
	  end // always @(posedge i_Clk)
	  
	  
	  assign o_TX_Active = r_TX_Active;
	  assign o_TX_Done = r_TX_Done;
	  
endmodule