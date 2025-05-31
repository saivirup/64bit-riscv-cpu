`timescale 1ns/1ps

module instr_mem (
    input  wire [63:0] address,
    output wire [31:0] instruction
);

    // === 256-word Instruction Memory (32-bit each) ===
    reg [31:0] memory [0:255];

    // Loop variable for initialization
    integer i;

    // === Combinational Read ===
    assign instruction = memory[address[63:2]];

    // === Instruction Initialization for Simulation ===
    initial begin

        // -----------------------------------------------
        // R-Type Instructions (Commented Out)
        // -----------------------------------------------
        /*
        memory[0] = 32'h003100B3; // ADD  x1,  x2,  x3
        memory[1] = 32'h40628233; // SUB  x4,  x5,  x6
        memory[2] = 32'h009473B3; // ADD  x7,  x8,  x9
        memory[3] = 32'h00C5E533; // AND  x10, x11, x12
        memory[4] = 32'h00F746B3; // OR   x13, x14, x15
        memory[5] = 32'h01289833; // XOR  x16, x17, x18
        memory[6] = 32'h015A59B3; // SLL  x19, x20, x21
        memory[7] = 32'h418BDB33; // SRA  x22, x23, x24
        memory[8] = 32'h01BD2CB3; // SRL  x25, x26, x27
        memory[9] = 32'h01EEBE33; // SLT  x28, x29, x30
        */

        // -----------------------------------------------
        // I-Type Arithmetic Instructions (Commented Out)
        // -----------------------------------------------
        /*
        memory[0] = 32'h00800093; // ADDI  x1,  x0, 8
        memory[1] = 32'h00A0A113; // SLTI  x2,  x1, 10
        memory[2] = 32'h00A0B193; // SLTIU x3,  x1, 10
        memory[3] = 32'h0050C213; // XORI  x4,  x1, 5
        memory[4] = 32'h0020E293; // ORI   x5,  x1, 2
        memory[5] = 32'h0030F313; // ANDI  x6,  x1, 3
        memory[6] = 32'h00109393; // SLLI  x7,  x1, 1
        memory[7] = 32'h0010D413; // SRLI  x8,  x1, 1
        memory[8] = 32'h4010D493; // SRAI  x9,  x1, 1
        */

        // -----------------------------------------------
        // Load Word (LW) Instruction Test
        // -----------------------------------------------
        /*
        memory[0] = 32'h01000093; // ADDI x1, x0, 16       ; x1 = 16
        memory[1] = 32'h0000A103; // LW   x2, 0(x1)        ; x2 = Mem[16]
        */

        // -----------------------------------------------
        // Jump And Link Register (JALR) Instruction Test
        // -----------------------------------------------

        memory[0] = 32'h00808567;  // jalr x10, x1, 8 -> PC should jump to 72

        // -----------------------------------------------
        // Fill Remaining Memory with NOPs
        // -----------------------------------------------
        for (i = 1; i < 256; i = i + 1)
            memory[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)

    end

endmodule
