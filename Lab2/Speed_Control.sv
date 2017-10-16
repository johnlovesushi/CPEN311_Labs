module Speed_Control(input speed_up, speed_down, speed_reset, clk, output logic [31:0] count = 32'h470);
	parameter Count_22K = 32'h470;
	always_ff @(posedge clk) begin 
		case ({speed_up, speed_down, speed_reset})
			3'b001: count <= Count_22K; 
			3'b010: count <= count - 32'h10; 
			3'b100: count <= count + 32'h10; 
			default: count <= count; 
		endcase 
	end 
endmodule
