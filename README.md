# 64-bit RISC-V CPU

A 64-bit RISC-V processor built in SystemVerilog, implementing the RV64I base instruction set (excluding OS-level instructions). Built with a modular architecture, where each component (ALU, Control, RegFile, PC, Memory) was unit-tested in simulation before full CPU integration. This project demonstrates a complete CPU datapath that executes important operations at the hardware level

---

## How It Works

The CPU follows the standard instruction execution cycle:
- Fetch: The processors looks at the current memory address and grabs the instruction.
- Decode: The processor figures out what the instructions is telling it to do.
- Execute: The processor performs the instruction.
- Memory: The processor reads/writes from/to memory if required.
- Writeback: The processor saves the result for future use.
This process repeats for every instruction in the Instruction Memory.

---

## Project Structure

```text
├── src/        # All main CPU components (Verilog modules)
│   ├── alu.v
│   ├── control.v
│   ├── reg_file.v
│   └── ...
│
├── tb/         # Testbenches to verify correctness of each module
│   ├── alu_tb.v
│   └── ...
│
├── docs/       # Reference materials, planning documents
│
├── img/        # Waveforms, timing diagrams, or screenshots
│
└── README.md   # You're reading it!

```
---

## How It Was Verified:
- Verified using SystemVerilog testbenches and ModelSim waveforms.

---

## What's Working Now
- Full support for R-Type instructions (ADD, SUB, AND, OR, XOR, etc.)

- Support for LW, SW, OP-IMM based I-Type instructions

- Functional ALU, Control Unit, Register File, and Program Counter

---

## What's Coming Next
- Extend the CPU to a 5 Stage Pipeline.

- Implement Hazard Handling: Data Hazards, Control Hazards, and Structural Hazards.

- Deploy for testing onto an FPGA.

- Explore Advanced Concepts: Out-of-Order execution, Superscalar pipelines, Cache hierarchies, Fabricating CPU.

---

## Want to Talk?
This project is part of our journey into digital systems design and low-level computer engineering. If you're working in ASIC design, FPGA development, or digital verification and want to connect — feel free to reach out to our emails at saivirup@gmail.com. and 

