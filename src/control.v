module control (
    input  [6:0]     opcode,
    output reg       RegWrite,
    output reg [1:0] ALUOp
);

always @(*) begin
    // Default values (safe fallback)
    RegWrite  = 0;
    ALUOp     = 2'b00;

    case (opcode)
        7'b0110011: begin // R-type
            RegWrite  = 1;
            ALUOp     = 2'b10;
        end

        default: begin
            // default values already set above
        end
    endcase
end

endmodule
