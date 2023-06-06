module router_sync(clk,resetn,data_in,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2);

input clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2;
input [1:0]data_in;
output  reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
output reg [2:0]write_enb;
output vld_out_0,vld_out_1,vld_out_2;
//output reg fifo_full;

reg [1:0]int_addr_reg;
reg [4:0]timer_0,timer_1,timer_2;

//latching
always@(posedge clk)
begin
	if(!resetn)
		int_addr_reg <= 2'b11;
	else if(detect_add)
		int_addr_reg <= data_in;
	else
		int_addr_reg <= int_addr_reg;
		
end

//write enable logic
always@(*)
begin
	//write_enb = 3'b000;
	if(write_enb_reg)
begin
		case(int_addr_reg)
			2'b00 : write_enb = 3'b001;
			2'b01 : write_enb = 3'b010;
			2'b10 : write_enb = 3'b100;
			default : write_enb = 3'b000;
		endcase
end
else
if(!write_enb_reg)
write_enb = 3'b000;
	end

//fifo_full logic
always@(*)
begin
case(int_addr_reg)
2'b00 : fifo_full = full_0;
2'b01 : fifo_full = full_1;
2'b10 : fifo_full = full_2;
default : fifo_full = 0;
endcase
end

//valid  out logic
assign vld_out_0 = ~ empty_0;
assign vld_out_1 = ~ empty_1;
assign vld_out_2 = ~ empty_2;

//timer_0 logic
always@(posedge clk)
begin
	if(!resetn)
		{timer_0,soft_reset_0} <= 0;
	else if(vld_out_0)
	begin
		if(read_enb_0)
		{timer_0,soft_reset_0} <= 0;
		else 
			begin
				if(!timer_0 == 29 && read_enb_0 == 0)
			begin 
				timer_0 <= timer_0 + 1; 
				soft_reset_0 <= 0;
			end

			else if(timer_0 == 29 && read_enb_0 == 0)
				soft_reset_0 <= 1;
			else 
				timer_0 <= timer_0 + 1;
			end
	end	
end

//timer_1 logic
always@(posedge clk)
begin
	if(!resetn)
		{timer_1,soft_reset_1} <= 0;
	else if(vld_out_1)
	begin
		if(read_enb_1)
		{timer_1,soft_reset_1} <= 0;
		else 
			begin
				if(!timer_1 == 29 && read_enb_1 == 0)
			begin 
				timer_1 <= timer_1 + 1; 
				soft_reset_1 <= 0;
			end

			else if(timer_1 == 29 && read_enb_1 == 0)
				soft_reset_1 <= 1;
			else 
				timer_1 <= timer_1 + 1;
			end
	end	
end

//timer_2 logic
always@(posedge clk)
begin
	if(!resetn)
		{timer_2,soft_reset_2} <= 0;
	else if(vld_out_2)
	begin
		if(read_enb_2)
		{timer_2,soft_reset_2} <= 0;
		else 
			begin
				if(!timer_2 == 29 && read_enb_2 == 0)
			begin 
				timer_2 <= timer_2 + 1; 
				soft_reset_2 <= 0;
			end

			else if(timer_2 == 29 && read_enb_2 == 0)
				soft_reset_2 <= 1;
			else 
				timer_2 <= timer_2 + 1;
			end
	end	
end

	endmodule	

