  //==========================================================
  /*
   * 
   *Slave.sv Update Time: Oct.18.2017 9.51 P.M.
	*This module is used to communicate with FSM_Master module and send back signal to tell master
	*that it is ready to read data, and this module is used to communicate with falsh_mem_controller, and send signal to 
	*flash_mem_controller and receive data from it then transfer it back to FSM_Master. It is controlled by the signal 'start'
	*from FSM_Master
   *
   */
  //============================================================
											//flash_mem_readdatavalid
module FSM_Slave(input clk, start, ready_to_read, waitrequest,
							  input [31:0] flash_data,
                       output read, finish,
							  output logic [31:0]return_data,
                       output [3:0] byteenable);  
  
  enum logic[4:0]{
  	idle						=5'b000_00,
	handle_read_op			=5'b001_10,
	wait_read				=5'b010_10,
	strobe_read				=5'b011_10,
	finished					=5'b100_01
} state; //define all states in this FSM

  assign read = state[1]; // read signal as state[1]
  assign finish = state[0]; // finsih signal as state[0]
  assign byteenable = 4'b1111;	//read the whole 32 bits
  
  always_ff @(posedge clk) begin 
    case(state)
      idle: 				begin if (start) state <= handle_read_op; end	//start reading process when received command from master
      handle_read_op: 	state <= wait_read;  // wait to read data from falsh_mem_controller
      wait_read:			if (!waitrequest) state <= strobe_read; // if we received from falsh_mem_controller, we will go to strobe_read
      strobe_read: 		state <= finished;
      finished:			state <= idle;	//send finish signal to master
      default: 			state <= idle;
    endcase
  end
  
  always_ff @ (posedge ready_to_read)	//check whether the data is ready
    begin
		return_data <= flash_data;
    end

endmodule
