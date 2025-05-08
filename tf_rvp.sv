/* verilator lint_off STMTDLY */  // delay warnings

module riscv_pipeline_tb;

  logic clk;
  logic reset;

  logic [4:0] wb_a;
  logic [31:0] wb_d;
  logic [31:0] pc_out;
  logic wb_e;
  logic dump;

  riscv_pipeline dut (
      .clk(clk),
      .reset(reset),
      .pc_init(0),
      .wb_a(wb_a),
      .wb_e(wb_e),
      .pc_out(pc_out),
      .wb_d(wb_d),
      .dump(dump)
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
    dump  = 0;
    #(CLK_PERIOD * 2);  // Hold reset for a few clock cycles
    reset = 0;

    // For tests 2 (52), 3(140)
    while (pc_out < 140) begin
      #(CLK_PERIOD);
      $display("Time: %0t, FLAGpc_out: %0d", $time, pc_out);
    end

    $display("Breaking loop at Time: %0t, pc_out: %0d", $time, pc_out);

    // Wait 4 clock cycles for the instruction to complete all stages
    #(CLK_PERIOD * 4);

    dump = 1;
    #(CLK_PERIOD);

    $finish;


    /////////////////////////
    // FURTHER is TEST 1
    /////////////////////////

    // --- Test Case 1: Load word from address 0x0 (offset 0, rs1 = 0) ---
    // lw x1, 0(x0)

    // Wait 4 clock cycles for the instruction to complete all stages
    #(CLK_PERIOD * 4);

    $display("Time %0t, pc = 0x%h", $time, pc_out);
    if (wb_e && wb_a == 5'd1 && wb_d == 32'hDEADBEEF) begin
      $display("Test Case 1 \033[32mPassed\033[0m: lw x1, 0(x0) (hDEADBEEF)");
    end else begin
      $display("Test Case 1 \033[31mFailed\033[0m: lw x1, 0(x0)");
      $display("Expected: x1 = 0xDEADBEEF, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end

    // --- Test Case 2: Load word from address 0x4 (offset 4, rs1 = 0) lw x2, 4(x0) ---
    #(CLK_PERIOD);

    $display("Time %0t, pc = 0x%h", $time, pc_out);
    if (wb_e && wb_a == 5'd2 && wb_d == 32'h12345678) begin
      $display("Test Case 2\033[32m Passed\033[0m: lw x2, 4(x0) (h12345678)");
    end else begin
      $display("Test Case 2 \033[31mFailed\033[0m: lw x2, 4(x0)");
      $display("Expected: x2 = 0x12345678, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end
    #(CLK_PERIOD);

    // --- Test Case 2.5: addi x7, x0, 4 ---
    $display("Time %0t, pc = 0x%h", $time, pc_out);
    if (wb_e && wb_a == 5'd7 && wb_d == 32'd4) begin
      $display("Test Case 2.5\033[32m Passed\033[0m: addi x7, x0, 4");
    end else begin
      $display("Test Case 2.5 \033[31mFailed\033[0m: addi x7, x0, 4");
      $display("Expected: x7 = 4, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end
    #(CLK_PERIOD);


    // --- Test Case 3: Load word from address 0xC (offset 8, rs1 = 4) lw x3, 8(x7) - Assuming x7 now holds 0x4 ---
    $display("Time %0t, pc = 0x%h", $time, pc_out);
    if (wb_e && wb_a == 5'd3 && wb_d == 32'hFEDCBA98) begin
      $display(
          "Test Case 3 (HU + load by reg+imm)  \033[32mPassed\033[0m: lw x3, 8(x7) (hFEDCBA98)");
    end else begin
      $display("Test Case 3 \033[31mFailed\033[0m: lw x3, 8(x7) (hFEDCBA98)");
      $display("Expected: x7 = 0xFEDCBA98, Actual: x%0d = 0x%h (enable=%b)", wb_a, wb_d, wb_e);
    end

    $finish;
  end

endmodule  // End of module riscv_load_pipeline_tb

