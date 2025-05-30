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

        // Only preload inputs for instruction tests
        registers[1] = 64'd3;
        registers[2] = 64'd5;
    end

endmodule
