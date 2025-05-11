set -euo

n=$1

mkdir -p build
riscv64-unknown-elf-gcc -nostdlib -march=rv32i -mabi=ilp32 tests/$n.s -o build/instr.o
riscv64-unknown-elf-objcopy -O binary build/instr.o build/instr.bin
py bin_to_hex.py build/instr.bin build/instr.hex

bash comrun.sh | rg 'reg\[' | rg '(\[[0-9a-f]+\]|0x[0-9a-f]+])' | rg '= (0x0*[1-9a-f][0-9a-f]*)?'
cat tests/$n.txt
