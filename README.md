# Simple-RISC-Processor

This repository contains the complete Verilog implementation of a pipelined processor with support for arithmetic operations, memory access, and register write-back. It also includes simulation testbenches, block schematics, and output memory results.

---

## 🗂️ Folder Structure

### `/Sources`
Contains all the Verilog module source files:
- `top_mod.v`: Top-level module integrating all pipeline stages.
- `fetch_unit.v`
- `control_unit.v`
- `operand_fetch_unit.v`
- `execute_unit.v`
  - `adder_sub.v`
  - `multiplier.v`
  - `divider.v`
  - `shifter.v`
- `memory_unit.v`
- `reg_writeback_unit.v`

### `/Simulation`
Contains testbenches for each module:
- Each source file has a corresponding `*_tb.v` file for simulation testing.

### `/Processor_Sch`
Processor pipeline schematics:
- `top_mod.pdf`
- `fetch.pdf`
- `control.pdf`
- `operand.pdf`
- `execute.pdf`
- `memory.pdf`
- `reg_write.pdf`
- `ALU_Sch/` — Subfolder for ALU component schematics:
  - `adder.pdf`
  - `divider.pdf`
  - `multiplier.pdf`
  - `shifter.pdf`

### `/output`
Contains memory dump outputs for the test program:
```asm
mov r0, 70
mov r2, -70
add r1, r2, r0
add r1, r0, 1
```

Binary representation:
```asm
01001100000000000000000001000110
01001100100000001111111110111010
00000000010010000000000000000000
00000100010000000000000000000001
```

![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im1.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im2.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im3.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im4.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im5.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im6.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im7.png)
![Simulation Output](https://github.com/puneethreddy592/Simple-RISC-Processor/blob/bc5f2b304b7363a4241bfa8cddb6c1d418325877/output/im8.png)
### ✅ Features
- 5-stage pipelining: Instruction Fetch → Operand Fetch + Control → Execute → Memory → Register Write-back
- ALU Operations: Addition, Subtraction, Multiplication, Division, Shifting, Logical And, Or, Not, Mov
- Register File and Memory Interface
- Schematic Diagrams for visual understanding of each stage and submodules
- Fully Testbenched: Simulations for each module to verify functionality

### 🚀 How to Run Simulations
- Open Vivado
- Compile the top module and include all required files from /Sources.
- Run the testbenche (tom_mod_tb.v) found in /Simulation.
- Observe waveform outputs and register/memory contents to validate functionality.

### 📃 License
This project is open-source under the MIT License. See LICENSE for more details.

