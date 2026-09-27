class mem_test extends uvm_test;
	 mem_env env;
	 `uvm_component_utils(mem_test)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  env = mem_env::type_id::create("env",this);
	 endfunction

	 function void end_of_elaboration_phase(uvm_phase phase);
		  super.end_of_elaboration_phase(phase);
		  uvm_top.print_topology();

	 endfunction

endclass
//1W
class wr_test extends mem_test;
	 wr_seq seq;
	 `uvm_component_utils(wr_test)
	 
	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  seq = wr_seq::type_id::create("seq",this);
	 endfunction

	 task run_phase(uvm_phase phase);
		  super.run_phase(phase);
		  phase.raise_objection(this);
		  phase.phase_done.set_drain_time(this,100);
		  seq.start(env.agent.sqr);
		  phase.drop_objection(this);
	 endtask
endclass

//5W
class wr5_test extends mem_test;
	 wr5_seq seq;
	 `uvm_component_utils(wr5_test)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sqr.run_phase","default_sequence",wr5_seq::get_type());
	 endfunction
endclass

//NW
class nwr_test extends mem_test;
	 nwr_seq seq;
	 `uvm_component_utils(nwr_test)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  seq = nwr_seq::type_id::create("seq",this);
	 endfunction

	 task run_phase(uvm_phase phase);
		  super.run_phase(phase);
		  phase.raise_objection(this);
		  phase.phase_done.set_drain_time(this,100);
		  seq.start(env.agent.sqr);
		  phase.drop_objection(this);
	 endtask
endclass

//1WR
class wr_rd_test extends mem_test;
	 wr_rd_seq seq;
	 `uvm_component_utils(wr_rd_test)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sqr.run_phase","default_sequence",wr_rd_seq::get_type());
	 endfunction
endclass

//5WR
class wr5_rd5_test extends mem_test;
	 wr5_rd5_seq seq;
	 `uvm_component_utils(wr5_rd5_test)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sqr.run_phase","default_sequence",wr5_rd5_seq::get_type());
	 endfunction
endclass

//NWR
class nwr_nrd_test extends mem_test;
	 nwr_nrd_seq seq;
	 `uvm_component_utils(nwr_nrd_test)

	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  seq = nwr_nrd_seq::type_id::create("seq",this);
	 endfunction

	 task run_phase(uvm_phase phase);
		  super.run_phase(phase);
		  phase.raise_objection(this);
		  phase.phase_done.set_drain_time(this,100);
		  seq.start(env.agent.sqr);
		  phase.drop_objection(this);
	 endtask
endclass
