`timescale 1ns/1ps

module reg_file_tb;
  // ---- Testbench expectations ----
  localparam int XLEN           = 64;
  localparam bit TB_HARDWIRE_X0 = 1;
  localparam bit TB_RAW_BYPASS  = 1;

  // ---- Clock ----
  logic clk = 0;
  always #5 clk = ~clk;  // 100 MHz

  // ---- DUT I/O ----
  logic            wen;
  logic [4:0]      rs1, rs2, rd;
  logic [XLEN-1:0] wd,  rd1, rd2;

  // ---- Instantiate DUT ----
  reg_file #(
    .HARDWIRE_X0(TB_HARDWIRE_X0),
    .RAW_BYPASS (TB_RAW_BYPASS)
  ) dut (
    .clk (clk),
    .wen (wen),
    .rs1 (rs1),
    .rs2 (rs2),
    .rd  (rd),
    .wd  (wd),
    .rd1 (rd1),
    .rd2 (rd2)
  );

  // ---- Golden model ----
  logic [XLEN-1:0] model [0:31];

  function automatic logic [XLEN-1:0]
  exp_read(input [4:0] r, input bit w, input [4:0] waddr, input logic [XLEN-1:0] wdata);
    if (TB_HARDWIRE_X0 && r == 5'd0)        return '0;
    if (TB_RAW_BYPASS && w && (r == waddr)) return wdata;
    return model[r];
  endfunction

  task automatic drive_cycle(input bit w,
                             input [4:0] r1, r2, waddr,
                             input logic [XLEN-1:0] wdata);
    begin
      wen = w; rs1 = r1; rs2 = r2; rd = waddr; wd = wdata;
      @(posedge clk);
      #1;
    end
  endtask

  task automatic check(string tag,
                       logic [XLEN-1:0] exp1,
                       logic [XLEN-1:0] exp2);
    if (rd1 !== exp1) $error("[%s] rd1 mismatch: exp=%h got=%h (rs1=%0d)", tag, exp1, rd1, rs1);
    if (rd2 !== exp2) $error("[%s] rd2 mismatch: exp=%h got=%h (rs2=%0d)", tag, exp2, rd2, rs2);
  endtask

  task automatic model_update(input bit w, input [4:0] waddr, input logic [XLEN-1:0] wdata);
    if (w && (!TB_HARDWIRE_X0 || waddr != 5'd0)) model[waddr] = wdata;
  endtask

  function automatic logic [XLEN-1:0] pat(input int i);
    return { {XLEN-16{1'b0}}, 16'(i) } ^ (64'h1111_1111_1111_0000 * i);
  endfunction

  // Assertions
  property p_raw_bypass_rs1; @(posedge clk) (wen && (rd == rs1)) |-> (rd1 == wd); endproperty
  property p_raw_bypass_rs2; @(posedge clk) (wen && (rd == rs2)) |-> (rd2 == wd); endproperty
  property p_x0_zero;       @(posedge clk) (rs1 == 5'd0) |-> (rd1 == '0); endproperty

  generate
    if (TB_RAW_BYPASS) begin
      assert property(p_raw_bypass_rs1) else $error("RAW bypass rs1 failed");
      assert property(p_raw_bypass_rs2) else $error("RAW bypass rs2 failed");
    end
    if (TB_HARDWIRE_X0) begin
      assert property(p_x0_zero) else $error("x0 != 0 on read");
    end
  endgenerate

  // ===================== Test Sequence =====================
  initial begin
    wen = 0; rs1 = 0; rs2 = 0; rd = 0; wd = '0;
    foreach (model[i]) model[i] = '0;

    // 0) x0 must be zero
    drive_cycle(0, 0, 0, 0, '0);
    check("x0_zero", exp_read(rs1,0,rd,wd), exp_read(rs2,0,rd,wd));

    // 1) Warm up registers
    for (int i = 1; i < 32; i++) begin
      drive_cycle(1, i, 0, i, pat(i));
      check($sformatf("warmup_r%0d", i),
            exp_read(i,1,i,pat(i)),
            exp_read(0,1,i,pat(i)));
      model_update(1, i, pat(i));
    end

    // 2) Directed readback
    drive_cycle(0, 5, 6, 0, '0);
    check("readback_5_6",
          exp_read(5,0,0,'0),
          exp_read(6,0,0,'0));

    // 3) Write to x0 ignored
    drive_cycle(1, 0, 0, 0, 64'hDEAD_BEEF);
    check("write_x0_ignored",
          exp_read(0,1,0,64'hDEAD_BEEF),
          exp_read(0,1,0,64'hDEAD_BEEF));
    model_update(1, 0, 64'hDEAD_BEEF);
    drive_cycle(0, 0, 0, 0, '0);
    check("x0_still_zero",
          exp_read(0,0,0,'0),
          exp_read(0,0,0,'0));

    // 4) RAW bypass rs1
    drive_cycle(1, 7, 1, 7, 64'hDEAD_BEEF_0000_0001);
    check("raw_bypass_rs1",
          exp_read(7,1,7,64'hDEAD_BEEF_0000_0001),
          exp_read(1,1,7,64'hDEAD_BEEF_0000_0001));
    model_update(1, 7, 64'hDEAD_BEEF_0000_0001);

    // 5) RAW bypass rs2
    drive_cycle(1, 2, 8, 8, 64'hDEAD_BEEF_0000_0002);
    check("raw_bypass_rs2",
          exp_read(2,1,8,64'hDEAD_BEEF_0000_0002),
          exp_read(8,1,8,64'hDEAD_BEEF_0000_0002));
    model_update(1, 8, 64'hDEAD_BEEF_0000_0002);

    // 6) Random stress
    for (int k = 0; k < 200; k++) begin
      automatic bit              w   = $urandom_range(0,1);
      automatic logic [4:0]      r1  = $urandom_range(0,31);
      automatic logic [4:0]      r2  = $urandom_range(0,31);
      automatic logic [4:0]      wa  = $urandom_range(0,31);
      automatic logic [XLEN-1:0] wd_r = {$urandom, $urandom};

      drive_cycle(w, r1, r2, wa, wd_r);
      check($sformatf("rand_%0d", k),
            exp_read(r1, w, wa, wd_r),
            exp_read(r2, w, wa, wd_r));
      model_update(w, wa, wd_r);
    end

    $display("TB DONE");
    $finish;
  end
endmodule