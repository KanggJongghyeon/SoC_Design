`timescale 1ns / 1ps
`include "memory/memory.svh"
module top_soc #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32
    )(
    input   wire                        clk,            // Global  
    input   wire                        rst_n,          // Global

    input   wire                        i_i_mem_en,     // Go to I-MEM  
    input   wire                        i_i_mem_wren,   // Go to I-MEM
    input   wire    [ADDR_BIT - 1:0]    i_i_mem_addr,   // Go to I-MEM   
    input   wire    [DATA_BIT - 1:0]    i_i_mem_data    // Go to I-MEM
    );

////////////////////
// Loal Parameter //
////////////////////
    localparam STRB_BIT     = DATA_BIT / `BYTE_SIZE;// STRB Bit
    localparam AXI5_ID_BIT  = 12;                   // AXI5 ID Bit

//////////
// Wire //
//////////
    wire                    w_i_mem_en;             //  I-MEM ENABLE
    wire [ADDR_BIT - 1:0]   w_i_mem_addr;           //  I-MEM ADDR
    wire [DATA_BIT - 1:0]   w_i_mem_rdata;          //  I-MEM RDATA
    wire                    w_d_mem_en;             //  D-MEM ENABLE
    wire                    w_d_mem_wren;           //  D-MEM WR ENABLE
    wire [ADDR_BIT - 1:0]   w_d_mem_addr;           //  D-MEM ADDR
    wire [DATA_BIT - 1:0]   w_d_mem_wdata;          //  D-MEM WDATA
    wire [STRB_BIT - 1:0]   w_d_mem_wstrb;          //  D-MEM WSTRB
    wire [DATA_BIT - 1:0]   w_d_mem_rdata;          //  D-MEM RDATA
    wire                    w_cpu_arbiter_wr_gnt;   // CPU WR Grant Signal
    wire                    w_cpu_arbiter_rd_gnt;   // CPU RD Grant Signal
    wire                    w_dma_arbiter_wr_gnt;   // DMA WR Grant Signal
    wire                    w_dma_arbiter_rd_gnt;   // DMA RD Grant Signal
    
///////////////////////////////////
// Advanced eXtensible Interface //
///////////////////////////////////
    /* CPU-NoC AXI */
    AXI5 #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT),
        .ID_W_BIT           (AXI5_ID_BIT),
        .ID_R_BIT           (AXI5_ID_BIT)
    ) AXI_CPU_NOC ();

    /* DMA-NoC AXI */
    AXI5 #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT),
        .ID_W_BIT           (AXI5_ID_BIT),
        .ID_R_BIT           (AXI5_ID_BIT)
    ) AXI_DMA_NOC ();

    /* NoC-AXI2APB AXI */
    AXI5 #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT),
        .ID_W_BIT           (AXI5_ID_BIT),
        .ID_R_BIT           (AXI5_ID_BIT)
    ) AXI_NOC_AXI2APB ();

////////////////
// Digital IP //
////////////////
    /* I-MEM */
    SDRAM #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT)
    ) u_inst_mem (
        .clk                (clk),
        .i_en               (w_i_mem_en     | i_i_mem_en),
        .i_wren             (i_i_mem_wren),
        .i_addr             (w_i_mem_addr   | i_i_mem_addr),
        .i_data             (i_i_mem_data),
        .i_strb             ({STRB_BIT{1'b1}}),
        .o_data             (w_i_mem_rdata)
    );

    /* CPU(Central Processing Unit) */
    top_cpu #(              
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT),
        .STRB_BIT           (STRB_BIT),
        .AXI5_ID_BIT        (AXI5_ID_BIT)
    ) u_top_cpu (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_i_mem_data       (w_i_mem_rdata),
        .o_i_mem_en         (w_i_mem_en),
        .o_i_mem_addr       (w_i_mem_addr),
        .i_d_mem_data       (w_d_mem_rdata),
        .o_d_mem_en         (w_d_mem_en),
        .o_d_mem_wren       (w_d_mem_wren),
        .o_d_mem_addr       (w_d_mem_addr),
        .o_d_mem_data       (w_d_mem_wdata),
        .o_d_mem_strb       (w_d_mem_wstrb),
        .i_arbiter_wr_gnt   (w_cpu_arbiter_wr_gnt),
        .i_arbiter_rd_gnt   (w_cpu_arbiter_rd_gnt),
        .AXI                (AXI_CPU_NOC)
    );

    /* NoC(Network on Chip) */
    top_noc #(
        .AXI5_ADDR_BIT          (ADDR_BIT),
        .AXI5_DATA_BIT          (DATA_BIT),
        .AXI5_STRB_BIT          (STRB_BIT),
        .AXI5_ID_BIT            (AXI5_ID_BIT)
    ) u_top_noc (
        .ACLK                   (clk),
        .ARESET_N               (rst_n),
        .AXI_CPU                (AXI_CPU_NOC),
        .AXI_DMA                (AXI_DMA_NOC),
        .o_cpu_arbiter_wr_gnt   (w_cpu_arbiter_wr_gnt),
        .o_dma_arbiter_wr_gnt   (w_dma_arbiter_wr_gnt),
        .o_cpu_arbiter_rd_gnt   (w_cpu_arbiter_rd_gnt),
        .o_dma_arbiter_rd_gnt   (w_dma_arbiter_rd_gnt),
        .AXI_AXI2APB            (AXI_NOC_AXI2APB)
    );

    /* AXI2APB */
    top_axi2apb u_top_axi2apb (
        .ACLK               (clk),
        .ARESET_N           (rst_n),
        .PCLK               (clk),
        .PRESET_N           (rst_n),
        .AXI_NOC            (AXI_NOC_AXI2APB)
    );
    
    /* D-MEM */
    SDRAM #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT)
    ) u_data_mem (
        .clk                (clk),
        .i_en               (w_d_mem_en),
        .i_wren             (w_d_mem_wren),
        .i_addr             (w_d_mem_addr),
        .i_data             (w_d_mem_wdata),
        .i_strb             (w_d_mem_wstrb),
        .o_data             (w_d_mem_rdata)
    );

endmodule
