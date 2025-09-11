`timescale 1ns/1ps

// Make sure this package is compiled first (src/constants_pkg.sv)
import rv64_constants_pkg::*;

module control_tb;

  // ---- DUT I/O ----
  logic [6:0] opcode;
  logic       RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
  logic [2:0] ALUOp;

  // NOTE: adjust instance/port names if your DUT differs
  control dut (
    .opcode   (opcode),
    .RegDst   (RegDst),
    .Jump     (Jump),
    .Branch   (Branch),
    .MemRead  (MemRead),
    .MemtoReg (MemtoReg),
    .ALUOp    (ALUOp),
    .MemWrite (MemWrite),
    .ALUSrc   (ALUSrc),
    .RegWrite (RegWrite)
  );

  // ---- Canonical RV64I major opcodes ----
  localparam logic [6:0]
    OPCODE_LOAD     = 7'h03, // I-type loads
    OPCODE_MISC_MEM = 7'h0F, // FENCE (unused here)
    OPCODE_OP_IMM   = 7'h13, // I-type ALU immediate
    OPCODE_AUIPC    = 7'h17, // U-type
    OPCODE_STORE    = 7'h23, // S-type
    OPCODE_OP       = 7'h33, // R-type
    OPCODE_LUI      = 7'h37, // U-type
    OPCODE_BRANCH   = 7'h63, // B-type
    OPCODE_JALR     = 7'h67, // I-type JALR
    OPCODE_JAL      = 7'h6F; // J-type

  // ---- Expected-vector type (UNPACKED; strings are OK here) ----
  typedef struct {
    logic [6:0] op;

    // expected values
    logic       RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    logic [2:0] ALUOp;

    // masks: 1 = check, 0 = don't-care
    logic       m_RegDst, m_Jump, m_Branch, m_MemRead, m_MemtoReg, m_MemWrite, m_ALUSrc, m_RegWrite;
    logic [2:0] m_ALUOp;

    string      name;
  } vec_t;

  // Shorthand for readability
  localparam bit CHK = 1'b1;
  localparam bit DNC = 1'b0;
  localparam logic [2:0] CHK3 = 3'b111;
  localparam logic [2:0] DNC3 = 3'b000;

  // ---- Test table ----
  // Tweak ALUOp symbols if your pkg uses different names.
  vec_t V[$] = '{
    //            op            RegDst Jump Branch MemR Mem2R MemW ALUSrc RegW  ALUOp              masks:        RegDst Jump Branch MemR Mem2R MemW ALUSrc RegW  ALUOp     name
    '{ OPCODE_OP,               1,     0,   0,     0,   0,    0,   0,     1,    ALUOP_RTYPE,       CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK3,    "R-type" },
    '{ OPCODE_OP_IMM,           0,     0,   0,     0,   0,    0,   1,     1,    ALUOP_ITYPE,       CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK3,    "I-type ALU" },
    '{ OPCODE_LOAD,             0,     0,   0,     1,   1,    0,   1,     1,    ALUOP_LS_JAL_R,    CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK3,    "LOAD" },
    '{ OPCODE_STORE,            0,     0,   0,     0,   0,    1,   1,     0,    ALUOP_LS_JAL_R,    DNC,  CHK,  CHK,  CHK,  DNC,  CHK,  CHK,  CHK,  CHK3,    "STORE" },
    '{ OPCODE_BRANCH,           0,     0,   1,     0,   0,    0,   0,     0,    ALUOP_BTYPE,       DNC,  CHK,  CHK,  CHK,  DNC,  CHK,  CHK,  CHK,  CHK3,    "BRANCH" },
    '{ OPCODE_JAL,              0,     1,   0,     0,   0,    0,   0,     1,    ALUOP_LS_JAL_R,    DNC,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK3,    "JAL" },
    '{ OPCODE_JALR,             0,     1,   0,     0,   0,    0,   1,     1,    ALUOP_LS_JAL_R,    DNC,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK,  CHK3,    "JALR" },
    '{ OPCODE_LUI,              0,     0,   0,     0,   0,    0,   1,     1,    ALUOP_LUI,         DNC,  CHK,  CHK,  CHK,  DNC,  CHK,  CHK,  CHK,  CHK3,    "LUI" },
    '{ OPCODE_AUIPC,            0,     0,   0,     0,   0,    0,   1,     1,    ALUOP_LS_JAL_R,    DNC,  CHK,  CHK,  CHK,  DNC,  CHK,  CHK,  CHK,  CHK3,    "AUIPC" }
  };

  // ---- Checker ----
  task automatic check(vec_t v);
    bit ok = 1;

    ok &= (!v.m_RegDst  ) || (RegDst   === v.RegDst);
    ok &= (!v.m_Jump    ) || (Jump     === v.Jump);
    ok &= (!v.m_Branch  ) || (Branch   === v.Branch);
    ok &= (!v.m_MemRead ) || (MemRead  === v.MemRead);
    ok &= (!v.m_MemtoReg) || (MemtoReg === v.MemtoReg);
    ok &= (!v.m_MemWrite) || (MemWrite === v.MemWrite);
    ok &= (!v.m_ALUSrc  ) || (ALUSrc   === v.ALUSrc);
    ok &= (!v.m_RegWrite) || (RegWrite === v.RegWrite);

    if (v.m_ALUOp != 3'b000) begin
      ok &= (ALUOp === v.ALUOp);
    end

    if (!ok) begin
      $error("FAIL %-10s (opcode 0x%02h): RegDst=%0b Jump=%0b Branch=%0b MemRead=%0b MemtoReg=%0b MemWrite=%0b ALUSrc=%0b RegWrite=%0b ALUOp=%0b",
             v.name, v.op, RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);
      $error("  Expected(masked):            RegDst=%0b Jump=%0b Branch=%0b MemRead=%0b MemtoReg=%0b MemWrite=%0b ALUSrc=%0b RegWrite=%0b ALUOp=%0b",
             v.RegDst, v.Jump, v.Branch, v.MemRead, v.MemtoReg, v.MemWrite, v.ALUSrc, v.RegWrite, v.ALUOp);
    end else begin
      $display("PASS %-10s (opcode 0x%02h)", v.name, v.op);
    end
  endtask

  // ---- Drive & verify ----
  initial begin
    opcode = '0;
    #1;
    foreach (V[i]) begin
      opcode = V[i].op;
      #1; // combinational settle
      check(V[i]);
    end
    $display("=== control_tb DONE ===");
    $finish;
  end

endmodule