class src_base_sequence extends uvm_sequence #(src_xtn); // parameterise with src_xtn,sequence  generate  data for drc
`uvm_object_utils(src_base_sequence)

bit [1:0] addr;	// we are settting the addr  beforehand

function new(string name="src_base_sequence");	// creating memory
	super.new(name);
endfunction 
endclass
 
class src_small_packet extends src_base_sequence;		//  create different xtn
`uvm_object_utils(src_small_packet)

function new(string name="src_small_packet"); // creating class 
	super.new(name);
endfunction

task body();	//  body method is called by start method in virtual seq
begin
	if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr))	// the addr is set ny the test 
		`uvm_fatal("SRC SMALL","couldn't get the addr")	
	req=src_xtn::type_id::create("req");	// creating the seq  as req
	start_item(req);	//sending the req to seqr
	assert(req.randomize() with {header[7:2] inside{[1:14]};	// randomizing with inline constraint 
				     header[1:0]==addr;});
//	`uvm_info("SRC_small_packet",$sformatf("printing from src \n %s",req.sprint()),UVM_LOW)
	
	finish_item(req);		//receiving the ack from the driver
end
endtask
endclass

class src_medium_packet extends src_base_sequence; 		// all xtn  seq are similar
`uvm_object_utils(src_medium_packet)

function new(string name="src_medium_packet");
	super.new(name);
endfunction

task body();
begin
	if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr))
		`uvm_fatal("SRC SMALL","couldn't get the addr")
	req=src_xtn::type_id::create("req");
	start_item(req);
	assert(req.randomize() with {header[7:2] inside{[15:33]};
					header[1:0]==addr;});
	`uvm_info("SRC_medium_packet",$sformatf("printing from src \n %s",req.sprint()),UVM_HIGH)
	finish_item(req);
end
endtask
endclass

class src_big_packet extends src_base_sequence;
`uvm_object_utils(src_big_packet)

function new(string name ="src_big_packet");
	super.new(name);
endfunction

task body();
begin
	if(!uvm_config_db#(bit[1:0])::get(null,get_full_name,"bit[1:0]",addr))
		`uvm_fatal("SRC SMALL","couldn't get the addr")

	req=src_xtn::type_id::create("req");
	start_item(req);
	assert(req.randomize() with {header[7:2]inside {[34:63]};
					header[1:0]==addr;});
	`uvm_info("SRC_big_packet",$sformatf("printing from src \n %s",req.sprint()),UVM_HIGH)

	finish_item(req);
end
endtask
endclass
  
