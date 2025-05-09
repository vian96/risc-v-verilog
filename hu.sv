`include "riscv_structures.sv"

module hu (
    input logic clk,
    input logic mem_we,
    input logic wb_we,
    input logic [4:0] ex_rs1,
    input logic [4:0] ex_rs2,
    input logic [4:0] mem_rd,
    input logic [4:0] wb_rd,
    input logic wb_lw,
    output hu_src_e src1,
    output hu_src_e src2,
    output logic stall
);

  always_ff @(posedge clk) begin
    //if (0)
    $display("Time %0t:  HAZARD UNIT memwe %d wbwe %d rs1 %d rs2 %d memrd %d wbrd %d wblw %d",
             $time, mem_we, wb_we, ex_rs1, ex_rs2, mem_rd, wb_rd, wb_lw);
  end

  assign src1  = (mem_we && ex_rs1 == mem_rd) ? MEM : (wb_we && ex_rs1 == wb_rd) ? WB : REG;
  assign src2  = (mem_we && ex_rs2 == mem_rd) ? MEM : (wb_we && ex_rs2 == wb_rd) ? WB : REG;

  assign stall = wb_lw && (ex_rs1 == mem_rd || ex_rs2 == mem_rd);

endmodule



