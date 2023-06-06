class router_base_test extends uvm_test;
`uvm_component_utils(router_base_test)

int no_of_src_agent_top=1;
int no_of_dst_agent_top=3;
int no_of_src_agent=1;
int no_of_dst_agent=1;
bit has_src_agent=1;
bit has_dst_agent=1;
bit[1:0] addr;

src_agent_config m_src_cfg[];  
dst_agent_config m_dst_cfg[];
 
// we are gonna create agent config files in test and they are assigned to the env config files				
// these  env config files have agent config files inside them , rember to create the config file and
// then call the method config  which will make the agent config files to point to agent config inside the env config 

env_config m_cfg;

router_tb tb_h;

function new(string name="router_test",uvm_component parent);
	super.new(name,parent);
endfunction
// create env config and assign the no.of dynamic handles in the agent config 
// call the congif function and and create the config files for agent according to the number of agent top
//(here we are gonna take the agent top has many and each agent top will be have one agent only,thats how we are gonna consider) 
//all of this is done if it has the particular agents inside it and the env config fill is set to all in test.
function void config_router();
if(has_src_agent)
begin
m_src_cfg=new[no_of_src_agent_top];
foreach(m_src_cfg[i])
begin
	m_src_cfg[i]=src_agent_config::type_id::create($sformatf("m_src_cfg[%0d]",i));
	if(!uvm_config_db#(virtual src_if)::get(this,"",$sformatf("s_vif_%0d",i),m_src_cfg[i].vif))// getting the interface from top to agent config file		`uvm_fatal("virtual interface src","couldn't get the config , have you set it properly")
	m_src_cfg[i].is_active=UVM_ACTIVE;
	m_cfg.m_src_cfg[i]=m_src_cfg[i];// assign the agent config file to agent config file inside env config file
end 
end

if(has_dst_agent)
begin
m_dst_cfg=new[no_of_dst_agent_top];
foreach(m_dst_cfg[i])
begin
	m_dst_cfg[i]=dst_agent_config::type_id::create($sformatf("m_dst_cfg[%0d]",i));
	if(!uvm_config_db#(virtual dst_if)::get(this,"",$sformatf("d_vif_%0d",i),m_dst_cfg[i].vif))
		`uvm_fatal("virtual interface dst","couldn't get the config ,have you set it properly")
	m_dst_cfg[i].is_active=UVM_ACTIVE;
	m_cfg.m_dst_cfg[i]=m_dst_cfg[i];		
	
end
end
m_cfg.has_src_agent=has_src_agent;
m_cfg.has_dst_agent=has_dst_agent;		// assign all the properties needed  for creating the agent and agent top, and for env also
m_cfg.no_of_src_agent_top=no_of_src_agent_top;
m_cfg.no_of_dst_agent_top=no_of_dst_agent_top;
m_cfg.no_of_src_agent=no_of_src_agent;
m_cfg.no_of_dst_agent=no_of_dst_agent;
endfunction

function void build_phase(uvm_phase phase );
	m_cfg=env_config::type_id::create("m_cfg"); // creating the env
	if(has_src_agent)
		m_cfg.m_src_cfg=new[no_of_src_agent_top];// the agent config files inside the env are considered to daynamic in nature 
	if(has_dst_agent)				// so you have  to initialize the number of agent config files required for it
		m_cfg.m_dst_cfg=new[no_of_dst_agent_top];
	config_router();				// after setting all the config inside tb then we can send it to tb  and all the other class
	uvm_config_db#(env_config)::set(this,"*","env_config",m_cfg);
	super.build_phase(phase);			// super.build is done at the end of buildphase	
	tb_h=router_tb::type_id::create("tb_h",this);
endfunction
	
endclass
///////////////////////////////////////////////////////////////////
class small_packet_test extends router_base_test;
`uvm_component_utils(small_packet_test)
small_packet_vseq small_packet_vseq_h;
function new(string name ="small_packet_test",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase );
	super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);
repeat(25)
begin					//in run_phase we are raising and dropping objections,also we are randomizing the the addr and setting it to v sequence 
	addr={$urandom}%3;		// so that is we don't have to start the seq for all the dst agents.(addr should be randomized between 0-2)
	$display("addr= %0d",addr);
	uvm_config_db#(bit[1:0])::set(this,"*","bit[1:0]",addr);
	small_packet_vseq_h=small_packet_vseq::type_id::create("small_packet_vseq_h");//  we are inst the required vsequence and call the start method on to it
	phase.raise_objection(this);
		$display(" if displayed that means you have raised the objection");
		small_packet_vseq_h.start(tb_h.v_seqr_h); 		// here to things are happening:1) m_sequencer handles gets pointed to the vsequencer
									// 					and using this handles only the vseqr inside vseq
									// 					is able to point to vseqr in env.
									//				2) start method will call the body method(task) inside the 														 vsequence.
		$display("you have started the start method nxt is dropping objection");
	phase.drop_objection(this);
end
endtask

endclass
/*///////////////////////////////////////////////////////////////////////////////////

	Same goes for every testcase,run_phase ,build_phase, constructor.
	The only differnce is that,the start method called on to different seq according to required test cases
	Inside the run_phase we are repeating all the steps  as many times as we need 

////////////////////////////////////////////////////////////////////////////////////*/
class medium_packet_test extends router_base_test;
`uvm_component_utils(medium_packet_test)
medium_packet_vseq medium_packet_vseq_h;

function new(string name ="medium_packet_test",uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);
repeat(26)
begin
	addr={$urandom}%3;	
	$display("addr =%d",addr);
	uvm_config_db#(bit[1:0])::set(this,"*","bit[1:0]",addr);
	medium_packet_vseq_h=medium_packet_vseq::type_id::create("medium_packet_vseq_h");
	phase.raise_objection(this);
		medium_packet_vseq_h.start(tb_h.v_seqr_h);
	phase.drop_objection(this);
end
endtask
endclass
////////////////////////////////////////////////////////////////////////////////////
class big_packet_test extends router_base_test;
`uvm_component_utils(big_packet_test)
big_packet_vseq big_packet_vseq_h;

function new(string name ="big_packet_test",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);
repeat(25)
begin
	addr={$urandom}%3;	
	$display("addr =%d",addr);
	uvm_config_db#(bit[1:0])::set(this,"*","bit[1:0]",addr);
	big_packet_vseq_h=big_packet_vseq::type_id::create("big_packet_vseq_h");
	phase.raise_objection(this);
		big_packet_vseq_h.start(tb_h.v_seqr_h);
	phase.drop_objection(this);
end
endtask
endclass
///////////////////////////////////////////////////////////////////////////
class err_packet_test extends router_base_test;
`uvm_component_utils(err_packet_test)
small_packet_vseq small_packet_vseq_h;

function new(string name="err_packet_test",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);
repeat(25)
begin
	addr={$urandom}%3;
	$display("addr=%0d",addr);
	uvm_config_db#(bit[1:0])::set(this,"*","bit[1:0]",addr);
	set_type_override_by_type(src_xtn::get_type(),src_err_xtn::get_type()); // here we are overridding all the smallvseq  with error seq , if call anything 
	small_packet_vseq_h=small_packet_vseq::type_id::create("small_packet_vseq_h");// with smallvseq handles it will point to error vseq after overriding
	phase.raise_objection(this);
		small_packet_vseq_h.start(tb_h.v_seqr_h);
	phase.drop_objection(this);
end
endtask
endclass
////////////////////////////////////////////////////////////////////////////////
class softreset_packet_test extends router_base_test;
`uvm_component_utils(softreset_packet_test)
softreset_packet_vseq softreset_packet_vseq_h;
function new(string name="softreset_packet_test",uvm_component parent);
	super.new(name,parent);
endfunction
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction
task run_phase(uvm_phase phase);
repeat(25)
begin	$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@strating softreset xtn");
	addr={$urandom}%3;
	$display("addr=%0d",addr);
	uvm_config_db#(bit[1:0])::set(this,"*","bit[1:0]",addr);
	softreset_packet_vseq_h=softreset_packet_vseq::type_id::create("softreset_packet_vseq_h");
	phase.raise_objection(this);
		softreset_packet_vseq_h.start(tb_h.v_seqr_h);
	phase.drop_objection(this);
end
endtask
endclass

