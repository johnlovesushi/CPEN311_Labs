
 //==========================================================
  /*
   * 
   *FSM_Master.sv Update Time: Oct.18.2017 9.53 P.M.
	*This module is master_FSM is used to communicate with slave_FSM. After it receive
	*singal from keyboard_FSM, it will decide to reset, play or pause. It will transfer signal to 
	*slave_FSM to start and also deal the address for flash_mem_controller 
   *
   */
  //============================================================
module FSM_master (input clk, edge_clk, restart, play, dir, slave_finish,
                   output slave_start, finish,
                   input [31:0] flash_mem_data,
                   output logic [22:0] addr,
                   output logic [15:0] audio_signal
                   );
  
  assign finish = state[0];
  assign slave_start = state[1];

typedef enum logic [4:0] {  
	idle 						= 5'b000_00,   // idle
	start_read_addr  		= 5'b001_10,	//give start signal to slave
	wait_read_addr   		= 5'b010_00,   //wait_to_read
	wait_berct_lsb 		= 5'b110_00,   //wait_berct_lsb
	transfer_berct_lsb 	= 5'b011_00,   //read least_significant_bits [15:0]
	wait_berct_msb 		= 5'b111_00,   //wait_berct_msb
	transfer_berct_msb 	= 5'b100_00,   //read most_signifiant_bits [31:16]
	Finished           	= 5'b101_01	   //give finished signal to keyboard controller
} stateType;
stateType state = idle;
  
  
  always@(posedge clk) begin
	case(state)
		idle:				 		if(play) state <= start_read_addr;  // if play, then proceed to next state to start read 
		start_read_addr:  	state <= wait_read_addr;  // This state will transfer a signal to slave 
		wait_read_addr:   	if(slave_finish) state <= wait_berct_lsb;  // if slave send back finish_signal, and probably we already get 32 bits data 
		wait_berct_lsb:	 	if(edge_clk) state <=transfer_berct_lsb;	//wait for 22k pulse
		transfer_berct_lsb:  begin if (dir)audio_signal <= flash_mem_data[15:0]; else audio_signal <= flash_mem_data[31:16]; state <= wait_berct_msb; end 
		// if it is forward direction, we should send [15:0] to audio_signal first, then send [31:16] to audio_signal
		wait_berct_msb:		if(edge_clk) state <=transfer_berct_msb; // wait for another 22k pulse
		transfer_berct_msb:  begin if (dir)audio_signal <= flash_mem_data[31:16]; else audio_signal <= flash_mem_data[15:0]; state <= Finished; end 
		// if it is still forward direction, we should send [31:16] to audio_signal, otherwise we should send [15:0] to audio_signal
		Finished :				begin
									state <= idle;
									case(dir)
										1'b1: if (restart) addr = 0;   // if it is forward and restart, we set address back to 0
												else if (addr < 23'h7FFFF) addr <= addr + 1'b1; // if the addr not exceed max address , address directly + 1
												else addr <= 0;	//otherwise reset to 0
										1'b0: if (restart) addr = 23'h7FFFF;   
												else if (addr > 0) addr <= addr - 1'b1;
												else addr <= 23'h7FFFF;	//backward
									endcase
									end
      default: state <= idle;
    endcase
   end
endmodule
