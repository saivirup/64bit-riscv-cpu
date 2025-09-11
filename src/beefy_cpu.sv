import rv64_constants_pkg::*;  // brings in XLEN and any shared params/types

module beefy_cpu (
    input  logic                 clk,
    input  logic                 rst,
    output logic [XLEN-1:0]      pc_out,
    output logic [31:0]          instruction,
    output logic [11:0]          control_signals,
    output logic [XLEN-1:0]      imm_out,
    output logic [XLEN-1:0]      read_data_1,
    output logic [XLEN-1:0]      read_data_2,
    output logic [XLEN-1:0]      alu_result,
    output logic [XLEN-1:0]      read_data_mem,
    output logic                 zero,
    output logic                 invalid
);

    // =========================
    // Internal wires & fields
    // =========================
    logic [31:0] instr_wire;
    logic [6:0]  opcode = instr_wire[6:0];
    logic [2:0]  funct3 = instr_wire[14:12];
    logic [6:0]  funct7 = instr_wire[31:25];

    logic [2:0]  imm_type_wire;
    logic [XLEN-1:0] sig_imm_out;
    logic [XLEN-1:0] pc_old, pc_new;

    assign instruction = instr_wire;
    assign imm_out     = sig_imm_out;
    assign pc_out      = pc_old;

    // =========================
    // PC logic
    // =========================
    pc pc_inst (
        .clk     (clk),
        .rst     (rst),
        .newAddr (pc_new),
        .oldAddr (pc_old)
    );

    logic [XLEN-1:0] pc4;
    assign pc4 = pc_old + 64'd4;

    // =========================
    // Instruction Fetch
    // =========================
    instr_mem instr_mem_inst (
        .address     (pc_old),
        .instruction (instr_wire)
    );

    // =========================
    // Immediate Decode & Sign Extend
    // =========================
    imm_decoder imm_decoder_inst (
        .opcode   (instr_wire[6:0]),
        .imm_type (imm_type_wire)
    );

    sign_extend sign_extend_inst (
        .instr    (instr_wire),
        .imm_type (imm_type_wire),
        .imm_out  (sig_imm_out)
    );

    // =========================
    // Register File & Operand Selection
    // =========================
    logic [4:0]  muxReg, rs1, rs2;
    logic [XLEN-1:0] writeData, readData1, readData2;

    assign read_data_1 = readData1;
    assign read_data_2 = readData2;
    assign rs1 = instr_wire[19:15];
    assign rs2 = instr_wire[24:20];

    // =========================
    // Jump Target Calculation (FIXED)
    // =========================
    // JAL:  target = PC + sign_extended_imm   (imm already pre-shifted if your sign_extend does it)
    // JALR: target = (rs1 + sign_extended_imm) & ~1
    logic [XLEN-1:0] jal_target  = pc_old + sig_imm_out;
    logic [XLEN-1:0] jalr_target = (readData1 + sig_imm_out) & ~{{(XLEN-1){1'b0}},1'b1};
    logic [XLEN-1:0] jump_target =
        (opcode == 7'b1101111) ? jal_target  : // JAL
        (opcode == 7'b1100111) ? jalr_target : // JALR
        '0;

    // =========================
    // Branch Target Calculation (FIXED)
    // =========================
    // Branch: target = PC + sign_extended_imm (imm already pre-shifted if your sign_extend does it)
    logic [XLEN-1:0] branch_target = pc_old + sig_imm_out;

    // =========================
    // Control Signals
    // =========================
    logic RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    logic [2:0] ALUOp;

    assign control_signals = {
        RegDst, Jump, Branch, MemRead, MemtoReg,
        MemWrite, ALUSrc, RegWrite, 1'b0, ALUOp
    };

    control control_unit (
        .opcode   (opcode),
        .RegDst   (RegDst),
        .Jump     (Jump),
        .Branch   (Branch),
        .MemRead  (MemRead),
        .MemtoReg (MemtoReg),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp)
    );

    mux2to1_5bit muxR (
        .in0 (instr_wire[24:20]),
        .in1 (instr_wire[11:7]),
        .sel (RegDst),
        .out (muxReg)
    );

    reg_file reg_file_inst (
        .clk (clk),
        .wen (RegWrite),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd  (muxReg),
        .wd  (writeData),
        .rd1 (readData1),
        .rd2 (readData2)
    );

    // =========================
    // ALU
    // =========================
    logic [XLEN-1:0] alu_b;
    mux2to1_64bit muxA (  // keep name if your existing module is fixed at 64b
        .a   (readData2),
        .b   (sig_imm_out),
        .sel (ALUSrc),
        .out (alu_b)
    );

    logic        Zero;
    alu_ctrl_e alu_control;
    logic [XLEN-1:0] ALUresult;
    assign zero       = Zero;
    assign alu_result = ALUresult;

    alu alu_inst (
        .a           (readData1),
        .b           (alu_b),
        .alu_control (alu_control),
        .invalid_op  (invalid),
        .ALUresult   (ALUresult),
        .Zero        (Zero)
    );

    alu_control alu_control_inst (
        .ALUOp       (ALUOp),
        .funct3      (funct3),
        .funct7      (funct7),
        .alu_control (alu_control)
    );

    // =========================
    // Branch Decision Logic (Using ALU)
    // =========================
    logic branch_cmp_taken;
    
    always_comb begin
        branch_cmp_taken = 1'b0; // default
        
        if (Branch) begin
            unique case (funct3)
                3'b000: branch_cmp_taken = Zero;         // BEQ: branch if rs1-rs2 == 0
                3'b001: branch_cmp_taken = ~Zero;        // BNE: branch if rs1-rs2 != 0
                3'b100: branch_cmp_taken = ALUresult[0]; // BLT: branch if rs1 < rs2 (signed)
                3'b101: branch_cmp_taken = ALUresult[0]; // BGE: branch if rs1 >= rs2 (signed)
                3'b110: branch_cmp_taken = ALUresult[0]; // BLTU: branch if rs1 < rs2 (unsigned)
                3'b111: branch_cmp_taken = ALUresult[0]; // BGEU: branch if rs1 >= rs2 (unsigned)
                default: branch_cmp_taken = 1'b0;
            endcase
        end
    end

    logic branch_taken = Branch && branch_cmp_taken;

    // =========================
    // Next PC Selection
    // =========================
    logic [XLEN-1:0] pc_after_branch;
    mux2to1_64bit branch_mux (
        .a   (pc4),
        .b   (branch_target),
        .sel (branch_taken),
        .out (pc_after_branch)
    );

    mux2to1_64bit jump_mux (
        .a   (pc_after_branch),
        .b   (jump_target),
        .sel (Jump),
        .out (pc_new)
    );

    // =========================
    // Data Memory
    // =========================
    logic [XLEN-1:0] mem_data_out;
    assign read_data_mem = mem_data_out;

    data_mem data_mem_inst (
        .clk        (clk),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .address    (ALUresult),
        .write_data (readData2),
        .read_data  (mem_data_out)
    );

    // =========================
    // Writeback Selection (ALU, Mem, PC+4)
    // =========================
    mux3to1_64bit writeback_mux (
        .a   (ALUresult),     // ALU
        .b   (mem_data_out),  // Load
        .c   (pc4),           // JAL/JALR
        .sel ({Jump, MemtoReg}),
        .out (writeData)
    );

endmodule