`include "../amba/AMBA.svh"
`timescale 1ns / 1ps
module top_noc #(
    parameter AXI5_ADDR_BIT = 32,
    parameter AXI5_DATA_BIT = 32,
    parameter AXI5_STRB_BIT = 4,
    parameter AXI5_ID_BIT   = 12
    )(
    input   wire    ACLK,       // Global  
    input   wire    ARESET_N,   // Global
    
    AXI5.SLAVE      AXI_CPU,    // CPU AXI Interface
   
    AXI5.SLAVE      AXI_DMA,    // DMA AXI Interface

    output  wire    o_cpu_arbiter_wr_gnt,   // CPU WR Grant Singal
    output  wire    o_dma_arbiter_wr_gnt,   // DMA WR Grant Signal
    output  wire    o_cpu_arbiter_rd_gnt,   // CPU RD Grant Signal
    output  wire    o_dma_arbiter_rd_gnt,   // DMA RD Grant Signal

    AXI5.MASTER     AXI_AXI2APB // AXI2APB AXI Interface 
    );

///////////////////
// AXI Interface //
///////////////////
    /* AXI NoC Bus */
    AXI5 #(
        .ADDR_BIT   (AXI5_ADDR_BIT),
        .DATA_BIT   (AXI5_DATA_BIT),
        .ID_W_BIT   (AXI5_ID_BIT),
        .ID_R_BIT   (AXI5_ID_BIT)
    ) AXI_NOC ();
    
////////////////
// Digital IP //
////////////////
    /* CPU-DMA Arbiter Interconnect */
    top_cpu_dma_arbiter u_cpu_dma_arbiter (
        .ACLK                   (ACLK),
        .ARESET_N               (ARESET_N),
        .AXI_CPU                (AXI_CPU),
        .AXI_DMA                (AXI_DMA),
        .AXI_NOC                (AXI_NOC),
        .o_cpu_arbiter_wr_gnt   (o_cpu_arbiter_wr_gnt),
        .o_dma_arbiter_wr_gnt   (o_dma_arbiter_wr_gnt),
        .o_cpu_arbiter_rd_gnt   (o_cpu_arbiter_rd_gnt),
        .o_dma_arbiter_rd_gnt   (o_dma_arbiter_rd_gnt)
    );

    /* Network on Chip */
    noc #(
        .ADDR_BIT       (AXI5_ADDR_BIT),
        .DATA_BIT       (AXI5_DATA_BIT)
    ) u_noc (
        .ACLK           (ACLK),
        .ARESET_N       (ARESET_N),
        .AXI_NOC        (AXI_NOC),
        .AXI_AXI2APB    (AXI_AXI2APB)
    );
    
endmodule
