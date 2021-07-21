# 5-stage Pipelined Extension of RV32I CPU

Implementation of 5 stage Pipelining of the Single Cycle RV32I CPU. Changes in this implementation compared to the earlier version include: 
- Breaking up of datapath into Instruction Fetch (IF), Instruction Decode & Register Read (ID), ALU Execution (EX), Memory Access (MEM) and Register File Write Back (WB) stages
- Adding Registers to the datapath for saving states communicated between stages (modules IF_ID, ID_EX, EX_MEM, MEM_WB)
- Module to generate control signals in the ID stage; modifying datapath design to avoid anti-causal dependencies
- Data Forwarding from EX->ID and MEM->ID, Forwarding with single cycle stall in case of Load Hazards, Two-cycle stall and Pipeline Flush to mitigate Control Hazards

ISA Reference: The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA
               Document Version 20191214-draft
               Editors: Andrew Waterman, Krste Asanović (July 27, 2020)

Architecture inspired by the discussion in "Computer Organization and Design, RISC-V Edition" by David A. Patterson and John L. Hennessy

