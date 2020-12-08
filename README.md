# EE2003-Computer-Organisation

This repository contains the HDL models (verilog) of the components of a single cycle implementation of an RV32I (32-bit Integer riscv ISA) processor, along with the corresponding verilog testbenches. 

**assign_1:** RTL model of a sequential (shift-and-add) multiplier for two 8-bit integers.

**assign_2:** riscv assembly code for computing the Nth Fibonacci number. 

**singlecycle_cpu:** (Assignments 3, 5 and 6) Implementation of the ALU (Assign3), Load-Store (Assign5) and Branch Instructions (Assign6) of the RV32I instruction set. 

Reference for hardware architecture: Computer Organization and Design, RISC-V Edition by David A. Patterson, John L. Hennessy

**periphIntfc:** Includes bus interface unit, HDL model of a sample output peripheral and a C application for implementing the printf function, interfaced with the single cycle CPU implementation.

**synthCPU:** Includes tcl and yosys scripts for synthesising the single cycle CPU on a Xilinx Artix-7 class FPGA, along with minor modifications (without affecting functionality) in the HDL model for the register file.
