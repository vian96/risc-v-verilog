	.global _start
	.option norelax

_start:
	nop
	addi x1, x0, 1
	addi x2, x0, 2
	blt x1, x2, target
	addi x3, x0, 3  # should NOT run
target:
	addi x4, x0, 4
	sub x5, x3, x1
	ecall

