`timescale 1ns/1ps

module ir_cpu_tb;

    reg clk;
    reg rst;

    wire [63:0] pc_out;
    wire [31:0] instruction;
    wire [4:0]  rd;
    wire [63:0] alu_result;
    wire        invalid;

    // Instantiate the CPU
    ir_cpu dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction(instruction),
        .rd(rd),
        .alu_result(alu_result),
        .invalid(invalid)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;

        // Add debug displays at the beginning (Fix #1)
        $display("=== Live Control & Memory Check ===");
        #30;
        $display("MemRead    = %b", dut.MemRead);
        $display("MemtoReg   = %b", dut.MemtoReg);
        $display("alu_result = %d", dut.alu_result);
        $display("mem_data   = %d", dut.mem_data);
        $display("write_back = %d", dut.write_back_data);
        $display("x2         = %d", dut.reg_file_inst.registers[2]);

        // Hold reset for 1 cycle
        #10;
        rst = 0;

        // === R-Type Arithmetic Instructions Test ===
        /*
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
        */

        // === I-Type Arithmetic Instructions Test ===
        /*
        // Wait long enough for all I-type instructions to execute
        #100;

        $display("=== I-Type Register File Dump ===");
        $display("x1  = %d", dut.reg_file_inst.registers[1]);  // ADDI
        $display("x2  = %d", dut.reg_file_inst.registers[2]);  // SLTI
        $display("x3  = %d", dut.reg_file_inst.registers[3]);  // SLTIU
        $display("x4  = %d", dut.reg_file_inst.registers[4]);  // XORI
        $display("x5  = %d", dut.reg_file_inst.registers[5]);  // ORI
        $display("x6  = %d", dut.reg_file_inst.registers[6]);  // ANDI
        $display("x7  = %d", dut.reg_file_inst.registers[7]);  // SLLI
        $display("x8  = %d", dut.reg_file_inst.registers[8]);  // SRLI
        $display("x9  = %d", dut.reg_file_inst.registers[9]);  // SRAI
        */

        // === LW Instruction Test ===
        // Program:
        //   ADDI x1, x0, 16     ; x1 = 16
        //   LW   x2, 0(x1)      ; x2 = Mem[16] = 1234
        /*
        // Wait long enough for ADDI and LW to execute
        #50;

        // Add opcode probing (Fix #3)
        $display("Fetched instruction: %h (opcode: %b)",
            dut.instruction, dut.instruction[6:0]);

        // Add PC output for sanity check (Fix #4)
        $display("PC = %d", dut.pc_out);

        $display("=== LW Register File Check ===");
        $display("x1 = %d", dut.reg_file_inst.registers[1]);  // Expect 16
        $display("x2 = %d", dut.reg_file_inst.registers[2]);  // Expect 1234

        // Optional: Pass/Fail check
        if (dut.reg_file_inst.registers[2] == 64'd1234)
            $display("PASS: x2 = 1234 as expected");
        else
            $display("FAIL: x2 = %d (expected 1234)", dut.reg_file_inst.registers[2]);
        */

        // === JALR Instruction Test ===
        // Instruction: jalr x10, x1, 8
        // Precondition: x1 = 64
        // Expected behavior:
        //   PC jumps to 64 + 8 = 72 (0x48)
        //   x10 receives PC + 4 = 4
        //   Next instruction executed at address 72

        // Wait for reset, fetch, and JALR execute
        #10;  // fetch JALR
        #5;  // execute JALR


        $display("=== JALR Instruction Test ===");
        $display("PC               = %d", dut.pc_out);
        $display("x1 (base addr)   = %d", dut.reg_file_inst.registers[1]);
        $display("x10 (return addr)= %d", dut.reg_file_inst.registers[10]);

        // Sanity checks
        if (dut.pc_out == 64'd72)
            $display("PASS: Jump target reached (PC = 72)");
        else
            $display("FAIL: PC = %d (expected 72)", dut.pc_out);

        if (dut.reg_file_inst.registers[10] == 64'd4)
            $display("PASS: Return address stored in x10");
        else
            $display("FAIL: x10 = %d (expected 4)", dut.reg_file_inst.registers[10]);
        
        $finish;



    end

endmodule