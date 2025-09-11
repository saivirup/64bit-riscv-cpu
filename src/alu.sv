import rv64_constants_pkg::*;

module alu (
    input  logic [XLEN-1:0] a,
    input  logic [XLEN-1:0] b,
    input  alu_ctrl_e       alu_control,
    output logic            invalid_op,
    output logic [XLEN-1:0] ALUresult,
    output logic            Zero
);

    localparam int SHAMT_BITS = $clog2(XLEN);

    always_comb begin
        invalid_op = 1'b0;
        ALUresult  = '0;

        unique case (alu_control)
            ALU_AND:   ALUresult = a & b;
            ALU_OR:    ALUresult = a | b;
            ALU_ADD:   ALUresult = a + b;
            ALU_SUB:   ALUresult = a - b; // BEQ/BNE use this
            ALU_SLT:   ALUresult = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0;
            ALU_SGE:   ALUresult = ($signed(a) >= $signed(b)) ? 64'b1 : 64'b0;
            ALU_SLTU:  ALUresult = (a < b) ? 64'b1 : 64'b0;
            ALU_SGEU:  ALUresult = (a >= b) ? 64'b1 : 64'b0;
            ALU_XOR:   ALUresult = a ^ b;
            ALU_SLL:   ALUresult = a << b[5:0];
            ALU_SRL:   ALUresult = a >> b[5:0];
            ALU_SRA:   ALUresult = $signed(a) >>> b[5:0];

            ALU_INV: begin
                invalid_op = 1'b1;
                ALUresult  = 64'b0;
            end

            default: begin
                invalid_op = 1'b1;
                ALUresult  = 64'b0;
            end
        endcase

        // Zero is used for BEQ/BNE branch decisions
        Zero = (ALUresult == 64'b0);
    end
endmodule
