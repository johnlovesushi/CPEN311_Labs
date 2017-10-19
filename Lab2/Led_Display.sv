module LED_display(clk, LED, lock);
	input clk, lock;
	output logic [9:0] LED = 10'b1;
	logic direction = 0;
	
	always @ (posedge clk)
	if (!lock)
		 begin
			if (direction == 0)
			begin
				if (LED < 10'b00_1000_0000)
					LED <= LED << 1;
				else 
				begin
					direction = ~direction;
					LED <= LED >> 1;
				end
			end
			else
			begin
				if (LED > 10'b00_0000_0001)
					LED <= LED >> 1;
				else 
				begin
					direction = ~direction;
					LED <= LED << 1;
				end
			end
		end
	else LED <= 10'b11_1111_1111;
endmodule
