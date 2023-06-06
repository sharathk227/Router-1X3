class src_monitor extends uvm_monitor; 	//  should we parameterized this, collect data from DUV  send data to scoreboard usig  analysis port
`uvm_component_utils(src_monitor)		// have  create the port in function new.

uvm_analysis_port#(src_xtn) monitor_port; // sending  xtn  file to scoreboard analysis fifo using analysis port 

virtual src_if.SRC_MON_MP s_vif;	// declaring virtual interface along with modport

src_agent_config m_cfg;	// config file to get virtual interface 

function new(string name="src_monitor",uvm_component parent);
	super.new(name,parent);
	monitor_port=new("monitor_port",this); 	// creating port
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(src_agent_config)::get(this,"","src_agent_config",m_cfg))	// get the config for virtual interface
		`uvm_fatal("config","couldn't get the config file,have you set it properly")
endfunction 

function void connect_phase(uvm_phase phase);
	//super.connect(phase);
	s_vif=m_cfg.vif;		// assign the  virtual interface the config virtual interface
endfunction

task run_phase(uvm_phase phase);
	forever
	begin
		collect_data();	 	// collect the data using a method

	end
endtask

task collect_data();	// declare local xtn type and the monitor does know the payload length. (doubt)
	src_xtn xtn;
	xtn=src_xtn::type_id::create("xtn");		// create memory for  xtn
	@(s_vif.src_mon_cb);	// with respect to clocking 
	wait(s_vif.src_mon_cb.pkt_valid && !s_vif.src_mon_cb.busy)		// check for pkt_valid and not busy
	xtn.header=s_vif.src_mon_cb.data_in;		//  assign the pin level data to packet data_type
	@(s_vif.src_mon_cb);		//nxt clock cycle assign payloaf 
	xtn.payload=new[xtn.header[7:2]];	// assign the payload length
	foreach(xtn.payload[i])
	begin
		wait(s_vif.src_mon_cb.pkt_valid && !s_vif.src_mon_cb.busy)	// checking whether pkt_valid and  busy is low .
		xtn.payload[i]=s_vif.src_mon_cb.data_in;	//  assigning the  payload( check the clocking)
		@(s_vif.src_mon_cb);		// can we assign value to rand datatype
	end
	wait(!s_vif.src_mon_cb.pkt_valid && !s_vif.src_mon_cb.busy)	// checking not busy
	xtn.parity=s_vif.src_mon_cb.data_in; 		// storing parity xtn parity
	@(s_vif.src_mon_cb);
	@(s_vif.src_mon_cb);
	xtn.error=s_vif.src_mon_cb.error;	// for chechking error  w clock cycle is needed // why  this err
	$display("\n printing from src monitor");
	xtn.print();	//printing 
	$display("error signal = %b",xtn.error);
	monitor_port.write(xtn);	// send data toscoreboard
	m_cfg.mon_rcvd_xtn_cnt++; 	// keep count

endtask
function void report_phase(uvm_phase phase);
	`uvm_info(get_type_name(),$sformatf("the no of data rcvd by the monitor is =%0d",m_cfg.mon_rcvd_xtn_cnt),UVM_LOW)	// print count
endfunction

endclass
