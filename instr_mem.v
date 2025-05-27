module inst_mem (
    input  wire [63:0] address,
    output wire [31:0] instruction
);

    // Declare memory with 256 32-bit instruction slots
    reg [31:0] memory [0:255];

    // Combinational read
    assign instruction = memory[address[63:2]];

    // Initialize memory contents (optional)
    initial begin
        $readmemh("instructions.mem", memory);
    end

endmodule
