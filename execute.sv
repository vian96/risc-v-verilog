`include "riscv_structures.sv"

module execute (
    input logic      clk,
    // verilator lint_off UNUSEDSIGNAL
    input de_to_ex_s de_to_ex,
    // verilator lint_on UNUSEDSIGNAL

    input hu_src_e        rs1s,
    input hu_src_e        rs2s,
    input logic    [31:0] bp_mem,
    input logic    [31:0] bp_wb,
    input logic           flush,

    output ex_to_mem_s        ex_to_mem,
    output logic              pc_reset,
    output logic       [31:0] pc_exec
);

  ex_to_mem_s ex_to_mem_reg;
  assign ex_to_mem = ex_to_mem_reg;

  // ALU
  logic [31:0] alu_in1;
  logic [31:0] alu_in2;
  logic [31:0] rs1_val;
  logic [31:0] rs2_val;
  logic [31:0] alu_result;
  logic cmp_res;

  alu alu_inst (
      .in1(alu_in1),
      .in2(alu_in2),
      .alu_op(de_to_ex.alu_op),
      .funct3(de_to_ex.funct3),
      .cond(cmp_res),
      .result(alu_result)
  );

  assign rs1_val = (rs1s == MEM) ? bp_mem : (rs1s == WB) ? bp_wb : de_to_ex.rs1_val;
  assign rs2_val = (rs2s == MEM) ? bp_mem : (rs2s == WB) ? bp_wb : de_to_ex.rs2_val;

  assign alu_in1 = (de_to_ex.is_jump) ? de_to_ex.pc_value : rs1_val;
  assign alu_in2 = (de_to_ex.is_jump) ? 32'd4 : (de_to_ex.use_imm) ? de_to_ex.sext_imm : rs2_val;

  // summator of target pc
  logic [31:0] sum1;
  logic [31:0] sum2;
  assign sum1 = (de_to_ex.is_jalr) ? rs1_val : de_to_ex.pc_value;
  assign sum2 = de_to_ex.sext_imm;
  assign pc_exec = sum1 + sum2;

  assign pc_reset = !flush && de_to_ex.v_de && (cmp_res && de_to_ex.is_branch || de_to_ex.is_jump);

  always_ff @(posedge clk) begin
    $display(
        "Time %0t: \033[31m Execute \033[0m -> in1 = 0x%h, in2 = 0x%h, out = 0x%h, use_imm = 0x%h, rd = %d, aluop = %d, rs1s = %b, rs2s = %b, bp_mem = 0x%h, bp_wb = 0x%h, cmpres %d, isjmp %d, regwrite %d, cmp1 0x%h, cmp2 0x%h, v_de %d, flush %d, mread %d, final %d",
        $time, alu_in1, alu_in2, alu_result, de_to_ex.use_imm, de_to_ex.rd, de_to_ex.alu_op, rs1s,
        rs2s, bp_mem, bp_wb, cmp_res, de_to_ex.is_jump, de_to_ex.reg_write && de_to_ex.v_de,
        rs1_val, rs2_val, de_to_ex.v_de, flush, de_to_ex.mem_read && ~flush, de_to_ex.is_final);

    if (flush) begin
      ex_to_mem_reg.mem_write  <= 0;
      ex_to_mem_reg.reg_write  <= 0;
      ex_to_mem_reg.mem_read   <= 0;  // for lw after lw causing reset
      ex_to_mem_reg.instr_done <= 0;
    end else begin
      ex_to_mem_reg.mem_write  <= de_to_ex.mem_write && de_to_ex.v_de;
      ex_to_mem_reg.reg_write  <= de_to_ex.reg_write && de_to_ex.v_de;
      ex_to_mem_reg.instr_done <= de_to_ex.instr_done && de_to_ex.v_de;
      ex_to_mem_reg.rd         <= de_to_ex.rd;
      ex_to_mem_reg.mem_data   <= rs2_val;
      ex_to_mem_reg.mem_read   <= de_to_ex.mem_read;
      ex_to_mem_reg.is_final   <= de_to_ex.is_final;
      ex_to_mem_reg.alu_result <= alu_result;
    end
  end

endmodule

