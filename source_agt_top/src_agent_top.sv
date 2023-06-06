class src_agent_top extends uvm_env; // there is not exculsive build-in class for agent top . uvm_env itself is considered as base class.
`uvm_component_utils(src_agent_top)		//get the number of agents and create them

env_config m_cfg; 		// for getting the number agents under agent top

src_agent src_agent_h[];	

function new(string name="src_agent_top",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))	// getting the env config and assign the numnber of agents under agent top
		`uvm_fatal(get_type_name(),"could get the config in src agent top")
	src_agent_h=new[m_cfg.no_of_src_agent]; 	//declaring the  number of agents
	foreach(src_agent_h[i])
		src_agent_h[i]=src_agent::type_id::create($sformatf("src_agent_h[%0d]",i),this); // creating the agents
endfunction

task run_phase(uvm_phase phase);
	uvm_top.print_topology; // for printing topology , there is build in method print_topology in build in class uvm_top
endtask
endclass
