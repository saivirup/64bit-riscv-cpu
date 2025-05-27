// assign is for combinational logic, while always is for sequential logic

module pc (

	input [63:0] newAddr,	// remove 'reg' for inputs
	input clk,
	input rst,
	output reg [63:0] oldAddr	// 'reg' is OK here since it's assigned in always block

);

	always @ (posedge clk or posedge rst) begin // "or posedge rst" makes it an asynchronous reset
		
		if (rst) begin
			oldAddr <= 64'd0;
		end
		
		else begin
			oldAddr <= newAddr;
		end
		
	end

endmodule