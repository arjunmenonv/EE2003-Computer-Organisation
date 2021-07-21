/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Project Extension
  5 stage Pipelined CPU Implementation of the RISCV RV32I ISA
  ID/EX Register Module
  July 2021

  Description:  - Stores state signals generated in ID stage
                - No control signal derived combinational logic to be implemented here (all
                 subsequent pipeline regs incorporate setting data signals using combinational logic)
                - rd <= 0 in case of nop 
*/
module ID_EX(
  input clk,
  input reset,
  input [31:0] PC_curr_in,
  input [5:0] op_in,
  input [1:0] instr_type_in,
  input [2:0] sub_op_in,
  input [4:0] rd_in,
  input [31:0] rv1_in,
  input [31:0] rv2_in,
  input [31:0] r_rv2_in,
  input [31:0] imm_val_in,
  input is_load_in,
  input is_store_in,
  input is_nop_in,
  output reset_out,
  output [31:0] PC_curr_out,
  output [5:0] op_out,
  output [1:0] instr_type_out,
  output [2:0] sub_op_out,
  output [4:0] rd_out,
  output [31:0] rv1_out,
  output [31:0] rv2_out,
  output [31:0] r_rv2_out,
  output [31:0] imm_val_out,
  output is_load_out,
  output is_store_out,
  output is_nop_out  );

reg reset_out;
reg [31:0] PC_curr_out;
reg [5:0] op_out;
reg [1:0] instr_type_out;
reg [2:0] sub_op_out;
reg [4:0] rd_out;
reg [31:0] rv1_out;
reg [31:0] rv2_out;
reg [31:0] r_rv2_out;
reg [31:0] imm_val_out;
reg is_load_out;
reg is_store_out;
reg is_nop_out;

always @(posedge clk) begin
  reset_out <= reset;
  is_nop_out <= is_nop_in;
  if (reset) begin
    PC_curr_out <= 0;
    op_out <= 0;
    instr_type_out <= 0;
    sub_op_out <= 0;
    rd_out <= 0;
    rv1_out <= 0;
    rv2_out <= 0;
    r_rv2_out <= 0;
    imm_val_out <= 0;
    is_load_out <= 0;
    is_store_out <= 0;
  end
  else if (is_nop_in) rd_out <= 0;    // This ensures that a NOP bubble does not trigger another stall
  else begin
    PC_curr_out <= PC_curr_in;
    op_out <= op_in;
    instr_type_out <= instr_type_in;
    sub_op_out <= sub_op_in;
    rd_out <= rd_in;
    rv1_out <= rv1_in;
    rv2_out <= rv2_in;
    r_rv2_out <= r_rv2_in;
    imm_val_out <= imm_val_in;
    is_load_out <= is_load_in;
    is_store_out <= is_store_in;
  end
end
endmodule
