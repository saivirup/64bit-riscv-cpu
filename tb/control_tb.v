`timescale 1ns / 1ps

module control_tb;

    // Inputs
    reg [6:0] opcode;

    // Outputs
    wire [1:0] ALUOp;

    // Instantiate the Unit Under Test (UUT)
    control uut (
        .opcode(opcode),
        .ALUOp(ALUOp)
    );

    initial begin
        $display("Time\tOpcode\t\tALUOp");
        $monitor("%0t\t%b\t%b", $time, opcode, ALUOp);

        // Test load (opcode = 0000011)
        opcode = 7'b0000011;
        #10;

        // Test store (opcode = 0100011)
        opcode = 7'b0100011;
        #10;

        // Test JALR (opcode = 1100111)
        opcode = 7'b1100111;
        #10;

        // Test AUIPC (opcode = 0010111)
        opcode = 7'b0010111;
        #10;

        // Test branch (opcode = 1100011)
        opcode = 7'b1100011;
        #10;

        // Test R-type (opcode = 0110011)
        opcode = 7'b0110011;
        #10;

        // Test I-type ALU (opcode = 0010011)
        opcode = 7'b0010011;
        #10;

        // Test default/fallback
        opcode = 7'b1111111;
        #10;

        $finish;
    end

endmodule
