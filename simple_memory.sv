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
    mem[0] = 32'hDEADBEEF;
    mem[1] = 32'h12345678;
    mem[2] = 32'hABCDEF01;
    mem[3] = 32'hFEDCBA98;
  end

  always @(posedge clk) begin
    $display("Time %0t: Memory Input -> Address = 0x%h, val = 0x%h", $time, address, read_data);
    if (write_enable) mem[address[31:2]] <= write_data;
  end

  assign read_data = mem[address[31:2]];

endmodule
