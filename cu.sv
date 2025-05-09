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
    output logic        use_pc,
    output logic        is_jump,
    output instr_type_e instr_type
);

  assign instr_type = (opcode == 7'b0110011) ? R_TYPE :
      (opcode == 7'b0010011) ? I_TYPE :  // I-type (Immediate arithmetic/logic)
      (opcode == 7'b0000011) ? I_TYPE :  // I-type (Load)
      (opcode == 7'b1100111) ? I_TYPE :  // I-type (JALR)
      (opcode == 7'b0100011) ? S_TYPE :
      (opcode == 7'b1100011) ? B_TYPE :
      (opcode == 7'b1101111) ? J_TYPE :  // J-type (JAL)
      (opcode == 7'b1110011) ? I_TYPE :  // I-type (ECALL, EBREAK, CSR)
      INVALID_TYPE;

  assign mem_read = (opcode == 7'b0000011) ? 1'b1 :  // LD
      1'b0;

  assign reg_write = (instr_type == R_TYPE) ? 1'b1 :
      (instr_type == I_TYPE) ? 1'b1 :
      (instr_type == U_TYPE) ? 1'b1 :
      (instr_type == J_TYPE) ? 1'b1 :
      1'b0;

  assign mem_write = (opcode == 7'b0100011) ? 1'b1 :  // SD
      1'b0;  // Other instructions do not write memory

  assign alu_op = (instr_type == S_TYPE) ? ALU_ADD :  // stores
      (instr_type == J_TYPE) ? ALU_ADD :  // JAL
      (instr_type == B_TYPE) ? ALU_ADD :  // branches
      (opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000) ? ALU_ADD :  // ADD
      (opcode == 7'b0010011 && funct3 == 3'b000) ? ALU_ADD :  // ADDI
      (opcode == 7'b0110011 && funct3 == 0 && funct7 == 7'b0100000) ? ALU_SUB :  // SUB
      (opcode == 7'b0000011) ? ALU_ADD :  // LD (calculate address)
      (opcode == 7'b1100111) ? ALU_ADD :  // JALR (calculate target address)
      ALU_INVALID;  // For any other instruction

  assign use_imm = (instr_type == I_TYPE) ? 1'b1 :
      (instr_type == J_TYPE) ? 1'b1 :
      (instr_type == B_TYPE) ? 1'b1 :
      (instr_type == S_TYPE) ? 1'b1 :
      1'b0;

  assign use_pc = (instr_type == B_TYPE) ? 1'b1 : (instr_type == J_TYPE) ? 1'b1 : 1'b0;
  assign is_jump = (instr_type == J_TYPE) ? 1'b1 : (opcode == 7'b1100111) ? 1'b1 : 1'b0;  // JAL(R)

endmodule
