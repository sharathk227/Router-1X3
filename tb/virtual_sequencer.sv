class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item) ;
`uvm_component_utils(virtual_sequencer)
								// nothing much is happening inside virtual seqr ,only  declaring the number of handles and getting config
src_sequencer src_seqr_h[]; 
dst_sequencer dst_seqr_h[];

env_config m_cfg;// we need the config files as we need to know the number of seqr present in agent 
				// accordingly only we assign number to dynamic handles


function new(string name="virtual_sequencer",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("ENV CONFIG","could get the config , have you set it properly")
	src_seqr_h=new[m_cfg.no_of_src_agent_top];
	dst_seqr_h=new[m_cfg.no_of_dst_agent_top];
	super.build_phase(phase);
endfunction
endclass
