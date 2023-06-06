class dst_agent_config extends uvm_object;	// config is always object. 
`uvm_object_utils(dst_agent_config)	//point virtual interface 
									//assigne ACTIVE or PASSIVE
virtual dst_if vif;

uvm_active_passive_enum is_active=UVM_ACTIVE;

static int mon_rcvd_xtn_cnt=0;	// for keeping count in mon and drv xtns
static int drv_sent_xtn_cnt=0;

function new(string name= "dst_agent_config");// memory creation of class
	super.new(name);	// call build in base class function new
endfunction

endclass
