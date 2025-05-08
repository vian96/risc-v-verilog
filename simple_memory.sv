`include "riscv_structures.sv"

module simple_memory (
    input  logic        clk,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    input  logic        write_enable,
    output logic [31:0] read_data
);

  // 256 words of 32 bits each
  reg [31:0] mem[255];

  initial begin
    // FOR TEST 1
    mem[0] = 32'hDEADBEEF;
    mem[1] = 32'h12345678;
    mem[2] = 32'hABCDEF01;
    mem[3] = 32'hFEDCBA98;

    // FOR TEST 2
    mem[20] = 32'h00000005;  // Data for lw x1 (value 5)
    // 2.1
    //mem[21] = 32'h00000005; // Data for lw x2 (value 5) - Set to 5 to trigger the BEQ branch initially
    // 2.2, 2.3
    mem[21] = 32'h0000000A; // Data for lw x2 (value 5) - Set to 5 to trigger the BEQ branch initially
    mem[22] = 32'h00000014;  // Data for lw x3 (value 20)

  end

  always @(posedge clk) begin
    $display("Time %0t: \033[34m Memory Input \033[0m -> Address = 0x%h, val = 0x%h", $time,
             address, read_data);
    if (write_enable) mem[address[31:2]] <= write_data;
  end

  assign read_data = mem[address[31:2]];

endmodule
