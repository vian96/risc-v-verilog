`include "riscv_structures.sv"

module execute (
    input  logic       clk,
    input  de_to_ex_s  de_to_ex,
    output ex_to_mem_s ex_to_mem,
    output logic       pc_reset
);

  ex_to_mem_s ex_to_mem_reg;
  assign ex_to_mem = ex_to_mem_reg;

  logic [31:0] alu_in1;
  logic [31:0] alu_in2;
  logic [31:0] alu_result_wire;
  logic [ 2:0] compare_result_wire;

  alu alu_inst (
      .in1(alu_in1),
      .in2(alu_in2),
      .alu_op(de_to_ex.alu_op),
      .result(alu_result_wire),
  );

  logic cmp_res;

  compare ex_cmp (
      .in1(de_to_ex.rs1_data),
      .in2(de_to_ex.rs2_data),
      .funct3(de_to_ex.funct3),
      .cond(cmp_res)
  );


  // TODO: add jalr
  assign alu_in1 = (de_to_ex.opcode == 7'b1101111) ? de_to_ex.pc_value :  // JAL uses PC
      de_to_ex.rs1_data;

  assign alu_in2 = (de_to_ex.opcode == 7'b0110011) ? de_to_ex.rs2_data :  // ADD uses rs2_data
      de_to_ex.immediate_sext;

  always_ff @(posedge clk) begin
    ex_to_mem_reg.alu_result <= alu_result_wire;
    ex_to_mem_reg.write_data <= de_to_ex.rs2_data;  // rs2_data is the value to store

    ex_to_mem_reg.mem_write  <= de_to_ex.mem_write;
    ex_to_mem_reg.reg_write  <= de_to_ex.reg_write;
    ex_to_mem_reg.rd         <= de_to_ex.rd;
    ex_to_mem_reg.mem_read   <= de_to_ex.mem_read;

    pc_reset                 <= cmp_res;
  end

endmodule

