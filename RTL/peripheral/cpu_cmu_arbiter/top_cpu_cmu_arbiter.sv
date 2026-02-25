`timescale 1ns / 1ps
module top_cpu_cmu_arbiter #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input  wire                  i_req [0:1],
    output wire                  o_gnt [0:1],
    input  wire [ADDR_BIT - 1:0] i_cpu_addr,
    input  wire [ADDR_BIT - 1:0] i_cmu_addr,
    output wire [ADDR_BIT - 1:0] o_dm_addr,
    input  wire                  i_cpu_en,
    input  wire                  i_cmu_en,
    output wire                  o_dm_en,
    input  wire                  i_cpu_wren,
    input  wire                  i_cmu_wren,
    output wire                  o_dm_wren,
    input  wire [DATA_BIT - 1:0] i_cpu_wdata,
    input  wire [DATA_BIT - 1:0] i_cmu_wdata,
    output wire [DATA_BIT - 1:0] o_dm_wdata
    );

    cpu_cmu_arbiter u_cpu_cmu_arbiter (
        .i_req      (i_req),
        .o_gnt      (o_gnt),
        .o_master   (w_master)
    );

    mux21 #(
        .DATA_BIT (ADDR_BIT)
    ) arbiter_addr_mux (
        .i_ctr    (w_master),
        .i_i0     (i_cpu_addr),
        .i_i1     (i_cmu_addr),
        .o_o      (o_dm_addr)
    );

    mux21 #(
        .DATA_BIT (1)
    ) arbiter_en_mux (
        .i_ctr    (w_master),
        .i_i0     (i_cpu_en),
        .i_i1     (i_cmu_en),
        .o_o      (o_dm_en)
    );

    mux21 #(
        .DATA_BIT (1)
    ) arbiter_wren_mux (
        .i_ctr    (w_master),
        .i_i0     (i_cpu_wren),
        .i_i1     (i_cmu_wren),
        .o_o      (o_dm_wren)
    );

    mux21 #(
        .DATA_BIT (DATA_BIT)
    ) arbiter_wdata_mux (
        .i_ctr    (w_master),
        .i_i0     (i_cpu_wdata),
        .i_i1     (i_cmu_wdata),
        .o_o      (o_dm_wdata)
    );

endmodule
