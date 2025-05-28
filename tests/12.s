	.global _start
	.option norelax

_start:
	nop
	lw x1, 428(x0)
	addi x1, x1, 10
	ecall

