module imm_type_decoder (
    input  [6:0] opcode,
    output reg [2:0] imm_type
);
    always @(*) begin
        case (opcode)
            7'b0000011, // lw
            7'b0010011: // addi
                imm_type = 3'b000; // I-type
            7'b0100011: // sw
                imm_type = 3'b001; // S-type
            7'b1100011: // beq
                imm_type = 3'b010; // SB-type
            7'b0110111: // lui
                imm_type = 3'b011; // U-type
            7'b1101111: // jal
                imm_type = 3'b100; // UJ-type
            default:
                imm_type = 3'b000;
        endcase
    end
endmodule
