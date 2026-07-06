`include "../amba/AMBA.svh"
`timescale 1ns / 1ps
module top_noc #(
    parameter AXI5_ADDR_BIT = 32,
    parameter AXI5_DATA_BIT = 32,
    parameter AXI5_ID_BIT   = 12
    )(
    input   wire                            clk,
    input   wire                            rst_n,
    // CPU Local Interface
    input   wire                            i_cpu_en,
    input   wire                            i_cpu_wren,
    input   wire    [AXI5_ADDR_BIT - 1:0]   i_cpu_addr,
    input   wire    [AXI5_DATA_BIT - 1:0]   i_cpu_data,
    output  wire    [AXI5_DATA_BIT - 1:0]   o_cpu_data
    // DMA AXI Interface
    //AXI5.SLAVE                              AXI_DMA
    //output  wire                            o_dma_aw_gnt,
    //output  wire                            o_dma_w_gnt,
    //output  wire                            o_dma_ar_gnt
    );

    // Arbiter Handshake Bit
    wire    w_cpu_aw_gnt,   w_aw_master;
    wire    w_cpu_w_gnt,    w_w_master;
    wire    w_cpu_ar_gnt,   w_ar_master;

    // CPU AXI Interface
    AXI5 #(
        .ADDR_BIT       (AXI5_ADDR_BIT),
        .DATA_BIT       (AXI5_DATA_BIT),
        .ID_BIT         (AXI5_ID_BIT)
    ) AXI_CPU           ();

    // NoC AXI Interface
    AXI5 #(
        .ADDR_BIT       (AXI5_ADDR_BIT),
        .DATA_BIT       (AXI5_DATA_BIT),
        .ID_BIT         (AXI5_ID_BIT)
    ) AXI_NOC           ();
    
    // CPU AXI Master
    cpu_axi_master #(
        .ADDR_BIT       (AXI5_ADDR_BIT),
        .DATA_BIT       (AXI5_DATA_BIT)
    ) u_cpu_axi_master (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_cpu_en       (i_cpu_en),
        .i_cpu_wren     (i_cpu_wren),
        .i_cpu_addr     (i_cpu_addr),
        .i_cpu_data     (i_cpu_data),
        .o_cpu_data     (o_cpu_data),
        .i_cpu_aw_gnt   (w_cpu_aw_gnt),
        .i_cpu_w_gnt    (w_cpu_w_gnt),
        .i_cpu_ar_gnt   (w_cpu_ar_gnt),
        .AXI            (AXI_CPU)
    );

    // Network on Chip
    noc #(
        .ADDR_BIT       (AXI5_ADDR_BIT),
        .DATA_BIT       (AXI5_DATA_BIT)
    ) u_noc (
        .ACLK           (clk),
        .ARESET_N       (rst_n),
        .AXI            (AXI_NOC)
    );

    // AW Channel Arbiter (Fixed)
    arbiter21_fixed u_aw_arbiter_fixed (
        .i_req0         (AXI_CPU.AWVALID),
        .i_req1         (1'b0/*AXI_DMA.AWVALID*/),
        .o_gnt0         (w_cpu_aw_gnt),
        .o_gnt1         (/*o_dma_aw_gnt*/),
        .o_master       (w_aw_master)
    );

    // W Channel Arbiter (Fixed)
    arbiter21_fixed u_w_arbiter_fixed (
        .i_req0         (AXI_CPU.WVALID),
        .i_req1         (1'b0/*AXI_DMA.WVALID*/),
        .o_gnt0         (w_cpu_w_gnt),
        .o_gnt1         (/*o_dma_w_gnt*/),
        .o_master       (w_w_master)
    );

    // AR Channel Arbiter (Fixed)
    arbiter21_fixed u_ar_arbiter_fixed (
        .i_req0         (AXI_CPU.ARVALID),
        .i_req1         (1'b0/*AXI_DMA.ARVALID*/),
        .o_gnt0         (w_cpu_ar_gnt),
        .o_gnt1         (/*o_dma_ar_gnt*/),
        .o_master       (w_ar_master)
    );

    // AW Channel MUX
    mux21 #(
        .DATA_BIT       (1)
    ) u_awvalid_mux (
        .i_ctr          (w_aw_master),
        .i_i0           (AXI_CPU.AWVALID),
        .i_i1           (1'b0/*AXI_DMA.AWVALID*/),
        .o_o            (AXI_NOC.AWVALID)
    );
    mux21 #(
        .DATA_BIT       (AXI5_ID_BIT)
    ) u_awid_mux (
        .i_ctr          (w_aw_master),
        .i_i0           (AXI_CPU.AWID),
        .i_i1           ({AXI5_ID_BIT{1'b0}}/*AXI_DMA.AWID*/),
        .o_o            (AXI_NOC.AWID)
    );
    mux21 #(
        .DATA_BIT       (AXI5_ADDR_BIT)
    ) u_awaddr_mux (
        .i_ctr          (w_aw_master),
        .i_i0           (AXI_CPU.AWADDR),
        .i_i1           ({AXI5_ADDR_BIT{1'b0}}/*AXI_DMA.AWADDR*/),
        .o_o            (AXI_NOC.AWADDR)
    );
    mux21 #(
        .DATA_BIT       (8)
    ) u_awlen_mux (
        .i_ctr          (w_aw_master),
        .i_i0           (AXI_CPU.AWLEN),
        .i_i1           (`SINGLE_BURST/*AXI_DMA.AWLEN*/),
        .o_o            (AXI_NOC.AWLEN)
    );
    mux21 #(
        .DATA_BIT       (3)
    ) u_awsize_mux (
        .i_ctr          (w_aw_master),
        .i_i0           (AXI_CPU.AWSIZE),
        .i_i1           (3'b000/*AXI_DMA.AWSIZE*/),
        .o_o            (AXI_NOC.AWSIZE)
    );
    mux21 #(
        .DATA_BIT       (2)
    ) u_awburst_mux (
        .i_ctr          (w_aw_master),
        .i_i0           (AXI_CPU.AWBURST),
        .i_i1           (`AXBURST_INCR/*AXI_DMA.AWBURST*/),
        .o_o            (AXI_NOC.AWBURST)
    );

    // W Channel MUX
    mux21 #(
        .DATA_BIT       (1)
    ) u_wvalid_mux (
        .i_ctr          (w_w_master),
        .i_i0           (AXI_CPU.WVALID),
        .i_i1           (1'b0/*AXI_DMA.WVALID*/),
        .o_o            (AXI_NOC.WVALID)
    );
    mux21 #(
        .DATA_BIT       (AXI5_DATA_BIT)
    ) u_wdata_mux (
        .i_ctr          (w_w_master),
        .i_i0           (AXI_CPU.WDATA),
        .i_i1           ({AXI5_DATA_BIT{1'b0}}/*AXI_DMA.WDATA*/),
        .o_o            (AXI_NOC.WDATA)
    );
    mux21 #(
        .DATA_BIT       (AXI_CPU.STRB_BIT)
    ) u_wstrb_mux (
        .i_ctr          (w_w_master),
        .i_i0           (AXI_CPU.WSTRB),
        .i_i1           ({AXI_CPU.STRB_BIT{1'b0}}/*AXI_DMA.WSTRB*/),
        .o_o            (AXI_NOC.WSTRB)
    );
    mux21 #(
        .DATA_BIT       (1)
    ) u_wlast_mux (
        .i_ctr          (w_w_master),
        .i_i0           (AXI_CPU.WLAST),
        .i_i1           (1'b0/*AXI_DMA.AWBURST*/),
        .o_o            (AXI_NOC.WLAST)
    );

    // AR Channel MUX
    mux21 #(
        .DATA_BIT       (1)
    ) u_arvalid_mux (
        .i_ctr          (w_ar_master),
        .i_i0           (AXI_CPU.ARVALID),
        .i_i1           (1'b0/*AXI_DMA.ARVALID*/),
        .o_o            (AXI_NOC.ARVALID)
    );
    mux21 #(
        .DATA_BIT       (AXI5_ID_BIT)
    ) u_arid_mux (
        .i_ctr          (w_ar_master),
        .i_i0           (AXI_CPU.ARID),
        .i_i1           ({AXI5_ID_BIT{1'b0}}/*AXI_DMA.ARID*/),
        .o_o            (AXI_NOC.ARID)
    );
    mux21 #(
        .DATA_BIT       (AXI5_ADDR_BIT)
    ) u_araddr_mux (
        .i_ctr          (w_ar_master),
        .i_i0           (AXI_CPU.ARADDR),
        .i_i1           ({AXI5_ADDR_BIT{1'b0}}/*AXI_DMA.ARADDR*/),
        .o_o            (AXI_NOC.ARADDR)
    );
    mux21 #(
        .DATA_BIT       (8)
    ) u_arlen_mux (
        .i_ctr          (w_ar_master),
        .i_i0           (AXI_CPU.ARLEN),
        .i_i1           (`SINGLE_BURST/*AXI_DMA.ARLEN*/),
        .o_o            (AXI_NOC.ARLEN)
    );
    mux21 #(
        .DATA_BIT       (3)
    ) u_arsize_mux (
        .i_ctr          (w_ar_master),
        .i_i0           (AXI_CPU.ARSIZE),
        .i_i1           (3'b000/*AXI_DMA.ARSIZE*/),
        .o_o            (AXI_NOC.ARSIZE)
    );
    mux21 #(
        .DATA_BIT       (2)
    ) u_arburst_mux (
        .i_ctr          (w_ar_master),
        .i_i0           (AXI_CPU.ARBURST),
        .i_i1           (`AXBURST_INCR/*AXI_DMA.ARBURST*/),
        .o_o            (AXI_NOC.ARBURST)
    );

endmodule
