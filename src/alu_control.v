module alu_control (
    input      [1:0]      ALUOp,
    input      [2:0]     funct3,
    input      [6:0]     funct7,
    output reg [3:0] alu_control
);

    // === ALU Control Codes ===
    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_SLT  = 4'b0111;
    localparam ALU_XOR  = 4'b1000;
    localparam ALU_SLL  = 4'b1001;
    localparam ALU_SRL  = 4'b1010;
    localparam ALU_SRA  = 4'b1011;
    localparam ALU_SLTU = 4'b1100;
    localparam ALU_INV  = 4'b1111; // Illegal operation

    wire funct7_5 = funct7[5];     // same as instruction[30]

    always @(*) begin

        alu_control = ALU_INV;      // Default to invalid

        if (ALUOp == 2'b10) begin   // R-type
            case (funct3)
                3'b000: alu_control = (funct7_5) ? ALU_SUB : ALU_ADD;
                3'b111: alu_control = ALU_AND;
                3'b110: alu_control = ALU_OR;
                3'b100: alu_control = ALU_XOR;
                3'b001: alu_control = ALU_SLL;
                3'b101: alu_control = (funct7_5) ? ALU_SRA : ALU_SRL;
                3'b010: alu_control = ALU_SLT;
                3'b011: alu_control = ALU_SLTU;
            endcase
        end else if (ALUOp == 2'b01) begin // I-type
            case (funct3)
                3'b000: alu_control = ALU_ADD; // ADDI
                3'b111: alu_control = ALU_AND; // ANDI
                3'b110: alu_control = ALU_OR;  // ORI
                3'b100: alu_control = ALU_XOR; // XORI
                3'b001: alu_control = ALU_SLL; // SLLI
                3'b101: alu_control = (funct7_5) ? ALU_SRA : ALU_SRL; // SRAI / SRLI
                3'b010: alu_control = ALU_SLT; // SLTI
                3'b011: alu_control = ALU_SLTU; // SLTIU
            endcase
        end else if (ALUOp == 2'b00) begin
                alu_control = ALU_ADD;  // for LW, SW, JALR
        end

    end

endmodule
