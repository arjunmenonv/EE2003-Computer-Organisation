/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Project Extension
  5 stage Pipelined CPU Implementation of the RISCV RV32I ISA
  Control Unit Module
  July 2021

  Description:  - Revamped Control Unit for the Pipelined implementation
                - Functionally Similar to control.v, however, no data signals are set here
                - Operates in the ID Stage
                - Control Operations that are performed in later stages are derived from
                  control signals set in this module
*/

module pipe_control(
  input [5:0] op,
  output [1:0] instr_type,
  output [2:0] sub_op,
  output is_load,
  output is_store);

reg [1:0] instr_type;
reg [2:0] sub_op;
reg is_load;
reg is_store;

always @(op) begin
  sub_op = 3'b0;
  is_load = 0;
  is_store = 0;
  if(op[3] == 1'b1) instr_type = 2'b0;   // ALU operation
  else if (op[4:3] == 2'b10) begin    // if load or store instr
    instr_type = 2'b01;
    case({op[5], op[2:0]})              
      4'b0000 :   begin
                  sub_op = 3'b0;   //LB
                  is_load = 1;
                  end
      4'b0001 :   begin
                  sub_op = 3'b001; //LH
                  is_load = 1;
                  end
      4'b0010 :   begin
                  sub_op = 3'b010; //LW
                  is_load = 1;
                  end
      4'b0100 :   begin
                  sub_op = 3'b011; //LBU
                  is_load  = 1;
                  end
      4'b0101 :   begin
                  sub_op = 3'b100; //LHU
                  is_load = 1;
                  end
      4'b1000 :   begin
                  sub_op = 3'b101; //SB
                  is_store  = 1;
                  end
      4'b1001 :   begin
                  sub_op = 3'b110; //SH
                  is_store  = 1;
                  end
      4'b1010 :   begin
                  sub_op = 3'b111; //SW
                  is_store  = 1;
                  end
    endcase
  end
  else if (op[5:3] == 3'b100) begin   // Conditional Branch
    instr_type = 2'b10;
    sub_op = op[2:0];
  end
  else if (op[5:3] == 3'b0) begin    // Miscellaneous Class: JALR, JAL, AUIPC, LUI
    instr_type = 2'b11;
    sub_op = op[2:0];
  end
end
endmodule
