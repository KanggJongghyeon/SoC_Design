`timescale 1ns / 1ps
`include "./../../amba/AMBA.svh"
module axi2apb (
    input   wire            ACLK,
    input   wire            ARESET_N,
    // NoC AXI
    AXI5.SLAVE               AXI,
    // WR Tx FIFO
    output  wire            o_wr_tx_pushen,
    output  wire    [63:0]  o_wr_tx_pushdata,   // {ADDR, DATA}
    input   wire            i_wr_tx_full,
    // RD Tx FIFO 
    output  wire            o_rd_tx_pushen,
    output  wire    [63:0]  o_rd_tx_pushdata,   // {ADDR, DATA}
    input   wire            i_rd_tx_full,
    // Rx RD FIFO
    output  wire            o_rd_rx_popen,
    input   wire    [31:0]  i_rd_rx_popdata,
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
    reg [63:0]  r_wr_tx_pushdata;
   
    // Reg for RD Tx FIFO
    reg         r_rd_tx_pushen;
    reg [63:0]  r_rd_tx_pushdata;

    // Reg for RD Rx FIFO
    reg         r_rd_rx_popen;

    // Reg for Store ID
    reg [AXI.ID_W_BIT - 1:0]r_wr_id;
    reg [AXI.ID_R_BIT - 1:0]r_rd_id;

    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_wr_tx_pushen  <= 1'b0;
            r_wr_tx_pushdata<= {64{1'b0}};
            r_wr_id         <= {AXI.ID_W_BIT{1'b0}};
            r_bvalid        <= 1'b0;
            r_bid           <= {AXI.ID_W_BIT{1'b0}};
            r_bresp         <= `XRESP_OKAY;
        end
        else begin
            if (i_wr_tx_full == 1'b0) begin
                if (AXI.AWVALID == 1'b1) begin
                    r_wr_id                 <= AXI.AWID;
                    r_wr_tx_pushdata[63:32] <= AXI.AWADDR;
                end
                else if (AXI.WVALID == 1'b1) begin
                    r_wr_tx_pushen          <= 1'b1;
                    r_wr_tx_pushdata[31:0]  <= AXI.WDATA;
                    r_bvalid                <= 1'b1;
                    r_bid                   <= r_wr_id;
                end
                else begin
                    r_wr_tx_pushen  <= 1'b0;
                    r_bvalid        <= 1'b0;
                    r_bid           <= {AXI.ID_W_BIT{1'b0}};
                end
            end
        end
    end

    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_rd_tx_pushen  <= 1'b0;
            r_rd_tx_pushdata<= 32'h00000000;
            r_rd_id         <= {AXI.ID_R_BIT{1'b0}};
        end
        else begin
            if (i_rd_tx_full == 1'b0) begin 
                if (AXI.ARVALID == 1'b1) begin
                    r_rd_tx_pushen  <= 1'b1;
                    r_rd_tx_pushdata<= AXI.ARADDR;
                    r_rd_id         <= AXI.ARID;
                end
                else begin
                    r_rd_tx_pushen  <= 1'b0;
                    r_rd_tx_pushdata<= 32'h00000000;
                end
            end
        end
    end

    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_rd_rx_popen   <= 1'b0;
        end
        else begin
            if (i_rd_rx_empty == 1'b0) begin
                r_rd_rx_popen   <= 1'b1;
            end
            else begin
                r_rd_rx_popen   <= 1'b0;
            end
        end
    end

    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_rvalid    <= 1'b0;
            r_rid       <= {AXI.ID_R_BIT{1'b0}};
            r_rdata     <= 32'h00000000;
            r_rlast     <= 1'b0;
            r_rresp     <= `XRESP_OKAY;
        end
        else begin
            if (r_rd_rx_popen == 1'b1) begin
                r_rvalid    <= 1'b1;
                r_rid       <= r_rd_id;
                r_rdata     <= i_rd_rx_popdata;
                r_rlast     <= 1'b1;
            end
            else begin
                r_rvalid    <= 1'b0;
                r_rid       <= {AXI.ID_R_BIT{1'b0}};
                r_rdata     <= 32'h00000000;
                r_rlast     <= 1'b0;
            end
        end
    end

//    always @ (posedge ACLK or negedge ARESET_N) begin
//        if (~ARESET_N) begin
//            r_wr_tx_pushen  <= 1'b0;
//            r_wr_tx_pushdata<= {64{1'b0}};
//            r_wr_state      <= `S_AXI_IDLE;
//        end
//        else begin
//            r_wr_tx_pushen  <= r_n_wr_tx_pushen;
//            r_wr_tx_pushdata<= r_n_wr_tx_pushdata;
//            r_wr_state      <= r_n_wr_state;
//        end
//    end
//
//    always @ (*) begin
//        if (~ARESET_N) begin
//            r_n_wr_tx_pushen    = 1'b0;
//            r_n_wr_tx_pushdata  = {64{1'b0}};
//            r_n_wr_state        = `S_AXI_IDLE;
//        end
//        else begin
//            case(r_wr_state)
//                `S_AXI_IDLE : begin
//                    if (AXI.AWVALID == 1'b1) begin
//                        r_n_wr_tx_pushen            = 1'b0;
//                        r_n_wr_tx_pushdata[63:32]   = AXI.AWADDR;
//                        r_n_wr_tx_pushdata[31:0]    = 32'h00000000;
//                        r_n_wr_state                = `S_AXI_RUN;
//                    end
//                    else begin
//                        r_n_wr_tx_pushen            = 1'b0;
//                        r_n_wr_tx_pushdata          = {64{1'b0}};
//                        r_n_wr_state                = `S_AXI_IDLE;
//                    end
//                end
//                `S_AXI_RUN  : begin
//                    if (AXI.WVALID == 1'b1) begin
//                        r_n_wr_tx_pushen            = 1'b1;
//                        r_n_wr_tx_pushdata[63:32]   = r_wr_tx_pushdata[63:32];
//                        r_n_wr_tx_pushdata[31:0]    = AXI.WDATA;
//                        r_n_wr_state                = 
//                    end
//                    else begin
//                        
//                    end
//                end
//                `S_AXI_WAIT : begin
//
//                end
//                default     : begin
//                    r_n_wr_tx_pushen    = 1'b0;
//                    r_n_wr_tx_pushdata  = {64{1'b0}};
//                    r_n_wr_state        = `S_AXI_IDLE;
//                end
//            endcase
//        end
//    end

    // AXI AW Output
    assign AXI.AWREADY      = 1'b1;
    // AXI W  Output
    assign AXI.WREADY       = 1'b1;
    // AXI B  Output
    assign AXI.BVALID       = r_bvalid;
    assign AXI.BID          = r_bid;
    assign AXI.BRESP        = r_bresp;
    // AXI AR Output
    assign AXI.ARREADY      = 1'b1;
    // AXI R  Output
    assign AXI.RVALID       = r_rvalid;
    assign AXI.RID          = r_rid;
    assign AXI.RDATA        = r_rdata;
    assign AXI.RLAST        = r_rlast;
    assign AXI.RRESP        = r_rresp;

    // WR Tx Ouput
    assign o_wr_tx_pushen   = r_wr_tx_pushen;
    assign o_wr_tx_pushdata = r_wr_tx_pushdata;

    // RD Tx Ouput
    assign o_rd_tx_pushen   = r_rd_tx_pushen;
    assign o_rd_tx_pushdata = r_rd_tx_pushdata;

    // RD Rx Ouput
    assign o_rd_rx_popen    = r_rd_rx_popen;

endmodule    
