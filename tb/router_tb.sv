`class router_tb extends uvm_env;
`uvm_component_utils(router_tb)
src_agent_top src_agent_top_h[];
dst_agent_top dst_agent_top_h[];

env_config m_cfg;

router_scoreboard r_sb;
virtual_sequencer v_seqr_h;

function new(string name="router_tb",uvm_component parent);
	super.new(name,parent);
endfunction
/* In tb we are not gonna crearte config class.In test only we need to create the config class.In tb getting what is already created*/
function void build_phase(uvm_phase phase);
	super.build_phase(phase); 			//in build phase only things sb,agent,vseqr begin created according to the env config files
	if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("config","could get the config ,have you set it properly")
	if(m_cfg.has_src_agent)
		begin
		src_agent_top_h=new[m_cfg.no_of_src_agent_top];// we are setting in config files the number of agents(src & dst) accordingly
		foreach(src_agent_top_h[i])						// it is begining created in tb,and foreach of the src_agent the agent config
		begin											// is send with ref env config
			src_agent_top_h[i]=src_agent_top::type_id::create($sformatf("src_agent_top_h[%0d]",i),this);// $sformat(both string and int present)
			uvm_config_db#(src_agent_config)::set(this,$sformatf("src_agent_top_h[%0d]*",i),"src_agent_config",m_cfg.m_src_cfg[i]);
		end
		end
	if(m_cfg.has_dst_agent)
		begin 											//same goes for dst agent also
		dst_agent_top_h=new[m_cfg.no_of_dst_agent_top];
		foreach(dst_agent_top_h[i])
		begin
			dst_agent_top_h[i]=dst_agent_top::type_id::create($sformatf("dst_agent_top_h[%0d]",i),this);
			uvm_config_db#(dst_agent_config)::set(this,$sformatf("dst_agent_top_h[%0d]*",i),"dst_agent_config",m_cfg.m_dst_cfg[i]);// setting config
		end
		end
	if(m_cfg.has_scoreboard)
		r_sb=router_scoreboard::type_id::create("r_sb",this);
	if(m_cfg.has_virtual_sequencer)
		v_seqr_h=virtual_sequencer::type_id::create("v_seqr_h",this);	
endfunction

function void connect_phase(uvm_phase phase);	// 2 connection happens 1) scoreboard and monitor(through TLM ports)
	if(m_cfg.has_scoreboard)					//						2)  vseqr's seqrs get assigned to agent seqr
		begin
		foreach(src_agent_top_h[i])
			for(int j=0;j<m_cfg.no_of_src_agent;j++)// even though we are having only 1 agent inside agent top we are using tested loops for reuseability
				src_agent_top_h[i].src_agent_h[j].mon_h.monitor_port.connect(r_sb.fifo_src[i].analysis_export);
		foreach(dst_agent_top_h[i])
			for(int j=0;j<m_cfg.no_of_dst_agent;j++)
				dst_agent_top_h[i].dst_agent_h[j].mon_h.monitor_port.connect(r_sb.fifo_dst[i].analysis_export);
		end
	if(m_cfg.has_virtual_sequencer)// we are define what all components are present, so check accordingly and creat and connect
		begin						// actually we don't need to check whether it has vseqr because we have already checked this while
		foreach(src_agent_top_h[i])	// creating and we cannot connect somthing which is not created
		begin
			for(int j=0;j<m_cfg.no_of_src_agent;j++)
				v_seqr_h.src_seqr_h[i]=src_agent_top_h[i].src_agent_h[j].seqr_h;// assign the handles 
		end
		foreach(dst_agent_top_h[i])
		begin
			for(int j=0;j<m_cfg.no_of_dst_agent;j++)	
				v_seqr_h.dst_seqr_h[i]=dst_agent_top_h[i].dst_agent_h[j].seqr_h;
		end
		end
endfunction
		
endclass
