module rc4_FSM(  input logic CLOCK_50,
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
logic [7:0]	data;		
logic			wren;	
logic [7:0] q;	
logic [6:0] state;  //////////////////////////
logic	[4:0]	address_d;	//32 words
logic [7:0] data_d;
logic 		wren_d;
logic	[7:0]		q_d;	//not used

logic [4:0] address_m;
logic [7:0]	q_m;

logic [23:0] secret_key;	//3 keys, 8-bit each
logic [7:0] single_sec_key;

logic [1:0] key_num;	//up to 2
logic [7:0] data_i;	//used to swap data
logic [7:0] data_j;
logic [7:0] sum;
logic [7:0] f;
logic [7:0] counter_j;
logic [7:0] counter_i;
logic [4:0] counter_k;

parameter Key_length = 3;

parameter Idle 		 		= 7'b00000_00;
parameter Loop1_init  = 7'b00001_10;
parameter Loop1_main  = 7'b00010_10;
parameter Loop2_init  = 7'b00011_00;
parameter Loop2_start = 7'b00100_00;
parameter Loop1_done  = 7'b01001_00;
parameter Loop2_sum 	 = 7'b00101_00;
parameter Loop2_read_i = 7'b10001_00;
parameter Loop2_wait_i = 7'b10010_00;
parameter Loop2_read_j = 7'b10011_00;
parameter Loop2_wait_j = 7'b10100_00;
parameter Loop2_swap_j = 7'b10101_10;
parameter Loop2_swap_i = 7'b10110_10;
parameter Loop2_get_j  = 7'b10111_00;
parameter Loop2_done   = 7'b11000_00;
parameter Loop2_get_key= 7'b11001_00;
parameter Finish 		 = 7'b01000_00;
/*
parameter Loop3_init  = 7'b01001_00;
parameter Loop3_start = 7'b01010_00;
parameter Loop3_inc_j = 7'b01011_00;
parameter Loop3_swap1 = 7'b01100_00;
parameter Loop3_swap2 = 7'b01101_00;
parameter Loop3_calc1 = 7'b01110_00;
parameter Loop3_calc2 = 7'b01111_00;
parameter Loop3_calc3 = 7'b10000_00;
*/
ksa (CLOCK_50,KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
s_memory sys_memory (address, CLOCK_50, data, wren, q);
d_message Dec_Msg   (address_d, CLOCK_50, data_d, wren_d, q_d);
//rom		 Enc_Msg	  (address_m, CLOCK_50, 	q_m);

//first 14 bits are 0, and the lower 10 are assigned by switches
assign secret_key[9:0] = 10'b10_01001001; //SW[9:0];
assign secret_key[23:10] = 0;
assign wren = state[1];
assign wren_d = state[0];
//assign reset = KEY[3];
always@(posedge CLOCK_50) begin
		//if (reset)	state <= idle;
		//else
		case(state)
			Idle:					state <= Loop1_init;
			//task 1
			Loop1_init: 		begin counter_i <= 0; state <= Loop1_main; end
			Loop1_main: 		begin	data <= counter_i;
											address <= counter_i;
											counter_i <= counter_i + 1;
											if ( counter_i == 255 ) state <= Loop1_done;
											else  state <= Loop1_main; 
									end
			Loop1_done: 			state <= Loop2_init;
			//task 2(a)
			Loop2_init: 		begin counter_j <= 0;	counter_i <= 0;	state <= Loop2_start; end
			Loop2_start:		begin key_num <= counter_i % Key_length; state <= Loop2_get_key; address <= counter_i; end
			Loop2_get_key:		begin		case (key_num)
												0:	single_sec_key <= secret_key[23:16];
												1: single_sec_key <= secret_key[15:8];
												2: single_sec_key <= secret_key[7:0];
												default: single_sec_key <= 0;
												endcase
												state <= Loop2_read_i; 
									end	//need a cycle to read data from S memory
			Loop2_read_i: 		begin address <= counter_i;
											state <= Loop2_wait_i;
									end		
			Loop2_wait_i:  			state <= Loop2_read_j;
								
			Loop2_read_j:		begin	data_i <= q;	//data_i = s[i];
											counter_j <= counter_j + single_sec_key + q;
											address <= counter_j;	//read s[j]
											state <= Loop2_wait_j;
									end
			Loop2_wait_j:				state <= Loop2_get_j;
			
			Loop2_get_j:		begin data_j <= q;
											state <= Loop2_swap_j;
									end
			Loop2_swap_j:		begin data <= data_j;
        							address <= counter_i; 
										//wren = 1, s[i] <= s[j];
											state <= Loop2_swap_i; 
									end
			Loop2_swap_i:		begin	data <= data_i;
        							address <= counter_j;
                      //wren = 1, s[j] = temp;
											state <= Loop2_done;
									end
			Loop2_done: 		begin counter_i <= counter_i + 1;
											if (counter_i == 255) state <= Finish;
											else state <= Loop2_start; 
									end
			//task 2(b)
			/*
			Loop3_init:			begin counter_i <= 0;
											counter_j <= 0;
											counter_k <= 0;
											state <= Loop3_start; end
			Loop3_start:		begin counter_i <= counter_i + 1;
											address <= i;
											state <= Loop3_inc_j; end
			Loop3_inc_j:		begin counter_j <= counter_j + q;
											temp <= q;	//temp = s[i]
											sum <= q;	//sum = s[i]
											address <= counter_j;
											state <= Loop3_swap1; end
			Loop3_swap1:		begin address <= counter_i;	//wren = 1
											data <= q; //s[i] = s[j]
											sum <= sum + q;	//sum = s[i] + s[j]
											state <= Loop3_swap2; end
			Loop3_swap2:		begin address <= counter_j;
											data <= temp;	//s[j] = temp
											state <= Loop3_calc1; end
			Loop3_calc1:		begin address <= sum;
											state <= Loop3_calc2; end
			Loop3_calc2:		begin f <= q;
											address_d <= counter_k;
											state <= Loop3_calc3; end
			Loop3_calc3:		begin f <= f ^ q_d;
											data_d <= f; //wren_d = 1, write to dec_Msg memory
											counter_k <= counter_k + 1;
											if (counter_k == 0) state <= Finish;
											else state <= Loop3_start; end
											
			*/								
											
			Finish:	state <= Idle;
			default: state <= Idle;
			endcase
end 
endmodule	