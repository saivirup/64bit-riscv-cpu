`timescale 1ns/1ps
import rv64_constants_pkg::*; // pulls in XLEN definition

module adder_64bit_tb;

    // DUT inputs and outputs
    logic [XLEN-1:0] a, b;
    logic [XLEN-1:0] sum;

    // Instantiate DUT
    adder_64bit dut (
        .a   (a),
        .b   (b),
        .sum (sum)
    );

    // Simple stimulus
    initial begin
        // Case 1: add small numbers
        a = 64'd5;  b = 64'd10;  #5;
        $display("a=%0d b=%0d sum=%0d", a, b, sum);

        // Case 2: add large numbers
        a = 64'hFFFFFFFFFFFFFFF0; b = 64'd20; #5;
        $display("a=%h b=%h sum=%h", a, b, sum);

        // Case 3: add zero
        a = 64'd0; b = 64'd12345; #5;
        $display("a=%0d b=%0d sum=%0d", a, b, sum);

        // Case 4: negative numbers (2's complement)
        a = -64'd7; b = 64'd3; #5;
        $display("a=%0d b=%0d sum=%0d", a, b, sum);

        // Case 5: overflow check
        a = 64'h7FFF_FFFF_FFFF_FFFF;
        b = 64'd1; #5;
        $display("a=%0d b=%0d sum=%0d", a, b, sum);

        $finish;
    end

endmodule
