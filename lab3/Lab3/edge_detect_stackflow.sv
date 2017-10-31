//==============================================================
/*
 * edge_detect  Updated Time: Oct.18.2017 6.56 P.M.
 * This module is used to synchronize 50_MHz and 22_kHz. When 22_kHz posedge, 
 * the output clk should have a positive pulse 
 * Input: outclk (50 MHz) is used as the clk for all the FSM except audio_signal genrate
 * Input:async_sig (22 kHz) is used to as the clk for audio_signal
 *
 */

//=============================================================

module edge_detect (input logic outclk, input logic async_sig, output logic out_sync_sig);
	logic Q_A, Q_B, Q_C, Q_D;
	parameter VCC = 1'b1;
	//parameter GND = 1'b1;
	
	edge_detect_FF_async FF_A (.clk(async_sig), .clr(!async_sig & Q_C), .d(VCC), .q(Q_A));  // first FF 
	edge_detect_FF_async FF_B (.clk(outclk), .clr(1'b0), .d(Q_A), .q(Q_B));  // second FF
	edge_detect_FF_async FF_C (.clk(outclk), .clr(1'b0), .d(Q_B), .q(Q_C));  // third FF
	edge_detect_FF_async FF_D (.clk(outclk), .clr(1'b0), .d(Q_C), .q(Q_D));  // fourth FF
	
	assign out_sync_sig = !Q_D & Q_C;
	
endmodule

module edge_detect_FF_async (input logic clk, input logic d, input logic clr, output logic q); // normal FF 
	always_ff @(posedge clk, posedge clr)
		if (clr)	q <= 1'b0;
		else 		q <= d;
endmodule

//based on lecture notes