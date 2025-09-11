`timescale 1ns/1ps
import rv64_constants_pkg::*;

module mux2to1_5bit_tb;

  logic [4:0] in0, in1, out;
  logic sel;

  mux2to1_5bit dut (
    .in0(in0),
    .in1(in1),
    .sel(sel),
    .out(out)
  );

  initial begin

    $display("=== 5 Bit 2:1 Mux Test ===");
    
    in0 = 5'b00110; in1 = 5'b00101; sel = 0; #5;
    $display("in0=%0b in1=%0b sel=%0b -> out=%0b (expected 00110)", in0, in1, sel, out);
    if (out !== (in0)) $error("Mismatch for in0 = 5'b00110, in1 = 5'b00101, sel = 0");

    in0 = 5'b11111; in1 = 5'b00000; sel = 0; #5;
    $display("in0=%0b in1=%0b sel=%0b -> out=%0b (expected 11111)", in0, in1, sel, out);
    if (out !== (in0)) $error("Mismatch for in0 = 5'b11111, in1 = 5'b00000, sel = 0");

    in0 = 5'b11111; in1 = 5'b00000; sel = 1; #5;
    $display("in0=%0b in1=%0b sel=%0b -> out=%0b (expected 00000)", in0, in1, sel, out);
    if (out !== (in1)) $error("Mismatch for in0 = 5'b11111, in1 = 5'b00000, sel = 1");

    in0 = 5'b00110; in1 = 5'b00101; sel = 1; #5;
    $display("in0=%0b in1=%0b sel=%0b -> out=%0b (expected 00101)", in0, in1, sel, out);
    if (out !== (in1)) $error("Mismatch for in0 = 5'b00110, in1 = 5'b00101, sel = 1");

    $display("=== Test Complete ===");
    $finish;
  end

endmodule