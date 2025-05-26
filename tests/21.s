	.global _start
	.option norelax

_start:
# for beq
lw   x1, 380(x0)
lw   x2, 380(x0)

addi x7, x0, 76
lw   x3, 312(x7)   # Load from 12 + x7 (76) = 88

# for blt
addi x4, x0, 5
addi x5, x0, 10

beq  x1, x2, targetbeq

# executed if BEQ is NOT taken (it should be taken)
addi x6, x0, 1

blt  x4, x5, targetblt

# executed if BLT is NOT taken (shouldn't get here)
addi x8, x0, 2
addi x9, x0, 99

targetbeq:
addi x6, x0, 100

targetblt:
addi x8, x0, 200

ecall

