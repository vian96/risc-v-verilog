module riscv_pipeline_tb;

  logic clk;
  logic reset;

  logic [4:0] wb_a;
  logic [31:0] wb_d;
  logic wb_e;

  riscv_pipeline dut (
      .clk(clk),
      .reset(reset),
      .pc_init(0),
      .wb_a(wb_a),
      .wb_e(wb_e),
      .wb_d(wb_d)
  );

  parameter CLK_PERIOD = 10;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    // Dump waveforms
    $dumpfile("riscv_load_dump.vcd");
    // Dump all variables in the testbench scope // TODO: what for?
    $dumpvars(0, riscv_pipeline_tb);

    reset = 1;
    #(CLK_PERIOD * 2);  // Hold reset for a few clock cycles
    reset = 0;

    // --- Test Case 1: Load word from address 0x0 (offset 0, rs1 = 0) ---
    // lw x1, 0(x0)

    // Wait 4 clock cycles for the instruction to complete all stages
    #(CLK_PERIOD * 4);

    // Check the result
    // The value at memory address 0x0 is DEADBEEF
    $display("Time %0t", $time);
    if (wb_e && wb_a == 5'd1 && wb_d == 32'hDEADBEEF) begin
      $display("Test Case 1 Passed: lw x1, 0(x0)");
    end else begin
      $display("Test Case 1 Failed: lw x1, 0(x0)");
      $display("Expected: x1 = 0xDEADBEEF, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end

    // --- Test Case 2: Load word from address 0x4 (offset 4, rs1 = 0) ---
    // lw x2, 4(x0)
    #(CLK_PERIOD);  // Wait for instruction to finish pipeline

    // The value at memory address 0x4 is 12345678
    $display("Time %0t", $time);
    if (wb_e && wb_a == 5'd2 && wb_d == 32'h12345678) begin
      $display("Test Case 2 Passed: lw x2, 4(x0)");
    end else begin
      $display("Test Case 2 Failed: lw x2, 4(x0)");
      $display("Expected: x2 = 0x12345678, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end
    #(CLK_PERIOD);  // Wait one more cycle before the next test case

    // --- Test Case 3: Load word from address 0xC (offset 8, rs1 = 4) ---
    // lw x3, 8(x1) - Assuming x1 now holds 0x4
    // rd = x3 (register 3), rs1 = x1 (register 1), imm = 8
    #(CLK_PERIOD);  // Wait for instruction to enter pipeline

    #(CLK_PERIOD * 4);  // Wait for the instruction to complete

    // Check the result (assuming register x3 should now hold the value from memory address 0x4 + 0x8 = 0xC)
    // The value at memory address 0xC is FEDCBA98 (from simple_memory.sv initial block)
    $display("Time %0t", $time);
    if (wb_e && wb_a == 5'd3 && wb_d == 32'hFEDCBA98) begin  // Corrected expected value
      $display("Test Case 3 Passed: lw x3, 8(x1)");
    end else begin
      $display("Test Case 3 Failed: lw x3, 8(x1)");
      $display("Expected: x3 = 0xFEDCBA98, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end
    #(CLK_PERIOD);  // Wait one more cycle


    // End simulation
    $finish;
  end

endmodule  // End of module riscv_load_pipeline_tb

