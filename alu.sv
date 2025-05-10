`include "riscv_structures.sv"

module alu (
    input  logic    [31:0] in1,
    input  logic    [31:0] in2,
    input  alu_op_e        alu_op,
    input  logic    [ 2:0] funct3,
    output logic           cond,
    output logic    [31:0] result
);

  assign result = (alu_op == ALU_ADD) ? in1 + in2 : (alu_op == ALU_SUB) ? in1 - in2 : 0;

  // TODO: add more conds
  assign cond = (funct3 == 0) ? in1 == in2 :
                (funct3 == 1) ? in1 != in2 :
                (funct3 == 4) ? in1 < in2 :
                0;

endmodule

