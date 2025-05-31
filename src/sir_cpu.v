module sir_cpu (
    input clk,
    input rst,
    output [63:0] pc_out,
    output [31:0] instruction,
    output [4:0]  rd,
    output [63:0] alu_result,
    output        invalid
);

    // === PC + Instruction Fetch ===
    wire [63:0] pc_plus_4;
    wire [63:0] jump_target;
    wire [63:0] pc_next;

    // === Instruction Memory Output ===
    wire [31:0] instruction_internal;
    assign instruction = instruction_internal;

    // === Instruction Fields (MUST COME EARLY) ===
    wire [6:0]  opcode      = instruction_internal[6:0];
    wire [4:0]  rd_internal = instruction_internal[11:7];
    wire [2:0]  funct3      = instruction_internal[14:12];
    wire [4:0]  rs1         = instruction_internal[19:15];
    wire [4:0]  rs2         = instruction_internal[24:20];
    wire [6:0]  funct7      = instruction_internal[31:25];

    assign rd = rd_internal;

    // === JALR Control Logic ===
    wire is_jalr = (opcode == 7'b1100111);
    assign jump_target = alu_result & 64'hFFFFFFFFFFFFFFFE;
    assign pc_next = is_jalr ? jump_target : pc_plus_4;

    // === PC Register ===
    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .newAddr(pc_next),
        .oldAddr(pc_out)
    );

    // === PC + 4 Logic ===
    pc_add4 pc_add4_inst (
        .pc(pc_out),
        .pc_plus_4(pc_plus_4)
    );

    // === Instruction Memory ===
    instr_mem instr_mem_inst (
        .address(pc_out),
        .instruction(instruction_internal)
    );

    // === Control Signals ===
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
    wire [1:0] ALUOp;

    control control_inst (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg)
    );

    // === Register File ===
    wire [63:0] reg_data1, reg_data2;
    wire [63:0] write_back_data;

    reg_file reg_file_inst (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd_internal),
        .wen(RegWrite),
        .wd(write_back_data),
        .rd1(reg_data1),
        .rd2(reg_data2)
    );

    // === Immediate Type Decode ===
    wire [2:0] imm_type;
    imm_decoder imm_decoder_inst (
        .opcode(opcode),
        .imm_type(imm_type)
    );

    // === Immediate Generation ===
    wire [63:0] imm_out;
    sign_extend sign_extend_inst (
        .instr(instruction_internal),
        .imm_type(imm_type),
        .imm_out(imm_out)
    );


    // === ALU Control ===
    wire [3:0] alu_control_signal;

    alu_control alu_control_inst (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control_signal)
    );

    // === ALU Operand Selection ===
    wire [63:0] alu_operand2 = (ALUSrc) ? imm_out : reg_data2;

    // === ALU ===
    alu alu_inst (
        .a(reg_data1),
        .b(alu_operand2),
        .alu_control(alu_control_signal),
        .ALUresult(alu_result),
        .invalid_op(invalid)
    );

    // === Data Memory ===
    wire [63:0] mem_data;

    data_mem data_mem_inst (
        .clk(clk),
        .address(alu_result),
        .write_data(reg_data2),
        .read_data(mem_data),
        .MemRead(MemRead),
        .MemWrite(MemWrite)
    );

    // === Write-Back MUX (Handles JALR) ===
    assign write_back_data = is_jalr ? pc_plus_4 :
                             MemtoReg ? mem_data :
                             alu_result;

endmodule
