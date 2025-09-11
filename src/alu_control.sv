import rv64_constants_pkg::*;

module alu_control (
    // Keep ALUOp as a 3-bit value (your package already defines the enum literals).
    // If you *also* have a typedef for it (e.g., alu_op_e), feel free to change the type here.
    input  logic [2:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    // Strongly type the output using your package enum for better lint/coverage
    output alu_ctrl_e  alu_control
);

    // instr[30] a.k.a. funct7 bit 5
    logic funct7_5;
    assign funct7_5 = funct7[5];

    always_comb begin
        // Defensive default — ensures no latches + clear failure mode
        alu_control = ALU_INV;

        // unique helps flag overlapping/unknown encodings in sim
        unique case (ALUOp)

            // R-Type
            ALUOP_RTYPE: begin
                unique case (funct3)
                    3'b000: alu_control  = (funct7_5) ? ALU_SUB  : ALU_ADD; // ADD/SUB
                    3'b111: alu_control  = ALU_AND;
                    3'b110: alu_control  = ALU_OR;
                    3'b100: alu_control  = ALU_XOR;
                    3'b001: alu_control  = ALU_SLL;
                    3'b101: alu_control  = (funct7_5) ? ALU_SRA  : ALU_SRL; // SRL/SRA
                    3'b010: alu_control  = ALU_SLT;
                    3'b011: alu_control  = ALU_SLTU;
                    default: alu_control = ALU_INV;
                endcase
            end

            // I-Type (ADDI/ANDI/ORI/XORI/SLLI/SRLI/SRAI/SLTI/SLTIU)
            ALUOP_ITYPE: begin
                unique case (funct3)
                    3'b000: alu_control  = ALU_ADD;
                    3'b111: alu_control  = ALU_AND;
                    3'b110: alu_control  = ALU_OR;
                    3'b100: alu_control  = ALU_XOR;
                    3'b001: alu_control  = ALU_SLL;                      // SLLI
                    3'b101: alu_control  = (funct7_5) ? ALU_SRA : ALU_SRL; // SRAI/SRLI (instr[30])
                    3'b010: alu_control  = ALU_SLT;
                    3'b011: alu_control  = ALU_SLTU;
                    default: alu_control = ALU_INV;
                endcase
            end

            // Load/Store/JAL/JALR address calc — A+B with A=base(PC/rs1), B=imm
            ALUOP_LS_JAL_R: begin
                alu_control = ALU_ADD;
            end

            // LUI / AUIPC — both can be implemented as ADD with appropriate operands
            ALUOP_LUI:   begin
                // LUI: rd = imm << 12  (datapath typically feeds A=0, B=imm)
                alu_control = ALU_ADD;
            end
            ALUOP_AUIPC: begin
                // AUIPC: rd = PC + imm (A=PC, B=imm)
                alu_control = ALU_ADD;
            end

            // Branch class — ALU produces comparison predicate as 0/1 in result
            ALUOP_BTYPE: begin
                unique case (funct3)
                    3'b000: alu_control  = ALU_SUB;   // BEQ    -> zero test on (a-b)
                    3'b001: alu_control  = ALU_SUB;   // BNE    -> nonzero test on (a-b)
                    3'b100: alu_control  = ALU_SLT;   // BLT
                    3'b101: alu_control  = ALU_SGE;   // BGE
                    3'b110: alu_control  = ALU_SLTU;  // BLTU
                    3'b111: alu_control  = ALU_SGEU;  // BGEU
                    default: alu_control = ALU_INV;
                endcase
            end

            default: begin
                alu_control = ALU_INV;
            end
        endcase
    end

endmodule
