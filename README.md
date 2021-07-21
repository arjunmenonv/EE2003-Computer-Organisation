# EE2003-Computer-Organisation

This repository contains the HDL models (verilog) of the components of a 5-stage Pipelined implementation of an RV32I (32-bit Integer riscv ISA) processor, along with the corresponding verilog testbenches. Also included is a single cycle implementation which was done as part of assignments for the EE2003 Computer Organisation Course in Fall 2020 at IITMadras.

**assign_1:** RTL model of a sequential (shift-and-add) multiplier for two 8-bit integers.

**assign_2:** riscv assembly code for computing the Nth Fibonacci number. 

**singlecycle_cpu:** (Assignments 3, 5 and 6) Implementation of the ALU (Assign3), Load-Store (Assign5) and Branch Instructions (Assign6) of the RV32I instruction set. 

Reference for hardware architecture: Computer Organization and Design, RISC-V Edition by David A. Patterson, John L. Hennessy

**pipelinedCPU:** Extension of the Single Cycle CPU for a 5-stage pipelined design, with Forwarding and Stalling to mitigate Data and Control Hazards.

**periphIntfc:** Includes bus interface unit, HDL model of a sample output peripheral and a C application for implementing the printf function, interfaced with the single cycle CPU implementation.

**synthCPU:** Includes tcl and yosys scripts for synthesising the single cycle CPU on a Xilinx Artix-7 class FPGA, along with minor modifications (without affecting functionality) in the HDL model for the register file.
