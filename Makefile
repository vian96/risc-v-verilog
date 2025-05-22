VERILATOR = verilator
VERILATOR_FLAGS = -Wall --cc --exe --build --timing
SRC_FILES = riscv_structures.sv alu.sv cu.sv decode.sv execute.sv fetch.sv hu.sv imm.sv instr_mem.sv memory.sv reg_file.sv riscv_pipeline.sv simple_memory.sv writeback.sv
TOP_MODULE = riscv_pipeline
CPP_FILE = sim_main_alternative.cpp

TEST_NUMBER ?= 1

all: sim

sim:
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module $(TOP_MODULE) $(SRC_FILES) $(CPP_FILE)

run:
	obj_dir/Vriscv_pipeline

clean:
	rm -rf obj_dir

test_build:
	@echo "building test number: $(TEST_NUMBER)"
	riscv64-unknown-elf-gcc -nostdlib -march=rv32i -mabi=ilp32 tests/$(TEST_NUMBER).s -o build/instr.o
	riscv64-unknown-elf-objcopy -O binary build/instr.o build/instr.bin
	py bin_to_hex.py build/instr.bin build/instr.hex

test: sim test_build
	obj_dir/Vriscv_pipeline | rg 'reg\[' | rg '= (0x0*[1-9a-f][0-9a-f]*)?'
	@echo "test number $(TEST_NUMBER) was run"
	cat tests/$(TEST_NUMBER).txt


.PHONY: all sim clean
