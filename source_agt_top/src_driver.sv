class src_driver extends uvm_driver#(src_xtn);	// has build-in class uvm_driver , the class in parameterized witb src xtns
`uvm_component_utils(src_driver)		// get the config , get the data from seqr ,send the data to DUV

virtual src_if.SRC_DRV_MP vif; 		// declaring virtual interface along with modport(modport needed to send the data)

src_agent_config m_cfg;			// declaring agent config

function new(string name="src_driver",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(src_agent_config)::get(this,"","src_agent_config",m_cfg)) 	// getting the config for virtual interface
		`uvm_fatal(get_full_name(),"couldn't get the config ,have you set it properly")
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);// in connect phase , assign the handle virtual interface from   agent config virtual interface
	vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);	// the send of data to DUV depends on the protocol
	@(vif.src_drv_cb);			// sending data with respect to clocking block
	vif.src_drv_cb.resetn<=0;	// resting 
	@(vif.src_drv_cb);
	vif.src_drv_cb.resetn<=1;
	forever
	begin				// inside forever loop, always check for whether data has been send by seqr . 
	seq_item_port.get_next_item(req);	// through seq item port get the nxt item send
	send_to_dut(req);		// calling method to send data to DUV
	seq_item_port.item_done();		// giving ack to seqr
	end
endtask

task send_to_dut(src_xtn xtn); 		// send the data according to protocol, and in diver always use non blocking assignment
	$display("at src drv cb");		// always refer to data with respect  to interface handle while send and recieving
	@(vif.src_drv_cb);
	wait(!vif.src_drv_cb.busy)		// check whether busy is high or not
	vif.src_drv_cb.pkt_valid<=1;	// assign pkt_vld has high
	vif.src_drv_cb.data_in<=xtn.header;		// now on the same clock we will send the header
	@(vif.src_drv_cb);	
	foreach(xtn.payload[i])	// on nxrt clk sen all the data ,each at one clock and always check for busy no to be high
	begin
		wait(!vif.src_drv_cb.busy)
		vif.src_drv_cb.data_in<=xtn.payload[i];
		@(vif.src_drv_cb);
	end
	vif.src_drv_cb.pkt_valid<=0;		// after sending all the data , it will get out of the loop and nxt clock make pkt_valid low
	vif.src_drv_cb.data_in<=xtn.parity;		// when pkt_vld is low send the parity
	@(vif.src_drv_cb);				//the 2 clock cycles are for checking err 
	@(vif.src_drv_cb);

	m_cfg.drv_sent_xtn_cnt++;		// for keeping  the xtn count
	`uvm_info("src_driver",$sformatf("\nprinting from src_DRIVER \n %s",xtn.sprint()),UVM_LOW)	//  will print whole packet 
endtask

function void report_phase(uvm_phase phase);
	
	`uvm_info(get_type_name,$sformatf("the number of src xtns driven is =%d",m_cfg.drv_sent_xtn_cnt),UVM_LOW) // for ref 
endfunction
endclass
