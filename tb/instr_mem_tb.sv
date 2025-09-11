`timescale 1ns/1ps
module instr_mem_tb;

  import rv64_constants_pkg::*;  // must define: XLEN, HLEN, IMEM_WORDS

  // --- DUT I/O ---
  logic            clk = 0;
  logic [XLEN-1:0] address;
  logic [HLEN-1:0] instruction;

  // --- Clock: 100 MHz ---
  always #5 clk = ~clk;

  // --- Instantiate DUT ---
  instr_mem dut (
    .clk        (clk),
    .address    (address),
    .instruction(instruction)
  );

  // Handy locals
  localparam int INDEX_BITS = $clog2(IMEM_WORDS);
  localparam int unsigned LAST_IDX  = IMEM_WORDS-1;
  localparam logic [XLEN-1:0] ADDR0  = '0;
  localparam logic [XLEN-1:0] ADDR4  = 64'(4);
  localparam logic [XLEN-1:0] ADDR8  = 64'(8);
  localparam logic [XLEN-1:0] LAST_ADDR = 64'(LAST_IDX) << 2;         // byte addr of last word
  localparam logic [XLEN-1:0] OOB_ADDR  = 64'(IMEM_WORDS) << 2;       // 1 past end (should be X)

  // Known patterns (distinct to catch swaps)
  localparam logic [31:0] P0 = 32'hDEAD_BEEF;
  localparam logic [31:0] P1 = 32'h0000_0013; // NOP (ADDI x0,x0,0)
  localparam logic [31:0] P2 = 32'hC001_D00D;
  localparam logic [31:0] PL = 32'hA5A5_5A5A; // last

  // === Pre-seed ROM contents hierarchically (so TB works even without imem.hex) ===
  // NOTE: instr_mem also calls $readmemh at time 0. These assignments after time 0
  //       deterministically override for simulation.
  initial begin
    // Default all to NOP to avoid stray Xs in valid range
    @(posedge clk);  // ensure we execute after t=0 so we win the race with $readmemh
    for (int i = 0; i < IMEM_WORDS; i++) begin
      dut.memory[i] = P1;
    end
    // Sprinkle test patterns
    dut.memory[0]          = P0;
    dut.memory[1]          = P1;   // keep as NOP
    dut.memory[2]          = P2;
    dut.memory[LAST_IDX]   = PL;
  end

  // === Single-step, synchronous read checker ===
  task automatic rd_chk(input logic [XLEN-1:0] addr,
                        input logic [31:0]     exp,
                        input string           tag);
    // Drive address during the *setup* window before the sampling posedge
    address = addr;
    @(posedge clk); #1; // ROM updates on this edge; sample after a delta
    if (instruction !== exp) begin
      $error("[%s] addr=0x%0h idx=%0d : got 0x%08h, exp 0x%08h",
             tag, addr, addr[INDEX_BITS+1:2], instruction, exp);
    end else begin
      $display("[PASS] %s : addr=0x%0h -> 0x%08h", tag, addr, instruction);
    end
  endtask

  // Check for unknown/X result (e.g., out-of-bounds)
  task automatic rd_expect_x(input logic [XLEN-1:0] addr, input string tag);
    address = addr;
    @(posedge clk); #1;
    if (!$isunknown(instruction)) begin
      $error("[%s] addr=0x%0h expected X (OOB/invalid), got 0x%08h",
             tag, addr, instruction);
    end else begin
      $display("[PASS] %s : addr=0x%0h produced X as expected", tag, addr);
    end
  endtask

  // === Directed tests ===
  initial begin
    // Initialize address away from X
    address = '0;

    // 1) Basic word-aligned reads, first few locations
    rd_chk(ADDR0, P0, "aligned @0");
    rd_chk(ADDR4, P1, "aligned @4");
    rd_chk(ADDR8, P2, "aligned @8");

    // 2) Misaligned access should **truncate low 2 bits** (word addressing)
    //    address[INDEX_BITS+1:2] is the index
    rd_chk(64'(2),  P0, "misaligned @+2 -> idx 0");
    rd_chk(64'(6),  P1, "misaligned @+6 -> idx 1");
    rd_chk(64'(10), P2, "misaligned @+10 -> idx 2");

    // 3) Last location and one past end
    rd_chk(LAST_ADDR, PL, "last word");
    rd_expect_x(OOB_ADDR, "one past end");

    // 4) Back-to-back changes (prove 1-cycle latency)
    //    Change addr each *negedge* so next posedge samples new value.
    @(negedge clk); address = ADDR0;
    @(posedge clk); #1; if (instruction !== P0)  $error("b2b step 1 failed");
    @(negedge clk); address = ADDR4;
    @(posedge clk); #1; if (instruction !== P1)  $error("b2b step 2 failed");
    @(negedge clk); address = ADDR8;
    @(posedge clk); #1; if (instruction !== P2)  $error("b2b step 3 failed");

    $display("=== instr_mem_tb DONE ===");
    $finish;
  end

  // === Sanity: widths/assertions ===
  // HLEN must be 32 for RV32I instruction width (adapt if you support compressed)
  initial begin
    if (HLEN != 32) $warning("HLEN=%0d; TB assumes 32-bit instructions.", HLEN);
    if (XLEN < 32)  $warning("XLEN=%0d; TB uses 64-bit literals for addresses.", XLEN);
  end

endmodule
