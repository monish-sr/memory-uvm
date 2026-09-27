class mem_seq extends uvm_sequence #(mem_tx);
	 mem_tx tx,temp[$];
	 bit[`ADDR_WIDTH-1:0] addr_tx[$];

	 uvm_phase phase;
	 `uvm_object_utils(mem_seq)
	 `NEW_OBJ

	 task pre_body();
		  phase = get_starting_phase();
		  if(phase != null) begin
			   phase.raise_objection(this);
			   phase.phase_done.set_drain_time(this,100);
		  end
	 endtask

	 task post_body();
		  if(phase != null) phase.drop_objection(this);
	 endtask
endclass

//1W
class wr_seq extends mem_seq;
	 `uvm_object_utils(wr_seq)
	 `NEW_OBJ

	 task body();
		  `uvm_do_with(req, {req.wr_rd_i == 1;})
	 endtask
endclass

//5W
class wr5_seq extends mem_seq;
	 `uvm_object_utils(wr5_seq)
	 `NEW_OBJ

	 task body();
		  repeat(5) begin
			   `uvm_do_with(req,{req.wr_rd_i == 1;!(req.addr_i inside {addr_tx});})
			   addr_tx.push_back(req.addr_i);
		  end
	 endtask
endclass

//NW
class nwr_seq extends mem_seq;
	 `uvm_object_utils(nwr_seq)
	 `NEW_OBJ

	 task body();
		  repeat(common::N) begin
			   `uvm_do_with(req,{req.wr_rd_i == 1;})
		  end
	 endtask
endclass

//1WR
class wr_rd_seq extends mem_seq;
	 `uvm_object_utils(wr_rd_seq)
	 `NEW_OBJ

	 task body();
	 	begin
			 `uvm_do_with(req,{req.wr_rd_i == 1;})
			 tx = new req;
			 temp.push_back(tx);
	 	end

   		begin
			tx = temp.pop_front();
			`uvm_do_with(req,{req.wr_rd_i == 0; req.addr_i == tx.addr_i; req.wdata_i == 0;})
		end
	 endtask
endclass

//5WR
class wr5_rd5_seq extends mem_seq;
	 `uvm_object_utils(wr5_rd5_seq)
	 `NEW_OBJ

	 task body();
		  repeat(5) begin
			   `uvm_do_with(req,{req.wr_rd_i == 1; !(req.addr_i inside {addr_tx});})
			   addr_tx.push_back(req.addr_i);
			   tx = new req;
			   temp.push_back(tx);
		  end

		  repeat(5) begin
			   tx = temp.pop_front();
			   `uvm_do_with(req,{req.wr_rd_i == 0; req.addr_i == tx.addr_i; req.wdata_i == 0;})
		  end
	 endtask
endclass

//NWR
class nwr_nrd_seq extends mem_seq;
	 `uvm_object_utils(nwr_nrd_seq)
	 `NEW_OBJ

	 task body();
		  repeat(common::N) begin
			   `uvm_do_with(req,{req.wr_rd_i == 1; !(req.addr_i inside {addr_tx});})
			   addr_tx.push_back(req.addr_i);
			   tx = new req;
			   temp.push_back(tx);
		  end

		  repeat(common::N) begin
			   tx = temp.pop_front();
			   `uvm_do_with(req,{req.wr_rd_i == 0; req.addr_i == tx.addr_i; req.wdata_i == 0;})
		  end
	 endtask
endclass
