module instr_mem (
    input  wire [63:0] address,
    output wire [31:0] instruction
);

    // Declare memory with 256 32-bit instruction slots
    reg [31:0] memory [0:255];

    // Combinational read
    assign instruction = memory[address[63:2]];

    // Hardcoded instruction memory for simulation
    initial begin
        memory[0] = 32'h003100B3;
        memory[1] = 32'h40628233;
        memory[2] = 32'h009473B3;
        memory[3] = 32'h00C5E533;
        memory[4] = 32'h00F746B3;
        memory[5] = 32'h01289833;
        memory[6] = 32'h015A59B3;
        memory[7] = 32'h418BDB33;
        memory[8] = 32'h01BD2CB3;
        memory[9] = 32'h01EEBE33;

        // Optional: zero out the rest of memory (not required)
        integer i;
        for (i = 10; i < 256; i = i + 1)
            memory[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)
    end

endmodule
