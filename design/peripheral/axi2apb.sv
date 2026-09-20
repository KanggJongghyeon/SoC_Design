`timescale 1ns / 1ps
`include "./../amba.AMBA.svh"
module axi2apb (
    input   wire    ACLK,
    input   wire    ARESET_N,
    // NoC AXI
    AXI.SLAVE       AXI
    // WR Tx FIFO
    output  wire            o_wr_tx_pushen,
    output  wire    [65:0]  o_wr_tx_pushdata,
    input   wire            i_wr_tx_full,
    // RD Tx FIFO 
    output  wire            o_rd_tx_pushen,
    output  wire    [65:0]  o_rd_tx_pushdata,
    input   wire            i_rd_tx_full,
    // Rx WR FIFO
    output  wire            o_wr_rx_popen,
    output  wire    [33:0]  o_wr_rx_popdata,
    input   wire            i_wr_rx_empty
    // Rx RD FIFO
    output  wire            o_rd_rx_popen,
    output  wire    [33:0]  o_rd_rx_popdata,
    input   wire            i_rd_rx_empty
    );

    // Reg for AXI Interface
    reg                     r_bvalid;
    reg [AXI.ID_W_BIT - 1:0]r_bid;
    reg [1:0]               r_bresp;
    reg                     r_rvalid;
    reg [AXI.ID_R_BIT - 1:0]r_rid;
    reg [AXI.DATA_BIT - 1:0]r_rdata;
    reg                     r_rlast;
    reg [1:0]               r_rresp;
    
    // Reg for WR Tx FIFO
    reg         r_wr_tx_pushen;
    reg [64:0]  r_wr_tx_pushdata;
    
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~rst_n) begin
            r_wr_tx_pushen  <= 1'b0;
            r_wr_tx_pushdata<= {66{1'b0}};
        end
        else begin
            if (AXI.AWVALID == 1'b1) begin
                if (i_wr_tx_full != 1'b1) begin
                    r_wr_tx_pushdata[64]    <= 1'b1;        // PWRITE
                    r_wr_tx_pushdata[63:32] <= AXI.AWADDR;  // PADDR
                end                     
            end
        end
    end


    // AXI AW Output
    assign AXI.AWREADY  = 1'b1;
    // AXI W  Output
    assign AXI.WREADY   = 1'b1;
    // AXI B  Output
    assign AXI.BVALID   = r_bvalid;
    assign AXI.BID      = r_bid;
    assign AXI.BRESP    = r_bresp;
    // AXI AR Output
    assign AXI.ARREADY  = 1'b1;
    // AXI R  Output
    assign AXI.RVALID   = r_rvalid;
    assign AXI.RID      = r_rid;
    assign AXI.RDATA    = r_rdata;
    assign AXI.RLAST    = r_rlast;
    assign AXI.RRESP    = r_rresp;

    // WR TX Ouput

endmodule    
