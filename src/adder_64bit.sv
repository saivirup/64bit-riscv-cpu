import rv64_constants_pkg::*;

module adder_64bit (
    input  logic [XLEN-1:0] a,
    input  logic  [XLEN-1:0] b,
    output logic [XLEN-1:0] sum
);

    assign sum = a + b;

endmodule