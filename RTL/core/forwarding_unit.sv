`timescale 1ns / 1ps
/////////////////////////
// ALU Forwarding Unit //
/////////////////////////
module alu_forwarding_unit #(
    parameter   REG_BIT = 2
    )(
    input   wire                    i_mem_regwrite,
    input   wire                    i_wb_regwrite,
    input   wire    [REG_BIT - 1:0] i_mem_wr_reg,
    input   wire    [REG_BIT - 1:0] i_wb_wr_reg,
    input   wire    [REG_BIT - 1:0] i_ex_rs,
    input   wire    [REG_BIT - 1:0] i_ex_rt,
    output  wire                    o_1c_forward_a,
    output  wire                    o_1c_forward_b,
    output  wire                    o_2c_forward_a,
    output  wire                    o_2c_forward_b
    );

    assign o_1c_forward_a   = (i_mem_regwrite == 1'b1) && (i_mem_wr_reg != {REG_BIT{1'b0}}) && (i_mem_wr_reg == i_ex_rs);
    assign o_1c_forward_b   = (i_mem_regwrite == 1'b1) && (i_mem_wr_reg != {REG_BIT{1'b0}}) && (i_mem_wr_reg == i_ex_rt);
    assign o_2c_forward_a   = (i_wb_regwrite  == 1'b1) && (i_wb_wr_reg  != {REG_BIT{1'b0}}) && (i_wb_wr_reg  == i_ex_rs);
    assign o_2c_forward_b   = (i_wb_regwrite  == 1'b1) && (i_wb_wr_reg  != {REG_BIT{1'b0}}) && (i_wb_wr_reg  == i_ex_rt);

endmodule

//////////////////////////
// WDATA Fowarding Unit //
//////////////////////////
module wdata_forwarding_unit #(
    parameter   REG_BIT = 2
    )(
    input   wire                    i_wb_regwrite,
    input   wire    [REG_BIT - 1:0] i_wb_wr_reg,
    input   wire    [REG_BIT - 1:0] i_ex_rt,
    input   wire    [REG_BIT - 1:0] i_mem_rt,
    output  wire                    o_2c_forward,
    output  wire                    o_1c_forward
    );
    
    assign o_2c_forward = (i_wb_regwrite == 1'b1) && (i_wb_wr_reg != {REG_BIT{1'b0}}) && (i_wb_wr_reg == i_ex_rt);
    assign o_1c_forward = (i_wb_regwrite == 1'b1) && (i_wb_wr_reg != {REG_BIT{1'b0}}) && (i_wb_wr_reg == i_mem_rt);

endmodule

/////////////////////
// Load Stall Unit //
/////////////////////
module load_stall_unit #(
    parameter REG_BIT = 2
    )(
        input   wire                    i_ex_memread,
        input   wire    [REG_BIT - 1:0] i_ex_wr_reg,
        input   wire    [REG_BIT - 1:0] i_id_rs,
        input   wire    [REG_BIT - 1:0] i_id_rt,
        output  wire                    o_load_stall
    );

    assign o_load_stall = (i_ex_memread == 1'b1) && (i_ex_wr_reg != {REG_BIT{1'b0}}) && ((i_ex_wr_reg == i_id_rs) || (i_ex_wr_reg == i_id_rt));

endmodule
//////////////////////////////////////////
// Path : .\RTL\core\forwarding_unit.sv //
//////////////////////////////////////////
