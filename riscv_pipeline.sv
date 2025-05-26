`include "riscv_structures.sv"

module riscv_pipeline (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_init,
    output logic        wb_e,
    output logic [ 4:0] wb_a,
    output logic [31:0] wb_d,
    output logic [31:0] pc_out,
    output logic        done,
    output logic [31:0] regs   [32],
    input  logic        dump
);

  fe_to_de_s         fe_to_de_wire;
  de_to_ex_s         de_to_ex_wire;
  ex_to_mem_s        ex_to_mem_wire;
  mem_to_wb_s        mem_to_wb_wire;

  // wb -> decode
  logic       [ 4:0] wb_addr_wire;
  logic       [31:0] wb_data_wire;
  logic              wb_en_wire;

  logic              pc_r;
  logic       [31:0] pc_exec;

  // Hazard Unit
  hu_src_e           rs1s;
  hu_src_e           rs2s;
  logic              stall;

  hu hu_inst (
      .clk(clk),
      .ex_rs1(de_to_ex_wire.rs1),
      .ex_rs2(de_to_ex_wire.rs2),
      .mem_we(ex_to_mem_wire.reg_write),
      .wb_we(mem_to_wb_wire.reg_write),
      .mem_rd(ex_to_mem_wire.rd),
      .wb_rd(mem_to_wb_wire.rd),
      .wb_lw(ex_to_mem_wire.mem_read),
      .src1(rs1s),
      .src2(rs2s),
      .stall(stall)
  );

  // Main modules

  fetch fetch_inst (
      .clk(clk),
      .reset(reset),
      .pc_init(pc_init),
      .pc_r(pc_r),
      .pc_exec(pc_exec),
      .fe_to_de(fe_to_de_wire),
      .pc_out(pc_out),
      .en(~stall)
  );

  decode decode_inst (
      .clk(clk),
      .pc_r(pc_r),
      .fe_to_de(fe_to_de_wire),
      .writeback_address(wb_addr_wire),
      .write_back_data(wb_data_wire),
      .write_back_enable(wb_en_wire),
      .de_to_ex(de_to_ex_wire),
      .dump(dump),
      .reset(reset),
      .regs(regs),
      .en(~stall)
  );

  execute execute_inst (
      .clk(clk),
      .pc_reset(pc_r),
      .pc_exec(pc_exec),
      .de_to_ex(de_to_ex_wire),
      .ex_to_mem(ex_to_mem_wire),
      .rs1s(rs1s),
      .rs2s(rs2s),
      .flush(stall),
      .bp_mem(ex_to_mem_wire.alu_result),
      .bp_wb(mem_to_wb_wire.data)
  );

  memory memory_inst (
      .clk(clk),
      .ex_to_mem(ex_to_mem_wire),
      .mem_to_wb(mem_to_wb_wire)
  );

  writeback writeback_inst (
      .clk(clk),
      .mem_to_wb(mem_to_wb_wire),
      .writeback_address(wb_addr_wire),
      .write_back_data(wb_data_wire),
      .write_back_enable(wb_en_wire)
  );

  assign wb_e = wb_en_wire;
  assign wb_d = wb_data_wire;
  assign wb_a = wb_addr_wire;

  assign done = mem_to_wb_wire.is_final;

endmodule

