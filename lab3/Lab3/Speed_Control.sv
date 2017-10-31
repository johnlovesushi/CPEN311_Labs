//==============================================================
/*
 * Speed_Control  Updated Time: Oct.18.2017 7.04 P.M.
 * This module is used to speed up or speed down the frequency. Basically we calculate the time 
 * for frequency 22kHz(470 shown in 7 seg). We can press (Key0,Key1 and Key2) to speed up, speed down 
 * or reset frequency by adding, subtracting the count for 22kHz. And we set boundary for the frequency 
 *  (0 to 470*2)
 * Input: Speed_up, Speed_down and spped_reset (Key0, Key1 and Key2) to control the frequency
 * Input:async_sig (22 kHz) is used to as the clk for audio_signal
 *
 */

//=============================================================
module Speed_Control(input speed_up, speed_down, speed_reset, clk, output logic [31:0] count);	

	parameter Count_22K = 32'h470;	//default value for 22K Hz
	logic [31:0] temp_count = Count_22K;
	assign count = temp_count;
	
	always_ff @(posedge clk) begin 
		casex ({speed_down, speed_up, speed_reset}) // reset is state[0], speed_up is state[1], and speed_down is state[2]
			3'bxx1: temp_count <= Count_22K; 	//reset to back to 
			3'bx1x: if (count >= 32'h10) temp_count <= count - 32'h10; else  temp_count <= count; // condition for upper boundary
			3'b1xx: if (count <= 32'h8D0) temp_count <= count + 32'h10; else temp_count <= count; // condition for lower boundary
			default: temp_count <= count;  
		endcase 
	end 
endmodule
