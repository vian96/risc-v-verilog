module compare (
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic [ 2:0] funct3,
    output logic        cond
);

  // TODO: add more conds
  assign cond = (funct3 == 0) ? in1 == in2 :
                (funct3 == 1) ? in1 != in2 :
                (funct3 == 4) ? in1 < in2 :
                0;

endmodule


