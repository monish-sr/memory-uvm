vlog +incdir+C:/questasim64_10.7c/verilog_src/uvm-1.2/src \
C:/questasim64_10.7c/verilog_src/uvm-1.2/src/uvm_pkg.sv \
list.svh
vopt top +cover=fcbest +acc=rnb -o nwr_nrd_test
vsim -suppress 12110 nwr_nrd_test -sv_lib {C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi} \
   +UVM_VERBOSITY=UVM_MEDIUM \
   +uvm_set_verbosity=uvm_test_top.env.agent.mem_drv.*,ALL,UVM_MEDIUM,time,100
do wave.do
coverage save -onexit nwr_nrd.ucdb
run -all
