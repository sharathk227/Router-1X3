class dst_monitor extends uvm_monitor;  //  getting the data from DUV and sending to scoreboard 
`uvm_component_utils(dst_monitor)	// pin level data to packet ,xtn is send to SB through TLM analysis fifo

virtual dst_if.DST_MON_MP vif;		// defining local virtual interface to point to static interface

dst_agent_config m_cfg;		// config the get the virtual interface

uvm_analysis_port#(dst_xtn) monitor_port;	// analysis port for sending the data to DUV

function new(string name="dst_monitor",uvm_component parent);// memory creation
	super.new(name,parent);
	monitor_port=new("monitor_port",this);		// creating analysis port
endfunction

function void  build_phase(uvm_phase phase );	// in build_phase get the config
	super.build_phase(phase);
	if(!uvm_config_db#(dst_agent_config)::get(this,"","dst_agent_config",m_cfg))	// get the config
		`uvm_fatal("config","couldn't get the configuration ")
endfunction

function void connect_phase(uvm_phase phase);	// assign the config interface(pointing to static interface) to local virtula interface
	vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
	forever 
	begin
		collect_data();// collect the data and send to scoreboard(using one method to collec data and to write it scoreboard)
	end
endtask

task collect_data();	// pin level to packet level, we have to check the header,payload and parity so collect that.
	dst_xtn xtn;	// to store the pin level data  to packet level 
	xtn=dst_xtn::type_id::create("xtn");// create it
	@(vif.dst_mon_cb);	// collect each data_packet
	wait(vif.dst_mon_cb.read_enb)	// waiting for read _enb
	@(vif.dst_mon_cb);		//nxt cycle collect the header
	xtn.header=vif.dst_mon_cb.data_out;	
	@(vif.dst_mon_cb);// now after collectiong the header assign the payload lenght
	xtn.payload=new[xtn.header[7:2]];
	foreach(xtn.payload[i])
	begin	// for each payload assign data and chech for read_enb 
		@(vif.dst_mon_cb);	
		wait(vif.dst_mon_cb.read_enb)
		xtn.payload[i]=vif.dst_mon_cb.data_out;
	end	
	@(vif.dst_mon_cb);
	wait(!vif.dst_mon_cb.valid_out) // after getting all the payload ,check for valid_out to go low and get the parity
	@(vif.dst_mon_cb);
	xtn.parity=vif.dst_mon_cb.data_out;
	monitor_port.write(xtn);// send to the entire xtn to scoreboard
	m_cfg.mon_rcvd_xtn_cnt++;	// keep the count
	`uvm_info("DST MONITOR",$sformatf("\n printing from dst  monitor \n %s ",xtn.sprint()),UVM_LOW)	// print the entire xtn as a string
endtask

function void report_phase(uvm_phase phase);
	`uvm_info(get_full_name,$sformatf("the no of xtn send from dst monitor %0d",m_cfg.mon_rcvd_xtn_cnt),UVM_LOW) 	// print the final count stored in config
endfunction

endclass
