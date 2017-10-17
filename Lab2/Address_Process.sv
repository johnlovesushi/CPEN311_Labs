 //==========================================================
  /*
   * 
   *Address_Process.sv Update Time: Oct.16.2017 9.51 P.M.
   *
   */
  //============================================================

//												CLK_22K_Sync												flash_mem_addr
module Address_Process(input clk, dir, play, rst,ready_to_read,change_addr, 
                       output [31:0] addr, 
                       output flash_read_check_signal);
  
	parameter Max_addr = 32'h7FFFF;// maximum audio data address
  reg [3:0] state;
  // states
  parameter idle = 4'b000_0;
  parameter Read_Flash = 4'b001_1;
  parameter Read_AudioData  = 4'b010_0;
  //parameter Read_AudioData = 4'b011_0;
  //parameter Finish = 4'b100_0;
  
  assign flash_read_check_signal = state[0];
  always@ (*) begin
    if (rst) addr = 0;
    
    			state <= idle;
    else
      
      	case(state)
        			
          idle: state <= Read_Flash;
          Read_Flash: if(ready_to_read)
            							state <= Read_AudioData;
          Read_AudioData:
            if(play)  begin//check whether it is pause, if it is pause, the address won't change, 
              if(dir == 1 && change_addr == 1)begin
                  	if(addr >= 32'h7FFFF)
														addr <= 32'h0;  
										else
														addr <= addr + 1'b1;
                	end
              else if (dir == 0 && change_addr == 0)
                  begin
                    if(addr <= 32'h0)
														addr <= 32'h7FFFF;
										else
														addr <= addr - 1'b1;
									end
              			state <= idle;  // after all conditions, we will move to next satate
						end
            else 
              			state <= Read_AudioData;  // since no address is updated, we keep in Read_AudioData state
          	default: state <= idle;
        endcase   
  end
endmodule