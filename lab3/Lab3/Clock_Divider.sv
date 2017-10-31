 //===================================================================
  /*
   * 
   *FSM_Master.sv Update Time: Oct.18.2017 9.53 P.M.
	*This module is master_FSM is used to communicate with slave_FSM. After it receive
	*singal from keyboard_FSM, it will decide to reset, play or pause. It will transfer signal to 
	*slave_FSM to start and also deal the address for flash_mem_controller 
   *
   */
  //===================================================================

module Clock_Divider(inclk,outclk,outclk_Not,div_clk_count,Reset);
    input inclk;
	 input Reset;
    output reg outclk = 0;
	 output outclk_Not;
	 input[31:0] div_clk_count;
	 
	 reg [31:0] count;
	 assign outclk_Not = ~outclk;
	 
	 always @ (posedge inclk)
	 begin
		if (Reset)
		begin
			count = 0;
			outclk = 0;
		end
		else
		begin
			if (count < div_clk_count)
				count = count + 1;
			else
			begin 
				outclk = ~outclk;
				count = 0;
			end	
		end
	 end
endmodule
//copied from Lab1