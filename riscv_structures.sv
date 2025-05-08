`ifndef RISCV_STRUCTURES_SV_
`define RISCV_STRUCTURES_SV_

`define ANSIRESET "\033[0m";
`define BOLD "\033[1m";
`define BLACK "\033[30m";
`define RED "\033[31m";
`define GREEN "\033[32m";
`define YELLOW "\033[33m";
`define BLUE "\033[34m";
`define MAGENTA "\033[35m";
`define CYAN "\033[36m";
`define WHITE "\033[37m";

typedef struct packed {
  logic [31:0] instruction_value;
  logic [31:0] pc_value;
} fe_to_de_s;

typedef enum logic [4:0] {
  ALU_ADD,    // Addition (for ADD, LD, SD, JALR, JAL, AUIPC)
  ALU_EQ,     // Equal (for BEQ)
  // Add other necessary ALU ops if more instructions are added later
  ALU_INVALID // Default for unsupported instructions
} alu_op_e;

typedef struct packed {
  logic [31:0] pc_value;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] immediate_sext;
  logic [23:0] instruction_bits_30_7;
  // Control signals
  alu_op_e alu_op;
  logic mem_write;
  logic reg_write;
  logic mem_read;
  logic [4:0] rd;
  logic [6:0] opcode;
  logic [2:0] funct3;
} de_to_ex_s;

typedef struct packed {
  logic [31:0] alu_result;
  logic [31:0] write_data;

  // Pass through control signals and rd
  logic       mem_write;
  logic       reg_write;
  logic       mem_read;
  logic [4:0] rd;
} ex_to_mem_s;

typedef struct packed {
  logic [31:0] data;
  logic        reg_write;
  logic [4:0]  rd;
} mem_to_wb_s;

`endif  // RISCV_STRUCTURES_SV_

