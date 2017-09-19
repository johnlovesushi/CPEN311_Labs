module SW_CONFIG(sw0, sw1, sw2, sw3, out);
	input sw0, sw1, sw2, sw3;
	output logic [31:0] out;
	
	always@(*)
	begin
		case({sw3,sw2,sw1,sw0})
			4'b0001: out = 32'hBA9E;  //Do 95547 
			4'b0011: out = 32'hA65A;  //Re 47797 
			4'b0101: out = 32'h942D;  //Mi 37933 
			4'b0111: out = 32'h8BE6;  //Fa 35814 
			4'b1001: out = 32'h7C8D;  //So 31926 
			4'b1011: out = 32'h6EF7;  //La 25327 
			4'b1101: out = 32'h62DB;  //Si 28406 
			4'b1111: out = 32'h5D50;  //Do 23899
			default: out = 32'h0;     //default value
		endcase
	end
endmodule 