module Flash_Read(input start, read, flash_mem_waitrequest, data_valid, clk, output finish);
	enum logic [3:0]{
		idle   		=	4'b000_0,
		check_read 	=  4'b001_0,
		slave_ready =  4'b010_0,
		wait_read	=  4'b011_0,
		finished 	=  4'b100_1
	} state;
	
	assign finish = state[0];
	
	always_ff@(posedge clk)
	case(state)
		idle: if(start) state <= check_read; 
		check_read: if(read) state <= slave_ready; 
		slave_ready: if(!flash_mem_waitrequest) state <= wait_read; //falsh memory is able to response
		wait_read: if(!data_valid) state <= finished; 
		finished: state <= idle;	//data is ready to be fetched in "flash_mem_readdata"
		default: state <= idle; 
	endcase 
endmodule
