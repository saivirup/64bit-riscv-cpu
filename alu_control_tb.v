`timescale 1ns/1ps

module alu_control_tb;

    // Inputs
    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg       funct7_5;

    // Output
    wire [3:0] alu_control;

    // Instantiate the Unit Under Test (UUT)
    alu_control uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_control(alu_control)
    );

    // Waveform dump (for ModelSim or GTKWave via VCD)
    initial begin
        $dumpfile("alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);
    end

    // Self-checking task
    task test;
        input [1:0] op;
        input [2:0] f3;
        input       f7;
        input [3:0] expected;

        begin
            ALUOp    = op;
            funct3   = f3;
            funct7_5 = f7;
            #5; // Allow time for signals to propagate

            if (alu_control !== expected)
                $display("[FAIL] ALUOp=%b funct3=%b funct7_5=%b => alu_control=%b (expected %b)", op, f3, f7, alu_control, expected);
            else
                $display("[PASS] ALUOp=%b funct3=%b funct7_5=%b => alu_control=%b", op, f3, f7, alu_control);
        end
    endtask

    // Run tests
    initial begin
        // R-type tests
        test(2'b10, 3'b000, 1'b0, 4'b0010); // ADD
        test(2'b10, 3'b000, 1'b1, 4'b0110); // SUB
        test(2'b10, 3'b111, 1'b0, 4'b0000); // AND
        test(2'b10, 3'b110, 1'b0, 4'b0001); // OR
        test(2'b10, 3'b100, 1'b0, 4'b1000); // XOR
        test(2'b10, 3'b001, 1'b0, 4'b1001); // SLL
        test(2'b10, 3'b101, 1'b0, 4'b1010); // SRL
        test(2'b10, 3'b101, 1'b1, 4'b1011); // SRA
        test(2'b10, 3'b010, 1'b0, 4'b0111); // SLT
        test(2'b10, 3'b011, 1'b0, 4'b1100); // SLTU

        // I-type tests
        test(2'b11, 3'b000, 1'b0, 4'b0010); // ADDI
        test(2'b11, 3'b111, 1'b0, 4'b0000); // ANDI
        test(2'b11, 3'b110, 1'b0, 4'b0001); // ORI
        test(2'b11, 3'b100, 1'b0, 4'b1000); // XORI
        test(2'b11, 3'b001, 1'b0, 4'b1001); // SLLI
        test(2'b11, 3'b101, 1'b0, 4'b1010); // SRLI
        test(2'b11, 3'b101, 1'b1, 4'b1011); // SRAI
        test(2'b11, 3'b010, 1'b0, 4'b0111); // SLTI
        test(2'b11, 3'b011, 1'b0, 4'b1100); // SLTIU

        // Branching tests
        test(2'b01, 3'b000, 1'b0, 4'b0110); // BEQ
        test(2'b01, 3'b001, 1'b0, 4'b0110); // BNE
        test(2'b01, 3'b100, 1'b0, 4'b0111); // BLT
        test(2'b01, 3'b101, 1'b0, 4'b0111); // BGE
        test(2'b01, 3'b110, 1'b0, 4'b1100); // BLTU
        test(2'b01, 3'b111, 1'b0, 4'b1100); // BGEU

        // Load/Store test
        test(2'b00, 3'b000, 1'b0, 4'b0010); // LW/SW → ADD

        $finish;
    end

endmodule
