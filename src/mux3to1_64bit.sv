import rv64_constants_pkg::*;

module mux3to1_64bit (
    input  logic [XLEN-1:0] a, b, c,
    input  logic [1:0] sel,
    output logic [XLEN-1:0] out
);
    always_comb begin
        case (sel)
            2'b00: out = a; // ALU
            2'b01: out = b; // Memory
            2'b10: out = c; // PC+4
            default: out = '0;
        endcase
    end
endmodule
