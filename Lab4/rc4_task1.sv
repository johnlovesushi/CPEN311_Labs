module rc4_task1(input logic CLOCK_50,
					  input logic [3:0] KEY,
					  input logic [9:0] SW,               
					  output logic [9:0]LEDR, 
					  output logic [6:0]HEX0, 
					  output logic [6:0]HEX1, 
					  output logic [6:0]HEX2,
					  output logic [6:0]HEX3, 
					  output logic [6:0]HEX4,
					  output logic [6:0]HEX5);
					 
logic [7:0]	address;	
logic [7:0]		data;		
logic		wren;	
logic    q;	
logic [7:0] counter;
logic [2:0] state;
//logic reset;
parameter idle = 3'b00_0;
parameter init_counter = 3'b01_1;
parameter counter_increment = 3'b10_1;
parameter finish = 3'b11_0;

s_memory memory(address,CLOCK_50,data,wren,q);
ksa (CLOCK_50,KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
assign wren = state[0];
//assign reset = KEY[3];
always@(posedge CLOCK_50) begin
		//if (reset)	state <= idle;
		//else
			case(state)
				idle: state <= init_counter;
				init_counter: begin counter <= 0;
								  state <= counter_increment;
								  end
					counter_increment: begin data <= counter;
													 address <= counter;
													 counter <= counter + 1;
													 if ( counter == 255 ) state <= finish;
													 else  state <= counter_increment;
											 end
					finish: state <= idle;
				default: state <= idle;
			endcase
end 
endmodule