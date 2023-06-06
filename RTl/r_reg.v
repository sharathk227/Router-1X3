module r_reg(clk,rst,pkt_valid,data_in,fifo_full,rst_int_reg,detect_addr,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout);
input clk,rst,pkt_valid,fifo_full,rst_int_reg,detect_addr,ld_state,laf_state,full_state,lfd_state;
input [7:0] data_in;
output reg err,parity_done,low_pkt_valid;
output reg[7:0] dout;
reg[7:0] hold_header_byte,fifo_full_state,internal_parity,packet_parity;
always@(posedge clk)
begin
	if(!rst||detect_addr)
		parity_done=1'b0;
	else if((ld_state && !pkt_valid && !fifo_full)||(laf_state && low_pkt_valid && !parity_done))
		parity_done=1'b1;
	else 
		parity_done=0;	
end
always@(posedge clk)
begin
	if(!rst)
		{hold_header_byte,fifo_full_state,dout}<=8'b0;
	else if(detect_addr && pkt_valid)
		hold_header_byte<=data_in;
	else if(lfd_state)
		dout<=hold_header_byte;
	else if (ld_state && !fifo_full)
		dout<=data_in;
	else if(ld_state && fifo_full)
		fifo_full_state<=data_in;
	else if(laf_state)
		dout<=fifo_full_state;
end
always@(posedge clk)
begin
	if(!rst || (rst_int_reg && !pkt_valid))
		internal_parity=8'b0;
	else if(lfd_state)
		internal_parity<=hold_header_byte;
	else if(ld_state && pkt_valid)
		internal_parity=internal_parity^data_in;
	else
		internal_parity=internal_parity;
end	

always@(posedge clk)
begin
	if(!rst || (rst_int_reg && !pkt_valid))
		packet_parity=8'b0;
	else if(ld_state && !pkt_valid && !fifo_full)
	       	packet_parity=data_in;
	else if(laf_state && low_pkt_valid && !parity_done ) // will it be store inside fifo_full_state reg
	 	packet_parity=data_in;	
	else 
		packet_parity=packet_parity;
end
always@(posedge clk)
begin
	if(!rst)
		err=0;
	else if(parity_done &&(packet_parity!=internal_parity))
		begin
		err=1'b1;
		@(posedge clk)
		err=1'b0;
		end
	else 
		err=0;
	                                                                  
end	
always@(posedge clk)
begin
	if(!rst || rst_int_reg)
		low_pkt_valid=0;
	else if(ld_state && !pkt_valid)
		low_pkt_valid=1'b1;
end
endmodule
