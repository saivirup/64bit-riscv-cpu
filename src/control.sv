// control.sv
import rv64_constants_pkg::*;

module control (
    input  logic [6:0]  opcode,
    output logic        RegDst,
    output logic        Jump,
    output logic        Branch,
    output logic        MemRead,
    output logic        MemtoReg,
    output logic [2:0]  ALUOp,
    output logic        MemWrite,
    output logic        ALUSrc,
    output logic        RegWrite
);

    always_comb begin
        // ---- Default safe values ----
        RegDst    = 1'b0;
        Jump      = 1'b0;
        Branch    = 1'b0;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        MemRead   = 1'b0;
        MemWrite  = 1'b0;
        MemtoReg  = 1'b0;
        ALUOp     = ALUOP_INVALID;

        // ---- Decode ----
        unique case (opcode)

            OPCODE_RTYPE: begin
                RegDst    = 1'b1;
                ALUSrc    = 1'b0;
                RegWrite  = 1'b1;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                MemtoReg  = 1'b0;
                Branch    = 1'b0;
                Jump      = 1'b0;
                ALUOp     = ALUOP_RTYPE;
            end

            OPCODE_ITYPE: begin
                RegDst    = 1'b0;
                ALUSrc    = 1'b1;
                RegWrite  = 1'b1;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                MemtoReg  = 1'b0;
                Branch    = 1'b0;
                Jump      = 1'b0;
                ALUOp     = ALUOP_ITYPE;
            end

            OPCODE_LOAD: begin
                RegDst    = 1'b0;
                ALUSrc    = 1'b1;
                RegWrite  = 1'b1;
                MemRead   = 1'b1;
                MemWrite  = 1'b0;
                MemtoReg  = 1'b1;   // write loaded data to rd
                Branch    = 1'b0;
                Jump      = 1'b0;
                ALUOp     = ALUOP_LS_JAL_R; // address calc
            end

            OPCODE_STORE: begin
                RegDst    = 1'b0;
                ALUSrc    = 1'b1;
                RegWrite  = 1'b0;   // no rd write
                MemRead   = 1'b0;
                MemWrite  = 1'b1;   // do store
                MemtoReg  = 1'b0;   // don't care
                Branch    = 1'b0;
                Jump      = 1'b0;
                ALUOp     = ALUOP_LS_JAL_R; // address calc
            end

            OPCODE_BRANCH: begin
                RegDst    = 1'b0;
                ALUSrc    = 1'b0;
                RegWrite  = 1'b0;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                MemtoReg  = 1'b0;
                Branch    = 1'b1;
                Jump      = 1'b0;
                ALUOp     = ALUOP_BTYPE;
            end

            OPCODE_JAL: begin
                RegDst    = 1'b0;
                ALUSrc    = 1'b1;   // feed PC+imm path as needed
                RegWrite  = 1'b1;   // rd <- PC+4
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                MemtoReg  = 1'b0;   // select PC+4, not memory
                Branch    = 1'b0;
                Jump      = 1'b1;
                ALUOp     = ALUOP_LS_JAL_R; // add for target calc
            end

            OPCODE_JALR: begin
                RegDst    = 1'b0;
                ALUSrc    = 1'b1;   // base rs1 + imm
                RegWrite  = 1'b1;   // rd <- PC+4
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                MemtoReg  = 1'b0;   // select PC+4
                Branch    = 1'b0;
                Jump      = 1'b1;
                ALUOp     = ALUOP_LS_JAL_R; // add for target calc
            end

            // Optional: if your pkg defines LUI/AUIPC opcodes, you can add cases and still map ALUOp to ADD

            default: begin
                // keep defaults + ALUOP_INVALID
            end
        endcase
    end
endmodule