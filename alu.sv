`include "riscv_structures.sv"

module alu (
    input  logic    [31:0] in1,
    input  logic    [31:0] in2,
    input  alu_op_e        alu_op,
    output logic    [31:0] result
);

  assign result = (alu_op == ALU_ADD) ? in1 + in2 : 0;

endmodule

