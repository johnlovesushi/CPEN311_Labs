module LED_display(clk, LED);
	input clk;
	output logic [7:0] LED = 8'b1;
	logic direction = 0;
	
	always @ (posedge clk)
    begin
		if (direction == 0)
		begin
			if (LED < 8'b1000_0000)
				LED <= LED << 1;
			else 
			begin
				direction = ~direction;
				LED <= LED >> 1;
			end
		end
		else
		begin
			if (LED > 8'b0000_0001)
				LED <= LED >> 1;
			else 
			begin
				direction = ~direction;
				LED <= LED << 1;
			end
		end
	end
endmodule
