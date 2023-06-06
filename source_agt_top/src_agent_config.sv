class src_agent_config extends uvm_object;	// object type  src_agent_config , agent config are created at test and they are send to env config 
`uvm_object_utils(src_agent_config)//  used to assign the static interface with the virtual interface and for assigning whether active or passive

virtual src_if vif;  	// declaring virtual interface

uvm_active_passive_enum is_active =UVM_ACTIVE;		// assigning active  

static int mon_rcvd_xtn_cnt=0;		// keeping count for mon and drv send xtns . used in scoreboard.
static int drv_sent_xtn_cnt=0;

function new(string name ="src_agent_config");
	super.new(name);
endfunction
endclass
