import rv64_constants_pkg::*;

module data_mem #(
    parameter int DMEM_WORDS = 256,
    parameter bit SYNC_READ = 1
) (
    input         clk,          // Clock input
    input         MemRead,      // Read enable
    input         MemWrite,     // Write enable
    input  [XLEN-1:0] address,      // Byte address
    input  [XLEN-1:0] write_data,   // Data to write
    output [XLEN-1:0] read_data     // Data read
);

    localparam int INDEX_BITS = $clog2(DMEM_WORDS);
    wire [INDEX_BITS-1:0] idx = address[INDEX_BITS+2:3];
    
    // 256 words of 64-bit memory = 2KB memory
    logic [63:0] memory [0:DMEM_WORDS-1];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (MemWrite) begin
            memory[idx] <= write_data;
        end
    end

    generate
        if (SYNC_READ) begin : g_sync_read
            // 1-cycle registered read; "write-first" semantics on W/R same address
            always_ff @(posedge clk) begin
                if (MemRead) begin
                read_data <= (MemWrite) ? write_data : memory[idx];
                end else begin
                read_data <= '0;
                end
            end
        end else begin : g_async_read
        // Combinational read (may map to LUT RAM; easier timing-wise to use sync)
            always_comb begin
                read_data = MemRead ? memory[idx] : '0;
            end
        end
    endgenerate

    /*
    initial begin
        memory[2] = 64'd1234;  // Expected value to be loaded into x2
    end
    */
    
    // Optional initialization (uncomment to use during simulation)
    // initial begin
    //     $readmemh("data.mem", memory);
    // end

endmodule
