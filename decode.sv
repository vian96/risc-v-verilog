`include "riscv_structures.sv"

module decode (
    // control signals
    input logic clk,
    input logic reset,
    input logic en,
    input logic pc_r,

    input fe_to_de_s        fe_to_de,
    input logic      [ 4:0] writeback_address,
    input logic      [31:0] write_back_data,
    input logic             write_back_enable,

    input logic dump,  // print regs

    output logic [31:0] regs[32],
    output de_to_ex_s de_to_ex
);

  de_to_ex_s de_to_ex_reg;
  assign de_to_ex = de_to_ex_reg;
  de_to_ex_s de_to_ex_int;

  logic [31:0] instruction;
  logic [6:0] opcode;
  logic [4:0] rd;
  logic [2:0] funct3;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [6:0] funct7;

  assign instruction         = fe_to_de.instruction_value;
  assign opcode              = instruction[6:0];
  assign rd                  = instruction[11:7];
  assign funct3              = instruction[14:12];
  assign rs1                 = instruction[19:15];
  assign rs2                 = instruction[24:20];
  assign funct7              = instruction[31:25];

  assign de_to_ex_int.rs1    = rs1;
  assign de_to_ex_int.rs2    = rs2;
  assign de_to_ex_int.rd     = rd;
  assign de_to_ex_int.funct3 = funct3;

  reg_file rf (
      .clk(clk),
      .a1 (rs1),
      .a2 (rs2),
      .a3 (writeback_address),
      .wd (write_back_data),
      .we3(write_back_enable),

      .d1  (de_to_ex_int.rs1_val),
      .d2  (de_to_ex_int.rs2_val),
      .regs(regs),
      .dump(dump)
  );

  instr_type_e instr_type;

  cu cu_inst (
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),

      .alu_op    (de_to_ex_int.alu_op),
      .mem_write (de_to_ex_int.mem_write),
      .mem_read  (de_to_ex_int.mem_read),
      .reg_write (de_to_ex_int.reg_write),
      .use_imm   (de_to_ex_int.use_imm),
      .is_branch (de_to_ex_int.is_branch),
      .is_jump   (de_to_ex_int.is_jump),
      .is_final  (de_to_ex_int.is_final),
      .instr_type(instr_type),
      .is_jalr   (de_to_ex_int.is_jalr)
  );

  imm imm_inst (
      .instr_type(instr_type),
      .instruction(instruction[31:7]),
      .sext_imm(de_to_ex_int.sext_imm)
  );

  assign de_to_ex_int.pc_value = fe_to_de.pc_value;
  assign de_to_ex_int.instruction_bits_30_7 = instruction[30:7];
  assign de_to_ex_int.v_de = !(pc_r || fe_to_de.pc_r);

  always_ff @(posedge clk or posedge reset) begin
    $display("Time %0t: decode -> v_de %d, pc_r %d, fe.pc_r %d, en %d", $time, de_to_ex_reg.v_de,
             pc_r, fe_to_de.pc_r, en);

    if (reset) begin
      de_to_ex_reg.mem_read <= 0;  // for backward loop at start
      de_to_ex_reg.v_de     <= 0;
    end else if (en) begin
      de_to_ex_reg <= de_to_ex_int;
    end
  end

endmodule

