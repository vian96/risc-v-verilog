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

  alu alu_inst (
      .in1(alu_in1),
      .in2(alu_in2),
      .alu_op(de_to_ex.alu_op),
      .result(alu_result_wire)
  );

  logic cmp_res;

  compare ex_cmp (
      .in1(de_to_ex.rs1_data),
      .in2(de_to_ex.rs2_data),
      .funct3(de_to_ex.funct3),
      .cond(cmp_res)
  );


  // TODO: add jalr
  assign alu_in1 = (de_to_ex.use_pc) ? de_to_ex.pc_value : de_to_ex.rs1_data;

  assign alu_in2 = (de_to_ex.use_imm) ? de_to_ex.immediate_sext : de_to_ex.rs2_data;

  always_ff @(posedge clk) begin
    $display("Time %0t:  Execute -> in1 = 0x%h, in2 = 0x%h, out = 0x%h, use_imm = 0x%h", $time,
             alu_in1, alu_in2, alu_result_wire, de_to_ex.use_imm);

    ex_to_mem_reg.alu_result <= alu_result_wire;
    ex_to_mem_reg.write_data <= de_to_ex.rs2_data;  // rs2_data is the value to store

    ex_to_mem_reg.mem_write  <= de_to_ex.mem_write;
    ex_to_mem_reg.reg_write  <= de_to_ex.reg_write;
    ex_to_mem_reg.rd         <= de_to_ex.rd;
    ex_to_mem_reg.mem_read   <= de_to_ex.mem_read;

    pc_reset                 <= cmp_res;
  end

endmodule

