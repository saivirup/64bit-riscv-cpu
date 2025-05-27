`timescale 1ns/1ps

module aluCore_tb;

    // Inputs
    reg funct7_5;
    reg [63:0] a, b;
    reg [2:0] funct3;
    reg [6:0] opcode;

    // Outputs
    wire [63:0] ALUresult;
    wire        zero;

    // Instantiate the DUT
    aluCore uut (
        .funct7_5(funct7_5),
        .a(a),
        .b(b),
        .funct3(funct3),
        .opcode(opcode),
        .zero(zero),
        .ALUresult(ALUresult)
    );

    // Waveform dumping
    initial begin
        $dumpfile("aluCore_tb.vcd");
        $dumpvars(0, aluCore_tb);
    end

    // Self-checking task
    task test;
        input [6:0] op;
        input [2:0] f3;
        input       f7_5;
        input [63:0] val_a, val_b;
        input [63:0] expected;
        begin
            opcode    = op;
            funct3    = f3;
            funct7_5  = f7_5;
            a         = val_a;
            b         = val_b;
            #5;
            if (ALUresult !== expected)
                $display("[FAIL] opcode=%b funct3=%b funct7_5=%b a=%0d b=%0d → ALUresult=%0d (expected %0d)", op, f3, f7_5, val_a, val_b, ALUresult, expected);
            else
                $display("[PASS] opcode=%b funct3=%b funct7_5=%b a=%0d b=%0d → ALUresult=%0d", op, f3, f7_5, val_a, val_b, ALUresult);
        end
    endtask

    initial begin
        // Test ADD (R-type): opcode 0110011, funct3 000, funct7_5 0
        test(7'b0110011, 3'b000, 1'b0, 10, 5, 15);

        // Test SUB (R-type): opcode 0110011, funct3 000, funct7_5 1
        test(7'b0110011, 3'b000, 1'b1, 10, 5, 5);

        // Test AND (R-type): funct3 111
        test(7'b0110011, 3'b111, 1'b0, 64'hFF00, 64'h0F0F, 64'h0F00);

        // Test ORI (I-type): opcode 0010011, funct3 110
        test(7'b0010011, 3'b110, 1'b0, 64'hA5A5, 64'h5A5A, 64'hFFFF);

        // Test SLT (R-type): opcode 0110011, funct3 010
        test(7'b0110011, 3'b010, 1'b0, -1, 5, 1);

        // Test XORI (I-type): opcode 0010011, funct3 100
        test(7'b0010011, 3'b100, 1'b0, 64'hAAAA, 64'h5555, 64'hFFFF);

        $finish;
    end

endmodule
