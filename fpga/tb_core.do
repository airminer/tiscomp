# set up the "work" library
vlib work
# compile our SystemVerilog files
vlog core.sv
vlog tb_core.sv
# point the simulator at the compiled design
vsim work.tb_core
radix 10
run 10
