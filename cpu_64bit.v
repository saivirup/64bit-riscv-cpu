module cpu_64bit (
    input clk,
    input rst,
    output [63:0] pc_out,
    output [31:0] instruction_out,
    output [63:0] alu_result_out
);

    // Internal wires
    wire [63:0] pc, pc_next, pc_plus_4;
    wire [31:0] instruction;
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire funct7_5 = instruction[30];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];

    // Control signals
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, Jump;
    wire [2:0] ALUOp;
    wire [3:0] alu_control_signal;

    // Register file
    wire [63:0] rd1, rd2;
    wire [63:0] write_back_data, final_write_data;

    // Immediate logic
    wire [2:0] imm_type;
    wire [63:0] imm_out, imm_shifted;

    // ALU
    wire [63:0] operand2;
    wire [63:0] alu_result;
    wire alu_zero;

    // Branch logic
    wire [63:0] branch_target;
    wire branch_en;

    // Program Counter
    pc pc_module (
        .clk(clk),
        .rst(rst),
        .oldAddr(pc_next),
        .newAddr(pc)
    );

    adder_64bit pc_adder (
        .a(pc),
        .b(64'd4),
        .sum(pc_plus_4)
    );

    inst_mem instruction_memory (
        .address(pc),
        .instruction(instruction)
    );

    control control_unit (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    reg_file register_file (
        .clk(clk),
        .wen(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(final_write_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    imm_type_decoder decoder (
        .opcode(opcode),
        .imm_type(imm_type)
    );

    sign_extend sign_extender (
        .instr(instruction),
        .imm_type(imm_type),
        .imm_out(imm_out)
    );

    mux2to1_64bit alu_mux (
        .a(rd2),
        .b(imm_out),
        .sel(ALUSrc),
        .out(operand2)
    );

    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_control(alu_control_signal)
    );

    alu alu_unit (
        .a(rd1),
        .b(operand2),
        .alu_control(alu_control_signal),
        .zero(alu_zero),
        .ALUresult(alu_result)
    );

    data_mem memory (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(rd2),
        .read_data(write_back_data)
    );

    mux2to1_64bit writeback_mux (
        .a(alu_result),
        .b(write_back_data),
        .sel(MemtoReg),
        .out(final_write_data)
    );

    shift_left1_64bit sl1 (
        .in(imm_out),
        .out(imm_shifted)
    );

    adder_64bit branch_adder (
        .a(pc),
        .b(imm_shifted),
        .sum(branch_target)
    );

    and_gate branch_condition (
        .a(Branch),
        .b(alu_zero),
        .y(branch_en)
    );

    mux2to1_64bit pc_select (
        .a(pc_plus_4),
        .b(branch_target),
        .sel(branch_en),
        .out(pc_next)
    );

    assign pc_out = pc;
    assign instruction_out = instruction;
    assign alu_result_out = alu_result;

endmodule
