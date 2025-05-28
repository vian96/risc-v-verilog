`include "riscv_structures.sv"

module memory (
    input  logic       clk,
    input  ex_to_mem_s ex_to_mem,
    output logic       mem_ready,
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

  logic [31:0] cache_v[4];
  logic [31:0] cache_a[4];

  logic [4:0] read_state;

  initial begin
    for (int i = 0; i < 32; i++) cache_a[i] = 0;
    read_state = 0;
  end

  logic [1:0] cache_hash;
  assign cache_hash = ex_to_mem.alu_result[3:2];

  logic is_in_cache;  // either already in cache or spent 4 cycles reading
  assign is_in_cache = (cache_a[cache_hash] == ex_to_mem.alu_result) || (read_state == 3);

  assign mem_ready   = is_in_cache || !ex_to_mem.mem_read;

  always_ff @(posedge clk) begin
    $display(
        "Time %0t: \033[34m Memory Input \033[0m -> Address = 0x%h, val = 0x%h; regwe %d, rd %d",
        $time, ex_to_mem.alu_result, mem_data, ex_to_mem.reg_write, ex_to_mem.rd);

    if (is_in_cache || !ex_to_mem.mem_read) begin  // either no memory or in cache
      mem_to_wb_reg.data <= ex_to_mem.mem_read ? cache_v[cache_hash] : ex_to_mem.alu_result;
      mem_to_wb_reg.reg_write <= ex_to_mem.reg_write;
      mem_to_wb_reg.is_final <= ex_to_mem.is_final;
      mem_to_wb_reg.rd <= ex_to_mem.rd;
      mem_to_wb_reg.instr_done <= ex_to_mem.instr_done;
      read_state <= 0;


    end else begin
      read_state <= read_state + 1;  // tries to read but not in cache

      if (read_state == 2) begin  // read from cache
        cache_v[cache_hash] <= mem_data;
        cache_a[cache_hash] <= ex_to_mem.alu_result;
      end


      // writeback does nothing
      mem_to_wb_reg.data <= 0;
      mem_to_wb_reg.reg_write <= 0;
      mem_to_wb_reg.is_final <= 0;
      mem_to_wb_reg.rd <= 0;
      mem_to_wb_reg.instr_done <= 0;
    end

  end

endmodule

