interface dst_if(input bit clock);
bit clk;
logic[7:0] data_out;
logic valid_out;
logic read_enb;

assign clk=clock;

modport DUV_DST(input clk,read_enb,output valid_out,data_out);

clocking dst_drv_cb@(posedge clock);
default input #1 output #1;
output read_enb;
input valid_out ;
endclocking

clocking dst_mon_cb@(posedge clock);
default input #1 output #1;
input data_out;
input read_enb;
endclocking 

modport DST_DRV_MP(clocking dst_drv_cb);

modport DST_MON_MP(clocking dst_mon_cb);

endinterface

 


