module router_fsm(clk,resetn,pkt_valid,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

input clk,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input [1:0]data_in;
output  busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;
parameter DECODE_ADDRESS = 3'b000, LOAD_FIRST_DATA = 3'b001, LOAD_DATA = 3'b010, FIFO_FULL_STATE = 3'b011, LOAD_AFTER_FULL = 3'b100, LOAD_PARITY = 3'b101,
       	CHECK_PARITY_ERROR = 3'b110, WAIT_TILL_EMPTY = 3'b111;

reg [2:0]state,next_state;
reg [1:0]addr;

//latching address

always@(posedge clk)
begin
	if(!resetn || soft_reset_0 || soft_reset_1 || soft_reset_2)
		addr <= 2'b11;
	else 
		if(detect_add)
		addr <= data_in;
	else 
		addr <= addr;
end

//preset state logic

always@(posedge clk or negedge resetn)
begin
if(!resetn)
	state <= DECODE_ADDRESS;
else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
	state <= DECODE_ADDRESS;
	else
		state <= next_state;
end

//next state combinational logic

always@(*)
begin
	next_state = DECODE_ADDRESS;
	case(state)
		DECODE_ADDRESS : 
				begin
				if((pkt_valid && (data_in[1:0]==0) && fifo_empty_0) 
				|| (pkt_valid && (data_in[1:0]==1) && fifo_empty_1)
				|| (pkt_valid && (data_in[1:0]==2) && fifo_empty_2))
					next_state = LOAD_FIRST_DATA;
				else if((pkt_valid && (data_in[1:0]==0) && !fifo_empty_0) 
				|| (pkt_valid && (data_in[1:0]==1) && !fifo_empty_1) 
				|| (pkt_valid && (data_in[1:0]==2) && !fifo_empty_2))
					next_state = WAIT_TILL_EMPTY;
				else
					next_state = DECODE_ADDRESS;
				end

		LOAD_FIRST_DATA :
				//	begin 
				 next_state = LOAD_DATA;
					//end

		LOAD_DATA : begin 
			if(fifo_full)
			next_state = FIFO_FULL_STATE;
		else if(!fifo_full && !pkt_valid)
			next_state = LOAD_PARITY;
		else
			next_state = LOAD_DATA;
			end

		FIFO_FULL_STATE : 
			begin
			if(!fifo_full)
			next_state = LOAD_AFTER_FULL;
		else
			next_state = FIFO_FULL_STATE;
				end

		LOAD_AFTER_FULL :
			begin
			 if(!parity_done && !low_pkt_valid)
			next_state = LOAD_DATA;
		else if(!parity_done && low_pkt_valid)
			next_state = LOAD_PARITY;
		else 
			if(parity_done)
			next_state = DECODE_ADDRESS;
			end

		LOAD_PARITY : 
			//	begin
			next_state = CHECK_PARITY_ERROR;
		//	end
			
		CHECK_PARITY_ERROR : begin
				if(fifo_full)
			next_state = FIFO_FULL_STATE;
		else 
			if(!fifo_full)
			next_state = DECODE_ADDRESS;
		//else 
		//	next_state = CHECK_PARITY_ERROR;
			end

		WAIT_TILL_EMPTY :	
				begin
				 if((fifo_empty_0 && (addr==0)) || (fifo_empty_1 && (addr==1)) || (fifo_empty_2 && (addr==2)))
	       		next_state = LOAD_FIRST_DATA;
		else 
			next_state = WAIT_TILL_EMPTY;
			end
	endcase
end

// output logic

assign detect_add = (state == DECODE_ADDRESS) ? 1:0;
assign ld_state = (state == LOAD_DATA) ? 1 : 0;
assign lfd_state = (state == LOAD_FIRST_DATA) ? 1 : 0;
assign laf_state = (state == LOAD_AFTER_FULL) ? 1 : 0;
assign full_state = (state == FIFO_FULL_STATE) ? 1 : 0;
assign write_enb_reg = ((state == LOAD_DATA) || (state == LOAD_PARITY) || (state == LOAD_AFTER_FULL)) ? 1 : 0;
assign rst_int_reg = (state == CHECK_PARITY_ERROR) ? 1 : 0;
assign busy = ((state == LOAD_FIRST_DATA) || (state == LOAD_PARITY) || (state == FIFO_FULL_STATE) || (state == LOAD_AFTER_FULL) || (state == WAIT_TILL_EMPTY) || (state == CHECK_PARITY_ERROR) )? 1 : 0;

endmodule






