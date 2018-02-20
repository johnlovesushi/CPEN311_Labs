module Modulation(input clk,	//50M hz
						input clk_sample,	//200 hz
						input [1:0] signal_selector,
						input [1:0] modulation_selector,
						input [1:0]ctrl,
						input qpsk,
						input [11:0] cos,
						input [11:0] sin,
						input [11:0] saw,
						input [11:0] squ,
						output [11:0] modulation,	//top
						output [11:0] signal);		//bottom
	
	logic [11:0] signal_temp, modulation_temp;
														//acutal singal
	always@* begin
		if		 (signal_selector[1:0] == 2'b00) signal_temp = sin; 
		else if(signal_selector[1:0] == 2'b01) signal_temp = cos; 
		else if(signal_selector[1:0] == 2'b10) signal_temp = saw; 
		else if(signal_selector[1:0] == 2'b11) signal_temp = squ; 
	end
	always@* begin
		if (qpsk) modulation_temp = ctrl[0]? (ctrl[1]? sin: ~sin+1): (ctrl[1]? cos: ~cos+1); 
		else if(modulation_selector[1:0] == 2'b00) modulation_temp = ctrl[0]? sin: 0; 
		else if(modulation_selector[1:0] == 2'b01) modulation_temp = sin; 
		else if(modulation_selector[1:0] == 2'b10) modulation_temp = ctrl[0]? (~sin+1): sin; 
		else if(modulation_selector[1:0] == 2'b11) modulation_temp = ctrl[0]? 12'b0:12'b100000000000;
	end
	//clock domain crossing (fast clock to slow clock)
	Clock_crossing sig (.fast_clk(clk), .slow_clk(clk_sample), .data_in(signal_temp), .data_out(signal));
	Clock_crossing mod (.fast_clk(clk), .slow_clk(clk_sample), .data_in(modulation_temp), .data_out(modulation));
	
endmodule

//reference: lecture slide - clock_skew_clock_domains
//"Moving data from fast clk1 to slower clk2"
module Clock_crossing (input fast_clk,
							  input slow_clk,
							  input [11:0] data_in,
							  output [11:0] data_out);
	
	logic [11:0] reg1_out, reg3_out;
	logic en, temp;
	
	DFFf #(12) reg1 (data_in,  1'b1, fast_clk, reg1_out);
	DFFf #(12) reg3 (reg1_out, en,   fast_clk, reg3_out);
	DFFf #(12) reg2 (reg3_out, 1'b1, slow_clk, data_out);
	
	DFFf #(1)  s1 	(slow_clk, 1'b1, ~fast_clk, temp);
	DFFf #(1)  s2 	(temp, 	  1'b1, ~fast_clk, en);
	
endmodule
//D FLIP-FLOP
module DFFf (d, enable, clk, q);
	parameter N = 1;
	input [N-1:0] d;
	input logic enable;
	input clk;
	output logic [N-1: 0] q;
	always_ff@(posedge clk)
		if(enable) q <= d;
		else q <= q;
	
endmodule

