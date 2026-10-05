`timescale 1ns / 1ps
module top_cpu_dma_arbiter (
    // Global
    input   wire    ACLK,
    input   wire    ARESET_N,
    // AXI Master Interface
    AXI5.SLAVE      AXI_CPU,
    AXI5.SLAVE      AXI_DMA,
    AXI5.MASTER     AXI_NOC,
    // Grant Signal by Channel
    output  wire    o_cpu_arbiter_wr_gnt,
    output  wire    o_dma_arbiter_wr_gnt,
    output  wire    o_cpu_arbiter_rd_gnt,
    output  wire    o_dma_arbiter_rd_gnt
    );

//////////
// Wire //
//////////
    wire w_ctr_wr_master;   // WR Transaction Master Flag
    wire w_ctr_rd_master;   // RD Transaction Master Flag

////////////////////
// WR Transaction //
////////////////////
    /* Fixed Priority Arbiter (WR Transaction) */
    arbiter21_fixed u_cpu_dma_wr_arbiter (
        .clk        (ACLK),
        .rst_n      (ARESET_N),
        .i_req0     (AXI_CPU.AWVALID),
        .i_req1     (AXI_DMA.AWVALID),
        .i_done     (AXI_NOC.BVALID),
        .o_gnt0     (o_cpu_arbiter_wr_gnt),
        .o_gnt1     (o_dma_arbiter_wr_gnt),
        .o_master   (w_ctr_wr_master)
    );

    ////////////////
    // AW Channel //
    ////////////////
    /* AWVALID MUX*/
    mux21 #(
        .DATA_BIT   (1)
    ) u_awvalid_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.AWVALID),
        .i_i1       (AXI_DMA.AWVALID),
        .o_o        (AXI_NOC.AWVALID)
    );
    
    /* AWID MUX */
    mux21 #(
        .DATA_BIT   (AXI_CPU.ID_W_BIT)
    ) u_awid_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.AWID),
        .i_i1       (AXI_DMA.AWID),
        .o_o        (AXI_NOC.AWID)
    );

    /* AWADDR MUX */
    mux21 #(
        .DATA_BIT   (AXI_CPU.ADDR_BIT)
    ) u_awaddr_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.AWADDR),
        .i_i1       (AXI_DMA.AWADDR),
        .o_o        (AXI_NOC.AWADDR)
    );

    /* AWLEN MUX */
    mux21 #(
        .DATA_BIT   (8)
    ) u_awlen_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.AWLEN),
        .i_i1       (AXI_DMA.AWLEN),
        .o_o        (AXI_NOC.AWLEN)
    );

    /* AWSIZE MUX */
    mux21 #(
        .DATA_BIT   (3)
    ) u_awsize_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.AWSIZE),
        .i_i1       (AXI_DMA.AWSIZE),
        .o_o        (AXI_NOC.AWSIZE)
    );

    /* AWBURST MUX */
    mux21 #(
        .DATA_BIT   (2)
    ) u_awburst_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.AWBURST),
        .i_i1       (AXI_DMA.AWBURST),
        .o_o        (AXI_NOC.AWBURST)
    );

    ///////////////
    // W Channel //
    ///////////////
    /* WVALID MUX*/
    mux21 #(
        .DATA_BIT   (1)
    ) u_wvalid_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.WVALID),
        .i_i1       (AXI_DMA.WVALID),
        .o_o        (AXI_NOC.WVALID)
    );

    /* WDATA MUX*/
    mux21 #(
        .DATA_BIT   (AXI_CPU.DATA_BIT)
    ) u_wdata_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.WDATA),
        .i_i1       (AXI_DMA.WDATA),
        .o_o        (AXI_NOC.WDATA)
    );

    /* WSTRB MUX*/
    mux21 #(
        .DATA_BIT   (AXI_CPU.STRB_BIT)
    ) u_wstrb_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.WSTRB),
        .i_i1       (AXI_DMA.WSTRB),
        .o_o        (AXI_NOC.WSTRB)
    );

    /* WLAST MUX*/
    mux21 #(
        .DATA_BIT   (1)
    ) u_wlast_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.WLAST),
        .i_i1       (AXI_DMA.WLAST),
        .o_o        (AXI_NOC.WLAST)
    );

    /* BREADY MUX*/
    mux21 #(
        .DATA_BIT   (1)
    ) u_bready_mux (
        .i_ctr      (w_ctr_wr_master),
        .i_i0       (AXI_CPU.BREADY),
        .i_i1       (AXI_DMA.BREADY),
        .o_o        (AXI_NOC.BREADY)
    );

////////////////////
// RD Transaction //
////////////////////
    /* Fixed Priority Arbiter (RD Channel) */
    arbiter21_fixed u_cpu_dma_rd_arbiter (
        .clk        (ACLK),
        .rst_n      (ARESET_N),
        .i_req0     (AXI_CPU.ARVALID),
        .i_req1     (AXI_DMA.ARVALID),
        .i_done     (AXI_NOC.RVALID && AXI_NOC.RLAST),
        .o_gnt0     (o_cpu_arbiter_rd_gnt),
        .o_gnt1     (o_dma_arbiter_rd_gnt),
        .o_master   (w_ctr_rd_master)
    );

    ////////////////
    // AR Channel //
    ////////////////
    /* ARVALID MUX*/
    mux21 #(
        .DATA_BIT   (1)
    ) u_arvalid_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.ARVALID),
        .i_i1       (AXI_DMA.ARVALID),
        .o_o        (AXI_NOC.ARVALID)
    );

    /* ARID MUX */
    mux21 #(
        .DATA_BIT   (AXI_CPU.ID_W_BIT)
    ) u_arid_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.ARID),
        .i_i1       (AXI_DMA.ARID),
        .o_o        (AXI_NOC.ARID)
    );

    /* ARADDR MUX */
    mux21 #(
        .DATA_BIT   (AXI_CPU.ADDR_BIT)
    ) u_araddr_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.ARADDR),
        .i_i1       (AXI_DMA.ARADDR),
        .o_o        (AXI_NOC.ARADDR)
    );

    /* ARLEN MUX */
    mux21 #(
        .DATA_BIT   (8)
    ) u_arlen_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.ARLEN),
        .i_i1       (AXI_DMA.ARLEN),
        .o_o        (AXI_NOC.ARLEN)
    );

    /* ARSIZE MUX */
    mux21 #(
        .DATA_BIT   (3)
    ) u_arsize_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.ARSIZE),
        .i_i1       (AXI_DMA.ARSIZE),
        .o_o        (AXI_NOC.ARSIZE)
    );

    /* ARBURST MUX */
    mux21 #(
        .DATA_BIT   (2)
    ) u_arburst_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.ARBURST),
        .i_i1       (AXI_DMA.ARBURST),
        .o_o        (AXI_NOC.ARBURST)
    );
   
    /* RREADY MUX*/
    mux21 #(
        .DATA_BIT   (1)
    ) u_rready_mux (
        .i_ctr      (w_ctr_rd_master),
        .i_i0       (AXI_CPU.RREADY),
        .i_i1       (AXI_DMA.RREADY),
        .o_o        (AXI_NOC.RREADY)
    );
  
    // DEMUX for HandShake Signal
    assign AXI_CPU.AWREADY  = (o_cpu_arbiter_wr_gnt == 1'b1) ? AXI_NOC.AWREADY : 1'b0;
    assign AXI_DMA.AWREADY  = (o_dma_arbiter_wr_gnt == 1'b1) ? AXI_NOC.AWREADY : 1'b0;
    assign AXI_CPU.WREADY   = (o_cpu_arbiter_wr_gnt == 1'b1) ? AXI_NOC.WREADY  : 1'b0;
    assign AXI_DMA.WREADY   = (o_dma_arbiter_wr_gnt == 1'b1) ? AXI_NOC.WREADY  : 1'b0;
    assign AXI_CPU.BVALID   = (o_cpu_arbiter_wr_gnt == 1'b1) ? AXI_NOC.BVALID  : 1'b0;
    assign AXI_DMA.BVALID   = (o_dma_arbiter_wr_gnt == 1'b1) ? AXI_NOC.BVALID  : 1'b0;
    assign AXI_CPU.ARREADY  = (o_cpu_arbiter_rd_gnt == 1'b1) ? AXI_NOC.ARREADY : 1'b0;
    assign AXI_DMA.ARREADY  = (o_dma_arbiter_rd_gnt == 1'b1) ? AXI_NOC.ARREADY : 1'b0;
    assign AXI_CPU.RVALID   = (o_cpu_arbiter_rd_gnt == 1'b1) ? AXI_NOC.RVALID  : 1'b0;
    assign AXI_DMA.RVALID   = (o_dma_arbiter_rd_gnt == 1'b1) ? AXI_NOC.RVALID  : 1'b0;
   
    assign AXI_CPU.BID  = AXI_NOC.BID;
    assign AXI_DMA.BID  = AXI_NOC.BID;
    assign AXI_CPU.BRESP= AXI_NOC.BRESP;
    assign AXI_DMA.BRESP= AXI_NOC.BRESP;
    assign AXI_CPU.RID  = AXI_NOC.RID;
    assign AXI_DMA.RID  = AXI_NOC.RID;
    assign AXI_CPU.RDATA= AXI_NOC.RDATA;
    assign AXI_DMA.RDATA= AXI_NOC.RDATA;
    assign AXI_CPU.RLAST= AXI_NOC.RLAST;
    assign AXI_DMA.RLAST= AXI_NOC.RLAST;
    assign AXI_CPU.RRESP= AXI_NOC.RRESP;
    assign AXI_DMA.RRESP= AXI_NOC.RRESP;
   
endmodule
