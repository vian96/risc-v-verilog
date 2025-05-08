`include "riscv_structures.sv"

module instr_mem (
    input  logic        clk,
    input  logic [31:0] address,
    output logic [31:0] read_data
);

  // 256 words of 32 bits each
  reg [31:0] mem[255];

  initial begin
    mem[0] = 32'b000000000000_00000_010_00001_0000011;  // lw x1, 0(x0)
    mem[1] = 32'b000000000100_00000_010_00010_0000011;  // lw x2, 4(x0)
    mem[2] = 32'h00400393;  // addi x7, x0, 4
    mem[3] = 32'h00000013;  // nop
    mem[4] = 32'h00000013;  // nop
    mem[5] = 32'h00000013;  // nop
    mem[6] = 32'h0083a183;  // lw x3, 8(x7)
  end

  always @(posedge clk) begin
    $display("Time %0t: \033[33m Instr Memory Input \033[0m -> Address = 0x%h, val = 0x%h", $time,
             address, read_data);
  end

  assign read_data = mem[address[31:2]];

endmodule

