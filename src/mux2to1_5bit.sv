import rv64_constants_pkg::*;

module mux2to1_5bit (
    input  logic [4:0] in0,
    input  logic [4:0] in1,
    input  logic       sel,
    output logic [4:0] out
);

    assign out = sel ? in1 : in0;

endmodule