module LFSR (input clk, 
				 output logic [4:0] lfsr);
	//giving lfsr a non-zero inital value
	initial lfsr = 1;
	always @(posedge clk)
		lfsr <= {(lfsr[2]^lfsr[0]), lfsr[4],lfsr[3],lfsr[2],lfsr[1]};
endmodule
 