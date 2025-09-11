import rv64_constants_pkg::*;

module imm_decoder (
    input  opcode_e   opcode,     // strongly typed input (7-bit enum)
    output imm_type_e imm_type    // strongly typed output (3-bit enum)
);

    always_comb begin
        imm_type = INVALID_TYPE;

        unique case (opcode)
            OPCODE_LOAD,                        // LOAD
            OPCODE_ITYPE,                       // OP-IMM
            OPCODE_JALR:   imm_type = I_TYPE;  // JALR

            OPCODE_STORE:  imm_type = S_TYPE;  // STORE

            OPCODE_BRANCH: imm_type = B_TYPE;  // BRANCH

            OPCODE_LUI,                         // LUI
            OPCODE_AUIPC:  imm_type = U_TYPE;  // AUIPC

            OPCODE_JAL:    imm_type = J_TYPE; // JAL
            
        endcase
    end

endmodule
