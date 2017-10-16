module Address_processing (input logic clk_50MHz,clk_22,ready_to_read,
								input logic [1:0] address_ctrl,
								//inout logic flag,
								input logic [31:0] Song_Data,	//flash_mem_readdata
								output logic startFlash,read,
								output [3:0] byteenable,
								output logic [15:0] audio_data,
								output logic [22:0] address
								);		  
					    
//address_ctrl == 11: reset address to 0
//address_ctrl == 10:address does not change
//address_ctrl == 01:address increases
//address_ctrl == 00:address decreases
		//parameter address_Max = 0x7FFFF;
		enum logic [3:0]{
		idle   					 = 4'b000_0,
		readFlash_Forward     = 4'b001_1,
		readFlash_Backward    = 4'b010_1,
		ReadData              = 4'b011_0,
		Read_AudioData        = 4'b100_0,
		Finish                = 4'b101_0
	} state;
  
  
			assign byteenable = 4'b1111;
			assign read = state[0]; 
			assign startFlash = state[0];
			//assign finsih = state[2];
  		//logic [31:0] address;
  		logic flag;//, flag;
		logic [15:0] Output_Data;
			
			always_ff @(posedge clk_50MHz) begin
					case(state) 
							idle:begin
										case(address_ctrl)
												2'b01: 
													begin
														state <= readFlash_Forward;
													end
												2'b00: 
													begin
														state <= readFlash_Backward;
													end
												2'b10: 
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
										if(flag == 1'b0) begin //read the lower half
											address <= address;
											flag <= 1'b1;	//next is the upper half
											end
										else begin
											address <= address + 1;	//read the lower half of the next address
											flag <= 1'b0;
										end
										if(ready_to_read) state <= ReadData;
								end		
										
								readFlash_Backward:begin
										if(flag == 1'b0) begin 	//read the upper half of the last address
											address <= address - 1;
											flag<= 1'b1;
											end
										else begin 	// read the lower half of this address
										  address <= address;
                      flag <= 1'b0;
										end
										if(ready_to_read) state <= ReadData;
										end
								ReadData: state <= Read_AudioData;
								Read_AudioData:
									if(clk_22 == 1) begin
										if(flag == 1'b0 ) Output_Data = Song_Data[15:0];
										else Output_Data = Song_Data[31:16];
										state <= idle;
									end
								default: begin 
										address <= address; 
										Output_Data <= Output_Data;
								end
				endcase
		end
/*		
		always_ff @(posedge clk_22)
		begin
      audio_data <= Output_Data;
      address <= address;
		end*/
endmodule			