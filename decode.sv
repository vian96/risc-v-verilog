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
      .clk(clk),
      .a1 (rs1),
      .a2 (rs2),
      .a3 (writeback_address),
      .wd (write_back_data),
      .we3(write_back_enable),

      .d1  (rs1_val),
      .d2  (rs2_val),
      .dump(dump)
  );

  logic        [31:0] sext_imm;

  // will be output
  alu_op_e            alu_op;
  logic               mem_write;
  logic               mem_read;
  logic               reg_write;
  logic               use_imm;
  logic               use_pc;
  logic               is_jump;
  instr_type_e        instr_type;

  cu cu_inst (
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),

      .alu_op    (alu_op),
      .mem_write (mem_write),
      .mem_read  (mem_read),
      .reg_write (reg_write),
      .use_imm   (use_imm),
      .use_pc    (use_pc),
      .is_jump   (is_jump),
      .instr_type(instr_type)
  );

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

      de_to_ex_reg.alu_op                <= alu_op;
      de_to_ex_reg.mem_write             <= mem_write;
      de_to_ex_reg.reg_write             <= reg_write;
      de_to_ex_reg.mem_read              <= mem_read;
      de_to_ex_reg.use_imm               <= use_imm;
      de_to_ex_reg.use_pc                <= use_pc;
      de_to_ex_reg.is_jump               <= is_jump;

      de_to_ex_reg.v_de                  <= !(pc_r || fe_to_de.pc_r);
    end
  end

endmodule

