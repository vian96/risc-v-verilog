	.global _start
	.option norelax

_start:
	lw x1, 436(x0)
	lw x1, 336(x1) ;#// x1=[[136]+36]=[160]=92
	lw x1, 392(x1) ;#// x1=[92+92]=[184]=0xCEC0CEC0
	ecall

