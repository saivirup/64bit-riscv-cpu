`timescale 1ns/1ps

module data_mem (
    input         clk,          // Clock input
    input         MemRead,      // Read enable
    input         MemWrite,     // Write enable
    input  [63:0] address,      // Byte address
    input  [63:0] write_data,   // Data to write
    output [63:0] read_data     // Data read
);

    // 256 words of 64-bit memory = 2KB memory
    reg [63:0] memory [0:255];

    // Synchronous write
    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address[63:3]] <= write_data;
        end
    end

    // Asynchronous read
    assign read_data = (MemRead) ? memory[address[63:3]] : 64'b0;

    // Optional initialization (uncomment to use during simulation)
    // initial begin
    //     $readmemh("data.mem", memory);
    // end

endmodule
