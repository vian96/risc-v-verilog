	.global _start
	.option norelax

_start:
	nop
	lw x1, 428(x0)
	add x2, x1, x0
	ecall


