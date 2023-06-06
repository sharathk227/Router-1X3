class v_base_sequence extends uvm_sequence #(uvm_sequence_item);
`uvm_object_utils(v_base_sequence)
virtual_sequencer v_seqr_h;

src_sequencer src_seqr_h[];
dst_sequencer dst_seqr_h[]; 

env_config m_cfg;

src_small_packet src_small_packet_h;
dst_rand_packet dst_rand_packet_h;  // have to declare handles of different sequences
src_medium_packet src_medium_packet_h;
src_big_packet src_big_packet_h;
dst_softreset_packet dst_softreset_packet_h;

bit[1:0] addr;

function new(string name="v_base_sequence");
	super.new(name);
endfunction

task body();
	if(!uvm_config_db#(env_config)::get(null,get_full_name,"env_config",m_cfg))// vseq is a object type ,it doesn't  have hierarcy, while setting 
		`uvm_fatal(get_type_name,"have you set it properly")					// 1st arg is "null", 2nd is "get_full_name"(for getting the path)  
	src_seqr_h=new[m_cfg.no_of_src_agent_top];		// 	both dst and src agent are expected to be ACTIVE , so the number seqr will be the 
	dst_seqr_h=new[m_cfg.no_of_dst_agent_top];		// same as that of number of agent top
	assert($cast(v_seqr_h,m_sequencer))				// using assert we are dynamic casting for letting the vseqr handle inside vseq point to
	else											// the vseqr inside env. this is done via m_seqr
 	  `uvm_error("BODY", "Error in $cast of virtual sequencer")
	foreach(src_seqr_h[i])
		src_seqr_h[i]=v_seqr_h.src_seqr_h[i];	// assigning the local seqr with the seqr inside the vseqr of vseq
	foreach(dst_seqr_h[i])
		dst_seqr_h[i]=v_seqr_h.dst_seqr_h[i];
endtask

endclass
///////////////////////////////////////////////////////////////////////////////
class small_packet_vseq extends v_base_sequence;
`uvm_object_utils(small_packet_vseq)

function new(string name="small_packet_vseq");
	super.new(name);
endfunction


task body();
	super.body();		// super.body is called  for the seqrh to point and creation of the local seqrs inside the the vseq. 
	if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr)) // addr is set in test and according to that addr on the start
		`uvm_fatal("ADDR IN VSEQ","could get the addr")		// start should happen other if all the dst is started  all 3 dst will be waiting
	src_small_packet_h=src_small_packet::type_id::create("src_small_packet_h"); 	// creating of the seq
	dst_rand_packet_h=dst_rand_packet::type_id::create("dst_rand_packet_h");
	fork
	for(int i=0;i<m_cfg.no_of_src_agent_top;i++)
		src_small_packet_h.start(src_seqr_h[i]);
	if(addr==0)
		dst_rand_packet_h.start(dst_seqr_h[0]);
	if(addr==1)
		dst_rand_packet_h.start(dst_seqr_h[1]);
	if(addr==2)
		dst_rand_packet_h.start(dst_seqr_h[2]);
	join
endtask
endclass
///////////////////////////////////////////////////////////////////////////////
class medium_packet_vseq extends v_base_sequence;
`uvm_object_utils(medium_packet_vseq)
function new(string name ="medium_packet_vseq");
	super.new(name);
endfunction 
task body();
super.body();
if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr))
	`uvm_fatal("ADDR IN VSEQ","could get the addr ")

src_medium_packet_h=src_medium_packet::type_id::create("src_medium_packet_h");
dst_rand_packet_h=dst_rand_packet::type_id::create("dst_rand_packet_h");
fork
foreach(src_seqr_h[i])
	src_medium_packet_h.start(src_seqr_h[i]);
if(addr==0)
	dst_rand_packet_h.start(dst_seqr_h[0]);
if(addr==1)
	dst_rand_packet_h.start(dst_seqr_h[1]);
if(addr==2)
	dst_rand_packet_h.start(dst_seqr_h[2]);
join
endtask
endclass

//////////////////////////////////////////////////////////////////////////////
class big_packet_vseq extends v_base_sequence;
`uvm_object_utils(big_packet_vseq)
function new(string name="big_packet_vseq");
	super.new(name);
endfunction

task body();
super.body();
if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr))
	`uvm_fatal("ADDR IN VSEQ","could get the addr")
src_big_packet_h=src_big_packet::type_id::create("src_big_packet_h");
dst_rand_packet_h=dst_rand_packet::type_id::create("dst_rand_packet_h");
fork
foreach(src_seqr_h[i])
	src_big_packet_h.start(src_seqr_h[i]);
if(addr==0)
	dst_rand_packet_h.start(dst_seqr_h[0]);
if(addr==1)
	dst_rand_packet_h.start(dst_seqr_h[1]);
if(addr==2)
	dst_rand_packet_h.start(dst_seqr_h[2]);
join

endtask
endclass
///////////////////////////////////////////////////////////////////
class softreset_packet_vseq extends v_base_sequence;
`uvm_object_utils(softreset_packet_vseq)

function new(string name="softreset_packet_vseq");
 super.new(name);
endfunction


task body();
super.body();
if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr))
	`uvm_fatal("ADDR IN VSEQ","could get the addr")

src_medium_packet_h=src_medium_packet::type_id::create("src_medium_packet_h");
dst_softreset_packet_h=dst_softreset_packet::type_id::create("dst_softreset_packet");
fork
for(int i=0;i<m_cfg.no_of_src_agent_top;i++)
	src_medium_packet_h.start(src_seqr_h[i]);
if(addr==0)
	dst_softreset_packet_h.start(dst_seqr_h[0]);
if(addr==1)
	dst_softreset_packet_h.start(dst_seqr_h[1]);
if(addr==2)
	dst_softreset_packet_h.start(dst_seqr_h[2]);
join
endtask
endclass

