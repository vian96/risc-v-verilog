`include "riscv_structures.sv"

module fetch (
    input  logic             clk,
    input  logic             reset,
    input  logic      [31:0] pc_init,
    input  logic      [31:0] pc_exec,
    input  logic             pc_r,
    output fe_to_de_s        fe_to_de
);

  logic [31:0] pc;
  logic [31:0] instruction_value_wire;
  fe_to_de_s fe_to_de_reg;
  assign fe_to_de = fe_to_de_reg;

  instr_mem instrs (
      .clk      (clk),
      .address  (pc),
      .read_data(instruction_value_wire)
  );

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= pc_init;
      fe_to_de_reg.instruction_value <= '0;
      fe_to_de_reg.pc_value <= pc_init;
      fe_to_de_reg.pc_r <= 0;
    end else begin
      fe_to_de_reg.instruction_value <= instruction_value_wire;
      fe_to_de_reg.pc_value <= pc;
      fe_to_de_reg.pc_r <= pc_r;
      pc <= pc_r ? pc_exec : (pc + 32'd4);
    end
  end

endmodule

