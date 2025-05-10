	.global _start
	.option norelax

_start:
	lw x1, 136(x0)
	lw x1, 36(x1) ;#// x1=[[136]+36]=[160]=92
	lw x1, 92(x1) ;#// x1=[92+92]=[184]=0xCEC0CEC0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

