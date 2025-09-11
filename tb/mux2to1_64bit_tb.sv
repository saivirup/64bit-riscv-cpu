`timescale 1ns/1ps
// import rv64_constants_pkg::*; // not needed here; comment out if unused

module mux2to1_64bit_tb;

  // --- Declarations first ---
  localparam int W = 64;
  typedef logic [W-1:0] u64;

  u64  a, b, out;
  logic sel;

  // --- DUT instantiation (module/ports must match your RTL) ---
  mux2to1_64bit dut (
    .a  (a),
    .b  (b),
    .sel(sel),
    .out(out)
  );

  // --- Helper: single check ---
  task automatic check(input u64 aa, input u64 bb, input logic s, input string tag);
    u64 exp;
    a   = aa;
    b   = bb;
    sel = s;
    #1;           // allow combinational settle
    exp = s ? bb : aa;
    if (out !== exp) begin
      $error("[%s] sel=%0b a=%h b=%h -> out=%h exp=%h", tag, s, aa, bb, out, exp);
      $fatal(1);
    end else begin
      $display("[PASS] %s sel=%0b a=%h b=%h -> out=%h", tag, s, aa, bb, out);
    end
  endtask

  // --- Test program ---
  initial begin
    $display("=== 64-bit 2:1 Mux Directed Tests ===");

    // 1) All-zeros vs all-ones
    check(64'h0000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, 0, "zeros->ones sel=0");
    check(64'h0000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, 1, "zeros->ones sel=1");

    // 2) Alternating patterns
    check(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555, 0, "alternating sel=0");
    check(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555, 1, "alternating sel=1");

    // 3) MSB vs LSB emphasized
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0001, 0, "MSB_vs_LSB sel=0");
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0001, 1, "MSB_vs_LSB sel=1");

    // 4) a == b (sel shouldn't matter)
    check(64'h1234_5678_9ABC_DEF0, 64'h1234_5678_9ABC_DEF0, 0, "a==b sel=0");
    check(64'h1234_5678_9ABC_DEF0, 64'h1234_5678_9ABC_DEF0, 1, "a==b sel=1");

    // 5) Single-bit differences at key positions
    check(64'h0000_0000_0000_0001, 64'h0000_0000_0000_0000, 0, "diff@bit0 sel=0");
    check(64'h0000_0000_0000_0001, 64'h0000_0000_0000_0000, 1, "diff@bit0 sel=1");
    check(64'h0000_0000_8000_0000, 64'h0000_0000_0000_0000, 0, "diff@bit31 sel=0");
    check(64'h0000_0000_8000_0000, 64'h0000_0000_0000_0000, 1, "diff@bit31 sel=1");
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0000, 0, "diff@bit63 sel=0");
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0000, 1, "diff@bit63 sel=1");

    // 6) Near-identical but off-by-one-bit words
    check(64'h7FFF_FFFF_FFFF_FFFF, 64'hFFFF_FFFF_FFFF_FFFF, 0, "near-eq(MSB) sel=0");
    check(64'h7FFF_FFFF_FFFF_FFFF, 64'hFFFF_FFFF_FFFF_FFFF, 1, "near-eq(MSB) sel=1");
    check(64'h0000_0000_7FFF_FFFF, 64'h0000_0000_FFFF_FFFF, 0, "near-eq(mid) sel=0");
    check(64'h0000_0000_7FFF_FFFF, 64'h0000_0000_FFFF_FFFF, 1, "near-eq(mid) sel=1");

    // 7) “Looks-random” big hex values
    check(64'hDEAD_BEEF_CAFE_BABE, 64'h0123_4567_89AB_CDEF, 0, "randish#1 sel=0");
    check(64'hDEAD_BEEF_CAFE_BABE, 64'h0123_4567_89AB_CDEF, 1, "randish#1 sel=1");
    check(64'hFACE_C0DE_F00D_BAAD, 64'h0BAD_F00D_FEED_BEEF, 0, "randish#2 sel=0");
    check(64'hFACE_C0DE_F00D_BAAD, 64'h0BAD_F00D_FEED_BEEF, 1, "randish#2 sel=1");

    $display("=== ALL DIRECTED TESTS PASSED ===");
    $finish;
  end

endmodule