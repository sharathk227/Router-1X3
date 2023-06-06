class dst_base_sequence extends uvm_sequence #(dst_xtn);//parameterize with dst xtn type,
`uvm_object_utils(dst_base_sequence)// have build _in class,

function new(string name ="dst_base_sequence"); 	// class memory creation 
	super.new(name);
endfunction

endclass

class dst_rand_packet extends dst_base_sequence;
`uvm_object_utils(dst_rand_packet) // the seq will be instantiated in vseq 

function new(string name ="dst_rand_packet");
	super.new(name);
endfunction

task body();	// start method in vseq will call the body method of seq
begin
	req=dst_xtn::type_id::create("req");// have to create the xtn req for sending
	start_item(req);//start_item will ask for grant and send the xtns after grant is given
	assert(req.randomize() with {no_of_cycles inside{[0:28]};})//randomize,inline constraint
		`uvm_info("DST SMALL PACKET",$sformatf(" \n printing from dst \n %s",req.sprint()),UVM_LOW)
	finish_item(req);// after sending data to drv and waiting for ack
end
endtask

endclass
//////////////////////////////////////////////////////////////////////////////////////
class dst_softreset_packet extends dst_base_sequence;	// softreset xtn
`uvm_object_utils(dst_softreset_packet)	// similar to  above seq but constraint is different

function new(string name="dst_softreset_packet");
	super.new(name);
endfunction

task body();
begin
	req=dst_xtn::type_id::create("req");
	start_item(req);
	assert(req.randomize() with{no_of_cycles inside {[29:40]};}) // read_enb after 28 clock cycles
	$display("the no of cycles is =%0d ",req.no_of_cycles);
		`uvm_info("DST MEDIUM PACKET ",$sformatf("printing from dst \n %s",req.sprint()),UVM_LOW)
	finish_item(req);// send and waiting for ack
end
endtask

endclass

