set -euo
iverilog -o simulation_riscv -g2012 -s riscv_pipeline alu.sv decode.sv execute.sv fetch.sv instr_mem.sv memory.sv reg_file.sv riscv_pipeline.sv simple_memory.sv writeback.sv
vvp simulation_riscv
gtkwave riscv_load_dump.vcd
