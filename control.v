module control (
    input  [6:0] opcode,
    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemWrite,
    output reg       MemRead,
    output reg       MemtoReg,
    output reg       Branch,
    output reg [1:0] ALUOp
);

always @(*) begin
    // Default values (safe fallback)
    RegWrite  = 0;
    ALUSrc    = 0;
    MemWrite  = 0;
    MemRead   = 0;
    MemtoReg  = 0;
    Branch    = 0;
    ALUOp     = 2'b00;

    case (opcode)
        7'b0000011: begin // Load
            RegWrite  = 1;
            ALUSrc    = 1;
            MemWrite  = 0;
            MemRead   = 1;
            MemtoReg  = 1;
            Branch    = 0;
            ALUOp     = 2'b00;
        end

        7'b0100011: begin // Store
            RegWrite  = 0;
            ALUSrc    = 1;
            MemWrite  = 1;
            MemRead   = 0;
            MemtoReg  = 0; // doesn't matter
            Branch    = 0;
            ALUOp     = 2'b00;
        end

        7'b0110011: begin // R-type
            RegWrite  = 1;
            ALUSrc    = 0;
            MemWrite  = 0;
            MemRead   = 0;
            MemtoReg  = 0;
            Branch    = 0;
            ALUOp     = 2'b10;
        end

        7'b0010011: begin // I-type (addi, andi, ori, etc)
            RegWrite  = 1;
            ALUSrc    = 1;
            MemWrite  = 0;
            MemRead   = 0;
            MemtoReg  = 0;
            Branch    = 0;
            ALUOp     = 2'b11;
        end

        7'b1100011: begin // Branch
            RegWrite  = 0;
            ALUSrc    = 0;
            MemWrite  = 0;
            MemRead   = 0;
            MemtoReg  = 0; // doesn't matter
            Branch    = 1;
            ALUOp     = 2'b01;
        end

        default: begin
            // default values already set above
        end
    endcase
end

endmodule
