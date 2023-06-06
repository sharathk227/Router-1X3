package router_test_pkg;

import uvm_pkg::*;

`include "uvm_macros.svh"
`include "src_xtn.sv"
`include "src_agent_config.sv"
`include "dst_agent_config.sv"
`include "env_config.sv"

`include "src_driver.sv"
`include "src_monitor.sv"
`include "src_sequencer.sv"
`include "src_agent.sv"
`include "src_agent_top.sv"
`include "src_sequence.sv" 


`include "dst_xtn.sv"
`include "dst_monitor.sv"
`include "dst_sequencer.sv"
`include "dst_driver.sv"
`include "dst_agent.sv"
`include "dst_agent_top.sv"
`include "dst_sequence.sv"

`include "virtual_sequencer.sv"
`include "virtual_sequence.sv"
`include "router_scoreboard.sv"

`include "router_tb.sv" 
 
`include "router_test.sv"
endpackage
