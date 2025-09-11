`timescale 1ns/1ps

// Import the package that defines XLEN (matches your constants_pkg.sv)
import rv64_constants_pkg::*;

module shift_left_2_tb;

  // --- Types & DUT I/O ---
  typedef logic [XLEN-1:0] uxl;
  uxl x;
  uxl y;

  // --- Device Under Test ---
  shift_left_2 dut (
    .x (x),
    .y (y)
  );

  // --- Result accounting ---
  int unsigned n_checks = 0;
  int unsigned n_fail   = 0;

  // --- Golden checker ---
  task automatic check(input uxl xin, input string tag = "");
    uxl exp;
    x   = xin;
    #1;                  // allow combinational settle
    exp = xin << 2;      // golden model (oracle)

    n_checks++;
    if (y !== exp) begin
      n_fail++;
      $error("[%s] x=0x%016h -> y=0x%016h, expected 0x%016h", tag, xin, y, exp);
    end
  endtask

  // --- Directed vectors: focus on “falling off” MSBs & tricky patterns ---
  task automatic directed_suite();
    check('0,                           "zero");               // all zeros
    check(uxl'(1),                      "single_lsb");         // only bit0 set
    check(uxl'(2),                      "bit1");               // only bit1 set
    check(uxl'(3),                      "bits1_0");            // small combo
    check(uxl'(~0),                     "all_ones");           // all ones
    check(uxl'(64'h8000_0000_0000_0000),"msb_set");            // msb drops off
    check(uxl'(64'h4000_0000_0000_0001),"edge_mix");           // msb-1 + lsb
    check(uxl'(64'h0000_0000_0000_0004),"already_shifted2");   // verify idempotent pattern
    check(uxl'(64'h7fff_ffff_ffff_ffff),"max_no_msb");         // largest w/o MSB
    // Your turn later: add 3 more you think are high value and explain why.
  endtask

  // --- Random sweep for broader confidence ---
  task automatic random_suite(input int N = 200);
    for (int i = 0; i < N; i++) begin
      uxl r = uxl'({$urandom, $urandom}); // 64-bit from two 32-bit PRNs
      check(r, $sformatf("rand[%0d]", i));
    end
  endtask

  // --- Test sequence ---
  initial begin
    $display("=== shift_left_2 TB start (XLEN=%0d) ===", XLEN);

    directed_suite();
    random_suite(200);

    if (n_fail == 0) begin
      $display("=== PASS: %0d checks, %0d failures ===", n_checks, n_fail);
    end else begin
      $display("=== FAIL: %0d checks, %0d failures ===", n_checks, n_fail);
      $fatal(1);
    end

    $finish;
  end

endmodule
