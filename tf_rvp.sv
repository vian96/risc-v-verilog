// Define the testbench module
module riscv_load_pipeline_tb;

  // Clock and Reset signals
  logic clk;
  logic reset;

  // Signals connecting to the pipeline module
  logic [31:0] instruction_in;
  logic [31:0] mem_address;
  logic [31:0] mem_read_data;
  logic mem_read_enable;
  logic [4:0] writeback_reg_addr;
  logic [31:0] writeback_data;
  logic writeback_enable;

  // Signal for rs1 value (simplified - in a real testbench, this would come from a register file model)
  logic [31:0] tb_rs1_value;

  // Signals connecting to the memory module
  logic [31:0] tb_mem_address;
  logic tb_mem_read_enable;
  logic [31:0] tb_mem_read_data;

  // Instantiate the pipeline module
  riscv_load_pipeline dut (
      .clk(clk),
      .reset(reset),
      .instruction_in(instruction_in),
      .rs1_value(tb_rs1_value),  // Connect the simplified rs1 value
      .mem_address(tb_mem_address),  // Connect to testbench memory address signal
      .mem_read_data(tb_mem_read_data),  // Connect to testbench memory read data signal
      .mem_read_enable(tb_mem_read_enable),  // Connect to testbench memory read enable signal
      .writeback_reg_addr(writeback_reg_addr),
      .writeback_data(writeback_data),
      .writeback_enable(writeback_enable)
  );

  // Instantiate the memory module
  simple_memory mem_inst (
      .clk(clk),
      .address(tb_mem_address),  // Connect to pipeline's memory address output
      .read_data(tb_mem_read_data)  // Connect to pipeline's memory read data input
  );

  // Clock generation
  parameter CLK_PERIOD = 10;  // Define clock period in time units
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;  // Toggle clock every half period
  end

  // Test sequence
  initial begin
    // Dump waveforms
    $dumpfile("riscv_load_dump.vcd");
    $dumpvars(0, riscv_load_pipeline_tb);  // Dump all variables in the testbench scope

    // Apply reset
    reset = 1;
    instruction_in = 32'b0;  // No instruction during reset
    tb_rs1_value = 32'b0;
    #(CLK_PERIOD * 2);  // Hold reset for a few clock cycles

    reset = 0;
    #(CLK_PERIOD);  // Wait one clock cycle after reset

    // --- Test Case 1: Load word from address 0x0 (offset 0, rs1 = 0) ---
    // lw x1, 0(x0) - Assuming x0 is always 0
    // Instruction format: imm[11:0] | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode[6:0]
    // lw opcode: 0000011, funct3: 010
    // rd = x1 (register 1), rs1 = x0 (register 0), imm = 0
    instruction_in = 32'b000000000000_00000_010_00001_0000011;  // lw x1, 0(x0)
    tb_rs1_value   = 32'h0;  // Assume x0 value is 0
    #(CLK_PERIOD);  // Wait for instruction to enter pipeline

    // Wait 4 clock cycles for the instruction to complete all stages
    #(CLK_PERIOD * 4);

    // Check the result (assuming register x1 should now hold the value from memory address 0)
    // The value at memory address 0x0 is DEADBEEF
    if (writeback_enable && writeback_reg_addr == 5'd1 && writeback_data == 32'hDEADBEEF) begin
      $display("Test Case 1 Passed: lw x1, 0(x0)");
    end else begin
      $display("Test Case 1 Failed: lw x1, 0(x0)");
      $display("Expected: x1 = 0xDEADBEEF, Actual: x%0d = 0x%h (enable=%b)", writeback_reg_addr,
               writeback_data, writeback_enable);
    end
    #(CLK_PERIOD);  // Wait one more cycle before the next test case

    // --- Test Case 2: Load word from address 0x4 (offset 4, rs1 = 0) ---
    // lw x2, 4(x0)
    // rd = x2 (register 2), rs1 = x0 (register 0), imm = 4
    instruction_in = 32'b000000000100_00000_010_00010_0000011;  // lw x2, 4(x0)
    tb_rs1_value   = 32'h0;  // Assume x0 value is 0
    #(CLK_PERIOD);  // Wait for instruction to enter pipeline

    #(CLK_PERIOD * 4);  // Wait for the instruction to complete

    // Check the result (assuming register x2 should now hold the value from memory address 4)
    // The value at memory address 0x4 is 12345678
    if (writeback_enable && writeback_reg_addr == 5'd2 && writeback_data == 32'h12345678) begin
      $display("Test Case 2 Passed: lw x2, 4(x0)");
    end else begin
      $display("Test Case 2 Failed: lw x2, 4(x0)");
      $display("Expected: x2 = 0x12345678, Actual: x%0d = 0x%h (enable=%b)", writeback_reg_addr,
               writeback_data, writeback_enable);
    end
    #(CLK_PERIOD);  // Wait one more cycle before the next test case

    // --- Test Case 3: Load word from address 0xC (offset 8, rs1 = 4) ---
    // lw x3, 8(x1) - Assuming x1 now holds 0x4
    // rd = x3 (register 3), rs1 = x1 (register 1), imm = 8
    instruction_in = 32'b000000001000_00001_010_00011_0000011;  // lw x3, 8(x1)
    tb_rs1_value   = 32'h4;  // Assume x1 value is 0x4
    #(CLK_PERIOD);  // Wait for instruction to enter pipeline

    #(CLK_PERIOD * 4);  // Wait for the instruction to complete

    // Check the result (assuming register x3 should now hold the value from memory address 0x4 + 0x8 = 0xC)
    // The value at memory address 0xC is FEDCBA98 (from simple_memory.sv initial block)
    if (writeback_enable && writeback_reg_addr == 5'd3 && writeback_data == 32'hFEDCBA98) begin // Corrected expected value
      $display("Test Case 3 Passed: lw x3, 8(x1)");
    end else begin
      $display("Test Case 3 Failed: lw x3, 8(x1)");
      $display("Expected: x3 = 0xFEDCBA98, Actual: x%0d = 0x%h (enable=%b)", writeback_reg_addr,
               writeback_data, writeback_enable);
    end
    #(CLK_PERIOD);  // Wait one more cycle


    // End simulation
    $finish;
  end

endmodule  // End of module riscv_load_pipeline_tb

