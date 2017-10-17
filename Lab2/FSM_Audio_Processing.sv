
 //==========================================================
  /*
   * 
   *FSM_Audio_Processing.sv Update Time: Oct.16.2017 9.53 P.M.
   *
   */
  //============================================================
module FSM_Audio_Processing(input edge_clk,
                            input [31:0] flash_mem_readdata,
														output reg change_addr,  
                            output reg [15:0] audio_signal );
	
   //input [1:0] fsm1_state,
  //output reg [1:0] fsm1_nextState,
  parameter lower_state = 1'b0;
  parameter upper_state = 1'b1;
	// 2'b11: Read lower 16 bits
	// 2'b10: Read upper 16 bits
  logic  state,Next_state;
  
  always @(posedge edge_clk)
    state <= Next_state;
	always @(*)
	begin
    case(state)
		  lower_state: 	begin
						Next_state <= upper_state;
						audio_signal <= flash_mem_readdata[15:0]; // has problem, remember to check it 
						change_addr <= 0; // tells address controller to update address if necessary
						end

		  upper_state:	begin
						Next_state <= lower_state;
						audio_signal <= flash_mem_readdata[31:16];
						change_addr <= 1;
						end

		  default: 		Next_state <= lower_state; 
		endcase
	end
	

	
endmodule
