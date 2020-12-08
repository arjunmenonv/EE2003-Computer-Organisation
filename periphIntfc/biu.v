/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Assignment 7
  Single Cycle CPU Implementation- Peripheral Interfacing
  Bus Interface module
  November 2020
*/

`timescale 1ns/1ps
`define OUTPERIPH_BASE 32'h34560  // copy macros used in outbyte.c for base addr of peripheral
`define OUTPERIPH_WRITE_OFFSET 32'h00
`define OUTPERIPH_READSTATUS_OFFSET 32'h04
// Bus interface unit: assumes two branches of the bus -
// 1. connect to dmem
// 2. connect to a single peripheral
// The BIU needs to know the addresses at which DMEM and peripheral are
// connected, so it can do the required multiplexing.
// These need to be added as part of your code.
module biu (
    input clk,
    input reset,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata,

    // Signals going to/from dmem
    output [31:0] daddr1,
    output [31:0] dwdata1,
    output [3:0]  dwe1,
    input  [31:0] drdata1,

    // Signals going to/from peripheral
    output [31:0] daddr2,
    output [31:0] dwdata2,
    output [3:0]  dwe2,
    input  [31:0] drdata2
);
    reg [31:0] rd_data;
    // Modify below so that depending on the actual daddr range the BIU decides whether
    // the response was from DMEM or peripheral - maybe a MUX?
    always @(daddr or drdata1 or drdata2) begin
      if((daddr >= 0) && (daddr <= `MEMTOP)) rd_data = drdata1;
      else if (daddr == (`OUTPERIPH_BASE + `OUTPERIPH_READSTATUS_OFFSET)) rd_data = drdata2;
      else rd_data = 32'bx;
    end
    assign drdata = rd_data;

    // Send values to DMEM or peripheral (or both if it does not matter)
    // as required
    assign daddr1 = daddr;
    assign dwdata1 = dwdata;
    assign dwe1 = ((daddr >= 0) && (daddr <= `MEMTOP)) ? dwe : 4'b0;

    assign daddr2 = daddr;
    assign dwdata2 = dwdata;
    assign dwe2 = (daddr == (`OUTPERIPH_BASE + `OUTPERIPH_WRITE_OFFSET)) ? dwe : 4'b0;

endmodule
