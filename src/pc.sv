import rv64_constants_pkg::*;
// assign is for combinational logic, while always is for sequential logic
module pc (
	input  logic [XLEN-1:0] newAddr,	// remove 'reg' for inputs
	input  logic clk,
	input  logic rst,
	output logic [XLEN-1:0] oldAddr	// 'reg' is OK here since it's assigned in always block
);

	always_ff @ (posedge clk or posedge rst) begin // "or posedge rst" makes it an asynchronous reset
		
		if (rst)
			oldAddr <= '0;
		
		else begin
			oldAddr <= newAddr;
		end
		
	end

endmodule