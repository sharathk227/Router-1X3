class src_xtn extends uvm_sequence_item ; 		// declaring  the data types  involved in src xtn packets
`uvm_object_utils(src_xtn)		// randamize header and payload . but not parity .parity is assigned after randamization
								// define constraints also
rand bit [7:0] header; // declaring the data types for xtns 
rand bit [7:0] payload[];
bit[7:0] parity;
bit error;

constraint pl_size{header[7:2]!=0;}		// defining the constraints for data types
constraint addr_range{header[1:0]!=3;}
constraint payload_length{payload.size()==header[7:2];}

function void post_randomize(); 	// after randamizing ,we have create internal parity .
	parity=0^header;				// parity is calculated by  EXORing header and each payload .
	foreach(payload[i])	
		parity=parity^payload[i];
endfunction
 

function new(string name ="src_xtn");
	super.new(name); 
endfunction

function void do_print(uvm_printer printer);	// Define different methods used on the xtns data types , here it's  do_print. 
	printer.print_field("header",this.header,8,UVM_DEC);		// if this property is called the whole xtn data should be printed .
	foreach(payload[i])												// first the header then payload  and finaly parity .
		printer.print_field($sformatf("payload[%0d]",i),this.payload[i],8,UVM_DEC);	// printing is done table formate (print_field)
	printer.print_field("parity",this.parity,8,UVM_DEC);	//uvm_printer is a build in class
endfunction
endclass
/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Defining the err xtn class which is extended from src_xtn class only but funtion post_randomize is overriden.
err xtn class  ussed by replace any other xtns class such as small ,medium or large.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
class src_err_xtn extends src_xtn;
`uvm_object_utils(src_err_xtn)

function void post_randomize();
	parity=$urandom;
endfunction

function new(string name="src_err_xtn");	// parity is made to be randome so that parity mismatch happens.
	super.new(name);
endfunction
endclass
	
