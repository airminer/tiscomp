# set up the "work" library
vlib work
# compile our SystemVerilog files
vlog core.sv
vlog stack.sv
vlog tb_core.sv
# point the simulator at the compiled design
vsim work.tb_core
radix 10
radix signal prog 16
run 10
