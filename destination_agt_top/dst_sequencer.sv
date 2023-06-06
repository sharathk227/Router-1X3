class dst_sequencer extends uvm_sequencer#(dst_xtn) ;// parameterized with dst_xtn 
`uvm_component_utils(dst_sequencer)				//base class have seq_item_export

function new(string name="dst_sequencer",uvm_component parent);	// creating memory  
	super.new(name,parent);	// creating base class memory
endfunction

endclass
