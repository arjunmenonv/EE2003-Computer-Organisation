/*

*/
module MEM_WB(
  input clk,
  input reset,
  input [31:0] drdata,
  input [1:0] daddr_LSBits,
  //input [1:0] instr_type_in,
  input [2:0] sub_op_in,
  input [31:0] reg_wdata_in,
  input [4:0] rd_in,
  input [31:0] r_rv2_in,
  input rwe_in,
  input is_load_in,
  input is_store_in,
  input is_nop_in,
  //input wdata_set,
  output [31:0] reg_wdata_wire,
  output rwe_wire,
  output reset_out,
  output [31:0] reg_wdata_out,
  output [4:0] rd_out,
  output rwe_out,
  output [31:0] dwdata,
  output [3:0] dwe  );

// Assign to _wire in combinational block, write to _out in seq block
reg [31:0] reg_wdata_wire;
reg rwe_wire;
//
reg reset_out;
reg [31:0] reg_wdata_out;   // initialise reg_wdata_wire to reg_wdata_in, assign to rwdata for Load
reg [4:0] rd_out;
reg rwe_out;
reg [31:0] dwdata;
reg [3:0] dwe;

always @(
  is_nop_in or is_load_in or is_store_in or sub_op_in or
  reg_wdata_in or r_rv2_in or drdata or daddr_LSBits or rwe_in
  ) begin
  reg_wdata_wire = reg_wdata_in;
  rwe_wire = rwe_in;
  dwe = 4'b0;
  dwdata = 32'b0;
  if (!is_nop_in) begin
  if (is_load_in || is_store_in) begin    // Load or Store
  case(sub_op_in)              //
    3'b000:   begin
              rwe_wire = 1;
              case(daddr_LSBits)    // last two bits of address indicate the byte to be addressed
                2'b00:  reg_wdata_wire = {{24{drdata[7]}}, drdata[7:0]};   //Byte 0
                2'b01:  reg_wdata_wire = {{24{drdata[15]}}, drdata[15:8]}; //Byte 1
                2'b10:  reg_wdata_wire = {{24{drdata[23]}}, drdata[23:16]};//Byte 2
                2'b11:  reg_wdata_wire = {{24{drdata[31]}}, drdata[31:24]};//Byte 3
              endcase
              end               //LB
    3'b001 :  begin
              rwe_wire = 1;
              case(daddr_LSBits)    // last two bits of address indicate the byte to be addressed
                2'b00:  reg_wdata_wire = {{16{drdata[15]}}, drdata[15:0]}; //HW 0
                2'b10:  reg_wdata_wire = {{16{drdata[31]}}, drdata[31:16]};//HW 1
              endcase
              end             //LH
    3'b010 :  begin
              rwe_wire = 1;
              case(daddr_LSBits)    // last two bits of address indicate the byte to be addressed
                2'b00:  reg_wdata_wire = drdata;
              endcase
              end           //LW
    3'b011 :  begin
              rwe_wire = 1;
              case(daddr_LSBits)    // last two bits of address indicate the byte to be addressed
                2'b00:  reg_wdata_wire = {24'b0, drdata[7:0]};   //Byte 0
                2'b01:  reg_wdata_wire = {24'b0, drdata[15:8]};  //Byte 1
                2'b10:  reg_wdata_wire = {24'b0, drdata[23:16]}; //Byte 2
                2'b11:  reg_wdata_wire = {24'b0, drdata[31:24]}; //Byte 3
              endcase
              end         //LBU
    3'b100 :  begin
              rwe_wire = 1;
              case(daddr_LSBits)    // last two bits of address indicate the byte to be addressed
                2'b00:  reg_wdata_wire = {16'b0, drdata[15:0]}; //HW 0
                2'b10:  reg_wdata_wire = {16'b0, drdata[31:16]};//HW 1
              endcase
              end         //LHU
    3'b101 :  begin
              case(daddr_LSBits)
                2'b00:  begin dwe = 4'b0001;
                        dwdata = r_rv2_in; end
                2'b01:  begin dwe = 4'b0010;
                        dwdata = {r_rv2_in<<8}; end
                2'b10:  begin dwe = 4'b0100;
                        dwdata = {r_rv2_in<<16}; end
                2'b11:  begin dwe = 4'b1000;
                        dwdata = {r_rv2_in<<24}; end
              endcase
              end         //SB
    3'b110 :  begin
              case(daddr_LSBits)
                2'b00:  begin dwe = 4'b0011;
                        dwdata = r_rv2_in; end
                2'b10:  begin dwe = 4'b1100;
                        dwdata = {r_rv2_in<<16}; end
              endcase
              end     //SH
    3'b111 :  begin
              case(daddr_LSBits)
                2'b00:  begin dwe = 4'b1111;
                        dwdata = r_rv2_in; end
              endcase
              end     //SW
  endcase
  end
  end
end

always @(posedge clk) begin
reset_out <= reset;
  if (reset) begin
    reg_wdata_out <= 0;
    rd_out <= 0;
    rwe_out <= 0;
  end
  else if (is_nop_in) rd_out <= 0;    // Double protection (rwe=0, rd=0) to ensure no invalid write by NOP
  else begin
    reg_wdata_out <= reg_wdata_wire;
    rd_out <= rd_in;
    rwe_out <= rwe_wire;
  end
end
endmodule
