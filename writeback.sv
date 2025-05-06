`include "riscv_structures.sv"

module writeback (
    input  logic              clk,
    input  mem_to_wb_s        mem_to_wb,
    output logic       [ 4:0] writeback_address,
    output logic       [31:0] write_back_data,
    output logic              write_back_enable
);

  assign writeback_address = mem_to_wb.rd;
  assign write_back_enable = mem_to_wb.reg_write;
  assign write_back_data   = mem_to_wb.data;

endmodule

