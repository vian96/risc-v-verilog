	.global _start
	.option norelax

_start:
nop
# store 123 into address 120 (0x78), then load back
addi x10, x0, 0
addi x11, x0, 123
sw   x11, 420(x10)
lw   x10, 420(x0)
# Expected: x10==123

# Test JAL: call a func and check return address
addi x13, x0, 1      # to be modified by func
jal  x1, targetjal   # instr #5
# x1 will be set to 5*4+4=24

addi x20, x0, 1000   # verify correct return

# Test JALR
addi x15, x0, 144    # targetjalr
jalr x12, 0(x15)     # instr #8
# x12 should be 8*4+4=36

addi x30, x0, 15     # This instruction should NOT reached

# NOPs padding
NOP
NOP
NOP
NOP
NOP
# instr # 14

targetjal:
addi x13, x13, 100
jalr x0, 0(x1)

# 17 NOPs for padding
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP

addi x29, x0, 33 # should NOT be executed

# here should be 144

targetjalr:
addi x28, x0, 17
ecall


