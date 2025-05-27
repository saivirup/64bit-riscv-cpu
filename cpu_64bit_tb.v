`timescale 1ns/1ps

module cpu_64bit_tb;

    reg clk;
    reg rst;
    wire [63:0] pc_out;
    wire [31:0] instruction_out;
    wire [63:0] alu_result_out;

    // Instantiate the DUT (Device Under Test)
    cpu_64bit dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .alu_result_out(alu_result_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer cycle;

    initial begin
        rst = 1;
        #10 rst = 0;
        cycle = 0;
    end

    always @(posedge clk) begin
        cycle = cycle + 1;

        case (cycle)
            3: if (dut.register_file.registers[3] !== 64'd8)
                $display("[FAIL @cycle %0d] add x3 = %0d (expected 8)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] add x3 = %0d", cycle, dut.register_file.registers[3]);

            4: if (dut.register_file.registers[3] !== -2)
                $display("[FAIL @cycle %0d] sub x3 = %0d (expected -2)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] sub x3 = %0d", cycle, dut.register_file.registers[3]);

            5: if (dut.register_file.registers[3] !== 64'd6)
                $display("[FAIL @cycle %0d] xor x3 = %0d (expected 6)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] xor x3 = %0d", cycle, dut.register_file.registers[3]);

            6: if (dut.register_file.registers[3] !== 64'd7)
                $display("[FAIL @cycle %0d] or  x3 = %0d (expected 7)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] or  x3 = %0d", cycle, dut.register_file.registers[3]);

            7: if (dut.register_file.registers[3] !== 64'd1)
                $display("[FAIL @cycle %0d] and x3 = %0d (expected 1)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] and x3 = %0d", cycle, dut.register_file.registers[3]);

            8: if (dut.register_file.registers[3] !== 64'd96)
                $display("[FAIL @cycle %0d] sll x3 = %0d (expected 96)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] sll x3 = %0d", cycle, dut.register_file.registers[3]);

            9: if (dut.register_file.registers[3] !== 64'd0)
                $display("[FAIL @cycle %0d] srl x3 = %0d (expected 0)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] srl x3 = %0d", cycle, dut.register_file.registers[3]);

            10: if (dut.register_file.registers[3] !== 64'd0)
                $display("[FAIL @cycle %0d] sra x3 = %0d (expected 0)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] sra x3 = %0d", cycle, dut.register_file.registers[3]);

            11: if (dut.register_file.registers[3] !== 64'd1)
                $display("[FAIL @cycle %0d] slt x3 = %0d (expected 1)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] slt x3 = %0d", cycle, dut.register_file.registers[3]);

            12: if (dut.register_file.registers[3] !== 64'd1)
                $display("[FAIL @cycle %0d] sltu x3 = %0d (expected 1)", cycle, dut.register_file.registers[3]);
            else $display("[PASS @cycle %0d] sltu x3 = %0d", cycle, dut.register_file.registers[3]);

            13: if (dut.register_file.registers[1] !== 64'd5)
                $display("[FAIL @cycle %0d] addi x1 = %0d (expected 5)", cycle, dut.register_file.registers[1]);
            else $display("[PASS @cycle %0d] addi x1 = %0d", cycle, dut.register_file.registers[1]);

            14: if (dut.register_file.registers[1] !== 64'd7)
                $display("[FAIL @cycle %0d] xori x1 = %0d (expected 7)", cycle, dut.register_file.registers[1]);
            else $display("[PASS @cycle %0d] xori x1 = %0d", cycle, dut.register_file.registers[1]);

            15: if (dut.register_file.registers[1] !== 64'd7)
                $display("[FAIL @cycle %0d] ori  x1 = %0d (expected 7)", cycle, dut.register_file.registers[1]);
            else $display("[PASS @cycle %0d] ori  x1 = %0d", cycle, dut.register_file.registers[1]);

            16: if (dut.register_file.registers[1] !== 64'd2)
                $display("[FAIL @cycle %0d] andi x1 = %0d (expected 2)", cycle, dut.register_file.registers[1]);
            else $display("[PASS @cycle %0d] andi x1 = %0d", cycle, dut.register_file.registers[1]);

            17: if (dut.register_file.registers[2] !== 64'd8)
                $display("[FAIL @cycle %0d] slli x2 = %0d (expected 8)", cycle, dut.register_file.registers[2]);
            else $display("[PASS @cycle %0d] slli x2 = %0d", cycle, dut.register_file.registers[2]);

            18: if (dut.register_file.registers[2] !== 64'd2)
                $display("[FAIL @cycle %0d] srli x2 = %0d (expected 2)", cycle, dut.register_file.registers[2]);
            else $display("[PASS @cycle %0d] srli x2 = %0d", cycle, dut.register_file.registers[2]);

            19: if (dut.register_file.registers[2] !== 64'd2)
                $display("[FAIL @cycle %0d] srai x2 = %0d (expected 2)", cycle, dut.register_file.registers[2]);
            else $display("[PASS @cycle %0d] srai x2 = %0d", cycle, dut.register_file.registers[2]);

            20: if (dut.register_file.registers[2] !== 64'd0)
                $display("[FAIL @cycle %0d] slti x2 = %0d (expected 0)", cycle, dut.register_file.registers[2]);
            else $display("[PASS @cycle %0d] slti x2 = %0d", cycle, dut.register_file.registers[2]);

            21: if (dut.register_file.registers[2] !== 64'd0)
                $display("[FAIL @cycle %0d] sltiu x2 = %0d (expected 0)", cycle, dut.register_file.registers[2]);
            else $display("[PASS @cycle %0d] sltiu x2 = %0d", cycle, dut.register_file.registers[2]);

            22: begin
                $display("\n[TESTBENCH] All instruction checks completed.");
                $finish;
            end
        endcase
    end

endmodule
