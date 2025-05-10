`include "riscv_structures.sv"

module imm (
    input instr_type_e instr_type,
    input logic [31:7] instruction,
    output logic [31:0] sext_imm
);

  logic [11:0] imm_i;
  logic [11:0] imm_s;
  logic [12:0] imm_b;
  logic [20:0] imm_j;

  assign imm_i = instruction[31:20];
  assign imm_s = {instruction[31:25], instruction[11:7]};
  assign imm_b = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
  assign imm_j = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};


  assign sext_imm = (instr_type == I_TYPE) ? {{20{imm_i[11]}}, imm_i} :
      (instr_type == S_TYPE) ? {{20{imm_s[11]}}, imm_s} :
      (instr_type == I_TYPE) ? {{20{imm_i[11]}}, imm_i} :
      (instr_type == B_TYPE) ? {{19{imm_b[12]}}, imm_b} :
      (instr_type == J_TYPE) ? {{11{imm_j[20]}}, imm_j} :
      32'b0;

endmodule
