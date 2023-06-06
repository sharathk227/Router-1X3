module router_fifo(clk,resetn,soft_reset,lfd_state,write_enb,read_enb,data_in,empty,full,data_out);
input clk,resetn,soft_reset,lfd_state,write_enb,read_enb;
input [7:0]data_in;
output empty,full;
output reg [7:0]data_out;
integer i;

reg [8:0] mem [15:0];
reg [4:0]write_ptr,read_ptr;
reg [6:0]fifo_counter;
reg temp_lfd;

always@(posedge clk)
begin
	if(!resetn)
		temp_lfd<=0;
	else
		temp_lfd<=lfd_state;
end

//write pointer logic
always@(posedge clk)
begin
	if(!resetn || soft_reset)
		write_ptr <= 0;
	else
		if(write_enb && !full)
		write_ptr <= write_ptr + 1'b1;


end

//read pointer logic
always@(posedge clk)
begin
	if(!resetn || soft_reset)
		read_ptr <= 0;
	else
		if(read_enb && !empty)
		read_ptr <= read_ptr + 1'b1;
end


//counter logic
		always@(posedge clk)
		begin
		if(!resetn || soft_reset)
		fifo_counter <= 0;
		else if(mem[read_ptr[3:0]][8] == 1'b1)
		fifo_counter <= mem[read_ptr[3:0]][7:2]+1'b1;
		else
			if(fifo_counter != 0)
			fifo_counter <= fifo_counter - 1'b1;
		end


//write logic
		always@(posedge clk)
		begin
			if(!resetn || soft_reset)
					begin
					for(i=0;i<16;i=i+1)
						mem[i] = 0;
					end
				else

					if(write_enb && !full)
					{mem[write_ptr[3:0]][8], mem[write_ptr[3:0]][7:0]} <= {temp_lfd,data_in};

end


//read logic
			always@(posedge clk)
				begin
					if(!resetn)
						data_out<=0;
					else if(soft_reset)
						data_out <= 8'hz;
					else if(fifo_counter == 0)
						data_out <= 8'hz;
					else
						if(read_enb && !empty)
						data_out <= mem[read_ptr[3:0]];

				end


				assign full = ({write_ptr[4],write_ptr[3:0]} == {~ read_ptr[4],read_ptr[3:0]}) ? 1'b1 : 1'b0;
				assign empty = (write_ptr == read_ptr) ? 1'b1 : 1'b0;
endmodule


