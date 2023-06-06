class src_sequencer extends uvm_sequencer#(src_xtn);	// parameterzie with src_xtn, have base class uvm_sequencer
`uvm_component_utils(src_sequencer)			// use of sequncer is the ports and handshaking between seq and drv

function new(string name="sequencer",uvm_component parent);
	super.new(name,parent);
endfunction

endclass

