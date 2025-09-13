`timescale 1ns/1ps

module tb_adder_64bit;

    // Testbench signals
    reg  [63:0] a, b;
    wire [63:0] sum;

    // Instantiate the DUT (Device Under Test)
    adder_64bit dut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        // Display header
        $display("Time\t\ta\t\t\tb\t\t\tsum");
        $display("---------------------------------------------------------------");

        // Test 1
        a = 64'd10; b = 64'd5;
        #10 $display("%0t\t%0d\t%0d\t%0d", $time, a, b, sum);

        // Test 2
        a = 64'd123456789; b = 64'd987654321;
        #10 $display("%0t\t%0d\t%0d\t%0d", $time, a, b, sum);

        // Test 3 (edge case)
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1; // overflow wraps around
        #10 $display("%0t\t%0h\t%0d\t%0h", $time, a, b, sum);

        // Test 4 (random values)
        a = $random; b = $random;
        #10 $display("%0t\t%0d\t%0d\t%0d", $time, a, b, sum);

        $finish;
    end

endmodule

