`include "riscv_structures.sv"

module cu (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output alu_op_e     alu_op,
    output logic        mem_write,
    output logic        mem_read,
    output logic        reg_write,
    output logic        use_imm,
    output logic        is_branch,
    output logic        is_jump,
    output logic        is_jalr,
    output logic        is_final,
    output instr_type_e instr_type
);

  assign instr_type = (opcode == 7'b0110011) ? R_TYPE :
      (opcode == 7'b0010011) ? I_TYPE :  // Immediate arithmetic/logic
      (opcode == 7'b0000011) ? I_TYPE :  // Load
      (opcode == 7'b1100111) ? I_TYPE :  // JALR
      (opcode == 7'b1110011) ? I_TYPE :  // ecall
      (opcode == 7'b0100011) ? S_TYPE :  // SW
      (opcode == 7'b1100011) ? B_TYPE :  // branches
      (opcode == 7'b1101111) ? J_TYPE :  // JAL
      INVALID_TYPE;

  assign mem_read = (opcode == 7'b0000011) ? 1'b1 : 1'b0;  // LW

  assign reg_write = (instr_type == R_TYPE) ? 1'b1 :
      (instr_type == I_TYPE) ? 1'b1 :
      (instr_type == J_TYPE) ? 1'b1 :
      1'b0;

  assign mem_write = (opcode == 7'b0100011) ? 1'b1 : 1'b0;  // only SW writes to memory

  assign alu_op = (instr_type == S_TYPE) ? ALU_ADD :  // stores
      (instr_type == J_TYPE) ? ALU_ADD :  // JAL pc+4
      (opcode == 7'b1100111) ? ALU_ADD :  // JALR pc+4
      (instr_type == B_TYPE) ? ALU_INVALID :  // branches
      (opcode == 7'b0110011 && funct3 == 0 && funct7 == 7'b0100000) ? ALU_SUB :  // SUB
      (opcode == 7'b0110011 && funct3 == 0 && funct7 == 7'b0000000) ? ALU_ADD :  // ADD
      (opcode == 7'b0010011 && funct3 == 0) ? ALU_ADD :  // ADDI
      (opcode == 7'b0000011) ? ALU_ADD :  // LW (calculate address)
      ALU_INVALID;  // For any other instruction

  assign use_imm = (instr_type == I_TYPE) ? 1'b1 :
      (instr_type == J_TYPE) ? 1'b1 :
      (instr_type == B_TYPE) ? 1'b0 : // it's added in summator, alu uses rses
      (instr_type == S_TYPE) ? 1'b1 : 1'b0;

  assign is_branch = (instr_type == B_TYPE) ? 1'b1 : 1'b0;
  assign is_jump = (instr_type == J_TYPE) ? 1'b1 : (opcode == 7'b1100111) ? 1'b1 : 1'b0;  // JAL(R)
  assign is_jalr = (opcode == 7'b1100111) ? 1'b1 : 1'b0;
  assign is_final = (opcode == 7'b1110011);  // ecall

endmodule
