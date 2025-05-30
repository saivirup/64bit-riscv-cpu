module control (
    input  [6:0] opcode,
    output reg       RegWrite,
    output reg [1:0] ALUOp
);

    // === Constants ===
    localparam ALUOP_INVALID = 2'b11;
    localparam ALUOP_RTYPE   = 2'b10;
    localparam OPCODE_RTYPE  = 7'b0110011;

    always @(*) begin
        // Default values (safe fallback)
        RegWrite  = 0;
        ALUOp     = ALUOP_INVALID;

        case (opcode)
            OPCODE_RTYPE: begin
                RegWrite  = 1;
                ALUOp     = ALUOP_RTYPE;
            end

            default: begin
                // Already set to safe fallback
            end
        endcase
    end

endmodule
