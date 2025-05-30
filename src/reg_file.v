module reg_file (
    input         clk,
    input         wen,            // Write enable
    input  [4:0]  rs1,            // Read address 1
    input  [4:0]  rs2,            // Read address 2
    input  [4:0]  rd,             // Write address
    input  [63:0] wd,             // Write data
    output [63:0] rd1,            // Read data 1
    output [63:0] rd2             // Read data 2
);

    // 32 registers of 64-bit each
    reg [63:0] registers [0:31];

    // Asynchronous read logic
    assign rd1 = (rs1 == 0) ? 64'b0 : registers[rs1];
    assign rd2 = (rs2 == 0) ? 64'b0 : registers[rs2];

    // Synchronous write logic
    always @(posedge clk) begin
        if (wen && rd != 0) begin
            registers[rd] <= wd;
        end
    end

    // Initial preload block for simulation
    integer i; // <- declare outside the begin-end block
	 
	 initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'd0;
        end

        // Updated initial values to match testbench expectations
        registers[2]  = 64'd5;                   // x2
        registers[3]  = 64'd10;                  // x3
        registers[5]  = 64'd20;                  // x5
        registers[6]  = 64'd8;                   // x6
        registers[8]  = 64'hFF;                  // x8
        registers[9]  = 64'h0F;                  // x9
        registers[11] = 64'hF0;                 // x11
        registers[12] = 64'h0F;                 // x12
        registers[14] = 64'hAA;                 // x14
        registers[15] = 64'h55;                 // x15
        registers[17] = 64'd1;                  // x17
        registers[18] = 64'd3;                  // x18
        registers[20] = 64'd64;                 // x20
        registers[21] = 64'd3;                  // x21
        registers[23] = -64'sd16;               // x23
        registers[24] = 64'd2;                  // x24
        registers[26] = 64'd3;                  // x26
        registers[27] = 64'd7;                  // x27
        registers[29] = 64'hFFFFFFFFFFFFFFF0;   // x29
        registers[30] = 64'hFFFFFFFFFFFFFFF1;   // x30

    end

endmodule