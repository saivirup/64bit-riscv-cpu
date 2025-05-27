module mux2to1_64bit (
    input  [63:0] a,    // input 0
    input  [63:0] b,    // input 1
    input         sel,  // select: 0 selects a, 1 selects b
    output [63:0] out   // mux output
);

    assign out = sel ? b : a;

endmodule
