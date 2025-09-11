import rv64_constants_pkg::*;

module reg_file #(
  parameter bit HARDWIRE_X0 = 1,
  parameter bit RAW_BYPASS  = 1
)
(
  input  logic                    clk,
  input  logic                    wen,
  input  logic [ADDRW-1:0]        rs1,  // use ADDRW if you defined it; else keep [4:0]
  input  logic [ADDRW-1:0]        rs2,
  input  logic [ADDRW-1:0]        rd,
  input  logic [XLEN-1:0]         wd,
  output logic [XLEN-1:0]         rd1,
  output logic [XLEN-1:0]         rd2
);

  // 32 x XLEN-bit register file
  logic [XLEN-1:0] registers [0:HLEN-1];  

`ifdef RF_SIM_INIT
  initial begin
    integer i;
    for (i = 0; i < HLEN; i++) registers[i] = '0;
  end
`endif

  always_ff @(posedge clk) begin
    if (wen && (!HARDWIRE_X0 || (rd != 5'd0))) registers[rd] <= wd;
    if (HARDWIRE_X0) registers[0] <= '0;
  end

  always_comb begin
    logic [XLEN-1:0] a1, a2;
    a1 = registers[rs1];
    a2 = registers[rs2];
    if (HARDWIRE_X0 && (rs1 == 5'd0)) a1 = '0;
    if (HARDWIRE_X0 && (rs2 == 5'd0)) a2 = '0;

    rd1 = (RAW_BYPASS && (wen === 1'b1) && (rd == rs1) && (!HARDWIRE_X0 || (rd != 5'd0))) ? wd : a1;
    rd2 = (RAW_BYPASS && (wen === 1'b1) && (rd == rs2) && (!HARDWIRE_X0 || (rd != 5'd0))) ? wd : a2;
  end

`ifdef ASSERTIONS
  assert property (@(posedge clk) registers[0] == '0) else $error("x0 violated");
  assert property (@(posedge clk) !(HARDWIRE_X0 && wen && (rd == 5'd0))) else $warning("Attempted write to x0 ignored");
`endif

endmodule




        // Only preload inputs for R-Type instruction tests
        /*
        registers[2]  = 64'd5;           // x2
        registers[3]  = 64'd10;          // x3
        registers[5]  = 64'd20;          // x5
        registers[6]  = 64'd8;           // x6
        registers[8]  = 64'hFF;          // x8
        registers[9]  = 64'h0F;          // x9
        registers[11] = 64'hF0;          // x11
        registers[12] = 64'h0F;          // x12
        registers[14] = 64'hAA;          // x14
        registers[15] = 64'h55;          // x15
        registers[17] = 64'd1;           // x17
        registers[18] = 64'd3;           // x18
        registers[20] = 64'd64;          // x20
        registers[21] = 64'd3;           // x21
        registers[23] = -64'sd16;        // x23
        registers[24] = 64'd2;           // x24
        registers[26] = 64'd3;           // x26
        registers[27] = 64'd7;           // x27
        registers[29] = 64'hFFFFFFFFFFFFFFF0; // x29
        registers[30] = 64'hFFFFFFFFFFFFFFF1; // x30
        */
        
        // === For JALR ===
        /*
        registers[1] = 64'd64;  // x1 = base jump address
        */
