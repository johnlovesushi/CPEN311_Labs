//==============================================================================
module Address_Ctrl(input CLK_50M, input [7:0] kbd_received_ascii_code, output [1:0] address_ctrl);

//Uppercase Letters
parameter character_A =8'h41;
parameter character_B =8'h42;
parameter character_C =8'h43;
parameter character_D =8'h44;
parameter character_E =8'h45;
parameter character_F =8'h46;
parameter character_G =8'h47;
parameter character_H =8'h48;
parameter character_I =8'h49;
parameter character_J =8'h4A;
parameter character_K =8'h4B;
parameter character_L =8'h4C;
parameter character_M =8'h4D;
parameter character_N =8'h4E;
parameter character_O =8'h4F;
parameter character_P =8'h50;
parameter character_Q =8'h51;
parameter character_R =8'h52;
parameter character_S =8'h53;
parameter character_T =8'h54;
parameter character_U =8'h55;
parameter character_V =8'h56;
parameter character_W =8'h57;
parameter character_X =8'h58;
parameter character_Y =8'h59;
parameter character_Z =8'h5A;

enum logic[4:0]{
		Idle_Forward   =	5'b000_11, //address_ctrl == 11: reset address to 0
		Idle_Backward  =	5'b001_10, //address_ctrl == 10:address does not change
		Start_Forward  =	5'b010_01, //address_ctrl == 01:address increases
		Start_Backward =  5'b011_00, //address_ctrl == 00:address decreases
		Pause_Forward  =  5'b100_00,
		Pause_Backward =  5'b101_00
} state;

//logic [4:0] state;
assign address_ctrl = state[1:0];

always_ff @ (posedge CLK_50M)
begin
	if (kbd_received_ascii_code == character_R)
      state = Idle_Forward;	//Idle_Forward is the reset state
  	else begin
    	case (state)
        Idle_Forward:  if (kbd_received_ascii_code == character_E) state <= Start_Forward;
        							 else if (kbd_received_ascii_code == character_B) state <= Idle_Backward;
        Idle_Backward: if (kbd_received_ascii_code == character_E) state <= Start_Backward;
                       else if (kbd_received_ascii_code == character_F) state <= Idle_Forward;
        Start_Forward: if (kbd_received_ascii_code == character_B) state <= Start_Backward;
        							 else if (kbd_received_ascii_code == character_D) state <= Pause_Forward;
        Start_Backward:if (kbd_received_ascii_code == character_F) state <= Start_Forward;
        							 else if (kbd_received_ascii_code == character_D) state <= Pause_Backward;
        Pause_Forward: if (kbd_received_ascii_code == character_E) state <= Start_Forward;
       								 else if (kbd_received_ascii_code == character_B) state <= Pause_Backward;
		  Pause_Backward:if (kbd_received_ascii_code == character_E) state <= Start_Backward;
                       else if (kbd_received_ascii_code == character_F) state <= Pause_Forward;
        default: state <= Idle_Forward;
      endcase
  	end
end
endmodule
