	.global _start
	.option norelax

_start:
	# We will store the value 123 into memory address 120 (0x78), then load it back to verify.
	addi x10, x0, 0
	addi x11, x0, 123
	sw   x11, 120(x10)  # Store x11 (123) to mem[x10 + 120] (Address 120, mem[30])
	lw   x10, 120(x0)   # Load value from address 120 into x10.
				# Expected: x10 should be 123 after this instruction.
														   
	# Test JAL (Jump and Link for function call)
	# We will call a subroutine and ensure the return address is correctly saved.
	addi x13, x0, 1      # x13 = 1 (Initial value for subroutine to modify)
	jal  x1, targetjal          # Call subroutine (offset 40 bytes from current PC).
			       # PC will jump to (0x14 + 40) = 0x3C (Address 60, mem[15]).
			       # x1 (ra) will be set to (0x14 + 4) = 0x18 (Address 24, mem[6]).
														   
	# This instruction is executed upon return from the subroutine (at address 0x18 / mem[6])
	addi x20, x0, 1000   # x20 = 1000. Verification point for successful return.
														   
	# Test JALR (Indirect Jump)
	# Jumps to a specific termination address without linking (using x0 as rd).
	addi x15, x0, 140    # x15 = 140 (Target address for JALR indirect jump)
	jalr x0, 0(x15)      # Jump to 0 + x15 (140). Link register is x0 (discarded).
			       # PC will jump to (x15 + 0) = 140 (Address 0x8C, mem[35]).
														   
	# This instruction should NOT be reached if the JALR works (at address 0x24 / mem[9])
	addi x30, x0, 15     # This instruction should be skipped.
														   
	# --- Subroutine Section ---
	# NOPs for padding before the subroutine starts (Addresses 0x28 to 0x38).
	NOP
	NOP
	NOP
	NOP
	NOP
														   
targetjal:
	# Subroutine Starts Here (at address 0x3C / mem[15]) - Target of JAL at mem[5]
	addi x13, x13, 100   # x13 = x13 + 100. Expected: x13 becomes 101.
	jalr x0, 0(x1)       # Return using address in x1 (which is 0x18).
				 # PC will jump back to 0x18 (mem[6]).
														   
	# --- Termination Section ---
	# NOPs to fill space before the JALR indirect jump target and data.
	# (Addresses 0x44 to 0x88 / mem[17] to mem[34])
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
														   
	# NOPs after data, before the JALR termination target.
	NOP
	NOP
	NOP
	NOP

targetjalr:
	# Termination point for JALR indirect jump (at address 140 / 0x8C / mem[35])
	NOP # (Program execution should end here)
	NOP # (Further NOPs)


