`include "riscv_structures.sv"

module simple_memory (
    input  logic        clk,
    // verilator lint_off UNUSEDSIGNAL
    input  logic [31:0] address,
    // verilator lint_on UNUSEDSIGNAL
    input  logic [31:0] write_data,
    input  logic        write_enable,
    output logic [31:0] read_data
);

  // 256 words of 32 bits each
  reg [31:0] mem[255];

  initial begin
    // FOR TEST 1
    mem[75+0]  = 32'hDEADBEEF;
    mem[75+1]  = 32'h12345678;
    mem[75+2]  = 32'hABCDEF01;
    mem[75+3]  = 32'hFEDCBA98;

    // FOR TEST 2
    mem[75+20] = 32'h00000005;
    mem[75+21] = 32'h0000000A;

    mem[75+22] = 32'h00000014;

    // TEST 3
    // will be overwritten by SW
    mem[75+30] = 32'hFFFFFFFF;

    // TEST 4
    mem[75+32] = 32'hAB0BAB0B;

    // TEST 5
    mem[75+34] = 32'h7c;  // 124+36=160=mem[40]
    mem[75+40] = 32'h5c;  // 92+92=184=mem[46]
    mem[75+46] = 32'hCEC0CEC0;
  end

  // verilator lint_off WIDTH
  always @(posedge clk) begin
    if (write_enable) mem[address[31:2]] <= write_data;
  end

  assign read_data = mem[address[31:2]];
  // verilator lint_on WIDTH

endmodule
