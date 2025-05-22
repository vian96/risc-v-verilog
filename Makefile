VERILATOR = verilator
VERILATOR_FLAGS = -Wall --cc --exe --build --timing
SRC_FILES = riscv_structures.sv alu.sv cu.sv decode.sv execute.sv fetch.sv hu.sv imm.sv instr_mem.sv memory.sv reg_file.sv riscv_pipeline.sv simple_memory.sv writeback.sv
TOP_MODULE = riscv_pipeline
CPP_FILE = sim_main_alternative.cpp

all: sim

sim:
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module $(TOP_MODULE) $(SRC_FILES) $(CPP_FILE)

run:
	obj_dir/Vriscv_pipeline

clean:
	rm -rf obj_dir

.PHONY: all sim clean
