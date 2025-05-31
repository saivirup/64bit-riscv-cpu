module r_cpu (
    input clk,
    input rst,
    output [63:0] pc_out,
    output [31:0] instruction,
    output [4:0] rd,
    output [63:0] alu_result,
    output invalid  // Placeholder until invalid logic is defined
);

    // === PC + Instruction Fetch ===
    wire [63:0] pc_next;

    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .newAddr(pc_next),
        .oldAddr(pc_out)
    );

    pc_add4 pc_add4_inst (
        .pc(pc_out),
        .pc_plus_4(pc_next)
    );

    instr_mem instr_mem_inst (
        .address(pc_out),
        .instruction(instruction)
    );

    // === Instruction Fields ===
    wire [6:0] opcode   = instruction[6:0];
    assign rd           = instruction[11:7];
    wire [2:0] funct3   = instruction[14:12];
    wire [4:0] rs1      = instruction[19:15];
    wire [4:0] rs2      = instruction[24:20];
    wire funct7_5       = instruction[30];

    // === Control Unit ===
    wire RegWrite;
    wire [1:0] ALUOp;

    control control_inst (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );

    // === Register File ===
    wire [63:0] reg_data1, reg_data2;

    reg_file reg_file_inst (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wen(RegWrite),
        .wd(alu_result),
        .rd1(reg_data1),
        .rd2(reg_data2)
    );

    // === ALU Control ===
    wire [3:0] alu_control_signal;

    alu_control alu_control_inst (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_control(alu_control_signal)
    );

    // === ALU ===
    alu alu_inst (
        .a(reg_data1),
        .b(reg_data2),
        .alu_control(alu_control_signal),
        .ALUresult(alu_result)
    );

endmodule