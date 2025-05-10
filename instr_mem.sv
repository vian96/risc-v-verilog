`include "riscv_structures.sv"

module instr_mem (
    input  logic        clk,
    input  logic [31:0] address,
    output logic [31:0] read_data
);

  // 256 words of 32 bits each
  reg [31:0] mem[255];

  //initial begin
  //  // This path should be passed to the module or testbench
  //  $readmemh("build/instr.hex", mem);
  //  $display("--- Displaying mem at %0t ---", $time);
  //  for (int i = 0; i < 32; i = i + 1) begin
  //    $display("mem[%0d] = 0x%h", i, mem[i]);
  //  end
  //  $display("----------------------------------------------------");
  //end


  initial begin
    $display("TEST 3: JAL, JALR, SW + test1,2");
    $display("Expected: x10==123, x13==101, x20==1000, x30!=15 (usually 0)");

    // We will store the value 123 into memory address 120 (0x78), then load it back to verify.
    mem[0] = 32'h00000513;  // addi x10, x0, 0
    mem[1] = 32'h07B00593;  // addi x11, x0, 123
    mem[2] = 32'h06b52c23;  // sw   x11, 120(x10)  // Store x11 (123) to mem[x10 + 120] (Address 120, mem[30])
    mem[3] = 32'h07802503;  // lw   x10, 120(x0)   // Load value from address 120 into x10.
                            // Expected: x10 should be 123 after this instruction.

    // Test JAL (Jump and Link for function call)
    // We will call a subroutine and ensure the return address is correctly saved.
    mem[4] = 32'h00100693; // addi x13, x0, 1      // x13 = 1 (Initial value for subroutine to modify)
    mem[5] = 32'h028000ef; // jal  x1, 40          // Call subroutine (offset 40 bytes from current PC).
                           // PC will jump to (0x14 + 40) = 0x3C (Address 60, mem[15]).
                           // x1 (ra) will be set to (0x14 + 4) = 0x18 (Address 24, mem[6]).

    // This instruction is executed upon return from the subroutine (at address 0x18 / mem[6])
    mem[6] = 32'h3e800a13; // addi x20, x0, 1000   // x20 = 1000. Verification point for successful return.

    // Test JALR (Indirect Jump)
    // Jumps to a specific termination address without linking (using x0 as rd).
    mem[7] = 32'h08c00793; // addi x15, x0, 140    // x15 = 140 (Target address for JALR indirect jump)
    mem[8] = 32'h00078067; // jalr x0, 0(x15)      // Jump to 0 + x15 (140). Link register is x0 (discarded).
                           // PC will jump to (x15 + 0) = 140 (Address 0x8C, mem[35]).

    // This instruction should NOT be reached if the JALR works (at address 0x24 / mem[9])
    mem[9] = 32'h00f00f13;  // addi x30, x0, 15     // This instruction should be skipped.

    // --- Subroutine Section ---
    // NOPs for padding before the subroutine starts (Addresses 0x28 to 0x38).
    mem[10] = 32'h00000013;  // NOP
    mem[11] = 32'h00000013;  // NOP
    mem[12] = 32'h00000013;  // NOP
    mem[13] = 32'h00000013;  // NOP
    mem[14] = 32'h00000013;  // NOP

    // Subroutine Starts Here (at address 0x3C / mem[15]) - Target of JAL at mem[5]
    mem[15] = 32'h06468693;  // addi x13, x13, 100   // x13 = x13 + 100. Expected: x13 becomes 101.
    mem[16] = 32'h00008067;  // jalr x0, 0(x1)       // Return using address in x1 (which is 0x18).
                             // PC will jump back to 0x18 (mem[6]).

    // --- Termination Section ---
    // NOPs to fill space before the JALR indirect jump target and data.
    // (Addresses 0x44 to 0x88 / mem[17] to mem[34])
    mem[17] = 32'h00000013;  // NOP
    mem[18] = 32'h00000013;  // NOP
    mem[19] = 32'h00000013;  // NOP
    mem[20] = 32'h00000013;  // NOP
    mem[21] = 32'h00000013;  // NOP
    mem[22] = 32'h00000013;  // NOP
    mem[23] = 32'h00000013;  // NOP
    mem[24] = 32'h00000013;  // NOP
    mem[25] = 32'h00000013;  // NOP
    mem[26] = 32'h00000013;  // NOP
    mem[27] = 32'h00000013;  // NOP
    mem[28] = 32'h00000013;  // NOP
    mem[29] = 32'h00000013;  // NOP

    // NOPs after data, before the JALR termination target.
    mem[31] = 32'h00000013;  // NOP
    mem[32] = 32'h00000013;  // NOP
    mem[33] = 32'h00000013;  // NOP
    mem[34] = 32'h00000013;  // NOP

    // Termination point for JALR indirect jump (at address 140 / 0x8C / mem[35])
    mem[35] = 32'h00000013;  // NOP (Program execution should end here)
    mem[36] = 32'h00000013;  // NOP (Further NOPs)
  end


  // TEST 1: lw, addi, HU forwarding
  // x1=[0]=DEADBEEF, x2=[4]=12345678, x7=4, x3=mem[12]=FEDCBA98
  //initial begin
  //  mem[0] = 32'b000000000000_00000_010_00001_0000011;  // lw x1, 0(x0)
  //  mem[1] = 32'b000000000100_00000_010_00010_0000011;  // lw x2, 4(x0)
  //  mem[2] = 32'h00400393;  // addi x7, x0, 4
  //  mem[3] = 32'h0083a183;  // lw x3, 8(x7)
  //end

  //initial begin
  //  $display("TEST 2: BLT, BEQ, TEST 1");
  //  $display("Exptected: x1=5, x2=5, x3=20, x4=5, x5=10, x6=100, x7=76, x8=200, x9=0");
  //  $display("Exptected: 2.2: x2=10,                     x6=  1");
  //  $display("Exptected: 2.3: x2=10,       x4=10, x5= 5, x6=100,                x9=99");
  //  mem[0] = 32'h05002083;  // lw   x1, 80(x0)
  //  mem[1] = 32'h05402103;  // lw   x2, 84(x0)
  //  mem[2] = 32'h04C00393;  // addi x7, x0, 76
  //  mem[3] = 32'h00c3a183;  // lw   x3, 12(x7)   // Load word into x3 from address 12 + x7 (76) = 88

  //  // Added instructions for branching tests (starts at address 16 / mem[4])
  //  // TESTS 2.1, 2.2
  //  //mem[4] = 32'h00500213;  // addi x4, x0, 5
  //  //mem[5] = 32'h00a00293;  // addi x5, x0, 10
  //  // TEST 2.3
  //  mem[4] = 32'h00a00213;  // addi x4, x0, 10
  //  mem[5] = 32'h00500293;  // addi x5, x0, 5

  //  // Test BEQ
  //  // If x1 == x2, branch to address 24 + 20 = 44 (mem[11])
  //  mem[6] = 32'h00208a63;  // beq  x1, x2, +20

  //  // This instruction is executed if the BEQ branch is NOT taken (at address 28 / mem[7])
  //  mem[7] = 32'h00100313;  // addi x6, x0, 1    // Set x6 to 1

  //  // Test BLT
  //  // If x4 < x5, branch to address 32 + 16 = 48 (mem[12])
  //  mem[8] = 32'h00524863;  // blt  x4, x5, +16

  //  // This instruction is executed if the BLT branch is NOT taken (at address 36 / mem[9])
  //  mem[9] = 32'h00200413;  // addi x8, x0, 2    // Set x8 to 2

  //  // Common path after branches (at address 40 / mem[10])
  //  mem[10] = 32'h06300493;  // addi x9, x0, 99   // Set x9 to 99

  //  // Target for BEQ branch (at address 44 / mem[11])
  //  mem[11] = 32'h06400313;  // addi x6, x0, 100  // Set x6 to 100 if BEQ taken

  //  // Target for BLT branch (at address 48 / mem[12])
  //  mem[12] = 32'h0c800413;  // addi x8, x0, 200  // Set x8 to 200 if BLT taken

  //  // Jump to termination sequence (at address 52 / mem[13])
  //  // Offset 8 bytes to reach address 60 (mem[15])
  //  mem[13] = 32'h008000EF;  // jal  x0, +8

  //  // Fill space (at address 56 / mem[14]) - NOP
  //  mem[14] = 32'h00000013;  // addi x0, x0, 0

  //  // Termination sequence (at address 60 / mem[15]) - NOP
  //  mem[15] = 32'h00000013;  // addi x0, x0, 0

  //  // Fill space with NOPs up to data section
  //  mem[16] = 32'h00000013;  // NOP
  //  mem[17] = 32'h00000013;  // NOP
  //  mem[18] = 32'h00000013;  // NOP
  //  mem[19] = 32'h00000013;  // NOP
  //end

  always @(posedge clk) begin
    $display("Time %0t: \033[33m Instr Memory Input \033[0m -> Address = 0x%h, val = 0x%h", $time,
             address, read_data);
  end

  // verilator lint_off WIDTH
  assign read_data = mem[address[31:2]];
  // verilator lint_on WIDTH

endmodule

