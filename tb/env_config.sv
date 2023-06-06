class env_config extends uvm_object;// config file are generally objects type
`uvm_object_utils(env_config)
bit has_src_agent=1;				// In config file , we have to mention  what  and all is present inside env and also declare agent handles as dynamic in nature.
bit has_dst_agent=1;
bit has_virtual_sequencer=1;
bit has_scoreboard=1;

int no_of_dst_agent_top=1; // just initializing for creating .Test will have assign the orginal values.
int no_of_src_agent_top=1;  

int no_of_src_agent=1;
int no_of_dst_agent=1;

src_agent_config m_src_cfg[];// inside env config file we are gonna declare both src and dst config files as dynamic and further process done by test
dst_agent_config m_dst_cfg[];

function new(string name="env_config");
	super.new(name);
endfunction 
endclass :env_config
