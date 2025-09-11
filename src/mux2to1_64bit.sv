import rv64_constants_pkg::*;

module mux2to1_64bit (
    input  logic [XLEN-1:0] a,    // input 0
    input  logic [XLEN-1:0] b,    // input 1
    input  logic            sel,  // select: 0 selects a, 1 selects b
    output logic [XLEN-1:0] out   // mux output
);

    assign out = sel ? b : a;

endmodule
