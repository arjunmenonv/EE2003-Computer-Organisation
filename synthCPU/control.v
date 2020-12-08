/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Assignment 6
  Single Cycle CPU Implementation- ALU, Load and Store, Branching Instructions for RV32I ISA
  Control module
  October 2020

  Description:  Implement Load and Store Instructions
                Set PC_next (address of next instr in IMEM):
                  For branch type instructions, PC_next = PC_curr + inc (inc is determined by type of instr)
                  For ALU and Load/Store instructions, PC_next = PC_curr + 4
                Set Control signals (select alu operation, wrrite enable for regfile and dmem)
                Load values to be written to dmem and regfile onto dwdata and reg_wdata wires
*/

module control(
  input [5:0] op,             // 6-bit op from decoder
  input [31:0] r_rv2,         // value at rs2 register in regfile (used in case of store instructions)
  input [31:0] drdata,        // Data read from DMEM
  input [31:0] rvout,         // ALU output, used for Daddr calculation in Load and Store and Iaddr calc in Branch
  input [31:0] imm_val,       // immediate used for PC increment (conditional branch & JAL), and for AUIPC, LUI
  input [31:0] PC_curr,       // current PC value, from cpu
  output rwe,                 // regfile write enable
  output [31:0] dwdata,       // Data to be written to DMEM (Store)
  output [31:0] reg_wdata,    // Data to be written to regfile (Load)
  output [31:0] daddr,        // Address (to read/write) of DMEM location
  output [3:0] dwe,           // DMEM Write enable
  output [5:0] alu_op,        // 6-bit op sent to ALU
  output [31:0] PC_next       // next Iaddr, iaddr is set to PC_next in CPU
  );
reg [31:0] dwdata;
reg [31:0] reg_wdata;
reg [31:0] daddr;
reg [31:0] PC_next;
reg [3:0] dwe;
reg [5:0] alu_op;
reg rwe;

/*    NOTE:
            Control signals must have a definite value (0 or 1) for ALL possible input combinations
            alu_op = op if instr is ALU type
                   = op(addi) if instr is load/store (+ JALR)
                   = op(sub)  (BEQ and BNE)
                   = op(SLT)  (BLT, BGE)
                   = op(SLTU) (BLTU, BGEU)
                   = Dont care (JAL, AUIPC, LUI)

           reg_wdata = rvout for ALU operations
                     = drdata for load (rwe = 1 for both)
                     and rwe  = 0 for all other instr

           in case of Load/Store Operation, daddr = rvout;
*/

always @(op or drdata or rvout or r_rv2 or imm_val or PC_curr) begin
 PC_next = PC_curr + 4;   // default: Increment PC by 4, write disabled
 dwe = 4'b0;
 rwe = 0;
// Default cases to synthesise as wires
 daddr = 32'bx;
 dwdata = 32'bx;
 //alu_op = op;
 reg_wdata = 32'bx;
 //
  if(op[3] == 1'b1) begin   // ALU operation
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
                        default: reg_wdata = 32'bx;
                      endcase
                    end             //LH
      6'b010010 :   begin
                    rwe = 1;
                      case(daddr[1:0])    // last two bits of address indicate the byte to be addressed
                        2'b00:  reg_wdata = drdata;
                        default: reg_wdata = 32'bx;
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
                        default: reg_wdata = 32'bx;
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
                      default: dwdata = 32'bx;
                    endcase
                    end     //SH
      6'b110010 :   begin
                    case(daddr[1:0])
                      2'b00:  begin dwe = 4'b1111;
                              dwdata = r_rv2; end
                      default: dwdata = 32'bx;
                    endcase
                    end     //SW
    default: begin
             dwdata = 32'bx;
             reg_wdata = 32'bx;
             end
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
      default: alu_op = op;
    endcase
  end
  else if (op[5:3] == 3'b0) begin
    rwe = 1;
    case(op[2:0])
    3'b100 :  begin
                alu_op = 6'b001000;   // op(addi)
                reg_wdata = PC_curr + 4;                // Not using ALU here to avoid routing
                PC_next = {rvout[31:1], 1'b0};   //ALU input rv1 thro' control (hardware still simple)
              end   // JALR
    3'b101 :   begin
                alu_op = op;
                reg_wdata = PC_curr + 4;
                PC_next = PC_curr + imm_val;
              end // JAL
    3'b010 :  begin
              alu_op = op;
              reg_wdata = PC_curr + imm_val;                // AUIPC
              end
    3'b110 :  begin
              alu_op = op;
              reg_wdata = imm_val;  // LUI
              end
    default : alu_op = op;
    endcase
  end
  else alu_op = op;
  end // end always block
endmodule
