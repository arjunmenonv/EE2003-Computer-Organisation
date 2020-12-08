/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Assignment 6
  Single Cycle CPU Implementation- ALU, Load and Store, Branching Instructions for RV32I ISA
  ALU module
  October 2020

  Description: Combinational module that implements ALU operation based on input 6-bit op
*/

module alu32(
    input [5:0] op,      // some input encoding of your choice
    input [31:0] rv1,    // First operand
    input [31:0] rv2,    // Second operand
    output [31:0] rvout  // Output value
);
reg [31:0] val_out;
always @(op or rv1 or rv2)  begin
val_out = 32'bx;      // invalid op => output goes to unknown state
  case (op[4:0])
    5'b01000 : val_out = rv1 + rv2;          // ADD, ADDI
    5'b11000 : val_out = rv1 - rv2;          // SUB
    5'b01001 : val_out = {rv1 << {rv2[4:0]}};  // SLL, SLLI
    5'b01010 : begin                       // SLT, SLTI
                if ({rv1[31], rv2[31]} == 2'b00)  val_out = {31'b0, (rv1<rv2)};
                else if ({rv1[31], rv2[31]} == 2'b01) val_out = 32'b0;  // rv2<rv1
                else if ({rv1[31], rv2[31]} == 2'b10) val_out = 32'b1;  // rv1<rv2
                else if ({rv1[31], rv2[31]} == 2'b11) val_out = {31'b0, (rv1>rv2)};
              end
    5'b01011 : val_out = {31'b0, (rv1<rv2)}; // SLTU, SLTIU
    5'b01100 : val_out = rv1 ^ rv2;          // XOR, XORI
    5'b01101 : val_out = {rv1 >> {rv2[4:0]}};   // SRL, SRLI
    5'b11101 : val_out = {rv1 >>> {rv2[4:0]}};  // SRA, SRAI
    5'b01110 : val_out = rv1 | rv2;             // OR, ORI
    5'b01111 : val_out = rv1 & rv2;             // AND, ANDI
    default : val_out = 32'bx;                 // invalid op => output goes to unknown state
  endcase
end
assign rvout = val_out;
endmodule
