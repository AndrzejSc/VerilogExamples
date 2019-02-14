// Clocks per bit = freq i_Clk / freq of uart
// example 25MHz clock, 115200 baud rate 
// 25 000 000 / 115200 = 217


// Parametry: 8 bitów danych, 1 bit startu, 1 bit stopu, brak kontroli
// parzystosci.

// Gdy odbiór jest kompletny, sygnał o_RX_DV = 1 na czas jednego cyklu

module UART_RX
	# (parameter CLKS_PER_BIT = 217)
	( input i_Clk,
	  input i_RX_Serial,
	  output o_RX_DV, 			// pojedynczy impuls, czas 1 cykl, gdy dane zostanie odebrana
	  output [7:0] o_RX_Byte 	// bajt, jaki otrzymalismy z komputera
	  );
	  
	 // Działanie polaga na wykorzystaniu maszyny stanu
	 // Posczególne stany przedstawione poniżej
	 parameter IDLE 		= 3'b000;		// Oczekiwanie, stan bezczynny
	 parameter RX_START_BIT = 3'b001;		// Wykrycie bitu startu
	 parameter RX_DATA_BITS = 3'b010;		// Odczyt bitów
	 parameter RX_STOP_BIT	= 3'b011;		// Odczyt bitu stopu
	 parameter CLEANUP		= 3'b100;		// ??
	 
	 reg [7:0]	r_Clock_Count 	= 0; 		// Licznik, pozwalający na samlowanie sygnału w odpowiednim czasie
	 reg [2:0]	r_Bit_Index		= 0;		// 
	 reg [7:0]	r_RX_Byte		= 0;
	 reg 		r_RX_DV			= 0;		// 1 na czas 1 cyklu, gdy odebralismy poprawnie dane
	 reg [2:0]	r_SM_Main		= 0;		// Numer aktualnego stanu maszyny
	 
	 
	 always @(posedge i_Clk)
	 begin 
		case (r_SM_Main)
			// Oczekiwanie na bit startu, sygnał wejsciowy jest cały czas = 1
			IDLE: 				// State 1
			begin
				r_RX_DV			<= 0;		// Nie mamy poprawnie odebranych danych
				r_Clock_Count	<= 0;		// Zerujemy licznik
				r_Bit_Index		<= 0;		
				
				// Sprawdzamy sygnał przychodzący
				if(i_RX_Serial == 1'b0)			// Jeśli na wyjsciu pojawilo się cos innego niz 1
					r_SM_Main <= RX_START_BIT;	// Ustaw tryb maszyny na kolejny, sprawdzamy co to to przyszło
				else 							// 
					r_SM_Main <= IDLE;			// jeśli nie, to zostajemy tutej
			end	// case IDLE
				
			// Sprawdzamy, czy otrzymalismy bit startu	
			RX_START_BIT:		// State 2
			begin
				// Czekamy do połowy czasu trwania bitu i sprawdzamy co mamy na wejsciu
				if(r_Clock_Count == (CLKS_PER_BIT-1)/2)	// Samplujemy w połowie bitu, wiec licznik ilości
				begin									// cykli na bit dzielimy przez 2
					// Odczytujemy bit i zerujemy licznik
					if(i_RX_Serial == 1'b0)			// jesli na wejsciu mamy 0 to jest to bit startu
					begin 
						r_Clock_Count <= 0;	
						r_SM_Main <= RX_DATA_BITS;	// przechodzimy do trybu odczutu danych	
					end //if i_RX_Serial == 0 
					else r_SM_Main <= IDLE; 
				end // r_Clock_Count == CLKS_PER_BIT-1/2	
				
				else // Nie doliczylismy do ClksPerBit/2
					begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main <= RX_START_BIT;
					end					
			end // case RX_START_BIT
				
			RX_DATA_BITS:
			begin	
				// Teraz, czekamy jeden pełny czas trwania bitu, aby samplować w połowie nastepnego bitu
				if(r_Clock_Count < CLKS_PER_BIT-1)
					//Czekamy			
					begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main <= RX_DATA_BITS;
					end
					
				else // r_Clock_Count == CLKS_PER_BIT-1
					//Odczytujemy bit
					begin
						r_Clock_Count <= 0; 		// Zerujemy licznik
						r_RX_Byte[r_Bit_Index] <= i_RX_Serial;	// Zapisujemy bit wejsciowy w odpowiednie miejscie
						
						if(r_Bit_Index < 7)
							begin
								r_Bit_Index <= r_Bit_Index +1;
								r_SM_Main 	<= RX_DATA_BITS; 
							end //if r_Bit_Index<7
						else // r_Bit_Index == 7
							begin
							r_Bit_Index <= 0;
							r_SM_Main <= RX_STOP_BIT;
							end // r_Bit_Index ==7
					
					end // else r_Clock_Count == CLKS_PER_BIT
	
			end //case RX_DATA_BITS
			
			// Sprawdzamy, czy mamy bit stopu
			RX_STOP_BIT:
			begin
				if(r_Clock_Count < CLKS_PER_BIT-1)
				begin
					r_Clock_Count <= r_Clock_Count + 1;
					r_SM_Main <= RX_STOP_BIT;
				end 	//if r_Clock_Count < CLKS_PER_BIT-1
				
				else 	// r_Clock_Count == CLKS_PER_BIT-1
					begin
					r_RX_DV 		<= 1'b1;
					r_Clock_Count 	<= 0;
					r_SM_Main		<= CLEANUP;
					end// r_Clock_Count == CLKS_PER_BIT-1
			end //case RX_STOP_BIT
			
			// Stay here 1 clock i zeruj r_RX_DV
			CLEANUP:
				begin
					r_SM_Main 	<= IDLE;
					r_RX_DV 	<= 1'b0;
				end
				
			default:
				r_SM_Main <= IDLE;
				
		endcase
							
	end // always
	 
	 assign o_RX_DV = r_RX_DV;
	 assign o_RX_Byte = r_RX_Byte;
 endmodule // UART_RX 