	.global _start
	.option norelax

_start:
	lw x1, 0(x0)
	lw x2, 4(x0)
	addi x7, x0, 4
	lw x3, 8(x7)

