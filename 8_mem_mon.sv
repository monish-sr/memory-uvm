class mem_mon extends uvm_monitor;
	 mem_tx tx;
	 virtual mem_intf vif;

	 uvm_analysis_port #(mem_tx) ap_port;
	 `uvm_component_utils(mem_mon)


	 `NEW_COMP

	 function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  uvm_config_db#(virtual mem_intf)::get(this,"","vif",vif);
		  ap_port = new("ap_port",this);
	 endfunction
	 task run_phase(uvm_phase phase);
		  forever begin

			   @(vif.mon_cb);
			   if(vif.valid_i && vif.ready_o) begin
					tx = mem_tx::type_id::create("tx");
					tx.addr_i = vif.addr_i;
					tx.wr_rd_i = vif.wr_rd_i;
					if(tx.wr_rd_i) begin
						 tx.wdata_i = vif.wdata_i;
						 tx.rdata_o = 0;
					end
					else begin
						 tx.wdata_i = 0;
						 tx.rdata_o = vif.rdata_o;
					end

					ap_port.write(tx);
		  	   end
			   
		  end
	 endtask
endclass
