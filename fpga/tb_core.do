# set up the "work" library
vlib work
# compile our SystemVerilog files
vlog core.sv
vlog tb_core.sv
# point the simulator at the compiled design
vsim work.tb_core
radix 16
radix signal pLength 10
radix signal pc 10
radix signal acc 10
radix signal bak 10
run 10
