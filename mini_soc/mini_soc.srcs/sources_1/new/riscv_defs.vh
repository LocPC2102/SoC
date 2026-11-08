// ==========================================
// riscv_defs.vh
// ==========================================

// 1. Bit-Slicing Macros
`define OPCODE instruction[6:0]
`define RD     instruction[11:7]
`define FUNCT3 instruction[14:12]
`define RS1    instruction[19:15]
`define RS2    instruction[24:20]
`define FUNCT7 instruction[31:25]

// 2. Base RV32I Opcodes
`define OP_LOAD   7'b0000011  
`define OP_IMM    7'b0010011  
`define OP_STORE  7'b0100011  
`define OP_OP     7'b0110011  
`define OP_LUI    7'b0110111  
`define OP_BRANCH 7'b1100011  
`define OP_JALR   7'b1100111 
`define OP_JAL    7'b1101111  

// 3. Funct3 Definitions
`define F3_ADD_SUB 3'b000
`define F3_SLL     3'b001
`define F3_SLT     3'b010
`define F3_SLTU    3'b011
`define F3_XOR     3'b100
`define F3_SRL_SRA 3'b101
`define F3_OR      3'b110
`define F3_AND     3'b111