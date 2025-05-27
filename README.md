# 64-bit RISC-V CPU (RV64I)

This project is a complete design of a 64-bit single-cycle RISC-V processor built from scratch in Verilog. It closely follows the RV64I instruction set architecture and was developed with modularity, clarity, and extensibility in mind. All components were designed, tested, and simulated individually before integration.

---

## 🚀 What This Project Does

- **Simulates how a real CPU works at the hardware level**
- **Executes basic computer instructions**, like addition, subtraction, and branching (decision-making)
- Helps understand the internal workings of processors, such as how they fetch instructions, decode them, process data, and store results

---

## 🧠 Why I Built This

I created this project as a way to deeply understand how real CPUs operate under the hood. Rather than just using processors, this project was about learning how to *build one*. From instruction decoding to memory operations, each module was written and tested by hand. This project pushes beyond class assignments into real digital logic engineering.

---

## 🧩 Project Structure
```markdown
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
├── docs/       # Diagrams, reference materials, planning documents
│
├── img/        # Waveforms, timing diagrams, or screenshots
│
└── README.md   # You're reading it!

```text
---

## ⚙️ How It Works (Conceptually)
Even if you’re not familiar with hardware design, the processor works like this:

Fetch – It looks at the current memory address and grabs the instruction.

Decode – It figures out what kind of instruction it is (e.g., add two numbers).

Execute – It performs the operation (like addition, logic, shift).

Memory – It may read or write to memory if needed.

Writeback – It saves the result for future use.

Repeat – It goes to the next instruction and does it again.

Each of these steps is represented by a custom Verilog module and connected through a datapath.

---
