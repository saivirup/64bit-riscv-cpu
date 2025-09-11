`timescale 1ns/1ps
// No package imports needed here

module mux3to1_64bit_tb;

  // --- Parameters & types ---
  localparam int W = 64;
  typedef logic [W-1:0] u64;

  // --- Stimulus & observe ---
  u64   a, b, c, out;
  logic [1:0] sel;  // 0->a, 1->b, 2->c

  // --- DUT (edit this to match YOUR RTL name/ports) ---
  mux3to1_64bit dut (
    .a  (a),
    .b  (b),
    .c  (c),
    .sel(sel),
    .out(out)
  );

  // --- Single check helper ---
  task automatic check(input u64 aa, input u64 bb, input u64 cc,
                       input logic [1:0] s, input string tag);
    u64 exp;
    a   = aa;
    b   = bb;
    c   = cc;
    sel = s;
    #1; // allow combinational settle

    unique case (s)
      2'd0: exp = aa;
      2'd1: exp = bb;
      2'd2: exp = cc;
      default: exp = 'x; // illegal sel for 3:1
    endcase

    if (out !== exp) begin
      $error("[%s] sel=%0d a=%h b=%h c=%h -> out=%h exp=%h",
             tag, s, aa, bb, cc, out, exp);
      $fatal(1);
    end else begin
      $display("[PASS] %s sel=%0d a=%h b=%h c=%h -> out=%h",
               tag, s, aa, bb, cc, out);
    end
  endtask

  // --- Directed tests ---
  initial begin
    $display("=== 64-bit 3:1 Mux Directed Tests ===");

    // 1) canonical patterns
    check(64'h0000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, 64'hAAAA_AAAA_AAAA_AAAA, 2'd0, "zeros/ones/as");
    check(64'h0000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, 64'hAAAA_AAAA_AAAA_AAAA, 2'd1, "zeros/ones/as");
    check(64'h0000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, 64'hAAAA_AAAA_AAAA_AAAA, 2'd2, "zeros/ones/as");

    // 2) MSB/LSB emphasis
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0001, 64'h0000_0000_0000_0000, 2'd0, "msb/lsb/zero");
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0001, 64'h0000_0000_0000_0000, 2'd1, "msb/lsb/zero");
    check(64'h8000_0000_0000_0000, 64'h0000_0000_0000_0001, 64'h0000_0000_0000_0000, 2'd2, "msb/lsb/zero");

    // 3) a==b, a==c, b==c (sel shouldn’t matter among equal operands)
    check(64'h1234_5678_9ABC_DEF0, 64'h1234_5678_9ABC_DEF0, 64'hDEAD_BEEF_CAFE_BABE, 2'd0, "a==b");
    check(64'h1234_5678_9ABC_DEF0, 64'h1234_5678_9ABC_DEF0, 64'hDEAD_BEEF_CAFE_BABE, 2'd1, "a==b");
    check(64'hFACE_C0DE_F00D_BAAD, 64'h0BAD_F00D_FEED_BEEF, 64'hFACE_C0DE_F00D_BAAD, 2'd0, "a==c");
    check(64'hFACE_C0DE_F00D_BAAD, 64'h0BAD_F00D_FEED_BEEF, 64'hFACE_C0DE_F00D_BAAD, 2'd2, "a==c");
    check(64'hDEAD_BEEF_CAFE_BABE, 64'hBEEF_DEAD_BAAD_F00D, 64'hBEEF_DEAD_BAAD_F00D, 2'd1, "b==c");
    check(64'hDEAD_BEEF_CAFE_BABE, 64'hBEEF_DEAD_BAAD_F00D, 64'hBEEF_DEAD_BAAD_F00D, 2'd2, "b==c");

    // 4) near-equal words
    check(64'h7FFF_FFFF_FFFF_FFFF, 64'hFFFF_FFFF_FFFF_FFFF, 64'h7FFF_FFFF_FFFF_FFFE, 2'd0, "near-eq");
    check(64'h7FFF_FFFF_FFFF_FFFF, 64'hFFFF_FFFF_FFFF_FFFF, 64'h7FFF_FFFF_FFFF_FFFE, 2'd1, "near-eq");
    check(64'h7FFF_FFFF_FFFF_FFFF, 64'hFFFF_FFFF_FFFF_FFFF, 64'h7FFF_FFFF_FFFF_FFFE, 2'd2, "near-eq");

    $display("=== ALL DIRECTED TESTS PASSED ===");
    $finish;
  end

  // --- Optional: simple assertion to catch illegal sel
  // If your design ever drives sel==3, flag it.
  // always @* assert (sel <= 2) else $error("Illegal sel=3 for 3:1 mux");

endmodule
