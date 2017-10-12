module Edge_Detect(input logic CLK_50, CLK_22, output logic clk);
  always @(posedge CLK_50)    
  begin
    if (CLK_22)
      clk <= 1'b1;
    else clk <= 1'b0;
  end
endmodule
