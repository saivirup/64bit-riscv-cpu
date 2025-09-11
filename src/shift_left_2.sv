import rv64_constants_pkg::*;  // bring in your parameter definitions

module shift_left_2 (
    input  logic [XLEN-1:0] x,   // XLEN from constants_pkg (usually 64)
    output logic [XLEN-1:0] y
);

    // Shift input left by 2 bits (multiply by 4), used in branch address alignment
    assign y = x << 2;

endmodule
