interface src_if(input bit clock);
bit clk;
logic resetn;
logic[7:0] data_in ;
logic pkt_valid;
logic error;
logic busy;

assign clk=clock;
// modport for sou
modport DUV_SMP(input data_in,resetn,pkt_valid,clk,output error,busy);

//there will 2 clocking blocks one for driver and monitor

clocking src_drv_cb@(posedge clock);
default input #1 output #1;
output data_in;
output resetn;
output pkt_valid;
input error;
input busy;
endclocking

clocking src_mon_cb@(posedge clock);
default input #1 output #1;
input data_in;
input error;
input busy;
input pkt_valid;
endclocking

modport SRC_DRV_MP(clocking src_drv_cb);
modport SRC_MON_MP(clocking src_mon_cb);
 
endinterface
 
