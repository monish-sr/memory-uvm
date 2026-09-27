interface mem_intf(input bit clk,rst);
	 logic [`ADDR_WIDTH-1:0] addr_i;
	 logic wr_rd_i;
	 logic [`WIDTH-1:0] wdata_i;
	 logic valid_i;
	 logic ready_o;
	 logic [`WIDTH-1:0] rdata_o;

	 clocking drv_cb @(posedge clk);
		  output addr_i;
		  output wr_rd_i;
		  output wdata_i;
		  output valid_i;
		  input #1 ready_o;
		  input  rdata_o;
	 endclocking

	 clocking mon_cb @(posedge clk);
		  input addr_i;
		  input wr_rd_i;
		  input wdata_i;
		  input #1 valid_i;
		  input #1 ready_o;
		  input  rdata_o;
	 endclocking

	 sequence ready_valid;
		  valid_i ##1 ready_o;
	 endsequence

	 sequence ready_wr_rd;
		  ready_valid ##0 !($isunknown(wr_rd_i));
	 endsequence

	 property wr_addr_unknown;
		  @(posedge clk) disable iff(rst) (valid_i && wr_rd_i) |-> !($isunknown(addr_i));
	 endproperty

	 property wr_data_unknown;
		  @(posedge clk) disable iff (rst) (valid_i && wr_rd_i) |-> !($isunknown(wdata_i));
	 endproperty

	 property rd_addr_unknown;
		  @(posedge clk) disable iff (rst) (valid_i && !wr_rd_i) |-> !($isunknown(addr_i));
	 endproperty

	 property rd_data_unknown;
		  @(posedge clk) disable iff(rst) (valid_i && !wr_rd_i) |=> (ready_o && !($isunknown(rdata_o)));
	 endproperty


	 assert property(wr_addr_unknown);
	 assert property(wr_data_unknown);
	 assert property(rd_addr_unknown);
	 assert property(rd_data_unknown);
endinterface
