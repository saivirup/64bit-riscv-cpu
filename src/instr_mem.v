module instr_mem (
    input  wire [63:0] address,
    output wire [31:0] instruction
);

    // Declare memory with 256 32-bit instruction slots
    reg [31:0] memory [0:255];

    // Combinational read
    assign instruction = memory[address[63:2]];

    // Declare loop variable OUTSIDE the initial block
    integer i;

    // Initialize memory to all zeros (no file loading)
    initial begin
		for (i = 0; i < 256; i = i + 1) begin
			memory[i] = 32'h00000000;  // Set everything to 0
		end

		// Hardcoded program
		memory[0] = 32'h003100B3; // ADD x1, x2, x3
        memory[1] = 32'h40628233; // SUB x4, x5, x6
        memory[2] = 32'h009473B3; // AND x7, x8, x9
        memory[3] = 32'h00C5E533; // OR x10, x11, x12
        memory[4] = 32'h00F746B3; // XOR x13, x14, x15
        memory[5] = 32'h01289833; // SLL x16, x17, x18
        memory[6] = 32'h015A59B3; // SRL x19, x20, x21
        memory[7] = 32'h418BDB33; // SRA x22, x23, x24
        memory[8] = 32'h01BD2CB3; // SLT x25, x26, x27
        memory[9] = 32'h01EEBE33; // SLTU x28, x29, x30

	end


endmodule
