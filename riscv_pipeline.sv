`include "riscv_structures.sv"

module riscv_pipeline (
    input logic        clk,
    input logic        reset,
    input logic [31:0] pc_init
);

  fe_to_de_s         fe_to_de_wire;
  de_to_ex_s         de_to_ex_wire;
  ex_to_mem_s        ex_to_mem_wire;
  mem_to_wb_s        mem_to_wb_wire;

  // wb -> dec
  logic       [ 4:0] wb_addr_wire;
  logic       [31:0] wb_data_wire;
  logic              wb_en_wire;

  fetch fetch_inst (
      .clk(clk),
      .reset(reset),
      .pc_init(pc_init),
      .fe_to_de(fe_to_de_wire)
  );

  decode decode_inst (
      .clk(clk),
      .fe_to_de(fe_to_de_wire),
      .writeback_address(wb_addr_wire),
      .write_back_data(wb_data_wire),
      .write_back_enable(wb_en_wire),
      .de_to_ex(de_to_ex_wire)
  );

  execute execute_inst (
      .clk(clk),
      .de_to_ex(de_to_ex_wire),
      .ex_to_mem(ex_to_mem_wire)
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

endmodule

