/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Assignment 7
  Single Cycle CPU Implementation- Peripheral Interfacing
  Peripheral module
  November 2020
*/

`timescale 1ns/1ps
`define OUTFILE "output.txt"

module outperiph (
    input clk,
    input reset,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata
);
    reg [31:0] status_reg;
    reg [31:0] rd_data;
    reg inc_sreg;
    integer op_file;

    always @(posedge clk) begin
    op_file = $fopen(`OUTFILE, "a");

    if (reset) status_reg <= 32'b0;
    else if ((dwe[0] == 1'b1) && (daddr == `OUTPERIPH_BASE + `OUTPERIPH_WRITE_OFFSET))
    begin   // only writing 1 byte, hence dwe = 4'b1 is sufficient
      status_reg <= status_reg + 1;
      $fwrite(op_file, "%c",dwdata);
    end
    $fclose(op_file);
    end

    always @(daddr or status_reg) begin
    if (daddr == `OUTPERIPH_BASE + `OUTPERIPH_READSTATUS_OFFSET) rd_data = status_reg;
    else rd_data = 32'bx;
    end

    assign drdata = rd_data;
    // Implement the peripheral logic here: use $fwrite to the file output.txt
    // Use the `define above to open the file so that it can be
    // overridden later if needed

    // Return value from here (if requested based on address) should
    // be the number of values written so far

    //assign drdata = 0;

endmodule
