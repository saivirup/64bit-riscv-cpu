`timescale 1ns / 1ps

module r_cpu_tb;

    // === Clock and Reset ===
    reg clk;
    reg rst;

    // === Instantiate DUT ===
    r_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    // === Clock Generation (10ns period) ===
    always #5 clk = ~clk;

    // === Initialize Inputs and Stimulus ===
    initial begin
        // Initialize
        clk = 0;
        rst = 1;

        // Hold reset for a few cycles
        #10;
        rst = 0;

        // Run long enough for all instructions to execute
        #200;

        // Dump register values
        $display("==== Register File Output ====");
        $display("x1  = %d", dut.reg_file_inst.registers[1]);
        $display("x4  = %d", dut.reg_file_inst.registers[4]);
        $display("x7  = %d", dut.reg_file_inst.registers[7]);
        $display("x10 = %d", dut.reg_file_inst.registers[10]);
        $display("x13 = %d", dut.reg_file_inst.registers[13]);
        $display("x16 = %d", dut.reg_file_inst.registers[16]);
        $display("x19 = %d", dut.reg_file_inst.registers[19]);
        $display("x22 = %d", dut.reg_file_inst.registers[22]);
        $display("x25 = %d", dut.reg_file_inst.registers[25]);
        $display("x28 = %d", dut.reg_file_inst.registers[28]);

        $finish;
    end

    // === Monitor trace info ===
    initial begin
        $monitor("T=%0t | PC=%h | Instr=%h | rd=%0d | ALU=%h | Invalid=%b",
            $time,
            dut.pc_out,
            dut.instruction,
            dut.rd,
            dut.alu_result,
            dut.invalid
        );
    end

endmodule