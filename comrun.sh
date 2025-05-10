set -euo
iverilog -o simulation_riscv -g2012 -s tf_rvp `echo *sv`
vvp simulation_riscv
#gtkwave riscv_load_dump.vcd
