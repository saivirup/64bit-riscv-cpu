module imm_decoder (
    input      [6:0] opcode,
    output reg [2:0] imm_type
);

    localparam I_TYPE       = 3'b000;
    localparam S_TYPE       = 3'b001;
    localparam B_TYPE       = 3'b010;
    localparam U_TYPE       = 3'b011;
    localparam J_TYPE       = 3'b100;
    localparam INVALID_TYPE = 3'b111;

    always @(*) begin
        case (opcode)
            7'b0000011, // LOAD
            7'b0010011, // OP-IMM
            7'b0001111, // FENCE
            7'b1110011, // SYSTEM
            7'b1100111: imm_type = I_TYPE; // JALR

            7'b0100011: imm_type = S_TYPE; // STORE
            7'b1100011: imm_type = B_TYPE; // BRANCH

            7'b0110111, // LUI
            7'b0010111: imm_type = U_TYPE; // AUIPC

            7'b1101111: imm_type = J_TYPE; // JAL

            default: imm_type = INVALID_TYPE;
        endcase
    end

endmodule
