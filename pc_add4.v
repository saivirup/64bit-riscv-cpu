module pc_add4 (
    input  [63:0] pc,
    output [63:0] pc_plus_4
);
    assign pc_plus_4 = pc + 64'd4;
endmodule
