/*
  Author: Arjun Menon Vadakkeveedu
  Roll No.: EE18B104
  Electrical Engineering, IIT Madras
  October 2020
  Single Cycle CPU Implementation for RV32I ISA
  Instruction Memory Module
*/

`timescale 1ns/1ps

module imem (
    input [31:0] iaddr,
    output [31:0] idata
);
    // Ignores LSB 2 bits, so will not generate alignment exception
    reg [31:0] mem[0:4095]; // Define a 4-K location memory (16KB)
    initial begin $readmemh({`TESTDIR,"/idata.mem"},mem); end

    assign idata = mem[iaddr[31:2]];
endmodule
