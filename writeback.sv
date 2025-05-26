`include "riscv_structures.sv"

module writeback (
    input  logic              clk,
    // verilator lint_off UNUSEDSIGNAL
    input  mem_to_wb_s        mem_to_wb,
    // verilator lint_on UNUSEDSIGNAL
    output logic       [ 4:0] writeback_address,
    output logic       [31:0] write_back_data,
    output logic              write_back_enable
);

  assign writeback_address = mem_to_wb.rd;
  assign write_back_enable = mem_to_wb.reg_write;
  assign write_back_data   = mem_to_wb.data;

  always @(posedge clk) begin
    $display(
        "Time %0t: \033[32m Write Back \033[0m -> Address = 0x%h, val = 0x%h, enable = 0x%h, final %d",
        $time, writeback_address, write_back_data, write_back_enable, mem_to_wb.is_final);
  end


endmodule

