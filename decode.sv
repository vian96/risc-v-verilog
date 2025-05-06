`include "riscv_structures.sv"

module decode (
    input  logic             clk,
    input  fe_to_de_s        fe_to_de,
    input  logic      [ 4:0] writeback_address,
    input  logic      [31:0] write_back_data,
    input  logic             write_back_enable,
    output de_to_ex_s        de_to_ex
);

  de_to_ex_s de_to_ex_reg;
  assign de_to_ex = de_to_ex_reg;

  logic [31:0] instruction;
  logic [ 6:0] opcode;
  logic [ 4:0] rd;
  logic [ 2:0] funct3;
  logic [ 4:0] rs1;
  logic [ 4:0] rs2;
  logic [ 6:0] funct7;

  logic [31:0] rs1_val;
  logic [31:0] rs2_val;

  assign instruction = fe_to_de.instruction_value;
  assign opcode      = instruction[6:0];
  assign rd          = instruction[11:7];
  assign funct3      = instruction[14:12];
  assign rs1         = instruction[19:15];
  assign rs2         = instruction[24:20];
  assign funct7      = instruction[31:25];

  reg_file rf (
      // inp
      .clk(clk),
      .a1 (rs1),
      .a2 (rs2),
      .a3 (writeback_address),
      .wd (write_back_data),
      .we3(write_back_enable),
      // outp
      .d1 (rs1_val),
      .d2 (rs2_val)
  );

  // will be output
  logic    [31:0] next_immediate_sext;
  alu_op_e        next_alu_op;
  logic           next_mem_write;
  logic           next_reg_write;

  //// CONTROL UNIT

  assign next_mem_read = (opcode == 7'b0000011) ? 1'b1 :  // LD (I-type)
      1'b0;  // Other instructions do not read memory

  assign next_reg_write = (opcode == 7'b0110011) ? 1'b1 :  // ADD (R-type)
      (opcode == 7'b0000011) ? 1'b1 :  // LD (I-type)
      (opcode == 7'b1100111) ? 1'b1 :  // JALR (I-type)
      (opcode == 7'b1101111) ? 1'b1 :  // JAL (J-type)
      1'b0;  // SD, BEQ do not write to register

  assign next_mem_write = (opcode == 7'b0100011) ? 1'b1 :  // SD (S-type)
      1'b0;  // Other instructions do not write memory

  assign next_alu_op = (
          opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000
      ) ? ALU_ADD : // ADD
      (opcode == 7'b0000011) ? ALU_ADD :  // LD (calculate address)
      (opcode == 7'b0100011) ? ALU_ADD :  // SD (calculate address)
      (opcode == 7'b1100111) ? ALU_ADD :  // JALR (calculate target address)
      (opcode == 7'b1101111) ? ALU_ADD :  // JAL (calculate target address)
      (opcode == 7'b1100011 && funct3 == 3'b000) ? ALU_EQ :  // BEQ
      ALU_INVALID;  // For any other instruction

  //// IMMEDIATE UNIT

  // Calculate and sign-extend immediate value based on instruction type
  logic [11:0] imm_i;  // For I-type (LD, JALR)
  logic [11:0] imm_s;  // For S-type (SD)
  logic [12:0] imm_b;  // For B-type (BEQ)
  logic [20:0] imm_j;  // For J-type (JAL)

  // Extract raw immediate bits
  assign imm_i = instruction[31:20];
  assign imm_s = {instruction[31:25], instruction[11:7]};
  assign imm_b = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
  assign imm_j = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};


  // Sign-extend the correct immediate based on opcode
  assign next_immediate_sext = (opcode == 7'b0000011) ? {{20{imm_i[11]}}, imm_i} :  // LD (I-type)
      (opcode == 7'b0100011) ? {{20{imm_s[11]}}, imm_s} :  // SD (S-type)
      (opcode == 7'b1100111) ? {{20{imm_i[11]}}, imm_i} :  // JALR (I-type)
      (opcode == 7'b1100011) ? {{19{imm_b[12]}}, imm_b} :  // BEQ (B-type)
      (opcode == 7'b1101111) ? {{11{imm_j[20]}}, imm_j} :  // JAL (J-type)
      32'b0;  // Default to 0 for instructions with no immediate (ADD) or unsupported types

  always_ff @(posedge clk) begin
    de_to_ex_reg.pc_value              <= fe_to_de.pc_value;
    de_to_ex_reg.rs1_data              <= rs1_val;
    de_to_ex_reg.rs2_data              <= rs2_val;
    de_to_ex_reg.rd                    <= rd;
    de_to_ex_reg.opcode                <= opcode;
    de_to_ex_reg.funct3                <= funct3;

    de_to_ex_reg.immediate_sext        <= next_immediate_sext;
    de_to_ex_reg.instruction_bits_30_7 <= instruction[30:7];

    de_to_ex_reg.alu_op                <= next_alu_op;
    de_to_ex_reg.mem_write             <= next_mem_write;
    de_to_ex_reg.reg_write             <= next_reg_write;
    de_to_ex_reg.mem_read              <= next_mem_read;
  end

endmodule

