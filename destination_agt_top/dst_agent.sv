class dst_agent extends uvm_agent;// have build_in base class,components drv,mon and seqr 
`uvm_component_utils(dst_agent)	//creating all components according to agent config set.
									// connecting seqr and drv
dst_monitor mon_h; 		// declaring handles of components inside agent
dst_sequencer seqr_h;
dst_driver drv_h;

dst_agent_config m_cfg;		// have get agent config to check if declared ACTIVE or PASSIVE

function new(string name="dst_agent",uvm_component parent);// creating memory for class
	super.new(name,parent);		// calling function new of build-in class
endfunction

function  void build_phase(uvm_phase phase );	// all phase have void as return type
	super.build_phase(phase);		// in run_phase, creating mon, drv and seqr
	mon_h=dst_monitor::type_id::create("mon_h",this);	//  active or passive mon is present
	if(!uvm_config_db#(dst_agent_config)::get(this,"","dst_agent_config",m_cfg))//get the cofig
		`uvm_fatal("CONFIG","couldn't get the configuration have you set it ? ")
	if(m_cfg.is_active)		// after getting the config ,check if active or passive
	begin 	// if active  ,create drv and seqr
		seqr_h=dst_sequencer::type_id::create("seqr_h",this);	
		drv_h=dst_driver::type_id::create("drv_h",this);
	end
endfunction

function void connect_phase(uvm_phase phase );// not necessary to check active ,checking in build_phase
	if(m_cfg.is_active)	// connect drv and seqr using TLM ports(bidirectional)
	drv_h.seq_item_port.connect(seqr_h.seq_item_export);
endfunction

endclass
