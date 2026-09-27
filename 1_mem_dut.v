module memory_dut #(parameter depth = 16, width = 4, addr_width = $clog2(depth)) (clk_i,rst_i,wr_rd_i,wdata_i,rdata_o,addr_i,valid_i,ready_o);
	
	input clk_i,rst_i,wr_rd_i,valid_i;
	input [width-1:0] wdata_i;
	input [addr_width-1:0] addr_i;
	
	output reg [width-1:0] rdata_o;
	output reg ready_o;

	reg [width-1:0] mem [depth-1:0];
	
	integer i;

	always@(posedge clk_i or posedge rst_i) begin
		 if(rst_i) begin
			  ready_o <= 0;
			  rdata_o <= 0;

			  for(i=0;i<depth;i=i+1) begin
				   mem[i] <= 0;
			  end
		 end

		 else begin
			  if(valid_i) begin
				    ready_o <= 1;
				   if(wr_rd_i) mem[addr_i] <= wdata_i;
				   else rdata_o <= mem[addr_i];
			  end
		 	  else ready_o <= 0;
		 end
	end

endmodule
