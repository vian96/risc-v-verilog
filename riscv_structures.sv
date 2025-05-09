`ifndef RISCV_STRUCTURES_SV_
`define RISCV_STRUCTURES_SV_

typedef enum logic [2:0] {
  R_TYPE,
  I_TYPE,
  S_TYPE,
  B_TYPE,
  U_TYPE,
  J_TYPE,
  INVALID_TYPE
} instr_type_e;

typedef enum logic [1:0] {
  REG,
  MEM,
  WB
} hu_src_e;

typedef struct packed {
  logic [31:0] instruction_value;
  logic [31:0] pc_value;
  logic pc_r;
} fe_to_de_s;

typedef enum logic [4:0] {
  ALU_ADD,  // Addition (for ADD, LD, SD, JALR, JAL, AUIPC)
  ALU_SUB,
  ALU_INVALID
} alu_op_e;

typedef struct packed {
  logic [31:0] pc_value;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] immediate_sext;
  logic [23:0] instruction_bits_30_7;
  // Control signals
  alu_op_e alu_op;
  logic mem_write;
  logic reg_write;
  logic mem_read;
  logic use_imm;
  logic use_pc;  // for B.. or JAL
  logic is_jump;  // for uncond jumps: JAL(R)
  logic [4:0] rd;
  logic [2:0] funct3;
  logic v_de;
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

