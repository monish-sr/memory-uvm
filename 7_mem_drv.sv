class mem_drv extends uvm_driver #(mem_tx);
	 mem_tx tx;

	 virtual mem_intf vif;

	 `uvm_component_utils(mem_drv);
	 `NEW_COMP

	function void build_phase(uvm_phase phase);
		  uvm_config_db#(virtual mem_intf)::get(this,"","vif",vif);
	endfunction

	 task run_phase(uvm_phase phase);

		  //reset();
		  forever begin

		  	   wait(vif.rst == 0);
			   seq_item_port.get_next_item(req);
			   drive(req);
			   req.print();
			   seq_item_port.item_done();
		  end

	 endtask

	 task drive(mem_tx tx);
		  @(vif.drv_cb);


		  vif.drv_cb.addr_i <= tx.addr_i;
		  vif.drv_cb.wr_rd_i <= tx.wr_rd_i;
		  if(tx.wr_rd_i == 1) begin
			   vif.drv_cb.wdata_i <= tx.wdata_i;
			   tx.rdata_o <= 0;
		  end

		  vif.drv_cb.valid_i <= 1;
		  wait(vif.drv_cb.ready_o == 1);
		  if(tx.wr_rd_i == 0) tx.rdata_o <= vif.drv_cb.rdata_o;
		  vif.drv_cb.valid_i <= 0;

		  reset();
		  common::drv_count++;
	 endtask

	 task reset();

		  vif.drv_cb.addr_i <= 0;
		  vif.drv_cb.wr_rd_i <= 0;
		  vif.drv_cb.wdata_i <= 0;
		  vif.drv_cb.valid_i <= 0;

		  @(vif.drv_cb);
	 endtask



endclass
