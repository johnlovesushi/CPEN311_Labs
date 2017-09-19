module LED_display(clk, LED);
	input clk;
	output logic [7:0] LED = 8'b1;
  
  always @ (posedge clk)
    begin
      if(LED == 8'b10000000)
        	LED <= 8'b0000_0001;
      else
        LED = LED << 1; // left shift by 1 bit
    end
endmodule
