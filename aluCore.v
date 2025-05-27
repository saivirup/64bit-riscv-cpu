// Copyright (C) 2025  Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, the Altera Quartus Prime License Agreement,
// the Altera IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Altera and sold by Altera or its authorized distributors.  Please
// refer to the Altera Software License Subscription Agreements 
// on the Quartus Prime software download page.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 24.1std.0 Build 1077 03/04/2025 SC Lite Edition"
// CREATED		"Mon May 26 11:56:57 2025"

module aluCore(
	funct7_5,
	a,
	b,
	funct3,
	opcode,
	zero,
	ALUresult
);


input wire	funct7_5;
input wire	[63:0] a;
input wire	[63:0] b;
input wire	[2:0] funct3;
input wire	[6:0] opcode;
output wire	zero;
output wire	[63:0] ALUresult;

wire	[3:0] SYNTHESIZED_WIRE_0;
wire	[1:0] SYNTHESIZED_WIRE_1;





alu	b2v_inst(
	.a(a),
	.alu_control(SYNTHESIZED_WIRE_0),
	.b(b),
	.zero(zero),
	.ALUresult(ALUresult));


alu_control	b2v_inst2(
	.funct7_5(funct7_5),
	.ALUOp(SYNTHESIZED_WIRE_1),
	.funct3(funct3),
	.alu_control(SYNTHESIZED_WIRE_0));


control	b2v_inst3(
	.opcode(opcode),
	.ALUOp(SYNTHESIZED_WIRE_1));


endmodule
