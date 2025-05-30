module alu (
    input  [63:0] a,               // First ALU operand (usually rs1)
    input  [63:0] b,               // Second ALU operand (usually rs2 or immediate)
    input  [3:0]  alu_control,     // ALU operation selector from alu_control.v
    output reg        invalid_op,  // <-- NEW: goes high if alu_control is invalid
    output reg [63:0] ALUresult    // Final result of the selected ALU operation
);

    // === ALU Operation Codes ===
    localparam ALU_AND  = 4'b0000; // Logical AND
    localparam ALU_OR   = 4'b0001; // Logical OR
    localparam ALU_ADD  = 4'b0010; // Addition
    localparam ALU_SUB  = 4'b0110; // Subtraction
    localparam ALU_SLT  = 4'b0111; // Set on Less Than (signed)
    localparam ALU_XOR  = 4'b1000; // Logical XOR
    localparam ALU_SLL  = 4'b1001; // Shift Left Logical
    localparam ALU_SRL  = 4'b1010; // Shift Right Logical
    localparam ALU_SRA  = 4'b1011; // Shift Right Arithmetic (preserves sign)
    localparam ALU_SLTU = 4'b1100; // Set on Less Than Unsigned
    localparam ALU_INV  = 4'b1111; // Illegal or unrecognized operation


    always @(*) begin
        invalid_op = 1'b0;

        case (alu_control)
            ALU_AND:  ALUresult = a & b;
            ALU_OR:   ALUresult = a | b;
            ALU_ADD:  ALUresult = a + b;
            ALU_SUB:  ALUresult = a - b;
            ALU_SLT:  ALUresult = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0;
            ALU_XOR:  ALUresult = a ^ b;
            ALU_SLL:  ALUresult = a << b[5:0];
            ALU_SRL:  ALUresult = a >> b[5:0];
            ALU_SRA:  ALUresult = $signed(a) >>> b[5:0];
            ALU_SLTU: ALUresult = (a < b) ? 64'b1 : 64'b0;
            default:  begin
                ALUresult = 64'b0;
                invalid_op = 1'b1;  // Raise flag for unsupported operation
            end
        endcase
    end

endmodule
