/* verilator lint_off STMTDLY */  // delay warnings

module tf_rvp;

  logic clk;
  logic reset;

  // for debug or per-cycle checks
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

  parameter int CLK_PERIOD = 10;
  initial begin
    clk = 0;
    // verilator lint_off INFINITELOOP
    forever #(CLK_PERIOD / 2) clk = ~clk;
    // verilator lint_on INFINITELOOP
  end

  initial begin

    reset = 1;
    dump  = 0;
    #(CLK_PERIOD * 20);  // Hold reset for a few clock cycles
    reset = 0;

    while (pc_out < 150 && $time < 2000) begin
      #(CLK_PERIOD);
      $display("Time: %0t, FLAGpc_out: %0d", $time, pc_out);
    end

    $display("Breaking loop at Time: %0t, pc_out: %0d", $time, pc_out);

    // Wait 4 clock cycles for the instruction to complete all stages
    #(CLK_PERIOD * 4);

    dump = 1;
    #(CLK_PERIOD);

    $finish;
  end

endmodule

