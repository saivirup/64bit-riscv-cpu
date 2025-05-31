module control (
    input  [6:0]     opcode,
    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemRead,
    output reg       MemtoReg,
    output reg       MemWrite,
    output reg [1:0] ALUOp
);

    // === Constants ===
    localparam ALUOP_INVALID = 2'b11;
    localparam ALUOP_RTYPE   = 2'b10;
    localparam ALUOP_ITYPE   = 2'b01;

    localparam OPCODE_RTYPE  = 7'b0110011;
    localparam OPCODE_ITYPE  = 7'b0010011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_STORE  = 7'b0100011; // <--- added


    always @(*) begin
        // Default safe values
        ALUSrc    = 0;
        RegWrite  = 0;
        MemRead   = 0;
        MemWrite  = 0;
        MemtoReg  = 0;
        ALUOp     = ALUOP_INVALID;

        case (opcode)
        
            OPCODE_RTYPE: begin
                RegWrite  = 1;
                ALUSrc    = 0;
                ALUOp     = ALUOP_RTYPE;
            end

            OPCODE_ITYPE: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                ALUOp     = ALUOP_ITYPE;
            end

            OPCODE_LOAD: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                MemRead   = 1;
                MemtoReg  = 1;
                ALUOp     = 2'b00;
            end

            OPCODE_JALR: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                MemRead   = 0;
                MemWrite  = 0;
                MemtoReg  = 0;      // write pc+4 to rd, not memory
                ALUOp     = 2'b00;  // just add
            end

            OPCODE_STORE: begin
                RegWrite  = 0;      // No register write
                ALUSrc    = 1;      // Use immediate offset
                MemRead   = 0;
                MemWrite  = 1;      // Enable memory write
                MemtoReg  = 0;      // Don't care
                ALUOp     = 2'b00;  // Address calc (add)
            end

        endcase
    end

endmodule
