// -----------------------------------------------------------------------------
// Instruction Memory (ROM) for RV64 core
// - 32-bit instruction words (even for RV64)
// - Byte-addressed PC input; word index derived from addr[IMEM_LSB]
// - Loads contents from a hex file via $readmemh
// - Optional +IMEM_HEX=path/to/file.hex plusarg override
// - Parameterizable size and read style (sync/comb)
// -----------------------------------------------------------------------------
module instr_mem #(
    parameter int unsigned XLEN        = 64,                // address width of the core
    parameter int unsigned AW          = 16,                // ROM size = 2^AW bytes
    parameter int unsigned IMEM_LSB    = 2,                 // 32-bit words => LSB=2
    parameter bit          SYNC_READ   = 1,                 // 1=sync (BRAM-like), 0=comb
    parameter string       DEFAULT_HEX = "test_program.hex" // default image
) (
    input  logic                 clk,
    input  logic [XLEN-1:0]      addr,     // byte address from PC
    output logic [31:0]          instr     // fetched instruction
);

    // --- Derived sizing ---
    localparam int unsigned BYTES_PER_WORD = 4;
    localparam int unsigned ROM_BYTES      = (1 << AW);
    localparam int unsigned WORDS          = ROM_BYTES / BYTES_PER_WORD;
    localparam int unsigned WIDXW          = (WORDS > 1) ? $clog2(WORDS) : 1;

    // --- Storage (ROM) ---
    logic [31:0] mem [0:WORDS-1];

    // --- NOP (ADDI x0, x0, 0) ---
    localparam logic [31:0] NOP = 32'h0000_0013;

    // --- Word index and range checks ---
    wire [WIDXW-1:0] widx = addr[IMEM_LSB + WIDXW - 1 : IMEM_LSB];

    // Any address bits above the ROM's covered range?
    // If these are non-zero, the access is out of this ROM's address space.
    wire out_of_range = |addr[XLEN-1 : (IMEM_LSB + WIDXW)];

    // Optional alignment check: for pure 32-bit fetch (no C-extension), enforce word alignment.
    // Comment this if you plan to support 16-bit compressed instructions.
    // (Fired on the *cycle the address is sampled*; harmless in combinational mode.)
    // synopsys translate_off
    always_ff @(posedge clk) begin
        if (SYNC_READ && addr[1:0] != 2'b00)
            $error("[instr_mem] Unaligned fetch addr=%0h (LSB!=00, IMEM_LSB=%0d)", addr, IMEM_LSB);
    end
    // synopsys translate_on

    // --- Image load ---
    string hexfile;
    initial begin
        // Pre-fill with NOPs so any holes are deterministic
        for (int i = 0; i < WORDS; i++) mem[i] = NOP;

        if (!$value$plusargs("IMEM_HEX=%s", hexfile)) begin
            hexfile = DEFAULT_HEX;
        end

        // Light existence check (optional but nice during bring-up)
        integer fd;
        fd = $fopen(hexfile, "r");
        if (fd == 0) begin
            $fatal(1, "[instr_mem] Cannot open hex file '%0s'. Pass +IMEM_HEX=... or fix DEFAULT_HEX.", hexfile);
        end
        $fclose(fd);

        $display("[instr_mem] Loading hex file: %0s", hexfile);
        $readmemh(hexfile, mem);

        // Optional peek
        // $display("[instr_mem] mem[0]=%08x mem[1]=%08x mem[2]=%08x", mem[0], mem[1], mem[2]);
    end

    // --- Read behavior ---
    generate
        if (SYNC_READ) begin : g_sync
            always_ff @(posedge clk) begin
                instr <= out_of_range ? NOP : mem[widx];
            end
        end else begin : g_comb
            always_comb begin
                instr = out_of_range ? NOP : mem[widx];
            end
        end
    endgenerate

endmodule
