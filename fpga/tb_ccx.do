# set up the "work" library
vlib work
# compile our SystemVerilog files
vlog core.sv
vlog stack.sv
vlog node.sv
vlog row.sv
vlog corecomplex.sv
vlog tb_ccx.sv
# point the simulator at the compiled design
vsim work.tb_ccx
radix 10
radix signal prog 16
run 10