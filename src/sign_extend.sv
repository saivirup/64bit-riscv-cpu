import rv64_constants_pkg::*;

module sign_extend (
    input logic [HLEN-1:0]  instr,
    input imm_type_e        imm_type,
    output logic [XLEN-1:0] imm_out
);

    always_comb begin

        imm_out = '0;

        unique case (imm_type)
        
            // I-type: imm[11:0] = instr[31:20]
            I_TYPE:  imm_out = {{(XLEN-12){instr[31]}}, instr[31:20]};
                
            // imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            S_TYPE:  imm_out = {{(XLEN-12){instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: imm[12|10:5|4:1|11] = instr[31|30:25|11:8|7], imm[0]=0
            B_TYPE:  imm_out = {{(XLEN-13){instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            // U-type: imm[31:12]=instr[31:12], imm[11:0]=0  (sign-extend bit 31)
            U_TYPE:  imm_out = {{(XLEN-32){instr[31]}}, instr[31:12], 12'b0};

            // J-type: imm[20|10:1|11|19:12] = instr[31|30:21|20|19:12], imm[0]=0
            J_TYPE:  imm_out = {{(XLEN-21){instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            default: /* INVALID_TYPE or unknown */ ;
        endcase
    end

endmodule
