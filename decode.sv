`include "riscv_structures.sv"

module decode (
    input  logic             clk,
    input  fe_to_de_s        fe_to_de,
    input  logic      [ 4:0] writeback_address,
    input  logic      [31:0] write_back_data,
    input  logic             write_back_enable,
    input  logic             pc_r,
    output de_to_ex_s        de_to_ex,
    input  logic             dump,
    input  logic             reset,
    input  logic             en
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
      .clk (clk),
      .a1  (rs1),
      .a2  (rs2),
      .a3  (writeback_address),
      .wd  (write_back_data),
      .we3 (write_back_enable),
      // outp
      .d1  (rs1_val),
      .d2  (rs2_val),
      .dump(dump)
  );

  // will be output
  logic        [31:0] sext_imm;
  alu_op_e            next_alu_op;
  logic               next_mem_write;
  logic               next_mem_read;
  logic               next_reg_write;
  logic               use_imm;
  logic               use_pc;
  logic               is_jump;

  //// CONTROL UNIT
  // TODO: move to separate module

  instr_type_e        instr_type;

  assign instr_type = (opcode == 7'b0110011) ? R_TYPE :  // R-type
      (opcode == 7'b0010011) ? I_TYPE :  // I-type (Immediate arithmetic/logic)
      (opcode == 7'b0000011) ? I_TYPE :  // I-type (Load)
      (opcode == 7'b1100111) ? I_TYPE :  // I-type (JALR)
      (opcode == 7'b0100011) ? S_TYPE :
      (opcode == 7'b1100011) ? B_TYPE :
      (opcode == 7'b0110111) ? U_TYPE :  // U-type (LUI tho not implemented)
      (opcode == 7'b0010111) ? U_TYPE :  // U-type (AUIPC tho not implemented)
      (opcode == 7'b1101111) ? J_TYPE :  // J-type (JAL)
      (opcode == 7'b1110011) ? I_TYPE :  // I-type (ECALL, EBREAK, CSR)
      INVALID_TYPE;  // Default to invalid for any other opcode

  assign next_mem_read = (opcode == 7'b0000011) ? 1'b1 :  // LD (I-type)
      1'b0;  // Other instructions do not read memory

  assign next_reg_write = (instr_type == R_TYPE) ? 1'b1 :
      (instr_type == I_TYPE) ? 1'b1 :
      (instr_type == U_TYPE) ? 1'b1 :
      (instr_type == J_TYPE) ? 1'b1 :
      1'b0;

  assign next_mem_write = (opcode == 7'b0100011) ? 1'b1 :  // SD (S-type)
      1'b0;  // Other instructions do not write memory

  assign next_alu_op = (instr_type == S_TYPE) ? ALU_ADD :  // stores
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
      (instr_type == U_TYPE) ? 1'b1 : // TODO: not sure
      1'b0;

  assign use_pc = (instr_type == B_TYPE) ? 1'b1 : (instr_type == J_TYPE) ? 1'b1 : 1'b0;
  assign is_jump = (instr_type == J_TYPE) ? 1'b1 : (opcode == 7'b1100111) ? 1'b1 : 1'b0;

  imm imm_inst (
      .instr_type(instr_type),
      .instruction(instruction[31:7]),
      .sext_imm(sext_imm)
  );

  always_ff @(posedge clk or posedge reset) begin
    $display("Time %0t: decode -> v_de %d, pc_r %d, fe.pc_r %d, en %d", $time, de_to_ex_reg.v_de,
             pc_r, fe_to_de.pc_r, en);

    if (reset) begin
      de_to_ex_reg.mem_read <= 0;  // for backward loop at start
      de_to_ex_reg.v_de     <= 0;
    end else if (en) begin
      de_to_ex_reg.pc_value              <= fe_to_de.pc_value;
      de_to_ex_reg.rs1_data              <= rs1_val;
      de_to_ex_reg.rs2_data              <= rs2_val;
      de_to_ex_reg.rd                    <= rd;
      de_to_ex_reg.rs1                   <= rs1;
      de_to_ex_reg.rs2                   <= rs2;
      de_to_ex_reg.funct3                <= funct3;

      de_to_ex_reg.immediate_sext        <= sext_imm;
      de_to_ex_reg.instruction_bits_30_7 <= instruction[30:7];

      de_to_ex_reg.alu_op                <= next_alu_op;
      de_to_ex_reg.mem_write             <= next_mem_write;
      de_to_ex_reg.reg_write             <= next_reg_write;
      de_to_ex_reg.mem_read              <= next_mem_read;
      de_to_ex_reg.use_imm               <= use_imm;
      de_to_ex_reg.use_pc                <= use_pc;
      de_to_ex_reg.is_jump               <= is_jump;

      de_to_ex_reg.v_de                  <= !(pc_r || fe_to_de.pc_r);
    end
  end

endmodule

