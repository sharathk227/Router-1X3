module r_fifo(clk,rst,we,re,soft_rst,data,lfd_state,empty,data_out,full);
input clk,rst,we,re,soft_rst,lfd_state;
input [7:0] data;
output wire empty,full;
output reg [7:0] data_out;
reg templfd_state;
reg [8:0] mem [15:0];
reg [4:0] wrptr,reptr;
reg [6:0] fifo_counter;
integer i;
always@(posedge clk)
begin
if(!rst)
templfd_state<=0;
else
templfd_state<=lfd_state;
end
always @(posedge clk)
begin
	if(!rst)
		{wrptr,reptr}=0;
	else if(soft_rst)
		{wrptr,reptr}=0;
	else 
	begin
		if(!full && we)
			wrptr<=wrptr+1'b1;

		if(!empty && re)
			reptr<=reptr+1'b1;

	end
end

assign full=({wrptr[4],wrptr[3:0]}=={~reptr[4],reptr[3:0]})? 1'b1:1'b0;
assign empty=(reptr==wrptr)? 1'b1:1'b0;

always@(posedge clk) // counterlogic
begin
if(re && !empty)
begin
	if(!rst)
		fifo_counter=0;
	else if(soft_rst)
		fifo_counter=0;
	else 
	begin 
	if(mem[reptr[3:0]][8]==1'b1)
		fifo_counter<=mem[reptr[3:0]][7:2]+ 1'b1;// latch of payload 
	else if(fifo_counter !=0)
		fifo_counter <= fifo_counter - 1'b1;
	end
end
end
always@(posedge clk)
begin
	if(!rst)
	begin
		
		for(i=0;i<16;i=i+1)
			mem[i]=0;
	end
	else if(soft_rst)
	begin
		
		for(i=0;i<16;i=i+1)
			mem[i]=0;

	end
	else
	begin                       
	if(we && !full) //write 
	{mem[wrptr[3:0]][8],mem[wrptr[3:0]][7:0]}<={templfd_state,data};
	end
end
always@(posedge clk)
begin
	if(!rst)
		data_out=0;
	else if(soft_rst)
		data_out=8'bz;
	else
	begin	
		if(fifo_counter==0)
			data_out=8'bz;
		if(re && !empty)// read 
			data_out=mem[reptr[3:0]];
	end
end
endmodule


