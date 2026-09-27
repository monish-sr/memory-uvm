class mem_env extends uvm_env;
	 mem_agent agent;
	 mem_scb scb;
	 `uvm_component_utils(mem_env)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  agent = mem_agent::type_id::create("agent",this);
		  scb = mem_scb::type_id::create("scb",this);
	 endfunction

	 function void connect_phase(uvm_phase phase);
		  agent.mon.ap_port.connect(scb.ap_imp);
	 endfunction
endclass
