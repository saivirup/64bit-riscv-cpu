`timescale 1ns/1ps

module reg_file_tb;

    // Inputs
    reg clk;
    reg wen;
    reg [4:0] rs1, rs2, rd;
    reg [63:0] wd;

    // Outputs
    wire [63:0] rd1, rd2;

    // DUT
    reg_file uut (
        .clk(clk),
        .wen(wen),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    // Test sequence
    initial begin
        $display("Starting Register File Test...");

        // Test 1: Write to x5
        wen = 1; rd = 5; wd = 64'hA5A5A5A5A5A5A5A5;
        @(posedge clk);

        // Test 2: Try writing to x0 (should be ignored)
        rd = 0; wd = 64'hFFFFFFFFFFFFFFFF;
        @(posedge clk);

        // Test 3: Read x5 and x0
        wen = 0; rs1 = 5; rs2 = 0;
        #1;  // tiny delay to allow read logic to propagate

        if (rd1 !== 64'hA5A5A5A5A5A5A5A5) begin
            $fatal("FAILED: Expected x5 = 0xA5A5..., got %h", rd1);
        end
        if (rd2 !== 64'h0) begin
            $fatal("FAILED: Expected x0 = 0, got %h", rd2);
        end

        // Test 4: Write to x6
        wen = 1; rd = 6; wd = 64'h123456789ABCDEF0;
        @(posedge clk);

        // Test 5: Read x6 and x5
        wen = 0; rs1 = 6; rs2 = 5;
        #1;

        if (rd1 !== 64'h123456789ABCDEF0) begin
            $fatal("FAILED: Expected x6 = 0x1234..., got %h", rd1);
        end
        if (rd2 !== 64'hA5A5A5A5A5A5A5A5) begin
            $fatal("FAILED: Expected x5 = 0xA5A5..., got %h", rd2);
        end

        $display("TEST PASSED");
        $finish;
    end

endmodule
