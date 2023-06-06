module top;
import router_test_pkg::*; // include the config files
import uvm_pkg::*; 	// used for accessign pre-defined classes and utilities(functions)
bit clock;
always
#10 clock=~clock;

src_if s0_if(clock);// instantiating and passing clock to interface
dst_if d0_if(clock);// 1 src and 3 dst
dst_if d1_if(clock);
dst_if d2_if(clock);
 
// DUT INSTANTIATION can be done in 2ways , name based and order based
/*router_top DUV(.clk(clock),.resetn(s0_if.resetn),.read_enb_0(d0_if.read_enb),.read_enb_1(d1_if.read_enb),.read_enb_2(d2_if.read_enb),.data_in(s0_if.data_in),.pkt_valid(s0_if.pkt_valid),.data_out_0(d0_if.data_out),.data_out_1(d1_if.data_out),.data_out_2(d2_if.data_out),.vld_out_0(d0_if.valid_out),.vld_out_1(d1_if.valid_out),.vld_out_2(d2_if.valid_out),.error(s0_if.error),.busy(s0_if.busy));*/
router_top DUV(clock,s0_if.resetn,d0_if.read_enb,d1_if.read_enb,d2_if.read_enb,s0_if.data_in,s0_if.pkt_valid,d0_if.data_out,d1_if.data_out,d2_if.data_out,d0_if.valid_out,d1_if.valid_out,d2_if.valid_out,s0_if.error,s0_if.busy);

property softreset_0;// propert for checking  softreset condition
	@(posedge clock) $rose(DUV.vld_out_0) |=> ##[0:28] DUV.read_enb_0;// if vld_out_0 is high within nxt 28 clk cycles read_enb_0 should be high
endproperty

a_softreset_0 : assert property(softreset_0)	// asserting property  and displaying success or failure
			$display("read_enb_0  success");
		else 
			$display("read_enb_0 failed");

SOFTRESET_0_COVERAGE: cover property (softreset_0);// coverage for the property

// the same goes for all the softreset conditions
property softreset_1;
	@(posedge clock) $rose(DUV.vld_out_1) |=> ##[0:28] DUV.read_enb_1;
endproperty

a_softreset_1: assert property(softreset_1)
			$display("read_enb_1 success");
		else
			$display("read_enb_1 failed");

SOFTRESET_1_COVERAGE: cover property (softreset_1);


property softreset_2;
	@(posedge clock) $rose(DUV.vld_out_2) |=> ##[0:28] DUV.read_enb_2;
endproperty

a_softreset_2: assert property(softreset_2)
		$display("read_enb_2 success");
	else
		$display("read_enb_2 failed");

SOFTRESET_2_COVERAGE : cover property (softreset_2);


property busy;	// for busy ,if busy goes high then on nxt clock cycle also the data should not change
	@(posedge clock) $rose(s0_if.busy) |=> s0_if.data_in == $past(s0_if.data_in,1);
endproperty

a_busy1:assert property(busy)
		$display("busy is success");
	else
		$display(" busy failed");

BUSY_COVERAGE:	cover property (busy);
	


initial
begin

// set the interface , top doesn't have hierarcy hence null. we are setting the static interface to virtual interface by mentioning data_type as virtual interface,
uvm_config_db#(virtual src_if)::set(null,"*","s_vif_0",s0_if);
uvm_config_db#(virtual dst_if)::set(null,"*","d_vif_0",d0_if);
uvm_config_db#(virtual dst_if)::set(null,"*","d_vif_1",d1_if);
uvm_config_db#(virtual dst_if)::set(null,"*","d_vif_2",d2_if);

run_test(); // calling the run_phase of test.

end
endmodule
