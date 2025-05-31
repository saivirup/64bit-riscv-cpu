module sign_extend (
    input  [11:0] imm_in,
    output [63:0] imm_out
);
    assign imm_out = {{52{imm_in[11]}}, imm_in};
endmodule
