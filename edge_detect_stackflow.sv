module edge_detect(input CLK_50, CLK_22, output clk);

reg Q;

  always @(posedge CLK_50)    
  begin
    Q <= CLK_22;
  end  
  assign clk = CLK_22 & ~ Q;
endmodule