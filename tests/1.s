	.global _start
	.option norelax

_start:
	nop
	lw x1, 300(x0)
	lw x2, 304(x0)
	addi x7, x0, 4
	lw x3, 308(x7)
	ecall

