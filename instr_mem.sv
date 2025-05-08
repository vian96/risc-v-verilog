`include "riscv_structures.sv"

module instr_mem (
    input  logic        clk,
    input  logic [31:0] address,
    output logic [31:0] read_data
);

  // 256 words of 32 bits each
  reg [31:0] mem[255];

  // TEST 1: lw, addi, HU
  //initial begin
  //  mem[0] = 32'b000000000000_00000_010_00001_0000011;  // lw x1, 0(x0)
  //  mem[1] = 32'b000000000100_00000_010_00010_0000011;  // lw x2, 4(x0)
  //  mem[2] = 32'h00400393;  // addi x7, x0, 4
  //  mem[3] = 32'h0083a183;  // lw x3, 8(x7)
  //end

  // TEST 2: BLT, BEQ, TEST 1
  // Initial instructions
  initial begin
    mem[0] = 32'h05002083;  // lw   x1, 80(x0)
    mem[1] = 32'h05402103;  // lw   x2, 84(x0)
    mem[2] = 32'h04C00393;  // addi x7, x0, 76
    mem[3] = 32'h00c3a183;  // lw   x3, 12(x7)   // Load word into x3 from address 12 + x7 (76) = 88

    // Added instructions for branching tests (starts at address 16 / mem[4])
    // TESTS 2.1, 2.2
    //mem[4] = 32'h00500213;  // addi x4, x0, 5
    //mem[5] = 32'h00a00293;  // addi x5, x0, 10
    // TEST 2.3
    mem[4] = 32'h00a00213;  // addi x4, x0, 10
    mem[5] = 32'h00500293;  // addi x5, x0, 5

    // Test BEQ
    // If x1 == x2, branch to address 24 + 20 = 44 (mem[11])
    mem[6] = 32'h00208a63;  // beq  x1, x2, +20

    // This instruction is executed if the BEQ branch is NOT taken (at address 28 / mem[7])
    mem[7] = 32'h00100313;  // addi x6, x0, 1    // Set x6 to 1

    // Test BLT
    // If x4 < x5, branch to address 32 + 16 = 48 (mem[12])
    mem[8] = 32'h00524863;  // blt  x4, x5, +16

    // This instruction is executed if the BLT branch is NOT taken (at address 36 / mem[9])
    mem[9] = 32'h00200413;  // addi x8, x0, 2    // Set x8 to 2

    // Common path after branches (at address 40 / mem[10])
    mem[10] = 32'h06300493;  // addi x9, x0, 99   // Set x9 to 99

    // Target for BEQ branch (at address 44 / mem[11])
    mem[11] = 32'h06400313;  // addi x6, x0, 100  // Set x6 to 100 if BEQ taken

    // Target for BLT branch (at address 48 / mem[12])
    mem[12] = 32'h0c800413;  // addi x8, x0, 200  // Set x8 to 200 if BLT taken

    // Jump to termination sequence (at address 52 / mem[13])
    // Offset 8 bytes to reach address 60 (mem[15])
    mem[13] = 32'h008000EF;  // jal  x0, +8

    // Fill space (at address 56 / mem[14]) - NOP
    mem[14] = 32'h00000013;  // addi x0, x0, 0

    // Termination sequence (at address 60 / mem[15]) - NOP
    mem[15] = 32'h00000013;  // addi x0, x0, 0

    // Fill space with NOPs up to data section
    mem[16] = 32'h00000013;  // NOP
    mem[17] = 32'h00000013;  // NOP
    mem[18] = 32'h00000013;  // NOP
    mem[19] = 32'h00000013;  // NOP
  end

  always @(posedge clk) begin
    $display("Time %0t: \033[33m Instr Memory Input \033[0m -> Address = 0x%h, val = 0x%h", $time,
             address, read_data);
  end

  assign read_data = mem[address[31:2]];

endmodule

