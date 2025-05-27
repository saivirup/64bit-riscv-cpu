module sign_extend (

	input [31:0] instr,
	input [2:0] imm_type,
	output reg [63:0] imm_out

);

	always @(*) begin
		case (imm_type)
			3'b000: imm_out = {{52{instr[31]}}, instr[31:20]}; // I-type
			3'b001: imm_out = {{52{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
			3'b010: imm_out = {{51{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // SB-type
			3'b011: imm_out = {instr[31:12], 12'b0}; // U-type
			3'b100: imm_out = {{43{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // UJ-type
			default: imm_out = 64'b0;
		endcase
	end
	
endmodule
			