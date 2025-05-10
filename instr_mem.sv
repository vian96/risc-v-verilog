`include "riscv_structures.sv"

module instr_mem (
    input  logic        clk,
    input  logic [31:0] address,
    output logic [31:0] read_data
);

  // 256 words of 32 bits each
  reg [31:0] mem[255];

  initial begin
    $readmemh("build/instr.hex", mem);
  end

  always @(posedge clk) begin
    $display("Time %0t: \033[33m Instr Memory Input \033[0m -> Address = 0x%h, val = 0x%h", $time,
             address, read_data);
  end

  // verilator lint_off WIDTH
  assign read_data = mem[address[31:2]];
  // verilator lint_on WIDTH

endmodule

