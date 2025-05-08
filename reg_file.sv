`include "riscv_structures.sv"

module reg_file (
    input  logic        clk,
    input  logic [ 4:0] a1,
    input  logic [ 4:0] a2,
    input  logic [ 4:0] a3,
    input  logic        we3,
    input  logic [31:0] wd,
    output logic [31:0] d1,
    output logic [31:0] d2
);

  logic [31:0] registers[32];

  assign d1 = (a1 != 0) ? registers[a1] : 32'b0;
  assign d2 = (a2 != 0) ? registers[a2] : 32'b0;

  always_ff @(posedge clk) begin
    $display("Time %0t: \033[35m Reg file \033[0m -> Address = 0x%h, val = 0x%h, enable = 0x%h",
             $time, a3, wd, we3);
    if (we3 && (a3 != 0)) begin
      registers[a3] <= wd;
    end
  end

  initial begin  // not needed, just for strahovka
    registers[0] = 32'b0;
  end

endmodule
