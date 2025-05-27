`timescale 1ns/1ps

module data_mem_tb;

    // Inputs
    reg clk;
    reg MemRead;
    reg MemWrite;
    reg [63:0] address;
    reg [63:0] write_data;

    // Output
    wire [63:0] read_data;

    // Instantiate the data_mem module
    data_mem uut (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    initial begin
        $display("Starting Data Memory Test...");

        // Phase 1: Write 0x12345678ABCDEF00 to address 0x08
        MemWrite = 1;
        MemRead = 0;
        address = 64'h08;
        write_data = 64'h12345678ABCDEF00;
        @(posedge clk);

        // Phase 2: Try to read from the same address
        MemWrite = 0;
        MemRead = 1;
        @(posedge clk); #1;

        if (read_data !== 64'h12345678ABCDEF00) begin
            $fatal("FAILED: Expected read_data = 0x12345678ABCDEF00, got %h", read_data);
        end

        // Phase 3: Try to read with MemRead = 0
        MemRead = 0;
        #1;

        if (read_data !== 64'b0) begin
            $fatal("FAILED: Expected read_data = 0 when MemRead=0, got %h", read_data);
        end

        // Phase 4: Try writing to new address, then read it back
        MemWrite = 1;
        address = 64'h10;
        write_data = 64'hCAFEBABEDEADBEEF;
        @(posedge clk);

        MemWrite = 0;
        MemRead = 1;
        @(posedge clk); #1;

        if (read_data !== 64'hCAFEBABEDEADBEEF) begin
            $fatal("FAILED: Expected read_data = 0xCAFEBABEDEADBEEF, got %h", read_data);
        end

        $display("TEST PASSED");
        $finish;
    end

endmodule
