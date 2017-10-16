module flash_mem_FSM (input logic clk_50MHz,clk_22,ready_to_read,
					  input logic [1:0] address_ctrl,
					  //inout logic flag,
            input logic [31:0] Song_Data,	//flash_mem_readdata
					  output logic startFlash,read,
					  output [3:0] byteenable,
                        output logic [15:0] Output_Data,
                        output logic [3:0] state,
                        output logic [15:0] audio_data);		  
					    
//address_ctrl == 11: reset address to 0
//address_ctrl == 00:address does not change
//address_ctrl == 01:address increases
//address_ctrl == 10:address decreases
  //logic state = [3:0];
		//parameter address_Max = 0x7FFFF;
  parameter [3:0] idle = 4'b000_0;
  parameter [3:0.........
  0] readFlash_Forward = 4'b001_1;
  parameter [3:0] readFlash_Backward = 4'b010_1;
  parameter [3:0] ReadData = 4'b011_0;
  parameter [3:0] Read_AudioData = 4'b100_0;
  parameter [3:0] Finish = 4'b101_0;
		/*enum {
		idle   					 = 4'b000_0,
		readFlash_Forward     = 4'b001_1,
		readFlash_Backward    = 4'b010_1,
		ReadData              = 4'b011_0,
		Read_AudioData        = 4'b100_0,
		Finish                = 4'b101_0
	} state;
  */
  
			assign byteenable = 4'b1111;
			assign read = state[0]; 
			//assign finsih = state[2];
  		logic [31:0] address, next_address;
  		logic flag, next_flag;
			
			
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
														next_address <= address;
													end
												2'b11: 
													begin
														state <= idle;
														next_address <= 0;
													end
										endcase
								end		
								readFlash_Forward:begin
										if(flag == 1'b0) begin //read the lower half
											next_address <= address;
											next_flag <= 1'b1;	//next is the upper half
											end
										else begin
											next_address <= address + 1;	//read the lower half of the next address
											next_flag <= 1'b0;
										end
										if(ready_to_read) state <= ReadData;
								end		
										
								readFlash_Backward:begin
										if(flag == 1'b0) begin 	//read the upper half of the last address
											next_address <= address - 1;
											next_flag<= 1'b1;
										end
										else begin 	// read the lower half of this address
											next_address <= address;
											next_flag <= 1'b0;
										end
										if(ready_to_read) state <= ReadData;
								end
								ReadData: state <= Read_AudioData;
								
								Read_AudioData:begin
									//if(clk_22KHz == 1) begin
										if(flag == 1'b0 ) 
											Output_Data =  Song_Data[15:0];
										else begin 
											Output_Data = Song_Data [31:16];
											state <= idle;
										end
								end  
								default: begin 
										next_address <= address; 
										Output_Data <= Output_Data;
								end
				endcase
		end
		always_ff @(posedge clk_22) begin
      audio_data <= Output_Data;
      address <= next_address;
		end
endmodule			