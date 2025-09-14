# 64-bit RISC-V CPU

A 64-bit RISC-V processor built in SystemVerilog, implementing the core RV64I base instruction set. Built with a modular architecture, where each component (ALU, Control, RegFile, PC, Memory) was unit-tested in simulation before full CPU integration. This project demonstrates a complete CPU datapath that executes arithmetic, logic, memory, and branch operations at the hardware level.

---

## Architecture Overview

The CPU follows the standard instruction execution cycle: Fetch → Decode → Execute → Memory → Writeback. This process repeats for every instruction in the Instruction Memory, enabling sequential program execution through the complete datapath.

---

## Project Structure

```text
├── src/        # All main CPU components (SystemVerilog modules)
│   ├── alu.sv
│   ├── control.sv
│   ├── reg_file.sv
│   ├── pc.sv
│   └── memory.sv
│
├── tb/         # Testbenches to verify correctness of each module
│   ├── alu_tb.sv
│   ├── control_tb.sv
│   └── cpu_tb.sv
│
├── docs/       # Reference materials, planning documents
│
├── img/        # Waveforms, timing diagrams, or screenshots
│
└── README.md   # You're reading it!
```

---

## Verification & Testing

Each module was unit-tested in isolation with SystemVerilog testbenches. Integration tests were run in ModelSim, and waveforms were traced to validate datapath correctness. The modular testing approach ensured reliable component integration and simplified debugging during full CPU assembly.

---

## What's Working Now

- Full support for R-Type instructions (ADD, SUB, AND, OR, XOR, etc.)
- Support for LW, SW, OP-IMM based I-Type instructions
- Core modules fully functional and integrated: ALU, Control Unit, Register File, Program Counter

---

## What's Coming Next

- Extend the CPU to a 5-Stage Pipeline
- Implement Hazard Handling: Data Hazards, Control Hazards, and Structural Hazards
- Deploy for testing onto an FPGA
- Explore Advanced Concepts: Out-of-Order execution, Superscalar pipelines, Cache hierarchies, and synthesis-to-fabrication workflows

---

## Want to Talk?

This project is part of our journey into digital systems design and low-level computer engineering. If you're working in ASIC design, FPGA development, or digital verification and want to connect — reach me at saivirup@gmail.com
