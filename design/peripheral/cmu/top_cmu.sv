`timescale 1ns / 1ps
`include "../sfr_table.svh"
module top_cmu #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    output wire [ADDR_BIT - 1:0] o_addr,
    output wire                  o_en,
    output wire                  o_wren,
    input  wire [DATA_BIT - 1:0] i_data,
    output wire [DATA_BIT - 1:0] o_data,
    output wire                  PCLK,
    output wire                  HCLK,
    output wire                  ACLK,
    output wire                  PRESETn,
    output wire                  HRESETn,
    output wire                  ARESETn,
    output wire                  o_arbiter_req,
    input  wire                  i_arbiter_gnt
    );

    wire [2:0] w_clk_en;

    clk_sfr_ctrl #(
        .ADDR_BIT (ADDR_BIT),
        .DATA_BIT (DATA_BIT)
    ) u_cmu (
        .clk      (clk),
        .rst_n    (rst_n),
        .o_addr   (o_addr),
        .o_en     (o_en),
        .o_wren   (o_wren),
        .i_data   (i_data),
        .o_data   (o_data),
        .o_req    (o_arbiter_req),
        .i_gnt    (i_arbiter_gnt),
        .o_clk_en (w_clk_en)
    );

    apll u_apll (
        .ref_clk  (clk),
        .rst_n    (rst_n),
        .i_clk_en (w_clk_en),
        .PCLK     (PCLK),
        .HCLK     (HCLK),
        .ACLK     (ACLK),
        .PRESETn  (PRESETn),
        .HRESETn  (HRESETn),
        .ARESETn  (ARESETn)
    );

endmodule
