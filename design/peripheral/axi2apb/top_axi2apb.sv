`timescale 1ns / 1ps
module top_axi2apb (
    input   wire    ACLK,
    input   wire    ARESET_N,

    input   wire    PCLK,
    input   wire    PRESET_N,

    AXI5.SLAVE      AXI_NOC
    );

    wire            w_wr_tx_pushen;
    wire    [63:0]  w_wr_tx_pushdata;
    wire            w_wr_tx_full;
    wire            w_rd_tx_pushen;
    wire    [63:0]  w_rd_tx_pushdata;
    wire            w_rd_tx_full;
    wire            w_rd_rx_popen;
    wire    [31:0]  w_rd_rx_popdata;
    wire            w_rd_rx_empty;

    axi2apb_axi_slave u_axi2apb_axi_slave (
        .ACLK               (ACLK),
        .ARESET_N           (ARESET_N),
        .AXI                (AXI_NOC),
        .o_wr_tx_pushen     (w_wr_tx_pushen),
        .o_wr_tx_pushdata   (w_wr_tx_pushdata),
        .i_wr_tx_full       (w_wr_tx_full),
        .o_rd_tx_pushen     (w_rd_tx_pushen),
        .o_rd_tx_pushdata   (w_rd_tx_pushdata),
        .i_rd_tx_full       (w_rd_tx_full),
        .o_rd_rx_popen      (w_rd_rx_popen),
        .i_rd_rx_popdata    (w_rd_rx_popdata),
        .i_rd_rx_empty      (w_rd_rx_empty)
    );

    async_fifo #(
        .DATA_BIT           (64),
        .FIFO_SIZE          (256)
    ) u_wr_tx_async_fifo (
        .push_clk           (ACLK),
        .push_rst_n         (ARESET_N),
        .pop_clk            (PCLK),
        .pop_rst_n          (PRESET_N),
        .i_pushen           (w_wr_tx_pushen),
        .i_popen            (),
        .i_pushdata         (w_wr_tx_pushdata),
        .o_popdata          (),
        .o_full             (w_wr_tx_full),
        .o_empty            ()
    );

    async_fifo #(
        .DATA_BIT           (64),
        .FIFO_SIZE          (256)
    ) u_rd_tx_async_fifo (
        .push_clk           (ACLK),
        .push_rst_n         (ARESET_N),
        .pop_clk            (PCLK),
        .pop_rst_n          (PRESET_N),
        .i_pushen           (w_rd_tx_pushen),
        .i_popen            (),
        .i_pushdata         (w_rd_tx_pushdata),
        .o_popdata          (),
        .o_full             (w_rd_tx_full),
        .o_empty            ()
    );

    async_fifo #(
        .DATA_BIT           (32),
        .FIFO_SIZE          (8)
    ) u_rd_rx_async_fifo (
        .push_clk           (PCLK),
        .push_rst_n         (PRESET_N),
        .pop_clk            (ACLK),
        .pop_rst_n          (ARESET_N),
        .i_pushen           (),
        .i_popen            (w_rd_rx_popen),
        .i_pushdata         (),
        .o_popdata          (w_rd_rx_popdata),
        .o_full             (),
        .o_empty            (w_rd_rx_empty)
    );

endmodule
