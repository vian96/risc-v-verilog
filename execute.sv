`include "riscv_structures.sv"

module execute (
    input  logic              clk,
    input  de_to_ex_s         de_to_ex,
    input  hu_src_e           rs1s,
    input  hu_src_e           rs2s,
    input  logic       [31:0] bp_mem,
    input  logic       [31:0] bp_wb,
    input  logic              flush,
    output ex_to_mem_s        ex_to_mem,
    output logic              pc_reset,
    output logic       [31:0] pc_exec
);

  ex_to_mem_s ex_to_mem_reg;
  assign ex_to_mem = ex_to_mem_reg;

  logic [31:0] alu_in1;
  logic [31:0] alu_in2;
  logic [31:0] rs1_val;
  logic [31:0] rs2_val;
  logic [31:0] alu_result_wire;

  alu alu_inst (
      .in1(alu_in1),
      .in2(alu_in2),
      .alu_op(de_to_ex.alu_op),
      .result(alu_result_wire)
  );

  logic cmp_res;

  compare ex_cmp (
      .in1(rs1_val),
      .in2(rs2_val),
      .funct3(de_to_ex.funct3),
      .cond(cmp_res)
  );

  assign rs1_val  = (rs1s == MEM) ? bp_mem : (rs1s == WB) ? bp_wb : de_to_ex.rs1_data;
  assign rs2_val  = (rs2s == MEM) ? bp_mem : (rs2s == WB) ? bp_wb : de_to_ex.rs2_data;

  assign alu_in1  = (de_to_ex.use_pc) ? de_to_ex.pc_value : rs1_val;

  assign alu_in2  = (de_to_ex.use_imm) ? de_to_ex.immediate_sext : rs2_val;

  assign pc_reset = !flush && de_to_ex.v_de && (cmp_res && de_to_ex.use_pc || de_to_ex.is_jump);
  assign pc_exec  = alu_result_wire;

  always_ff @(posedge clk) begin
    $display(
        "Time %0t: \033[31m Execute \033[0m -> in1 = 0x%h, in2 = 0x%h, out = 0x%h, use_imm = 0x%h, rd = %d, aluop = %d, rs1s = %b, rs2s = %b, bp_mem = 0x%h, bp_wb = 0x%h, cmpres %d, usepc %d, isjmp %d, regwrite %d, cmp1 0x%h, cmp2 0x%h, v_de %d, flush %d",
        $time, alu_in1, alu_in2, alu_result_wire, de_to_ex.use_imm, de_to_ex.rd, de_to_ex.alu_op,
        rs1s, rs2s, bp_mem, bp_wb, cmp_res, de_to_ex.use_pc, de_to_ex.is_jump,
        de_to_ex.reg_write && de_to_ex.v_de, rs1_val, rs2_val, de_to_ex.v_de, flush);

    ex_to_mem_reg.alu_result <= de_to_ex.is_jump ? (de_to_ex.pc_value + 4) : alu_result_wire;
    ex_to_mem_reg.write_data <= rs2_val;  // rs2_data is the value to store

    ex_to_mem_reg.mem_write  <= !flush && de_to_ex.mem_write && de_to_ex.v_de;
    ex_to_mem_reg.reg_write  <= !flush && de_to_ex.reg_write && de_to_ex.v_de;
    ex_to_mem_reg.rd         <= de_to_ex.rd;
    ex_to_mem_reg.mem_read   <= de_to_ex.mem_read;
  end

endmodule

