`timescale 1ns/1ps
import rv64_constants_pkg::*;

module alu_tb;
  // ================== DUT I/O ==================
  localparam int W = XLEN;
  localparam int SHAMT_BITS = $clog2(W);

  logic [W-1:0] a, b, ALUresult;
  alu_ctrl_e    alu_control;
  logic         Zero, invalid_op;

  // ------------------ DUT ----------------------
  alu dut (
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .invalid_op(invalid_op),
    .ALUresult(ALUresult),
    .Zero(Zero)
  );

  // ================= Monitors ==================
  // Zero must always reflect (ALUresult == 0)
  always @* if (Zero !== (ALUresult == '0))
    $error("Zero flag mismatch: Zero=%0b ALUresult=%h", Zero, ALUresult);

  // --------------- Helper: mask ----------------
  function automatic int unsigned shamt_mask(input logic [W-1:0] bb);
    return bb[SHAMT_BITS-1:0];
  endfunction

  // ================== CHECKERS =================
  // ---- AND ----
  task automatic check_and (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_AND; #1;
    exp_res  = (aa & bb);
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[AND][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][AND][%s] res=%h zero=%0b inv=%0b", tag, ALUresult, Zero, invalid_op);
  endtask

  // ---- OR ----
  task automatic check_or (input logic [W-1:0] aa,
                           input logic [W-1:0] bb,
                           input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_OR; #1;
    exp_res  = (aa | bb);
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[OR ][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][OR ][%s] res=%h zero=%0b inv=%0b", tag, ALUresult, Zero, invalid_op);
  endtask

  // ---- XOR ----
  task automatic check_xor (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_XOR; #1;
    exp_res  = (aa ^ bb);
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[XOR][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][XOR][%s] res=%h zero=%0b inv=%0b", tag, ALUresult, Zero, invalid_op);
  endtask

  // ---- ADD ----
  task automatic check_add (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_ADD; #1;
    exp_res  = aa + bb;            // wraps mod 2^W
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[ADD][%s] got res=%h z=%0b inv=%0b | exp %h %0b %0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][ADD][%s]", tag);
  endtask

  // ---- SUB ----
  task automatic check_sub (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_SUB; #1;
    exp_res  = aa - bb;
    exp_zero = (exp_res == '0); // fix typo
    exp_inv  = 1'b0;
    if ((ALUresult !== exp_res) || (Zero !== exp_zero) || (invalid_op !== exp_inv))
      $error("[SUB][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SUB][%s] res=%h zero=%0b inv=%0b",
                  tag, ALUresult, Zero, invalid_op);
  endtask

  // ---- SLL ----
  task automatic check_sll (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv; int unsigned s;
    a = aa; b = bb; alu_control = ALU_SLL; #1;
    s = shamt_mask(bb);
    exp_res  = (aa << s);
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SLL][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SLL][%s] res=%h", tag, ALUresult);
  endtask

  // ---- SRL ----
  task automatic check_srl (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv; int unsigned s;
    a = aa; b = bb; alu_control = ALU_SRL; #1;
    s = shamt_mask(bb);
    exp_res  = (aa >> s);
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SRL][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SRL][%s] res=%h", tag, ALUresult);
  endtask

  // ---- SRA ----
  task automatic check_sra (
    input  logic [W-1:0] aa,
    input  logic [W-1:0] bb,
    input  string        tag
  );
    // Declarations FIRST in this scope
    automatic logic signed [W-1:0] sa;
    automatic logic        [5:0]   s;        // RV64: low 6 bits
    automatic logic        [W-1:0] exp_res;
    bit exp_zero;
    bit exp_inv;

    // Drive DUT
    a = aa; 
    b = bb; 
    alu_control = ALU_SRA; 
    #1;

    // Golden model
    sa      = aa;
    s       = bb[5:0];
    exp_res = $unsigned(sa >>> s);           // keep all W bits
    exp_zero = (exp_res == '0);
    exp_inv  = 1'b0;

    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SRA][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
            tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else
      $display("[PASS][SRA][%s] res=%h", tag, ALUresult);
  endtask



  // ---- SLT (signed) ----
  task automatic check_slt (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_SLT; #1;
    exp_res  = '0; if ($signed(aa) < $signed(bb)) exp_res[0] = 1'b1;
    exp_zero = (exp_res == '0); exp_inv = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SLT][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SLT][%s] res=%h", tag, ALUresult);
  endtask

  // ---- SGE (signed >=) ----
  task automatic check_sge (input logic [W-1:0] aa,
                            input logic [W-1:0] bb,
                            input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_SGE; #1;
    exp_res  = '0; if ($signed(aa) >= $signed(bb)) exp_res[0] = 1'b1;
    exp_zero = (exp_res == '0); exp_inv = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SGE][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SGE][%s] res=%h", tag, ALUresult);
  endtask

  // ---- SLTU (unsigned) ----
  task automatic check_sltu (input logic [W-1:0] aa,
                             input logic [W-1:0] bb,
                             input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_SLTU; #1;
    exp_res  = '0; if (aa < bb) exp_res[0] = 1'b1;
    exp_zero = (exp_res == '0); exp_inv = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SLTU][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SLTU][%s] res=%h", tag, ALUresult);
  endtask

  // ---- SGEU (unsigned >=) ----
  task automatic check_sgeu (input logic [W-1:0] aa,
                             input logic [W-1:0] bb,
                             input string tag);
    logic [W-1:0] exp_res; logic exp_zero; bit exp_inv;
    a = aa; b = bb; alu_control = ALU_SGEU; #1;
    exp_res  = '0; if (aa >= bb) exp_res[0] = 1'b1;
    exp_zero = (exp_res == '0); exp_inv = 1'b0;
    if (ALUresult !== exp_res || Zero !== exp_zero || invalid_op !== exp_inv)
      $error("[SGEU][%s] got res=%h zero=%0b inv=%0b | exp res=%h zero=%0b inv=%0b",
             tag, ALUresult, Zero, invalid_op, exp_res, exp_zero, exp_inv);
    else $display("[PASS][SGEU][%s] res=%h", tag, ALUresult);
  endtask

  // ---- INVALID OP ----
  task automatic check_invalid(input logic [W-1:0] aa,
                               input logic [W-1:0] bb,
                               input string tag);
    a = aa; b = bb; alu_control = alu_ctrl_e'(-1); #1;
    if (!(invalid_op === 1'b1 && ALUresult == '0 && Zero === 1'b1)) begin
      $error("[INV][%s] got res=%h zero=%0b inv=%0b (expected res=0 zero=1 inv=1)",
             tag, ALUresult, Zero, invalid_op);
    end else $display("[PASS][INV][%s]", tag);
  endtask

  // ================== STIMULUS =================
  initial begin
    // ---------- AND ----------
    $display("=== AND directed ===");
    check_and('0, '0, "zero&zero");
    check_and('1, '0, "all1&0");
    check_and('1, '1, "all1&all1");
    check_and(64'hDEAD_BEEF_F00D_1234, 64'hFFFF_FFFF_0000_0000, "mask upper");
    check_and(64'h0123_4567_89AB_CDEF, 64'hFEDC_BA98_7654_3210, "interleave");
    check_and(64'h8000_0000_0000_0001, 64'h0000_0000_0000_0001, "LSB&MSB");

    // ---------- OR -----------
    $display("=== OR directed ===");
    check_or(64'hDEAD_BEEF_F00D_1234, '0,   "x|0=x");
    check_or(64'h0123_4567_89AB_CDEF, '1,   "x|all1=all1");
    check_or(64'h00FF_00FF_00FF_00FF, 64'hFF00_FF00_FF00_FF00, "disjoint");
    check_or(64'h0F0F_0F0F_0F0F_0F0F, 64'h00FF_00FF_00FF_00FF, "overlap");
    check_or(64'h8000_0000_0000_0001, 64'h0000_0000_0000_0001, "msb|lsb");
    check_or(64'h1234_5678_9ABC_DEF0, 64'h0F0F_0F0F_0F0F_0F0F, "randomish");

    // ---------- XOR ----------
    $display("=== XOR directed ===");
    check_xor(64'hAAAA_AAAA_AAAA_AAAA, 64'hAAAA_AAAA_AAAA_AAAA, "x^x=0");
    check_xor(64'h0123_4567_89AB_CDEF, ~64'h0123_4567_89AB_CDEF, "x^~x=all1");
    check_xor(64'h1, 64'h1, "flip LSB");
    check_xor(64'h8000_0000_0000_0000, 64'h8000_0000_0000_0000, "flip MSB");
    check_xor(64'hDEAD_BEEF_DEAD_BEEF, 64'hBEEF_DEAD_BEEF_DEAD, "cross");
    check_xor(64'h1357_9BDF_2468_ACED, 64'h0F0F_F0F0_0F0F_F0F0, "mix");

    // ---------- ADD ----------
    $display("=== ADD directed ===");
    check_add(64'hDEAD_BEEF_F00D_1234, 64'd0, "ADD id");
    check_add(64'h0000_0000_FFFF_FFFF, 64'd1,  "ADD ripple");
    check_add('1,                      64'd1,  "ADD wrap to 0");
    check_add(64'h7FFF_FFFF_FFFF_FFFF, 64'd1,  "ADD +max->min");
    check_add(64'h8000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, "ADD min+(-1)");
    check_add(64'h0123_4567_89AB_CDEF, ~64'h0123_4567_89AB_CDEF + 64'd1, "ADD cancel");

    // ---------- SUB ----------
    $display("=== SUB directed ===");
    check_sub(64'hDEAD_BEEF_F00D_1234, 64'd0, "SUB id a-0");
    check_sub('0,                        '0,    "SUB 0-0");
    check_sub(64'h0123_4567_89AB_CDEF, 64'h0123_4567_89AB_CDEF, "SUB a-a");
    check_sub('0,                        64'd1, "SUB 0-1 wrap");
    check_sub(64'h0001_0000_0000_0000,  64'd1, "SUB long borrow");
    check_sub(64'h8000_0000_0000_0000,  64'd1, "SUB min-1 (signed ovf)");
    check_sub(64'h7FFF_FFFF_FFFF_FFFF,  64'hFFFF_FFFF_FFFF_FFFF, "SUB max-(-1)");
    check_sub(64'd5,                    64'd7, "SUB small-bigger");

    // ---------- SLL ----------
    $display("=== SLL directed ===");
    check_sll(64'h1, 64'd0,  "<<0");
    check_sll(64'h1, 64'd1,  "<<1");
    check_sll(64'h1, 64'd63, "<<63");
    check_sll(64'h1, 64'd64, "<<64 (mask->0)");
    check_sll(64'h1, 64'd65, "<<65 (mask->1)");
    check_sll(64'h8000_0000_0000_0001, 64'd4, "random shamt");

    // ---------- SRL ----------
    $display("=== SRL directed ===");
    check_srl(64'h8000_0000_0000_0000, 64'd0,  ">>0");
    check_srl(64'h8000_0000_0000_0000, 64'd1,  ">>1");
    check_srl(64'h8000_0000_0000_0000, 64'd63, ">>63");
    check_srl(64'h8000_0000_0000_0000, 64'd64, ">>64 (mask->0)");
    check_srl(64'h8000_0000_0000_0000, 64'd65, ">>65 (mask->1)");
    check_srl(64'hF0F0_F0F0_F0F0_F0F0, 64'd8,  "byte");

    // ---------- SRA ----------
    $display("=== SRA directed ===");
    check_sra(64'h8000_0000_0000_0000, 64'd0,  ">>>0 neg");
    check_sra(64'h8000_0000_0000_0000, 64'd1,  ">>>1 neg");
    check_sra(64'h8000_0000_0000_0000, 64'd63, ">>>63 neg");
    check_sra(64'h7FFF_FFFF_FFFF_FFFF, 64'd1,  ">>>1 pos");
    check_sra(64'h0000_0000_0000_0001, 64'd1,  ">>>1 tiny");
    check_sra(64'hF000_0000_0000_0000, 64'd4,  ">>>4 neg mix");

    // ---------- Signed comps: SLT / SGE ----------
    begin : slt_sge_signed
      automatic logic [W-1:0] eq;   // decls FIRST in this scope
      eq = 64'h1234_5678_9ABC_DEF0;

      $display("=== SLT/SGE (signed) ===");
      // Use same pairs for both ops
      check_slt(eq, eq, "eq");                 check_sge(eq, eq, "eq");
      check_slt(64'd3, 64'd5, "3<5");          check_sge(64'd3, 64'd5, "3<5");
      check_slt(64'd9, 64'd5, "9>5");          check_sge(64'd9, 64'd5, "9>5");
      check_slt('1, 64'd0,   "-1<0");          check_sge('1, 64'd0,   "-1<0");
      check_slt(64'd0, '1,   "0<-1?");         check_sge(64'd0, '1,   "0<-1?");
      check_slt(64'h8000_0000_0000_0000, 64'h7FFF_FFFF_FFFF_FFFF, "min<max");
      check_sge(64'h8000_0000_0000_0000, 64'h7FFF_FFFF_FFFF_FFFF, "min<max");
    end

    // ---------- Unsigned comps: SLTU / SGEU ----------
    begin : sltu_sgeu_unsigned
      automatic logic [W-1:0] eq;   // new scope, declare again here
      eq = 64'h1234_5678_9ABC_DEF0;

      $display("=== SLTU/SGEU (unsigned) ===");
      check_sltu(eq, eq, "eq");                 check_sgeu(eq, eq, "eq");
      check_sltu(64'd3, 64'd5, "3<5");          check_sgeu(64'd3, 64'd5, "3<5");
      check_sltu(64'd9, 64'd5, "9>5");          check_sgeu(64'd9, 64'd5, "9>5");
      check_sltu('1, 64'd0,   "max<0?");        check_sgeu('1, 64'd0,   "max>=0");
      check_sltu(64'd0, '1,   "0<max");         check_sgeu(64'd0, '1,   "0<max");
      check_sltu(64'h8000_0000_0000_0000, 64'h7FFF_FFFF_FFFF_FFFF, "half vs half-1");
      check_sgeu(64'h8000_0000_0000_0000, 64'h7FFF_FFFF_FFFF_FFFF, "half vs half-1");
    end

    // ---------- Invalid op ----------
    $display("=== INVALID op ===");
    check_invalid(64'h1234, 64'h5678, "cast -1");
    // If your enum defines ALU_INV explicitly, exercise it too:
    a = 64'hBEEF; b = 64'hCAFE; alu_control = ALU_INV; #1;
    if (!(invalid_op === 1'b1 && ALUresult == '0 && Zero === 1'b1))
      $error("[INV][enum] got res=%h zero=%0b inv=%0b (expected res=0 zero=1 inv=1)",
             ALUresult, Zero, invalid_op);
    else $display("[PASS][INV enum]");

    // ---------- Cheap invariants ----------
    $display("=== Invariants ===");
    // (a-b)+b == a  (mod 2^W)
    for (int i = 0; i < 20; i++) begin
      // Declarations first (make them automatic so each loop iter gets fresh storage)
      automatic logic [W-1:0] ra, rb, sub;

      // Randomize operands
      ra = $urandom();
      rb = $urandom();

      // Compute sub = (ra - rb)
      a = ra; 
      b = rb; 
      alu_control = ALU_SUB; 
      #1;
      sub = ALUresult;

      // Check (sub + rb) == ra
      a = sub; 
      b = rb; 
      alu_control = ALU_ADD; 
      #1;

      if (ALUresult !== ra)
        $error("Invariant fail: (a-b)+b != a  (got %h, exp %h)  a=%h b=%h", 
              ALUresult, ra, ra, rb);
    end

    $display("=== DONE ===");
    $finish;
  end
endmodule
