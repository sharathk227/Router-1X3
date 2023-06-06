module r_fsm(clk,rst,pkt_valid,busy,parity_done,data_in,soft_reset0,soft_reset1,soft_reset2,fifo_full,low_pkt_valid,fifo_empty0,fifo_empty1,fifo_empty2,detect_addr,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
input clk,rst,pkt_valid,parity_done,soft_reset0,soft_reset1,soft_reset2,fifo_full,low_pkt_valid,fifo_empty0,fifo_empty1,fifo_empty2 ;
input[1:0] data_in;
output busy,detect_addr,ld_state,laf_state,full_state,write_enb_reg,lfd_state,rst_int_reg;
parameter decode_addr=3'b000,
	load_first_data=3'b001,
	load_data=3'b010,
	wait_till_empty=3'b011,
	fifo_full_state=3'b100,
	load_after_full=3'b101,
	load_parity=3'b110,
	check_parity_error=3'b111;
reg[2:0] nxt_state,state;
reg[1:0] int_addr_reg;
always@(posedge clk )
begin
	if(!rst)
		int_addr_reg<=2'b11;
	else if(soft_reset0 || soft_reset1 || soft_reset2)
		int_addr_reg<=2'b11;
	else
		if(detect_addr)
			int_addr_reg<=data_in;
end

always@(posedge clk )
begin
	if(!rst)

		state<=decode_addr;   
	else if(soft_reset0 || soft_reset1 || soft_reset2) //state_transition
		state <=decode_addr;
	else
		state<=nxt_state;
end
always@(*)
begin
	if(int_addr_reg !== 2'b11)
	begin
	
	case (state)
	decode_addr: 	begin
				if((pkt_valid && (int_addr_reg[1:0]==2'b0) && fifo_empty0)||(pkt_valid && (int_addr_reg[1:0]==2'd1) && fifo_empty1)||(pkt_valid && (int_addr_reg[1:0]==2'd2) && fifo_empty2))
					nxt_state=load_first_data;
				else if((pkt_valid && (int_addr_reg==2'd0) && !fifo_empty0)||(pkt_valid &&(int_addr_reg[1:0]==2'd1)&& !fifo_empty1)||(pkt_valid &&(int_addr_reg[1:0]==2'd2) && !fifo_empty2))
					nxt_state=wait_till_empty;
				else 
					nxt_state=decode_addr;
				end
	load_first_data: 	begin
				nxt_state<=load_data;
				end
	load_data:	begin
				if(fifo_full)
				nxt_state=fifo_full_state;
				else if(!fifo_full && !pkt_valid)
				nxt_state=load_parity;
				else
					nxt_state<=load_data;
				end

	wait_till_empty:	begin
				if((fifo_empty0 && (int_addr_reg == 2'd0))||(fifo_empty1 && (int_addr_reg == 2'd1)) || (fifo_empty2 && (int_addr_reg==2'd2)))
				nxt_state=load_first_data;
				else 
					nxt_state=wait_till_empty;
				end
	fifo_full_state:	begin
				if(!fifo_full)
				nxt_state=load_after_full;
				else if(fifo_full)
				nxt_state=fifo_full_state;
				end	
	load_parity: 	begin
				nxt_state=check_parity_error;
				end
	load_after_full:	begin
				if(!parity_done && !low_pkt_valid)
				nxt_state=load_data;            
				else if(!parity_done && low_pkt_valid)
				nxt_state=load_parity;
				else if(parity_done) 
				nxt_state=decode_addr;
				end
	check_parity_error:	begin
				if(!fifo_full)
				nxt_state=decode_addr;
				else if(fifo_full)
				nxt_state=fifo_full_state;
				end
	default		:	nxt_state=decode_addr;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
		endcase
	end
end
assign detect_addr=(state==decode_addr)? 1'b1 :1'b0;
assign lfd_state=(state==load_first_data)? 1'b1:1'b0;
assign ld_state=(state==load_data)? 1'b1:1'b0;
assign laf_state=(state==load_after_full)? 1'b1:1'b0;
assign full_state=(state==fifo_full_state)? 1'b1:1'b0;
assign write_enb_reg=(state==load_data||state==load_parity||state==load_after_full)? 1'b1:1'b0;
assign rst_int_reg=(state==check_parity_error)? 1'b1:1'b0;
assign busy=(state==load_first_data|| state==load_parity||state==fifo_full_state||state==load_after_full||state==wait_till_empty||state==check_parity_error)?1'b1:1'b0;

endmodule

