`timescale 1ns/1ps
import rv64_constants_pkg::*;   // bring in enums & opcode constants

module imm_decoder_tb;

  // DUT signals
  opcode_e   opcode;
  imm_type_e imm_type;

  // Instantiate DUT
  imm_decoder dut (
    .opcode   (opcode),
    .imm_type (imm_type)
  );

  // Task for checking
  task automatic check(
    input opcode_e   op,
    input imm_type_e expected,
    input string     tag
  );
    begin
      opcode = op;
      #1; // let always_comb settle
      if (imm_type !== expected) begin
        $error("[%s] FAIL: opcode=%s (%0d) expected=%s got=%s",
               tag, op.name(), op, expected.name(), imm_type.name());
      end else begin
        $display("[%s] PASS: opcode=%s -> imm_type=%s",
                 tag, op.name(), expected.name());
      end
    end
  endtask

  initial begin
    $display("=== imm_decoder Testbench Start ===");

    // Valid opcodes
    check(OPCODE_LOAD,   I_TYPE,   "LOAD");
    check(OPCODE_ITYPE,  I_TYPE,   "OP-IMM");
    check(OPCODE_JALR,   I_TYPE,   "JALR");

    check(OPCODE_STORE,  S_TYPE,   "STORE");
    check(OPCODE_BRANCH, B_TYPE,   "BRANCH");

    check(OPCODE_LUI,    U_TYPE,   "LUI");
    check(OPCODE_AUIPC,  U_TYPE,   "AUIPC");

    check(OPCODE_JAL,    J_TYPE,   "JAL");

    // An invalid example
    opcode = opcode_e'(7'h7F); // cast raw value not in list
    #1;
    if (imm_type !== INVALID_TYPE) begin
      $error("[INVALID] FAIL: expected INVALID_TYPE got %s", imm_type.name());
    end else begin
      $display("[INVALID] PASS: opcode=7'h7F -> imm_type=INVALID_TYPE");
    end

    $display("=== imm_decoder Testbench Done ===");
    $finish;
  end

endmodule
