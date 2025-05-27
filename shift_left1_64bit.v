module shift_left1_64bit (
    input  [63:0] in,
    output [63:0] out
);

    assign out = in << 1;

endmodule
