/*
  Description:  -
                - Staller set in this module
*/
module EX_MEM(
  input clk,
  input reset,
  input [31:0] PC_curr,
  input [5:0] op,
  input [1:0] instr_type_in,
  input [2:0] sub_op_in,
  input [4:0] rd_in,
  input [31:0] r_rv2_in,
  input [31:0] imm_val_in,
  input [31:0] rvout,
  input is_load_in,
  input is_store_in,
  input is_nop_in,
  output reset_out,
  output [5:0] alu_op,
  //output [1:0] instr_type_out,
  output [31:0] reg_wdata_wire,     // wires that hold instantaneous values of
  output rwe_wire,                  // rwe, rwdata which are reqd. for forwarding
  output [2:0] sub_op_out,
  output [31:0] daddr_out,
  output [31:0] reg_wdata_out,
  output [4:0] rd_out,
  output [31:0] r_rv2_out,
  output rwe_out,
  //output wdata_set,       // TO distinguish Load & Store instructions from the rest in MEM stage
  output [31:0] PC_next,
  output is_load_out,
  output is_store_out,
  output is_nop_out  );

  // Assign to _wire in combinational block, write to _out in seq block
  reg [31:0] daddr_wire;
  reg [31:0] reg_wdata_wire;
  reg rwe_wire;
  //reg [3:0] dwe_wire;
  reg [5:0] alu_op;
  reg [31:0] PC_next;
  //reg wdata_set;
//
  reg reset_out;
  //reg [1:0] instr_type_out;
  reg [2:0] sub_op_out;
  reg [31:0] daddr_out;
  reg [31:0] reg_wdata_out;
  reg [4:0] rd_out;
  reg [31:0] r_rv2_out;
  reg rwe_out;
  reg is_load_out;
  reg is_store_out;
  //reg [3:0] dwe_out;
  reg is_nop_out;

  always @(
    is_nop_in or instr_type_in or sub_op_in or rvout or imm_val_in or r_rv2_in or PC_curr
    ) begin
    reg_wdata_wire = 32'b0;
    rwe_wire = 0;
  //  wdata_set = 0;
    daddr_wire = 32'b0;
    alu_op = 6'b0;
    PC_next = PC_curr + 4;
    if (!is_nop_in) begin
      if (instr_type_in == 2'b0) begin               //alu
        alu_op = op;
        reg_wdata_wire = rvout;
        rwe_wire = 1;
        //wdata_set = 1;
      end
      else if (instr_type_in == 2'b01) begin         //load or store
        alu_op = 6'b001000;
        daddr_wire = rvout;
      end
      else if (instr_type_in == 2'b10) begin         //conditional branches
        //wdata_set = 1;  // No write data, hence bus contains 'valid' wdata
        case (sub_op_in)
          3'b000 : begin
                   alu_op = 6'b111000; //op(SUB)
                   if (rvout == 0)  PC_next = PC_curr + imm_val_in;
                   end   //BEQ
          3'b001 : begin
                   alu_op = 6'b111000; //op(SUB)
                   if (rvout != 0) PC_next = PC_curr + imm_val_in;
                   end    //BNE
          3'b100 : begin
                   alu_op = 6'b101010; //op(SLT)
                   if (rvout[0])  PC_next = PC_curr + imm_val_in;
                   end    //BLT
          3'b101 : begin
                   alu_op = 6'b101010; //op(SLT)
                   if (!rvout[0]) PC_next = PC_curr + imm_val_in;
                   end    //BGE
          3'b110 : begin
                   alu_op = 6'b101011; //op(SLTU)
                   if (rvout[0])  PC_next = PC_curr + imm_val_in;
                   end    //BLTU
          3'b111 : begin
                   alu_op = 6'b101011; //op(SLTU)
                   if (!rvout[0]) PC_next = PC_curr + imm_val_in;
                   end //BGEU
        endcase
      end
      else if (instr_type_in == 2'b11) begin         //Misc class
        rwe_wire = 1;
        //wdata_set = 1;
        case(sub_op_in)
          3'b100 :  begin
                    alu_op = 6'b001000;   // op(addi)
                    reg_wdata_wire = PC_curr + 4;                // Not using ALU here to avoid routing
                    PC_next = {rvout[31:1], 1'b0};   //ALU input rv1 thro' control (hardware still simple)
                    end   // JALR
          3'b101 :   begin
                     reg_wdata_wire = PC_curr + 4;
                     PC_next = PC_curr + imm_val_in;
                     end // JAL
          3'b010 :  reg_wdata_wire = PC_curr + imm_val_in;                // AUIPC
          3'b110 :  reg_wdata_wire = imm_val_in;  // LUI
        endcase
    end
  end
  end
  always @(posedge clk) begin
  reset_out <= reset;
  is_nop_out <= is_nop_in;
    if (reset) begin
      daddr_out <= 0;
      //instr_type_out <= 0;
      sub_op_out <= 0;
      reg_wdata_out <= 0;
      rd_out <= 0;
      r_rv2_out <= 0;
      rwe_out <= 0;
      is_load_out <= 0;
      is_store_out <= 0;
      //dwe_out <= 0;
    end
    else if (is_nop_in) rd_out <= 0;    // This ensures that a NOP bubble does not trigger another stall
    else begin
      //instr_type_out <= instr_type_in;
      sub_op_out <= sub_op_in;
      daddr_out <= daddr_wire;
      reg_wdata_out <= reg_wdata_wire;
      rd_out <= rd_in;
      r_rv2_out <= r_rv2_in;
      rwe_out <= rwe_wire;
      is_load_out <= is_load_in;
      is_store_out <= is_store_in;
      //dwe_out <= dwe_wire;
    end
  end
endmodule
