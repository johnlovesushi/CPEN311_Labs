//==============================================================================
/*
 *Address_Ctrl updated date: Oct,16,2017 9.20 P.M.
 * 	This method is used to address the input from keyboard and then output correct
 *    signal to Address_Process method. 
 *  Output : dir (direction), play (play the audio), rst (reset the audio)
 *  Input : CLK_50M , kbd_received_ascii_code (ascii_code from keyboard)
 */
//==============================================================================
module Address_Ctrl(input CLK_50M, input [7:0] kbd_received_ascii_code, output dir, play, rst);

//Uppercase Letters
parameter character_B =8'h42; //backwards
parameter character_D =8'h44;	//pause
parameter character_E =8'h45;	//start
parameter character_F =8'h46;	//forward 
parameter character_R =8'h52;	//reset

											//dir, play, rst  
  enum logic[5:0]{
  	Reset_Forward  =  6'b001_111, //dir = 1 forward,  play = 1 play, rst = 1 reset
  	Reset_Backward =  6'b010_011, //dir = 0 backward, play = 1 play, rst = 1 reset
    Idle					 =	6'b000_100, //dir = 1 forward,  play = 0 not play, rst = 0 not reset
		Start_Forward  =	6'b011_110, //dir = 1 forward,  play = 1 play, rst = 0 not reset 
		Start_Backward =  6'b100_010, //dir = 0 backward, play = 1 play, rst = 0 not reset
		Pause_Forward  =  6'b101_100, //dir = 1 forward,  play = 0 not plat, rst = 0 not rst
		Pause_Backward =  6'b110_000  //dir = 0 backward, play = 0 not play, rst = 0 not rst
} state;

//logic [4:0] state;
  assign dir = state[2];	//1: forward, 0: backward
  assign play = state[1]; //1: play, 0: pause
  assign rst = state[0];	//1: reset the address

always_ff @ (posedge CLK_50M)
begin
	if (kbd_received_ascii_code == character_R)
    begin
      if (state == Idle) state <= Idle;
      else
        if (dir) state <= Reset_Forward;
      	else state <= Reset_Backward;
    end 
  	else begin
    	case (state)
        Idle				:  if (kbd_received_ascii_code == character_E) state <= Start_Forward;
        else if (kbd_received_ascii_code == character_B) state <= Pause_Backward;	//idle_
        Start_Forward: if (kbd_received_ascii_code == character_B) state <= Start_Backward;
        							 else if (kbd_received_ascii_code == character_D) state <= Pause_Forward;
        Start_Backward:if (kbd_received_ascii_code == character_F) state <= Start_Forward;
        							 else if (kbd_received_ascii_code == character_D) state <= Pause_Backward;
        Pause_Forward: if (kbd_received_ascii_code == character_E) state <= Start_Forward;
       								 else if (kbd_received_ascii_code == character_B) state <= Pause_Backward;
			  Pause_Backward:if (kbd_received_ascii_code == character_E) state <= Start_Backward;
                       else if (kbd_received_ascii_code == character_F) state <= Pause_Forward;
        Reset_Forward: if (kbd_received_ascii_code == character_D) state <= Pause_Forward;
                       else if (kbd_received_ascii_code == character_B) state <= Start_Backward;
        Reset_Backward:if (kbd_received_ascii_code == character_D) state <= Pause_Backward;
                       else if (kbd_received_ascii_code == character_F) state <= Start_Forward;
        default: state <= Idle;
      endcase
  	end
end
endmodule