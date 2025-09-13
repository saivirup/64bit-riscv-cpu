`timescale 1ns/1ps
import rv64_constants_pkg::*;

module alu_tb;

  logic [XLEN-1:0] a, b, ALUresult;
  alu_ctrl_e    alu_control;
  logic        Zero, invalid_op;

  alu dut (
  .a(a),
  .b(b),
  .alu_control(alu_control),
  .invalid_op(invalid_op),
  .ALUresult(ALUresult),
  .Zero(Zero)
  );

  // Tests AND Operation
  task automatic check_and(input logic [XLEN-1:0] aa,
                           input logic [XLEN-1:0] bb,
                           input string tag);

    // --- Declarations FIRST ---
    logic [XLEN-1:0] exp_res;
    logic           exp_zero;
    bit              exp_inv;


    // 1) Drive
    a = aa; b = bb; alu_control = ALU_AND;

    // 2) Settle
    #1;

    // 3) Compute expected (for AND only we can use the language operator)
    exp_res = (aa & bb);
    exp_zero = (exp_res == '0);
    exp_inv = 1'b0;

    // 4) Check
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv) begin
      $error("[AND][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    end else begin
      $display("[PASS][AND][%s] res=%h zero=%0b inv=%0b", tag, ALUresult, Zero, invalid_op);
    end
  endtask

  task automatic check_add(input logic [XLEN-1:0] aa,
                         input logic [XLEN-1:0] bb,
                         input string tag);
  
    logic [XLEN-1:0] exp_res;
    logic            exp_zero;
    bit              exp_inv;

    a = aa; b = bb; alu_control = ALU_ADD; #1;

    exp_res  = aa + bb;            // wraps mod 2^XLEN
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;

    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv) begin
      $error("[ADD][%s] got res=%h z=%0b inv=%0b | exp %h %0b %0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    end else begin
      $display("[PASS][ADD][%s]", tag);
    end

endtask

  initial begin

    /*
    $display("=== AND directed ===");

    // BEFORE YOU RUN: predict these 6 results on paper.
    // (Write expected hex and Zero flag.)

    check_and('0, '0, "zero & zero");
    check_and('1, '0, "all1 & zero");
    check_and('1, '1, "all1 & all1");
    check_and(64'hDEAD_BEEF_F00D_1234, 64'hFFFF_FFFF_0000_0000, "mask upper");
    check_and(64'h0123_4567_89AB_CDEF, 64'hFEDC_BA98_7654_3210, "interleave");
    check_and(64'h8000_0000_0000_0001, 64'h0000_0000_0000_0001, "LSB & MSB");
    */

    $display("=== ADD directed ===");

    check_add(64'hDEAD_BEEF_F00D_1234, 64'd0, "ADD id");
    check_add(64'h0000_0000_FFFF_FFFF, 64'd1,  "ADD ripple");
    check_add('1,                      64'd1,  "ADD wrap to 0");
    check_add(64'h7FFF_FFFF_FFFF_FFFF, 64'd1,  "ADD +max->min");
    check_add(64'h8000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, "ADD min+(-1)");
    check_add(64'h0123_4567_89AB_CDEF, ~64'h0123_4567_89AB_CDEF + 64'd1, "ADD cancel");

    $display("=== invalid-op sanity ===");

    // Invalid op: should set invalid_op=1 and result=0 (per your ALU)
    a = 64'h1234; b = 64'h5678; alu_control = alu_ctrl_e'(-1); #1;
    if (invalid_op !== 1'b1 || ALUresult !== '0 || Zero !== 1'b1)
      $error("[INV] got res=%h zero=%0b inv=%0b (expected res=0 zero=1 inv=1)",
              ALUresult, Zero, invalid_op);
    else
      $display("[PASS][INV] res=%h zero=%0b inv=%0b", ALUresult, Zero, invalid_op);

    $finish;
  end

endmodule
