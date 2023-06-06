module r_synch(detect_addr,data_in,write_enb_reg,clk,rst,vld_out0,vld_out1,vld_out2,read_enb0,read_enb1,read_enb2,write_enb,fifo_full,empty0,empty1,empty2,soft_reset0,soft_reset1,soft_reset2,full0,full1,full2);
input detect_addr,write_enb_reg,clk,rst,read_enb0,read_enb1,read_enb2,empty0,empty1,empty2,full0,full1,full2;
input [1:0] data_in;
output wire  vld_out0,vld_out1,vld_out2;
output reg fifo_full,soft_reset0,soft_reset1,soft_reset2;
output reg [2:0] write_enb;
reg[1:0] int_addr_reg;
integer timer0,timer1,timer2;
always@(posedge clk) // data_in 
begin
	if(!rst)
		int_addr_reg=2'b11;
	else if(detect_addr)
		int_addr_reg=data_in;
	else 
		int_addr_reg=2'b11;
end
always@(*)
begin
	//write enable 
	if(write_enb_reg)
	begin
		case(int_addr_reg)
			2'b00:	write_enb=3'b001;
			2'b01:	write_enb=3'b010;
			2'b10: 	write_enb=3'b100;
			default : write_enb=3'b0;
		endcase
	end
	else 
		write_enb=3'b000;
end
always@(*)
begin
	case(int_addr_reg)
		2'b00:	fifo_full=full0;// fifofull
		2'b01:	fifo_full=full1;
		2'b10:	fifo_full=full2;
		default:fifo_full=0;
	endcase
end
assign vld_out0=~empty0;  //valid_output
assign vld_out1=~empty1;
assign vld_out2=~empty2;

always@(posedge clk)//soft_reset
begin
	if(!rst)
	begin
		timer0<=0;
		soft_reset0<=0;
	end
	else if(vld_out0)
	begin
	
		if(read_enb0)
		begin
			timer0<=0;
			soft_reset0<=0;
		end
		else if(timer0!=29)
			timer0<=timer0+1;
		else 
		begin
			soft_reset0<=1'b1;
			timer0<=0;
		end
	end
	else
	begin
		soft_reset0<=0;
		timer0<=0;
	end
end

always@(posedge clk)
begin
	if(!rst)
	begin
		timer1=0;
		soft_reset1=0;
	end
	else if(vld_out1)
	begin
	
		if(read_enb1)
		begin
			timer1<=0;
			soft_reset1<=0;
		end
		else if(timer1!=29)
			timer1<=timer1+1;
		else 
		begin
			soft_reset1<=1'b1;
			timer1<=0;
		end
	end
	else
	begin
		soft_reset1<=0;
		timer1<=0;
	end
end
		
always@(posedge clk)
begin
	if(!rst)
	begin
		timer2<=0;
		soft_reset2<=0;
	end
	else if(vld_out2)
	begin
	
		if(read_enb2)
		begin
			timer2<=0;
			soft_reset2<=0;
		end
		else if(timer2!=29)
			timer2<=timer2+1;
		else 
		begin
			soft_reset2<=1'b1;
			timer2<=0;
		end
	end
	else
	begin
		soft_reset2<=0;
		timer2<=0;
	end
end
endmodule
					
	

