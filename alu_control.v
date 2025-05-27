module alu_control (
    input [1:0] ALUOp,
    input [2:0] funct3,
    input       funct7_5,
    output reg [3:0] alu_control
);

    always @(*) begin
        alu_control = 4'b0000; // default to AND

        if (ALUOp == 2'b10) begin // R-type
            case (funct3)
                3'b000: alu_control = (funct7_5) ? 4'b0110 : 4'b0010; // SUB or ADD
                3'b111: alu_control = 4'b0000; // AND
                3'b110: alu_control = 4'b0001; // OR
                3'b100: alu_control = 4'b1000; // XOR
                3'b001: alu_control = 4'b1001; // SLL
                3'b101: alu_control = (funct7_5) ? 4'b1011 : 4'b1010; // SRA or SRL
                3'b010: alu_control = 4'b0111; // SLT
                3'b011: alu_control = 4'b1100; // SLTU
            endcase
        end
        else if (ALUOp == 2'b11) begin // I-type ALU
            case (funct3)
                3'b000: alu_control = 4'b0010; // ADDI
                3'b111: alu_control = 4'b0000; // ANDI
                3'b110: alu_control = 4'b0001; // ORI
                3'b100: alu_control = 4'b1000; // XORI
                3'b001: alu_control = 4'b1001; // SLLI
                3'b101: alu_control = (funct7_5) ? 4'b1011 : 4'b1010; // SRAI / SRLI
                3'b010: alu_control = 4'b0111; // SLTI
                3'b011: alu_control = 4'b1100; // SLTIU
            endcase
        end
        else if (ALUOp == 2'b01) begin // Branches
            case (funct3)
                3'b000, // BEQ
                3'b001: alu_control = 4'b0110; // BNE
                3'b100, // BLT
                3'b101: alu_control = 4'b0111; // BGE
                3'b110, // BLTU
                3'b111: alu_control = 4'b1100; // BGEU
            endcase
        end
        else if (ALUOp == 2'b00) begin // Load/Store
            alu_control = 4'b0010; // ADD
        end
    end
endmodule
