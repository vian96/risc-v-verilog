`include "riscv_structures.sv"

module reg_file (
    input  logic        clk,
    input  logic [ 4:0] a1,
    input  logic [ 4:0] a2,
    input  logic [ 4:0] a3,
    input  logic        we3,
    input  logic [31:0] wd,
    output logic [31:0] d1,
    output logic [31:0] d2,
    output logic [31:0] regs[32],
    input  logic        dump
);

  logic [31:0] registers[32];
  assign regs = registers;

  assign d1   = (a1 != 0) ? registers[a1] : 32'b0;
  assign d2   = (a2 != 0) ? registers[a2] : 32'b0;

  always_ff @(posedge dump) begin
    $display("--- Displaying regs at %0t ---", $time);
    for (int i = 0; i < 32; i = i + 1) begin
      $display("reg[%0d] = 0x%h", i, registers[i]);
    end
    $display("----------------------------------------------------");
  end

  always_ff @(negedge clk) begin
    $display(
        "Time %0t: \033[35m Reg file \033[0m -> Address = %d, val = 0x%h, enable = %d, %d = 0x%h, %d = 0x%h",
        $time, a3, wd, we3, a1, d1, a2, d2);

    if (we3 && (a3 != 0)) begin
      registers[a3] <= wd;
    end
  end

  initial begin
    for (int i = 0; i < 32; i = i + 1) begin
      registers[i] = 32'b0;
    end
  end

endmodule
