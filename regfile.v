/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Assignment 5
  Single Cycle CPU Implementation- ALU, Load and Store Instructions
  Regfile module
  October 2020

  Description: Declare 32 registers of width 32-bits and initialise them by reading from a .mem file
               Implement Synchronous Write to and asynchronous read from the regfile
*/


`define INIT_MEM "init_regfile.mem"
module regfile(
    input [4:0] rs1,     // address of first operand to read - 5 bits
    input [4:0] rs2,     // address of second operand
    input [4:0] rd,      // address of value to write
    input we,            // should write update occur
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    input clk            // Clock signal - all changes at clock posedge
);
    // Desired function
    // rv1, rv2 are combinational outputs - they will update whenever rs1, rs2 change
    // on clock edge, if we=1, regfile entry for rd will be updated
    reg [31:0] x [0:31];
    initial begin       // synthesised as Distributed RAM using LUTs
      $readmemh(`INIT_MEM, x);
    end
    //Synchronous Write to reg
    always @(posedge clk) begin
    if(we) begin
      if(rd == 5'b0)  x[0] <= 32'b0;
      else            x[rd] <= wdata;
    end
    end
    //Async read
    assign rv1 = (rs1 == 0) ? 32'b0 :
                 ((rs1 == rd) && we) ? wdata : x[rs1];
    assign rv2 = (rs2 == 0) ? 32'b0 :
                 ((rs2 == rd) && we) ? wdata : x[rs2];
endmodule
