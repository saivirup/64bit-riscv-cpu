// constants_pkg.sv
package rv64_constants_pkg;

  // Constants handy to have around
  parameter int XLEN       = 64;
  parameter int HLEN       = 32;
  parameter int IMEM_WORDS = 256;
  parameter int ADDRW     = 5;

  //===ALUOp Categories (3 bits)====
  typedef enum logic [2:0] {
    ALUOP_LS_JAL_R = 3'b000,
    ALUOP_ITYPE    = 3'b001,
    ALUOP_RTYPE    = 3'b010,
    ALUOP_BTYPE    = 3'b011,
    ALUOP_LUI      = 3'b100,
    ALUOP_AUIPC    = 3'b101,
    ALUOP_ENV      = 3'b110,
    ALUOP_INVALID  = 3'b111
  } aluop_cat_e;

  //=== RISC‑V OPCODEs (7 bits)====
  typedef enum logic [6:0] {
    OPCODE_LOAD    = 7'b0000011,
    OPCODE_FENCE   = 7'b0001111,
    OPCODE_ITYPE   = 7'b0010011,
    OPCODE_AUIPC   = 7'b0010111,
    OPCODE_STORE   = 7'b0100011,
    OPCODE_RTYPE   = 7'b0110011,
    OPCODE_LUI     = 7'b0110111,
    OPCODE_BRANCH  = 7'b1100011,
    OPCODE_JALR    = 7'b1100111,
    OPCODE_JAL     = 7'b1101111,
    OPCODE_ENV     = 7'b1110011
  } opcode_e;

    //=== ALU Control (4 bits) ====
  typedef enum logic [3:0] {
    ALU_AND  = 4'b0000,  // Logical AND
    ALU_OR   = 4'b0001,  // Logical OR
    ALU_ADD  = 4'b0010,  // Addition
    ALU_SUB  = 4'b0110,  // Subtraction
    ALU_SLT  = 4'b0111,  // Set < (signed)
    ALU_XOR  = 4'b1000,  // XOR
    ALU_SLL  = 4'b1001,  // Shift Left Logical
    ALU_SRL  = 4'b1010,  // Shift Right Logical
    ALU_SRA  = 4'b1011,  // Shift Right Arithmetic
    ALU_SLTU = 4'b1100,  // Set < (unsigned)
    ALU_SGE  = 4'b1101,  // >= (signed)
    ALU_SGEU = 4'b1110,  // >= (unsigned)
    ALU_INV  = 4'b1111   // Illegal / unrecognized
  } alu_ctrl_e;

    //=== Immediate types from imm_decoder (3 bits) ====
  typedef enum logic [2:0] {
    I_TYPE        = 3'b000,
    S_TYPE        = 3'b001,
    B_TYPE        = 3'b010,
    U_TYPE        = 3'b011,
    J_TYPE        = 3'b100,
    INVALID_TYPE  = 3'b111
  } imm_type_e;

endpackage