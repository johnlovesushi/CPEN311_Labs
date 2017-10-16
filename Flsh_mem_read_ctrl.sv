data_processing (input logic clk_50MHz,clk_22KHz,dir,ready_to_read,
					  input logic [1:0] address_ctrl,
					  inout logic flag,
					  input logic [31:0] Song_Data,
					  output logic startFlash,read,
					  output [3:0] byteenable,
					  output logic [31:0] Output_Data);
					  
					  
					  
					  
					  
					  
					  
					    
//address_ctrl == 11: reset address to 0
//address_ctrl == 00:address does not change
//address_ctrl == 01:address increases
//address_ctrl == 10:address decreases
					  'define address_Max = 0x7FFFF
					    enum {
		idle   					 = 4'b000_0,
		readFlash_Forward     = 4'b001_1,
		readFlash_Backward    = 4'b010_1,
		ReadData              = 4'b011_0,
		Read_AudioData        = 4'b100_0,
		Finish                = 4'b101_0
	} state;
			/*
			parameter idle  									7'b0000_000;
			parameter readFlash_Forward 					7'b0001_001;
			parameter readData     							7'b0010
			parameter getData_1  							7'b0011
			parameter getData_2								7'b0100
			parameter check_Direction						7'b0101
			parameter Forward_Direction					7'b0110
			parameter Backward_Direction					7'b0111
			*/
			assign byteenable = 4'b1111;
			assign check_Flash_ready = state[0];
			assign read = state[0]; 
			assign finsih = state[2];
			
			
			
			always_ff @(posedge clk_50MHz) begin
					case(state) 
							
							idle:begin
										case(address_ctrl)
												2'b10: 
													begin
														state <= readFlash_Forward;
													end
												2'b01: 
													begin
														state <= readFlash_Backward;
													end
												2'b00: 
													begin
														state <= idle;
														address <= address;
													end
												2'b11: 
													begin
														state <= idle;
														address <= 0;
													end
										endcase
								end		
								readFlash_Forward:begin
										if(flag == 1'b0) begin 
											address <= address;
											flag <= 1'b1;
											end
										else begin
											address <= address + 1;
											flag <= 1'b0;
										end
										if(ready_to_read) state <= ReadData;
								end		
										
								readFlash_Backward:begin
										if(flag == 1'b0) begin 
											address <= address - 1;
											flag<= 1'b1;
										else begin 
										   address <= address;
											flag <= 1'b0;
										end
										if(ready_to_read) state <= ReadData;
								
										ReadData: state <= Read_AudioData;
								end
								Read_AudioData:begin
									if(clk_22KHz == 1) begin
										if(flag == 1'b0 ) Output_Data = [15:0] Song_Data;
										else Output_Data = [31:16] Song_Data;
										state <= idle;
									end
								end  
								default: begin 
										address <= address; 
										output_Data <= output_Data;
								end
								
				endcase
endmodule							
							
							
							
							
							
							