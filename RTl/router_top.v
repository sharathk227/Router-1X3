module router_top(clk,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,error,busy);
input clk,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
input [7:0] data_in;
output vld_out_0,vld_out_1,vld_out_2,error,busy;
output [7:0] data_out_0,data_out_1,data_out_2;

wire [2:0]write_enb;
wire [7:0]data_out;
wire soft_reset_0;

router_fifo fifo_0(clk,resetn,soft_reset_0,lfd_state,write_enb[0],read_enb_0,data_out,empty_0,full_0,data_out_0);
router_fifo fifo_1(clk,resetn,soft_reset_1,lfd_state,write_enb[1],read_enb_1,data_out,empty_1,full_1,data_out_1);
router_fifo fifo_2(clk,resetn,soft_reset_2,lfd_state,write_enb[2],read_enb_2,data_out,empty_2,full_2,data_out_2);

router_sync synchronizer(clk,resetn,data_in[1:0],detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2);

router_fsm fsm(clk,resetn,pkt_valid,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,empty_0,empty_1,empty_2,busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

router_reg register(clk,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,data_out);

endmodule
