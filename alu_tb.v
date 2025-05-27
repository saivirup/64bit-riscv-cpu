`timescale 1ns/1ps

module alu_tb;

    // Inputs
    reg  [63:0] a, b;
    reg  [3:0]  alu_control;

    // Outputs
    wire        zero;
    wire [63:0] ALUresult;

    // Instantiate the Unit Under Test (UUT)
    alu uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .zero(zero),
        .ALUresult(ALUresult)
    );

    // Waveform dump
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

    // Self-checking task
    task test;
        input [63:0] in_a, in_b;
        input [3:0]  ctrl;
        input [63:0] expected;
        begin
            a = in_a;
            b = in_b;
            alu_control = ctrl;
            #5;
            if (ALUresult !== expected)
                $display("[FAIL] ctrl=%b a=%0d b=%0d → result=%0d (expected %0d)", ctrl, in_a, in_b, ALUresult, expected);
            else
                $display("[PASS] ctrl=%b a=%0d b=%0d → result=%0d", ctrl, in_a, in_b, ALUresult);
        end
    endtask

    // Run tests
    initial begin
        // AND
        test(64'hFF00FF00FF00FF00, 64'h0F0F0F0F0F0F0F0F, 4'b0000, 64'h0F000F000F000F00);

        // OR
        test(64'hFF00FF00FF00FF00, 64'h0F0F0F0F0F0F0F0F, 4'b0001, 64'hFF0FFF0FFF0FFF0F);

        // ADD
        test(64'd10, 64'd5, 4'b0010, 64'd15);

        // SUB
        test(64'd10, 64'd5, 4'b0110, 64'd5);

        // SLT (signed)
        test(-5, 1, 4'b0111, 1);     // true
        test(5, -1, 4'b0111, 0);     // false

        // XOR
        test(64'hF0F0F0F0F0F0F0F0, 64'h0F0F0F0F0F0F0F0F, 4'b1000, 64'hFFFFFFFFFFFFFFFF);

        // SLL (logical left shift)
        test(64'd1, 64'd4, 4'b1001, 64'd16);  // 1 << 4 = 16

        // SRL (logical right shift)
        test(64'd16, 64'd2, 4'b1010, 64'd4);  // 16 >> 2 = 4

        // SRA (arithmetic right shift)
        test(-8, 64'd1, 4'b1011, -4); // -8 >>> 1 = -4

        // SLTU (unsigned comparison)
        test(64'd5, 64'd10, 4'b1100, 64'd1);
        test(64'd15, 64'd10, 4'b1100, 64'd0);

        // Zero flag test
        test(64'd5, 64'd5, 4'b0110, 64'd0); // SUB → zero flag should be 1

        $finish;
    end

endmodule
