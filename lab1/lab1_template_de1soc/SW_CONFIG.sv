module SW_CONFIG(sw0, sw1, sw2, sw3, out);
	input sw0, sw1, sw2, sw3;
	output [31:0] out;
	always@(*)
	begin
		case({sw3,sw2,sw1,sw0})
			4'b0001: out = 8'hBA9E;  //Do 95547 Hex:A65A
			4'b0011: out = 8'hA65A;  //Re 47797 Hex:BAB5
			4'b0101: out = 8'h942D;  //Mi 37933 Hex:942D	???
			4'b0111: out = 8'h8BE6;  //Fa 35814 Hex:8BE6
			4'b1001: out = 8'h7C8D;  //So 31926 Hex:7CB6
			4'b1011: out = 8'h62DB;  //La 25327 Hex:62EF
			4'b1101: out = 8'h6EF7;  //Si 28406 Hex:6EF7
			4'b1111: out = 8'h5D50;  //Do 23899 Hex:5D5B ???
			default: out = 8'h0;     //default value
		endcase
	end
endmodule 