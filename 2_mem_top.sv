module top;
	bit clk,rst;
	mem_intf pif(clk,rst);

	memory_dut #(.depth(`DEPTH), .width(`WIDTH), .addr_width(`ADDR_WIDTH))
	dut(
		 .clk_i(pif.clk),
		 .rst_i(pif.rst),
		 .wr_rd_i(pif.wr_rd_i),
		 .wdata_i(pif.wdata_i),
		 .rdata_o(pif.rdata_o),
		 .addr_i(pif.addr_i),
		 .valid_i(pif.valid_i),
		 .ready_o(pif.ready_o)
		 );
	

	always #5 clk = ~clk;
	initial begin
		 clk = 0;
		 rst = 1;
		 pif.addr_i = 0;
		 pif.wr_rd_i = 0;
		 pif.wdata_i = 0;
		 pif.valid_i = 0;
		 
		 repeat(2)@(posedge clk);
		 rst = 0;
	end
	initial begin
		 uvm_config_db#(virtual mem_intf)::set(uvm_root::get(),"uvm_test_top.env.agent.*","vif",pif);
		 run_test("nwr_nrd_test");
	end
endmodule
