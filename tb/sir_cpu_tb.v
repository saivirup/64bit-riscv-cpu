`timescale 1ns/1ps

module sir_cpu_tb;

    reg clk;
    reg rst;

    wire [63:0] pc_out;
    wire [31:0] instruction;
    wire [4:0]  rd;
    wire [63:0] alu_result;
    wire        invalid;

    // Instantiate the DUT
    sir_cpu dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction(instruction),
        .rd(rd),
        .alu_result(alu_result),
        .invalid(invalid)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        $display("=== Starting SIR CPU SW Test ===");

        clk = 0;
        rst = 1;
        #10;
        rst = 0;

        // Run long enough to execute all instructions
        #100;

        // === Check memory value ===
        $display("x3 = %d (Expected: 1234)", dut.reg_file_inst.registers[3]);
        if (dut.reg_file_inst.registers[3] === 64'd1234) begin
            $display("LW Test PASSED");
        end else begin
            $display("LW Test FAILED");
        end

        $display("Mem[1] = %d", dut.data_mem_inst.memory[1]);

        $finish;
    end

    initial begin
        #1000;
        $fatal("Timeout: simulation took too long");
    end

endmodule
