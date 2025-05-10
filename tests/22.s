	.global _start
	.option norelax

_start:
lw   x1, 80(x0)
lw   x2, 84(x0)

addi x7, x0, 76
lw   x3, 12(x7)   # Load word into x3 from address 12 + x7 (76) = 88

  # Added instructions for branching tests (starts at address 16 / mem[4])
addi x4, x0, 5
addi x5, x0, 10

  # Test BEQ
  # If x1 == x2, branch
beq  x1, x2, targetbeq

  # This instruction is executed if the BEQ branch is NOT taken (at address 28 / mem[7])
addi x6, x0, 1    # Set x6 to 1

  # Test BLT
  # If x4 < x5, branch
blt  x4, x5, targetblt

  # This instruction is executed if the BLT branch is NOT taken (at address 36 / mem[9])
addi x8, x0, 2    # Set x8 to 2

  # Common path after branches (at address 40 / mem[10])
addi x9, x0, 99   # Set x9 to 99

targetbeq:  
addi x6, x0, 100  # Set x6 to 100 if BEQ taken

targetblt:
addi x8, x0, 200  # Set x8 to 200 if BLT taken

  # Jump to termination sequence (at address 52 / mem[13])
  # Offset 8 bytes to reach address 60 (mem[15])
jal  x0, +8

  # Fill space (at address 56 / mem[14]) - NOP
addi x0, x0, 0

  # Termination sequence (at address 60 / mem[15]) - NOP
addi x0, x0, 0

