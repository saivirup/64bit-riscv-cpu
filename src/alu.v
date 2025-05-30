module alu (
    input  [63:0] a,
    input  [63:0] b,
    input  [3:0]  alu_control,
    output reg [63:0] ALUresult,
    output reg          invalid
);

    always @(*) begin
        invalid = 1'b0; // default

        case (alu_control)
            4'b0000: ALUresult = a & b;                  // AND
            4'b0001: ALUresult = a | b;                  // OR
            4'b0010: ALUresult = a + b;                  // ADD
            4'b0110: ALUresult = a - b;                  // SUB
            4'b0111: ALUresult = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0; // SLT
            4'b1000: ALUresult = a ^ b;                  // XOR
            4'b1001: ALUresult = a << b[5:0];            // SLL (lower 6 bits only)
            4'b1010: ALUresult = a >> b[5:0];            // SRL
            4'b1011: ALUresult = $signed(a) >>> b[5:0];  // SRA
            4'b1100: ALUresult = (a < b) ? 64'b1 : 64'b0; // SLTU
            default: begin
                ALUresult = 64'b0;
                invalid = 1'b1;
                $display("ALU ERROR: Invalid alu_control value %b at time %t", alu_control, $time);
            end
        endcase
    end

endmodule
