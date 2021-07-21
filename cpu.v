/*
  Author: Arjun Menon Vadakkeveedu- EE18B104, Electrical Engg, IIT Madras
  EE2003 Computer Organisation Project Extension
  5 stage Pipelined CPU Implementation of the RISCV RV32I ISA
  CPU module
  July 2021

  Description: - Instantiate alu, decoder, regfile and pipe_control modules
               - Instantiate Pipeline Registers between IF/ID, ID/EX, EX/MEM and MEM/WB stages
               - Load DMEM write enable, address and write data to the appropriate ports from
                 output wires of EX/MEM register
               - Implementation of Data Forwarding to mitigate hazards due to dependencies between
                 pipeline stages
               - Implementation of Stalling and Pipeline Flush to mitigate Load and Control Hazards

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
reg [31:0] daddr;
reg [31:0] dwdata;
reg [3:0]  dwe;
// Wire declaration for instantiation (outputs of modules must be wires and not regs)
wire [5:0] op;
wire [5:0] alu_op;
wire [4:0] rs1, rs2, rd;
wire [31:0] rv1, rv2, r_rv2, rvout;
wire [31:0] w_daddr;
wire [31:0] w_dwdata;
//
wire [31:0] imm_val;
wire [31:0] PC_next;
wire [3:0]  w_dwe;
wire is_load;
wire is_store;
// wires connecting pipelined registers to modules
/*
Notation: FD => IF/ID; DX => ID/EX; XM => EX/MEM; MW => MEM/WB
*/
wire FD_reset;
wire [31:0] FD_PC_curr;
wire [31:0] FD_idata;
wire [1:0] instr_type;
wire [2:0] sub_op;
wire DX_reset;
wire [31:0] DX_PC_curr;
wire [5:0] DX_op;
wire [1:0] DX_instr_type;
wire [2:0] DX_sub_op;
wire [4:0] DX_rd;
wire [31:0] DX_rv1;
wire [31:0] DX_rv2;
wire [31:0] fwd_rv1;
wire [31:0] fwd_r_rv2;
wire [31:0] DX_r_rv2;
wire [31:0] DX_imm_val;
wire DX_is_load;
wire DX_is_store;
wire XM_reset;
wire [2:0] XM_sub_op;
wire [31:0] XM_reg_wdata;
wire [31:0] EX_rwdata_wire;
wire [4:0] XM_rd;
wire [31:0] XM_r_rv2;
wire XM_rwe;
wire EX_rwe_wire;
wire XM_wdata_set;
wire XM_is_load;
wire XM_is_store;
wire MW_reset;
wire [31:0] MW_reg_wdata;
wire [31:0] MEM_rwdata_wire;
wire [4:0] MW_rd;
wire MW_rwe;
wire MEM_rwe_wire;
// wires used in Forwarding and stalling
wire [1:0] fwdA;
wire [1:0] fwdB;
wire IF_nop;
wire ID_nop;
wire EX_nop;
wire MEM_nop;
wire FD_nop;
wire DX_nop;
wire XM_nop;
wire stall1;
wire stall2;

// Instantiate alu, decoder, regfile, controller and Pipeline Registers
IF_ID u_IF_ID(
  .clk(clk),
  .reset(reset),
  .PC_curr_in(iaddr),
  .idata_in(idata),
  .is_nop_in(IF_nop),
  .stall(stall1),
  .reset_out(FD_reset),
  .PC_curr_out(FD_PC_curr),
  .idata_out(FD_idata),
  .is_nop_out(FD_nop)
  );

  decoder u_dec (
    .instr(FD_idata),
    .op(op),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .r_rv2(fwd_r_rv2),
    .rv2(rv2),
    .imm_val(imm_val)
    );

  pipe_control u_pipe_control (
    .op(op),
    .instr_type(instr_type),
    .sub_op(sub_op),
    .is_load(is_load),
    .is_store(is_store)
    );

  regfile u_reg(
    .rs1(rs1),
    .rs2(rs2),
    .rd(MW_rd),
    .we(MW_rwe & !MW_reset),
    .wdata(MW_reg_wdata),
    .rv1(rv1),
    .rv2(r_rv2),
    .clk(clk)
    );

  ID_EX u_ID_EX(
    .clk(clk),
    .reset(FD_reset),
    .PC_curr_in(FD_PC_curr),
    .op_in(op),
    .instr_type_in(instr_type),
    .sub_op_in(sub_op),
    .rd_in(rd),
    .rv1_in(fwd_rv1),
    .rv2_in(rv2),
    .r_rv2_in(fwd_r_rv2),
    .imm_val_in(imm_val),
    .is_load_in(is_load),
    .is_store_in(is_store),
    .is_nop_in(ID_nop),
    .reset_out(DX_reset),
    .PC_curr_out(DX_PC_curr),
    .op_out(DX_op),
    .instr_type_out(DX_instr_type),
    .sub_op_out(DX_sub_op),
    .rd_out(DX_rd),
    .rv1_out(DX_rv1),
    .rv2_out(DX_rv2),
    .r_rv2_out(DX_r_rv2),
    .imm_val_out(DX_imm_val),
    .is_load_out(DX_is_load),
    .is_store_out(DX_is_store),
    .is_nop_out(DX_nop)
    );

  alu32 u_alu (
    .op(alu_op),
    .rv1(DX_rv1),
    .rv2(DX_rv2),
    .rvout(rvout)
    );

  EX_MEM u_EX_MEM(
    .clk(clk),
    .reset(DX_reset),
    .PC_curr(DX_PC_curr),
    .op(DX_op),
    .instr_type_in(DX_instr_type),
    .sub_op_in(DX_sub_op),
    .rd_in(DX_rd),
    .r_rv2_in(DX_r_rv2),
    .imm_val_in(DX_imm_val),
    .rvout(rvout),         //in from ALU
    .is_load_in(DX_is_load),
    .is_store_in(DX_is_store),
    .is_nop_in(EX_nop),
    .reset_out(XM_reset),
    .alu_op(alu_op),        //out to ALU
    .reg_wdata_wire(EX_rwdata_wire),
    .rwe_wire(EX_rwe_wire),
    .sub_op_out(XM_sub_op),
    .daddr_out(w_daddr),    //out to DMEM via CPU
    .reg_wdata_out(XM_reg_wdata),
    .rd_out(XM_rd),
    .r_rv2_out(XM_r_rv2),
    .rwe_out(XM_rwe),
    .PC_next(PC_next),        //out to stall logic in CPU
    .is_load_out(XM_is_load),
    .is_store_out(XM_is_store),
    .is_nop_out(XM_nop),
    .stall2(stall2)
    );

    MEM_WB u_MEM_WB(
    .clk(clk),
    .reset(XM_reset),
    .drdata(drdata),
    .daddr_LSBits(w_daddr[1:0]),
    .sub_op_in(XM_sub_op),
    .reg_wdata_in(XM_reg_wdata),
    .rd_in(XM_rd),
    .r_rv2_in(XM_r_rv2),
    .rwe_in(XM_rwe),
    .is_load_in(XM_is_load),
    .is_store_in(XM_is_store),
    .is_nop_in(MEM_nop),
    .reg_wdata_wire(MEM_rwdata_wire),
    .rwe_wire(MEM_rwe_wire),
    .reset_out(MW_reset),
    .reg_wdata_out(MW_reg_wdata),
    .rd_out(MW_rd),
    .rwe_out(MW_rwe),
    .dwdata(w_dwdata),
    .dwe(w_dwe)
    );

// Data Hazard Forwarding (EX->ID and MEM->ID)
assign fwd_rv1 = ((EX_rwe_wire) && (DX_rd != 5'b0) && (DX_rd == rs1)) ? EX_rwdata_wire :
                 ((MEM_rwe_wire) && (XM_rd != 5'b0) && (XM_rd == rs1)) ? MEM_rwdata_wire : rv1;

assign fwd_r_rv2 = ((EX_rwe_wire) && (DX_rd != 5'b0) && (DX_rd == rs2)) ? EX_rwdata_wire :
                   ((MEM_rwe_wire) && (XM_rd != 5'b0) && (XM_rd == rs2)) ? MEM_rwdata_wire : r_rv2;

assign stall1 = ((DX_is_load) && (DX_rd != 5'b0) && ((DX_rd == rs1) || (DX_rd == rs2))) ? 1'b1 : 1'b0;
assign IF_nop = (stall2) ? 1 : 0;
assign ID_nop = (stall1 || stall2) ? 1 :
                (FD_reset)  ? 0 : FD_nop;
assign EX_nop = (DX_reset) ? 0 : DX_nop;
assign MEM_nop = (XM_reset) ? 0 : XM_nop;

//Load DMEM write enable, address and write data to the appropriate ports from output wires of control module
always @(w_daddr or w_dwdata or w_dwe) begin
  daddr = w_daddr;
  dwdata = w_dwdata;
  dwe = w_dwe;
end

always @(posedge clk) begin
    if (reset) begin
        iaddr <= 0;
        daddr <= 0;
        dwdata <= 0;
        dwe <= 0;
    end else if (stall1) begin
        iaddr <= iaddr;
    end else if (stall2) begin
        iaddr <= PC_next;
    end else begin
         iaddr <= iaddr + 4;  // Pipelining: assume branch not taken
    end
end
endmodule
