class dst_xtn extends uvm_sequence_item ; // have build_in base class
`uvm_object_utils(dst_xtn)// dst xtn data_types needed.The no_of_clock is defined as rand

bit [7:0]header;
bit [7:0]payload[];
bit [7:0]parity ;

rand int no_of_cycles;

function new(string name="dst_xtn");	// creating memory for dst_xtn
	super.new(name);
	payload=new[header[7:2]];	// creating size of memory needed for payload 
endfunction		//,since not rand can't use constraint

function  void do_print(uvm_printer printer);//  do_print(uvm_printer is build_in class)
	printer.print_field("header",this.header,8,UVM_DEC);// header
	foreach(payload[i])// each payload
		printer.print_field($sformatf("payload[%0d]",i),this.payload[i],8,UVM_DEC);
	printer.print_field("parity",this.parity,8,UVM_DEC);// parity 
	printer.print_field("no of cycles",this.no_of_cycles,5,UVM_DEC);// no of cycles
endfunction
	
endclass
