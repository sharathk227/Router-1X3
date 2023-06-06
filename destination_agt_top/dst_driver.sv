class dst_driver extends uvm_driver #(dst_xtn); //parameter with dst_xtn,have seq_item_port
`uvm_component_utils(dst_driver)	// have to get the data from seq and drv it t DUV

virtual dst_if.DST_DRV_MP vif;	// virtual interface with modport(interfacing with DUV)

dst_agent_config m_cfg;	// to get the virtula interface and keep the count

function new(string name="dst_driver",uvm_component parent);// memory creation 
	super.new(name,parent); 	// base class memory creation
endfunction 

function void build_phase(uvm_phase phase); 	// get the agent config 
	super.build_phase(phase);
	if(!uvm_config_db#(dst_agent_config)::get(this,"","dst_agent_config",m_cfg))
		`uvm_fatal("config","couldn't get the configuration ");
endfunction

function void connect_phase(uvm_phase phase);// assign the virtual interface in config to local interface
	vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);// get the seq send via seqr
	forever// always check if any xtn is send buy seq
	begin
		seq_item_port.get_next_item(req); // communication happens through seq_item_port,using get next_item method
		send_to_dut(req);	// calling method to send to DUV
		seq_item_port.item_done();	// send ack to seq
	end
endtask

task send_to_dut(dst_xtn xtn); 	// method for sending to DUV and driving to DUV is done according to protocol
	@(vif.dst_drv_cb);			// in driver we are using no blocking
	$display("going to wait for valid_out"); 
	wait(vif.dst_drv_cb.valid_out)	// waiting for valid_out
	$display("got valid out");
	repeat(xtn.no_of_cycles)	//  delaying for giving read_enb according to number cycles
		@(vif.dst_drv_cb);
	vif.dst_drv_cb.read_enb<=1'b1;	// read enb given
	@(vif.dst_drv_cb);
	$display("going to get valid_out ");
	wait(!vif.dst_drv_cb.valid_out)// on nxt clocky cycle wait for vali_out to go low
	vif.dst_drv_cb.read_enb<=1'b0;	//  then make read_enb as low
	m_cfg.drv_sent_xtn_cnt++; // keep count
	`uvm_info("DST DRIVER",$sformatf("\n printing from dst driver \n %s",xtn.sprint()),UVM_LOW)	// print the whole xtn as a single string
endtask

function void report_phase(uvm_phase phase);
	`uvm_info(get_type_name(),$sformatf("the number dst xts send is %0d",m_cfg.drv_sent_xtn_cnt),UVM_LOW)	// after run phase print the total ccount of xtn
endfunction
endclass

