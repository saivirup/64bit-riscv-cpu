`timescale 1ns/1ps
`default_nettype none
import rv64_constants_pkg::*;  // must define HLEN, XLEN, imm_type_e, etc.

module sign_extend_tb;

  // -----------------------------
  // DUT I/O
  // -----------------------------
  logic [HLEN-1:0] instr;
  imm_type_e       imm_type;
  logic [XLEN-1:0] imm_out;

  sign_extend dut (
    .instr    (instr),
    .imm_type (imm_type),
    .imm_out  (imm_out)
  );

  // -----------------------------
  // Golden reference (decode)
  // -----------------------------
  function automatic logic [XLEN-1:0]
    golden_imm (input logic [HLEN-1:0] i, input imm_type_e t);
    logic [XLEN-1:0] out;
    begin
      out = '0;
      unique case (t)
        I_TYPE: begin
          //  imm[11:0] = i[31:20]
          out = {{(XLEN-12){i[31]}}, i[31:20]};
        end
        S_TYPE: begin
          //  imm[11:5]=i[31:25], imm[4:0]=i[11:7]
          out = {{(XLEN-12){i[31]}}, i[31:25], i[11:7]};
        end
        B_TYPE: begin
          //  imm[12|10:5|4:1|11] = i[31|30:25|11:8|7], imm[0]=0
          out = {{(XLEN-13){i[31]}}, i[31], i[7], i[30:25], i[11:8], 1'b0};
        end
        U_TYPE: begin
          //  imm = {i[31:12], 12'b0} with sign from bit31
          out = {{(XLEN-32){i[31]}}, i[31:12], 12'b0};
        end
        J_TYPE: begin
          //  imm[20|10:1|11|19:12] = i[31|30:21|20|19:12], imm[0]=0
          out = {{(XLEN-21){i[31]}}, i[31], i[19:12], i[20], i[30:21], 1'b0};
        end
        default: out = '0;
      endcase
      return out;
    end
  endfunction

  // -----------------------------
  // Instruction builders (encode)
  // Given a desired immediate value, place its bits into instr fields.
  // -----------------------------

  // I-type: imm is 12-bit signed
  function automatic logic [31:0] build_I (input logic signed [11:0] imm12);
    logic [31:0] x;
    begin
      x = '0;
      x[31:20] = imm12;
      return x;
    end
  endfunction

  // S-type: imm is 12-bit signed
  function automatic logic [31:0] build_S (input logic signed [11:0] imm12);
    logic [31:0] x;
    begin
      x = '0;
      x[31:25] = imm12[11:5];
      x[11:7]  = imm12[4:0];
      return x;
    end
  endfunction

  // B-type: imm is 13-bit signed with imm[0]=0 (i.e., even byte address)
  function automatic logic [31:0] build_B (input logic signed [12:0] imm13);
    logic [31:0] x;
    begin
      // caller should ensure imm13[0]==0
      x = '0;
      x[31]    = imm13[12];
      x[7]     = imm13[11];
      x[30:25] = imm13[10:5];
      x[11:8]  = imm13[4:1];
      return x;
    end
  endfunction

  // U-type: imm is 32-bit value with low 12 zero (we pass imm[31:12])
  function automatic logic [31:0] build_U (input logic [31:12] upper);
    logic [31:0] x;
    begin
      x = '0;
      x[31:12] = upper;
      return x;
    end
  endfunction

  // J-type: imm is 21-bit signed with imm[0]=0
  function automatic logic [31:0] build_J (input logic signed [20:0] imm21);
    logic [31:0] x;
    begin
      // caller should ensure imm21[0]==0
      x = '0;
      x[31]    = imm21[20];
      x[30:21] = imm21[10:1];
      x[20]    = imm21[11];
      x[19:12] = imm21[19:12];
      return x;
    end
  endfunction

  // -----------------------------
  // Check helper
  // -----------------------------
  task automatic check_one
    (input logic [HLEN-1:0] i_instr,
     input imm_type_e       i_type,
     input string           tag);
    logic [XLEN-1:0] exp;
    begin
      instr    = i_instr;
      imm_type = i_type;
      #1; // settle comb
      exp = golden_imm(i_instr, i_type);
      if (imm_out !== exp) begin
        $error("[%s] FAIL imm_out=%h exp=%h  instr=%h type=%0d",
               tag, imm_out, exp, i_instr, i_type);
        $fatal;
      end else begin
        $display("[%s] PASS imm_out=%h  instr=%h", tag, imm_out, i_instr);
      end
    end
  endtask

  // -----------------------------
  // Directed tests
  // -----------------------------
  initial begin
    // I-type: edges and sign
    check_one(build_I(12'sd0),        I_TYPE, "I: 0");
    check_one(build_I(12'sd2047),     I_TYPE, "I: +2047 (max)");
    check_one(build_I(-12'sd2048),    I_TYPE, "I: -2048 (min)");
    check_one(build_I(-12'sd1),       I_TYPE, "I: -1");

    // S-type: edges and sign
    check_one(build_S(12'sd16),       S_TYPE, "S: +16");
    check_one(build_S(-12'sd16),      S_TYPE, "S: -16");
    check_one(build_S(12'sd2047),     S_TYPE, "S: +2047");
    check_one(build_S(-12'sd2048),    S_TYPE, "S: -2048");

    // B-type: multiples of 2, 13-bit with bit0=0
    check_one(build_B(13'sd0),        B_TYPE, "B: 0");
    check_one(build_B(13'sd8),        B_TYPE, "B: +8");
    check_one(build_B(-13'sd8),       B_TYPE, "B: -8");
    check_one(build_B(13'sd4094),     B_TYPE, "B: +4094 (max)");  // 13-bit signed, LSB=0
    check_one(build_B(-13'sd4096),    B_TYPE, "B: -4096 (min)");

    // U-type: sign-extension from bit31; upper is imm[31:12]
    check_one(build_U(20'h12345),     U_TYPE, "U: 0x12345000");
    check_one(build_U(20'h80000),     U_TYPE, "U: negative upper (bit31=1)");
    check_one(build_U(20'h00000),     U_TYPE, "U: 0");

    // J-type: multiples of 2, 21-bit with bit0=0
    check_one(build_J(21'sd2048),     J_TYPE, "J: +2048");
    check_one(build_J(-21'sd4),       J_TYPE, "J: -4");
    check_one(build_J(21'sd0),        J_TYPE, "J: 0");
    check_one(build_J(21'sd1048574),  J_TYPE, "J: +1048574 (max)"); // 2^20-2
    check_one(build_J(-21'sd1048576), J_TYPE, "J: -1048576 (min)"); // -2^20

    // -----------------------------
    // Optional: light random sweeps
    // -----------------------------
`ifdef SE_RANDOM
    automatic int N = 200;
    automatic int k;

    // I random
    for (k=0; k<N; k++) begin
      logic signed [11:0] v = $urandom_range(0, 4095);
      if ($urandom_range(0,1)) v = -v;
      check_one(build_I(v), I_TYPE, $sformatf("I-rand %0d", k));
    end

    // S random
    for (k=0; k<N; k++) begin
      logic signed [11:0] v = $urandom_range(0, 4095);
      if ($urandom_range(0,1)) v = -v;
      check_one(build_S(v), S_TYPE, $sformatf("S-rand %0d", k));
    end

    // B random (force LSB=0)
    for (k=0; k<N; k++) begin
      logic signed [12:0] v = $urandom_range(-4096, 4094);
      v[0] = 1'b0;
      check_one(build_B(v), B_TYPE, $sformatf("B-rand %0d", k));
    end

    // U random (20 upper bits)
    for (k=0; k<N; k++) begin
      logic [31:12] upper = $urandom();
      check_one(build_U(upper), U_TYPE, $sformatf("U-rand %0d", k));
    end

    // J random (force LSB=0)
    for (k=0; k<N; k++) begin
      logic signed [20:0] v;
      v = $urandom_range(-(1<<20), (1<<20)-2);
      v[0] = 1'b0;
      check_one(build_J(v), J_TYPE, $sformatf("J-rand %0d", k));
    end
`endif

    $display("All sign_extend tests PASSED.");
    $finish;
  end

endmodule
`default_nettype wire
