`include "riscv_structures.sv"

module fetch (
    input  logic             clk,
    input  logic             reset,
    input  logic      [31:0] pc_init,
    input  logic      [31:0] pc_exec,
    input  logic             pc_r,
    input  logic             en,
    output logic      [31:0] pc_out,
    output fe_to_de_s        fe_to_de
);

  logic [31:0] pc;
  logic [31:0] instruction;
  fe_to_de_s fe_to_de_reg;
  assign fe_to_de = fe_to_de_reg;

  instr_mem instrs (
      .clk      (clk),
      .address  (pc),
      .read_data(instruction)
  );

  assign pc_out = pc;

  always_ff @(posedge clk or posedge reset) begin
    $display(
        "Time %0t \033[96m FETCH \033[0m: pc_r 0x%h, pc_exec 0x%h, en %d, pc 0x%h, instruction 0x%h",
        $time, pc_r, pc_exec, en, pc, instruction);
    if (reset) begin
      pc <= pc_init;
      fe_to_de_reg.instruction_value <= '0;
      fe_to_de_reg.pc_value <= pc_init;
      fe_to_de_reg.pc_r <= 0;
      fe_to_de_reg.instr_done <= 0;
    end else if (en) begin
      fe_to_de_reg.instruction_value <= instruction;
      fe_to_de_reg.pc_value <= pc;
      fe_to_de_reg.pc_r <= pc_r;
      pc <= pc_r ? pc_exec : (pc + 32'd4);
      fe_to_de_reg.instr_done <= 1;
    end
  end

endmodule

