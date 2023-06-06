module router_reg(clk,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,data_out);

input clk,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
input [7:0]data_in;
output reg parity_done,low_pkt_valid,err;
output reg[7:0]data_out;

reg [7:0] hold_header_byte, fifo_full_state, internal_parity, packet_parity;

//parity done
always@(posedge clk)
begin
        if(!resetn)
                parity_done <= 0;
        else if( (ld_state && !fifo_full && !pkt_valid) || (laf_state && low_pkt_valid && !parity_done) )
                parity_done <= 1;
        else
                if(detect_add)
                        parity_done <= 0;
end

//low pkt valid
always@(posedge clk)
begin
        if(!resetn || rst_int_reg)
                low_pkt_valid <= 0;
        else
                if(ld_state && !pkt_valid)
                        low_pkt_valid <= 1;
end   
                                                                         
 //dout logic
  always@(posedge clk)
  begin
          if(!resetn)
                  data_out <= 0;
          else
          begin
                   if(detect_add && pkt_valid)
                          hold_header_byte <= data_in;
                  else if(lfd_state)
                          data_out <= hold_header_byte;
                  else if(ld_state && !fifo_full)
                          data_out <= data_in;
                  else if(ld_state && fifo_full)
                          fifo_full_state <= data_in;
                  else
                  if(laf_state)
                          data_out <= fifo_full_state;
          end
 end


 //error logic
 always@(posedge clk)
 begin
         if(!resetn)
                 err <= 0;
         else if(parity_done)
                 begin
                         if(internal_parity == packet_parity)
                                 err <= 0;
                         else
                                 err <= 1;
                 end
 end

 //internal parity
 always@(posedge clk)
 begin
         if(!resetn)
                 internal_parity <= 0;
         else if(lfd_state)
                 internal_parity <= internal_parity ^ hold_header_byte;
         else if(ld_state &&  pkt_valid)
                 internal_parity <= internal_parity ^ data_in;
         else
              if(rst_int_reg && !pkt_valid)
                 internal_parity = 0;
 end

 //packet parity
 always@(posedge clk)
 begin
         if(!resetn)
                 packet_parity <= 0;
         else if(rst_int_reg && !pkt_valid)
                 packet_parity <= 0;
         else if(ld_state && !fifo_full && !pkt_valid)
                  packet_parity<= data_in;
         else
         begin
                  if(laf_state && low_pkt_valid && !parity_done)
                         packet_parity <= data_in;
 end


 end
 endmodule


