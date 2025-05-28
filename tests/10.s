	.global _start
	.option norelax

_start:
	nop
	lw x1, 428(x0)
	lw x1, 428(x0)
	ecall

