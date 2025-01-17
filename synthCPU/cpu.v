/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Assignment 6
  Single Cycle CPU Implementation- ALU, Load and Store, Branching Instructions for RV32I ISA
  CPU module
  October 2020

  Description: Instantiate alu, decoder, regfile and control modules
               Load DMEM write enable, address and write data to the appropriate ports from output wires of control module
               Update PC to PC_next which is determined by the Control Module

  Reference for implementation of instructions: The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA
                                                Document Version 20191214-draft
                                                Editors: Andrew Waterman, Krste Asanović (July 27, 2020)
  Reference for Architecture: Computer Organization and Design, RISC-V Edition
                              Authors: David A. Patterson, John L. Hennessy
*/
module cpu (
    input clk,
    input reset,
    output [31:0] iaddr,
    input [31:0] idata,
    output [31:0] daddr,
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe
);
reg [31:0] iaddr;
//reg [31:0] daddr;
//reg [31:0] dwdata;
//reg [3:0]  dwe;
// Wire declaration for instantiation (outputs of modules must be wires and not regs)
wire [5:0] op;
wire [5:0] alu_op;
wire [4:0] rs1, rs2, rd;
wire [31:0] rv1, rv2, r_rv2, rvout;
wire [31:0] r_wdata;
wire rwe;
wire [31:0] w_daddr;
wire [31:0] w_dwdata;
//
wire [31:0] imm_val;
wire [31:0] PC_next;
wire [3:0]  w_dwe;
reg [31:0] PC_curr;

// Instantiate alu, decoder, mem_access and regfile
alu32 u_alu (
  .op(alu_op),    //in
  .rv1(rv1),   //in
  .rv2(rv2),   //in
  .rvout(rvout)  //out
  );

decoder u_dec (
  .instr(idata),  //in
  .op(op),     //out
  .rs1(rs1),    //out
  .rs2(rs2),    //out
  .rd(rd),     //out
  .r_rv2(r_rv2),    //in
  .rv2(rv2),     //out
  .imm_val(imm_val)   //out
  );

regfile u_reg(
  .rs1(rs1),     //in
  .rs2(rs2),     //in
  .rd(rd),      //in
  .reset(reset),  //in
  .we(rwe & !reset),      //in from control
  .wdata(r_wdata),  // in
  .rv1(rv1),   //out
  .rv2(r_rv2),   //out
  .clk(clk)
  );

control u_ls(
  .op(op),  // in
  .r_rv2(r_rv2), //in- used in case of store operations
  .drdata(drdata),  //in
  .rvout(rvout),  //in
  .imm_val(imm_val),    //in
  .PC_curr(iaddr),      //in
  .alu_op(alu_op),  //out
  .rwe(rwe),     //out
  .daddr(w_daddr), //out
  .dwdata(w_dwdata),  //out
  .reg_wdata(r_wdata), //out
  .dwe(w_dwe),        //out
  .PC_next(PC_next)   //out
  );

//Load DMEM write enable, address and write data to the appropriate ports from output wires of control module
assign daddr = (reset) ? 32'b0 : w_daddr;
assign dwdata = (reset) ? 32'b0 : w_dwdata;
assign dwe = (reset) ? 4'b0 : w_dwe;
/*always @(w_daddr or w_dwdata or w_dwe) begin
  daddr = w_daddr;
  dwdata = w_dwdata;
  dwe = w_dwe;
end*/

always @(posedge clk) begin
    if (reset) begin
        iaddr <= 0;
        //daddr = 0;
        //dwdata = 0;
        //dwe <= 0;
    end else begin
         iaddr <= PC_next; // PC_next is determined by Control module
    end
end
endmodule
