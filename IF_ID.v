/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Project Extension
  5 stage Pipelined CPU Implementation of the RISCV RV32I ISA
  IF/ID Register Module
  July 2021

  Description: - IF_ID register storing PC_curr and idata
               - No control logic to be implemented here 
               - Stall Bit (data hazard stalls) disallows Register Writes

*/
module IF_ID(
  input clk,
  input reset,
  input [31:0] PC_curr_in,
  input [31:0] idata_in,
  input is_nop_in,
  input stall,
  output reset_out,
  output [31:0] PC_curr_out,
  output [31:0] idata_out,
  output is_nop_out  );
reg reset_out;
reg [31:0] PC_curr_out;
reg [31:0] idata_out;
reg is_nop_out;

always @ (posedge clk) begin
  reset_out <= reset;
  is_nop_out <= is_nop_in;
  if (reset) begin
  PC_curr_out <= 0;
  idata_out <= 0;
  end
  else if (!stall) begin      //Stall Routine 1: Disallow writes to IF/ID
  PC_curr_out <= PC_curr_in;
  idata_out <= idata_in;
  end
end
endmodule
