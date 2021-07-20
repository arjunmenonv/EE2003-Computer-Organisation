/*
 Description: - IF_ID register storing PC_curr and idata
              - No control logic to be implemented here (all subsequent pipeline regs incorporate control)
              - Stalling in case of branches; No Forwarding logic

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
  else if (!stall) begin      //Stall Routine 1: Disallow writees to IF/ID
  PC_curr_out <= PC_curr_in;
  idata_out <= idata_in;
  end
end
endmodule
