
`default_nettype none
`define USE_PACOBLAZE
module 
picoblaze_template
#(
parameter clk_freq_in_hz = 25000000
) (
				output reg led_0,
				output reg[7:0] led,
				input clk, interrupt_event,
				input [7:0] input_data
			     );

  
//--
//------------------------------------------------------------------------------------
//--
//-- Signals used to connect KCPSM3 to program ROM and I/O logic
//--
wire[9:0]  address;
wire[17:0]  instruction;
wire[7:0]  port_id;
wire[7:0]  out_port;
reg[7:0]  in_port;
wire  write_strobe;
wire  read_strobe;
reg  interrupt;
wire  interrupt_ack;
wire  kcpsm3_reset;

//--
//-- Signals used to generate interrupt 
//--
reg[26:0] int_count;

//-- Signals for LCD operation
//--
//--

//reg        lcd_rw_control;
//reg[7:0]   lcd_output_data;
pacoblaze3 led_8seg_kcpsm
(
                  .address(address),
               .instruction(instruction),
                   .port_id(port_id),
              .write_strobe(write_strobe),
                  .out_port(out_port),
               .read_strobe(read_strobe),
                   .in_port(in_port),
                 .interrupt(interrupt),
             .interrupt_ack(interrupt_ack),
                     .reset(kcpsm3_reset),
                       .clk(clk));

 wire [19:0] raw_instruction;
	
	pacoblaze_instruction_memory 
	pacoblaze_instruction_memory_inst(
     	.addr(address),
	    .outdata(raw_instruction)
	);
	
	always @ (posedge clk)
	begin
	      instruction <= raw_instruction[17:0];
	end

    assign kcpsm3_reset = 0;                       
  
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- Interrupt 
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  --
//  -- Interrupt is used to provide a 1 second time reference.
//  --
//  --
//  -- A simple binary counter is used to divide the 50MHz system clock and provide interrupt pulses.
//  --


 always @ (posedge clk or posedge interrupt_ack)  //FF with clock "clk" and reset "interrupt_ack"
 begin
      if (interrupt_ack) //if we get reset, reset interrupt in order to wait for next clock.
            interrupt <= 0;
      else
		begin 
		      if (interrupt_event)   //read one 
      		      interrupt <= 1;
          		else
		            interrupt <= 0;
      end
 end

//  --
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- KCPSM3 input ports 
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  --
//  -- The inputs connect via a pipelined multiplexer
//  --

always @ (posedge clk)
 begin
    case (port_id[7:0])
        8'h0:    in_port <= input_data;  // take absolute value to assembly code
        default: in_port <= 8'bx;
    endcase
end
   
//
//  --
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- KCPSM3 output ports 
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  -- adding the output registers to the processor
//  --
//   
always @ (posedge clk)
begin
	//LED is port 80 hex (1000_0000)
	if (write_strobe & port_id[7])
		led <= out_port;
	//LED is port 40 hex (0100_0000)
   if (write_strobe & port_id[6]) 	
		led_0 <= out_port;
end

/*always@* begin
	casex(led_temp)
		8'b1xxx_xxxx: led = 8'b1111_1111;
		8'b01xx_xxxx: led = 8'b1111_1110;
		8'b001x_xxxx: led = 8'b1111_1100;
		8'b0001_xxxx: led = 8'b1111_1000;
		8'b0000_1xxx: led = 8'b1111_0000;
		8'b0000_01xx: led = 8'b1110_0000;
		8'b0000_001x: led = 8'b1100_0000;
		8'b0000_0001: led = 8'b1000_0000;
		8'b0000_0000: led = 8'b0000_0000;
	endcase
end*/
//
//  --
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- always block to take the input_data to abs
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  -- adding the output registers to the processor
//  --
//   
/*reg [7:0] abs_input_data;
always @ (*) begin 
	if(input_data[7] == 1'b1) abs_input_data <= -input_data;	//negative value, convert to its absolute value
	else abs_input_data <= input_data;  // positive value, no need to convert it
end*/

endmodule
