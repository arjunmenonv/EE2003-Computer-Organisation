/*
  Author: Arjun Menon Vadakkeveedu
  Roll No.: EE18B104
  Electrical Engineering, IIT Madras
  October 2020
  Single Cycle CPU Implementation for RV32I ISA
  Control Module and Implementation of Load-Store, Jump Instructions
*/

module control(
  input [5:0] op,
  input [31:0] r_rv2,
  input [31:0] drdata,
  input [31:0] rvout,
  input [31:0] imm_val,
  input [31:0] PC_curr,
  output rwe,
  output [31:0] dwdata,
  output [31:0] reg_wdata,
  output [31:0] daddr,
  output [3:0] dwe,
  output [5:0] alu_op,
  output [31:0] PC_next
  );
reg [31:0] dwdata;
reg [31:0] reg_wdata;
reg [31:0] daddr;
reg [31:0] PC_next;
reg [3:0] dwe;
reg [5:0] alu_op;
reg rwe;


//  NOTE: Control signals must have a definite value (0 or 1) for ALL possible input combinations

// alu_op = op if instr is ALU type, = op(addi) if instr is load/store and is op(SLTIU) (logical)
// for branch instructions

// r_wdata = rvout for ALU operations, = drdata for load (rwe = 1 for both) and rwe  = 0 for all other instr

// in case of Load/Store Operation, daddr = rvout;

// NOTE: PCinc must be 4 for all cases except where branching occurs

always @(op or drdata or rvout or r_rv2 or imm_val or PC_curr) begin
 PC_next = PC_curr + 4;
 dwe = 4'b0;
 rwe = 0;
  if(op[3] == 1'b1) begin
    alu_op = op;
    reg_wdata = rvout;
    rwe = 1;
  end
  else if (op[4:3] == 2'b10) begin    // if load or store instr
    alu_op = 6'b001000;   // op(addi)
    daddr = rvout;
    case(op)
      6'b010000 :   begin
                    rwe = 1;
                      case(daddr[1:0])    // last two bits of address indicate the byte to be addressed
                        2'b00:  reg_wdata = {{24{drdata[7]}}, drdata[7:0]};   //Byte 0
                        2'b01:  reg_wdata = {{24{drdata[15]}}, drdata[15:8]}; //Byte 1
                        2'b10:  reg_wdata = {{24{drdata[23]}}, drdata[23:16]};//Byte 2
                        2'b11:  reg_wdata = {{24{drdata[31]}}, drdata[31:24]};//Byte 3
                      endcase
                    end               //LB
      6'b010001 :   begin
                    rwe = 1;

                      case(daddr[1:0])    // last two bits of address indicate the byte to be addressed
                        2'b00:  reg_wdata = {{16{drdata[15]}}, drdata[15:0]}; //HW 0
                        2'b10:  reg_wdata = {{16{drdata[31]}}, drdata[31:16]};//HW 1
                      endcase
                    end             //LH
      6'b010010 :   begin
                    rwe = 1;
                      case(daddr[1:0])    // last two bits of address indicate the byte to be addressed
                        2'b00:  reg_wdata = drdata;
                      endcase
                    end           //LW
      6'b010100 :   begin
                    rwe = 1;
                      case(daddr[1:0])    // last two bits of address indicate the byte to be addressed
                        2'b00:  reg_wdata = {24'b0, drdata[7:0]};   //Byte 0
                        2'b01:  reg_wdata = {24'b0, drdata[15:8]};  //Byte 1
                        2'b10:  reg_wdata = {24'b0, drdata[23:16]}; //Byte 2
                        2'b11:  reg_wdata = {24'b0, drdata[31:24]}; //Byte 3
                      endcase
                    end         //LBU
      6'b010101 :   begin
                    rwe = 1;
                      case(daddr[1:0])    // last two bits of address indicate the byte to be addressed
                        2'b00:  reg_wdata = {16'b0, drdata[15:0]}; //HW 0
                        2'b10:  reg_wdata = {16'b0, drdata[31:16]};//HW 1
                      endcase
                    end         //LHU
      6'b110000 :  begin
                    case(daddr[1:0])
                      2'b00:  begin dwe = 4'b0001;
                              dwdata = r_rv2; end
                      2'b01:  begin dwe = 4'b0010;
                              dwdata = {r_rv2<<8}; end
                      2'b10:  begin dwe = 4'b0100;
                              dwdata = {r_rv2<<16}; end
                      2'b11:  begin dwe = 4'b1000;
                              dwdata = {r_rv2<<24}; end
                    endcase
                    end         //SB
      6'b110001 :  begin
                    case(daddr[1:0])
                      2'b00:  begin dwe = 4'b0011;
                              dwdata = r_rv2; end
                      2'b10:  begin dwe = 4'b1100;
                              dwdata = {r_rv2<<16}; end
                    endcase
                    end     //SH
      6'b110010 :   begin
                    case(daddr[1:0])
                      2'b00:  begin dwe = 4'b1111;
                              dwdata = r_rv2; end
                    endcase
                    end     //SW

    endcase
  end // end else
  else if (op[5:3] == 3'b100) begin   // Conditional Branch
    case (op[2:0])
      3'b000 : begin
                alu_op = 6'b111000; //op(SUB)
                if (rvout == 0)  PC_next = PC_curr + imm_val;
               end   //BEQ
      3'b001 : begin
                alu_op = 6'b111000; //op(SUB)
                if (rvout != 0) PC_next = PC_curr + imm_val;
               end    //BNE
      3'b100 : begin
                alu_op = 6'b101010; //op(SLT)
                if (rvout[0])  PC_next = PC_curr + imm_val;
               end    //BLT
      3'b101 : begin
                alu_op = 6'b101010; //op(SLT)
                if (!rvout[0]) PC_next = PC_curr + imm_val;
               end    //BGE
      3'b110 : begin
                alu_op = 6'b101011; //op(SLTU)
                if (rvout[0])  PC_next = PC_curr + imm_val;
               end    //BLTU
      3'b111 : begin
                alu_op = 6'b101011; //op(SLTU)
                if (!rvout[0]) PC_next = PC_curr + imm_val;
               end //BGEU
    endcase
  end
  else if (op[5:3] == 3'b0) begin
    rwe = 1;
    case(op[2:0])
    3'b100 :  begin
                alu_op = 6'b001000;   // op(addi)
                reg_wdata = PC_curr + 4;                // Not using ALU here to avoid routing
                PC_next = {rvout[31:1], 1'b0};   //ALU input rv1 thro' control (hardware still simple
              end   // JALR
    3'b101 :   begin
                reg_wdata = PC_curr + 4;
                PC_next = PC_curr + imm_val;
              end // JAL
    3'b010 :  reg_wdata = PC_curr + imm_val;                // AUIPC
    3'b110 :  reg_wdata = imm_val;  // LUI
    endcase
  end
  end // end always block
endmodule
