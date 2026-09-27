class mem_cov extends uvm_subscriber #(mem_tx);
	 mem_tx tx;
	 `uvm_component_utils(mem_cov)

	 covergroup cg;
		  ADDR: coverpoint tx.addr_i{
			   option.auto_bin_max = 4;
	      }

		  WR_RD: coverpoint tx.wr_rd_i{
			   bins HIGH = {1'b1};
			   bins LOW = {1'b0};
		  }

		 WR_RD_X_ADDR: cross WR_RD, ADDR;
	 endgroup

	 function new(string name, uvm_component parent);
		  super.new(name,parent);
		  cg = new();
	 endfunction

	 virtual function void write(mem_tx t);
		  tx = t;
		  cg.sample();
	 endfunction
endclass
