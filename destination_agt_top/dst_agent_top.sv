class dst_agent_top extends uvm_env; // no build_in base class, usign env.Total 3 agent top
`uvm_component_utils(dst_agent_top)	//create the number of agents according to env config 
									// in this case,each agent top will have 1 agent,
dst_agent dst_agent_h[];	// dynamic handle for dst_agent 

env_config m_cfg;	// for getting env config

function new(string name="dst_agent_top",uvm_component parent);	// creating memory
	super.new(name,parent);// call function of base class
endfunction

function void build_phase(uvm_phase phase);	// getting config and creating agents 
	super.build_phase(phase);				//but we cosider one agent for each top

	if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))//getting for number of agents
		`uvm_fatal(get_type_name(),"couldn't get the config ,have you set properly")
	dst_agent_h=new[m_cfg.no_of_dst_agent];	// assigning the number of handles needed for agent
	foreach(dst_agent_h[i])//creating each agents
		dst_agent_h[i]=dst_agent::type_id::create($sformatf("dst_agent_h[%0d]",i),this);
	
endfunction

task run_phase(uvm_phase phase );
 // can call print uvm_top.print_topology
endtask

endclass
