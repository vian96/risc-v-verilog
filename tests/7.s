	.global _start
	.option norelax

_start:
	nop
	addi x1, x0, 1234
	sb x1, 100(x0)
	lb x4, 103(x0)
	addi x2, x0, 1234
	slli x3, x2, 5

	
