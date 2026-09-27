class mem_scb extends uvm_scoreboard;
	 
	 //mem_tx tx;
	 uvm_analysis_imp #(mem_tx,mem_scb) ap_imp;
	 bit [`WIDTH-1:0] mem[*];

	 `uvm_component_utils(mem_scb)
	 
	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  ap_imp = new("ap_imp",this);
	 endfunction

	 function void write(mem_tx tx);
		  if(tx.wr_rd_i) mem[tx.addr_i] = tx.wdata_i;
		  else begin
			   if(tx.rdata_o == mem[tx.addr_i]) common::matching++;
			   else common::mismatching++;
		  end
	 endfunction

	 function void report_phase(uvm_phase phase);
		  `uvm_info("FINAL REPORT",$sformatf("Matching: %0d | Mismatching: %0d",common::matching,common::mismatching),UVM_LOW)
	 endfunction

endclass
