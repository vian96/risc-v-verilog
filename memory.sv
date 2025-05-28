`include "riscv_structures.sv"

module memory (
    input  logic       clk,
    input  ex_to_mem_s ex_to_mem,
    output mem_to_wb_s mem_to_wb
);

  mem_to_wb_s mem_to_wb_reg;
  assign mem_to_wb = mem_to_wb_reg;

  logic [31:0] mem_data;

  data_memory data_mem_inst (
      .clk         (clk),
      .address     (ex_to_mem.alu_result),
      .read_data   (mem_data),
      .write_data  (ex_to_mem.mem_data),
      .write_enable(ex_to_mem.mem_write)
  );

  always_ff @(posedge clk) begin
    $display(
        "Time %0t: \033[34m Memory Input \033[0m -> Address = 0x%h, val = 0x%h; regwe %d, rd %d",
        $time, ex_to_mem.alu_result, mem_data, ex_to_mem.reg_write, ex_to_mem.rd);

    mem_to_wb_reg.data <= ex_to_mem.mem_read ? mem_data : ex_to_mem.alu_result;
    mem_to_wb_reg.reg_write <= ex_to_mem.reg_write;
    mem_to_wb_reg.is_final <= ex_to_mem.is_final;
    mem_to_wb_reg.rd <= ex_to_mem.rd;
    mem_to_wb_reg.instr_done <= ex_to_mem.instr_done;
  end

endmodule

