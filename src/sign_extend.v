module sign_extend (
    input  [31:0] instr,
    input  [2:0]  imm_type,
    output reg [63:0] imm_out
);

    // === Immediate types ===
    localparam I_TYPE      = 3'b000;
    localparam S_TYPE      = 3'b001;
    localparam B_TYPE      = 3'b010;
    localparam U_TYPE      = 3'b011;
    localparam J_TYPE      = 3'b100;
    localparam INVALID_TYPE = 3'b111;

    always @(*) begin
        case (imm_type)
        
            I_TYPE: begin
                // imm[11:0] = instr[31:20]
                imm_out = {{52{instr[31]}}, instr[31:20]};
            end

            S_TYPE: begin
                // imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
                imm_out = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            end

            B_TYPE: begin
                // imm[12|10:5|4:1|11] = instr[31|30:25|11:8|7], with imm[0] = 0
                imm_out = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            U_TYPE: begin
                // imm[31:12] = instr[31:12], imm[11:0] = 0
                imm_out = {{32{instr[31]}}, instr[31:12], 12'b0};
            end

            J_TYPE: begin
                // imm[20|10:1|11|19:12] = instr[31|30:21|20|19:12], imm[0] = 0
                imm_out = {{43{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            // TODO: Add invalid flag output if used in pipelined CPU
            default: begin
                // INVALID_TYPE or undefined: signal zero
                imm_out = 64'b0;
            end

        endcase
    end

endmodule
