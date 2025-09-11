// -----------------------------------------------------------------------------
// tb/beefy_cpu_tb.sv  —  Clean, compile-proof smoke test for beefy_cpu
// - Drives clk/rst
// - (Option A) Let instr_mem.sv load hex via +IMEM_HEX=... plusarg (recommended)
// - (Option B) Uncomment TB-load to $readmemh directly into dut.instr_mem_inst.memory
// - Prints PC/instruction/ALU/flags each cycle; finishes after MAX_CYCLES
// - Optional fetch sanity-check: compare dut.instruction vs ROM contents
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
import rv64_constants_pkg::*; // defines XLEN, HLEN, IMEM_WORDS, etc.

module beefy_cpu_tb;

  // -------------------------------------------------------
  // Clock / Reset
  // -------------------------------------------------------
  localparam time  TCK_NS      = 10ns;   // 100 MHz
  localparam int   RESET_CYC   = 5;
  localparam int   MAX_CYCLES  = 500;

  logic clk = 1'b0;
  logic rst = 1'b1;

  always #(TCK_NS/2) clk = ~clk;

  // -------------------------------------------------------
  // DUT I/O (matches beefy_cpu.sv header)
  // -------------------------------------------------------
  logic [XLEN-1:0] pc_out;
  logic [31:0]     instruction;
  logic [11:0]     control_signals;
  logic [XLEN-1:0] imm_out;
  logic [XLEN-1:0] read_data_1;
  logic [XLEN-1:0] read_data_2;
  logic [XLEN-1:0] alu_result;
  logic [XLEN-1:0] read_data_mem;
  logic            zero;
  logic            invalid;

  // -------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------
  beefy_cpu dut (
    .clk            (clk),
    .rst            (rst),
    .pc_out         (pc_out),
    .instruction    (instruction),
    .control_signals(control_signals),
    .imm_out        (imm_out),
    .read_data_1    (read_data_1),
    .read_data_2    (read_data_2),
    .alu_result     (alu_result),
    .read_data_mem  (read_data_mem),
    .zero           (zero),
    .invalid        (invalid)
  );

  // -------------------------------------------------------
  // Utility tasks (make all tasks AUTOMATIC)
  // -------------------------------------------------------
  task automatic apply_reset(int cycles = RESET_CYC);
    rst = 1'b1;
    repeat (cycles) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic wait_cycles(int cycles);
    repeat (cycles) @(posedge clk);
  endtask

  // (OPTION B) Load hex file directly into ROM from TB (commented out by default).
  // Only use this if you want the TB to control the image instead of +IMEM_HEX.
  task automatic tb_load_hex(string path);
    $display("[TB] Loading hex into dut.instr_mem_inst.memory from '%0s'", path);
    $readmemh(path, dut.instr_mem_inst.memory);
  endtask

  // -------------------------------------------------------
  // Optional fetch check — ensures fetched 'instruction' equals ROM[widx]
  // Enable by setting localparam DO_FETCH_CHECK = 1
  // -------------------------------------------------------
  localparam bit DO_FETCH_CHECK = 1'b1;

  // Word index computation consistent with your instr_mem.sv (drop byte lanes)
  function automatic int unsigned pc_to_widx(input logic [XLEN-1:0] pc);
    return pc[ (2 + $clog2(IMEM_WORDS) - 1) : 2 ];
  endfunction

  // -------------------------------------------------------
  // Main stimulus
  // -------------------------------------------------------
  initial begin
    $timeformat(-9, 1, " ns", 10);
    $display("\n[TB] beefy_cpu_tb starting at %0t", $realtime);

    // OPTION A (recommended): Let instr_mem.sv load via +IMEM_HEX=<file>.
    // It already defaults to \"test_program.hex\" if +IMEM_HEX is not provided.

    // OPTION B: uncomment next 2 lines to force TB-controlled load:
    // string hexfile = "test_program.hex";
    // tb_load_hex(hexfile);

    // Reset and run
    apply_reset();

    int cycles = 0;
    // Simple watchdog: run up to MAX_CYCLES
    while (cycles < MAX_CYCLES) begin
      @(posedge clk);
      cycles++;

      // Optional sanity: detect invalid flag
      if (invalid) begin
        $display("[TB][%0t] INVALID asserted at PC=0x%016h instr=0x%08h", $time, pc_out, instruction);
        // You may choose to $stop here for debug:
        // $stop;
      end

      // Optional fetch correctness check (compare to ROM contents)
      if (DO_FETCH_CHECK && !rst) begin
        int unsigned widx = pc_to_widx(pc_out);
        if (widx < IMEM_WORDS) begin
          logic [31:0] rom_instr = dut.instr_mem_inst.memory[widx];
          if (instruction !== rom_instr) begin
            $display("[TB][%0t] FETCH MISMATCH @PC=0x%016h widx=%0d: dut.instruction=0x%08h, ROM=0x%08h",
                     $time, pc_out, widx, instruction, rom_instr);
          end
        end else begin
          $display("[TB][%0t] PC out of range: PC=0x%016h (widx=%0d >= IMEM_WORDS=%0d)",
                   $time, pc_out, widx, IMEM_WORDS);
        end
      end
    end

    $display("[TB] Finished after %0d cycles.", cycles);
    $finish;
  end

  // -------------------------------------------------------
  // Live monitor (kept simple to avoid formatting perf hits)
  // -------------------------------------------------------
  initial begin
    $display(" time        | PC                | instr     | ALU                 | Z | INV");
    forever begin
      @(posedge clk);
      if (!rst) begin
        $display("%10t | 0x%016h | 0x%08h | 0x%016h | %0b |  %0b",
                 $time, pc_out, instruction, alu_result, zero, invalid);
      end
    end
  end

endmodule