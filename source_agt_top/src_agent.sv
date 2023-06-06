class src_agent extends uvm_agent;		// has build-in class for deriving 
`uvm_component_utils(src_agent)			// here we are creating all the sub components inside the agent - drv,mon,seqr  and connecting the drv with seqr

src_driver drv_h;
src_monitor mon_h;
src_sequencer seqr_h;

src_agent_config m_cfg; // we have to get the env config file to check whether the inside agent config file, it is mentioned active or passive
						// and accordingly only we need to create the components 
function new(string name ="src_agent",uvm_component parent );
	super.new(name,parent);		// creating the memory for the build-in class
endfunction

function void build_phase(uvm_phase phase);
	mon_h=src_monitor::type_id::create("mon_h",this);	// for creating monitor we don't need to ge the config. active or passive it will have mon
	if(!uvm_config_db#(src_agent_config)::get(this,"","src_agent_config",m_cfg)) 	// getting the config 
		`uvm_fatal("config","could n't get the config ")
	if(m_cfg.is_active)		// checking if active or  passive .if active only drv and seqr have to be created
	begin
	drv_h=src_driver::type_id::create("drv_h",this);
	seqr_h=src_sequencer::type_id::create("seqr_h",this);
	end
endfunction

function void connect_phase(uvm_phase phase);
	if(m_cfg.is_active)
	drv_h.seq_item_port.connect(seqr_h.seq_item_export);	// connecting drv with seqr usign seq_item_port  and seq_item_export (TLM ports)
endfunction
endclass
