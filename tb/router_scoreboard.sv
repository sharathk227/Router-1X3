class router_scoreboard extends uvm_scoreboard;
`uvm_component_utils(router_scoreboard)

uvm_tlm_analysis_fifo #(src_xtn) fifo_src[]; 	//declareing dynamic  handlles of TLM fifos for both sides
uvm_tlm_analysis_fifo #(dst_xtn) fifo_dst[];

env_config m_cfg;		//we are getting the config from in SB to know how many number of fifo should be created  for each sides

src_xtn s_xtn;			// we need  to get the xtns from monitor , and the datatype is xtn 
dst_xtn d_xtn;

covergroup router_fcov1;// writing covergroups 
	
	SRC_HEADER_ADDR:coverpoint s_xtn.header[1:0]{		// coverpoints  and inside coverpoints we give the bins to hit
					bins zero={2'b00};					// if not mention , is will automatically define bins according to the declaration
					bins one={2'b01};					// of that data type
					bins two={2'b10};
						}
	SRC_PAYLOAD_LENGTH:coverpoint s_xtn.header[7:2]{	// each xtn property which is in xtns type is checked for the same way
					bins SMALL={[1:14]};
					bins MEDIUM ={[15:34]};
					bins BIG ={[34:63]};
						}
	SRC_CROSS:cross SRC_HEADER_ADDR,SRC_PAYLOAD_LENGTH;	// we have to get the cross for all the coverproperty also

	SRC_ERROR_XTN:coverpoint s_xtn.error{
						bins zero={0};
						bins one={1};
						}
endgroup

covergroup router_fcov2;		// similarly we have do for the dst side also
	
	DST_HEADER_ADDR:coverpoint d_xtn.header[1:0]{
					bins zero={2'b00};
					bins one={2'b01};
					bins two={2'b10};
						}
	DST_PAYLOAD_LENGTH:coverpoint d_xtn.header[7:2]{
					bins SMALL={[1:14]};
					bins MEDIUM ={[15:34]};
					bins BIG ={[35:63]};
						}
	DST_NO_OF_CYCLE:coverpoint d_xtn.no_of_cycles{
							bins IN_RANGE={[0:28]};
						//	bins OUT_OF_RANGE={[29:40]};
							}
						
	DST_CROSS:cross DST_HEADER_ADDR,DST_PAYLOAD_LENGTH,DST_NO_OF_CYCLE;
endgroup		


function new(string name ="router_scoreboard",uvm_component parent );
	super.new(name,parent);
	router_fcov1=new; 		//in function new we have to create the  memory for the covergroups also
	router_fcov2=new;
endfunction

function void build_phase (uvm_phase phase );
	if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("SCORE BOARD","\n could not get the env config ")
	fifo_src=new[m_cfg.no_of_src_agent_top];		// after getting the config ,declare the number of fifo you need according to the number
	fifo_dst=new[m_cfg.no_of_dst_agent_top];		// agent present,which in this case it will be 4(1src +3dst)
	foreach(fifo_src[i])
		fifo_src[i]=new($sformatf("fifo_src[%0d]",i),this);		//why we didn't create the memory for fifo inside function is that we need 
	foreach(fifo_dst[i])									// to get the config file and then only can assign the number of fifo needed
		fifo_dst[i]=new($sformatf("fifo_dst[%0d]",i),this);
	super.build_phase(phase);
	s_xtn=src_xtn::type_id::create("s_xtn",this);		// create the xtn handles for usiug
	d_xtn=dst_xtn::type_id::create("d_xtn",this);		
endfunction

task run_phase(uvm_phase phase);
	fork	// both the  src and dst side should check for getting the data
		begin
		forever
			begin
				fifo_src[0].get(s_xtn); // always check whether the monitor has written something
				router_fcov1.sample();	//sampling for coverage
			end
		end
		begin
		forever		// dst should always check whether  the is some data to get 
			begin
			fork	//since dst side has 3 agents we need to all 3 of them to check simultaneously as the scoreboard doesn't
			begin	// know which dst monitor is write the data . WE are usign fork join_any so any one completes first it will jump out
				fifo_dst[0].get(d_xtn);		//get the data from monitor
				$display("INSIDE SB \n from FIFO DST[0]");
				check_data(d_xtn);			//check data method is comparing the data send is correctly recieved or not
				router_fcov2.sample();		//sampling  for coverage of the xtns properties
			end
			begin
				fifo_dst[1].get(d_xtn);
				$display("INSIDE SB \n from FIFO DST[1]");				
				check_data(d_xtn);
				router_fcov2.sample();
			end

			begin
				fifo_dst[2].get(d_xtn);
				$display("INSIDE SB \n from FIFO DST[2]");
				check_data(d_xtn);
				router_fcov2.sample();
			end

			join_any  
			end
		end
	join
endtask

task check_data(dst_xtn d_xtn);		// check data will check the data send  and recieved are same or not at the same instance
$display("INSIDE SB \n check_data started");
if(s_xtn.header==d_xtn.header) 		// checking for header
	begin
	foreach(d_xtn.payload[i])
		begin
		if(d_xtn.payload[i]!=s_xtn.payload[i])	//chechking for each payload ,if it failes then it will display "PAYLOAD MISMATCH"
		begin									// and return out of the task
			$display("PAYLOAD MISMATCH");
			return;
		end
		end
	

	end
	
else	// checking header matches or not
	begin
	$display("HEADER MISMATCH");
	return;
	end
begin		// this block will check for parity to match ,and this block is separete block ,after checking the if condition only 
			//this block gets executed
	if(s_xtn.parity!=d_xtn.parity)
		begin
			$display("FAILED @@@@@@@ parity check");
			`uvm_info("PARITY MISMATCH" ,"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n BAD TRANSACTION",UVM_LOW)
			return;
		end
	else
		begin
			$display("SUCCESS @@@@@@@ parity check");
			`uvm_info("PARITY MATCH", "\n GOOD TRANACTION",UVM_LOW)
		end
end

$display("DONE CHECKING " );

$display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n\n\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
endtask
endclass
