set -euo
iverilog -o simulation_riscv -g2012 -s riscv_pipeline `echo *sv`
vvp simulation_riscv
gtkwave riscv_load_dump.vcd
