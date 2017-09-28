module Clock_Divider_top(inclk,outclk,outclk_Not,div_clk_count,Reset);
    input inclk;
	 input Reset;
    output reg outclk = 0;
	 output outclk_Not;
	 input[31:0] div_clk_count;
	 
	 reg [31:0] count;
	 assign outclk_Not = ~outclk;
	 
	 always @ (posedge inclk)
	 begin
		if (Reset)
		begin
			count = 0;
			outclk = 0;
		end
		else
		begin
			if (count < div_clk_count)
				count = count + 1;
			else
			begin 
				outclk = ~outclk;
				count = 0;
			end	
		end
	 end
endmodule
