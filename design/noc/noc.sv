`include "../amba/AMBA.svh"
`include "mmio.svh" // for setting Debug Mode
`timescale 1ns / 1ps
module noc #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32
    )(
    input   wire    ACLK,
    input   wire    ARESET_N,
    AXI5.SLAVE      AXI_NOC,    // (CPU or DMA Request)
    AXI5.MASTER     AXI_AXI2APB // AXI2APB Bridge
    );

    // Local Parameter
    localparam BUF_SIZE     = 32;
    localparam BUF_ADDR_BIT = $clog2(BUF_SIZE);
    
    // Wire from ADDR_DECODER
    wire                            w_boot_rom_wren;
    wire                            w_axi2ahb_wren;
    wire                            w_axi2apb_wren;
    wire                            w_cache_mem_wren;
    wire                            w_main_mem_wren;
    wire                            w_boot_rom_rden;
    wire                            w_axi2ahb_rden;
    wire                            w_axi2apb_rden;
    wire                            w_cache_mem_rden;
    wire                            w_main_mem_rden;

    // for AXI NoC Output
    reg                             r_noc_bvalid;
    reg [AXI_NOC.ID_BIT - 1:0]      r_noc_bid;
    reg [1:0]                       r_noc_bresp;
    reg                             r_noc_rvalid;
    reg [AXI_NOC.ID_BIT - 1:0]      r_noc_rid;
    reg [DATA_BIT - 1:0]            r_noc_rdata;
    reg                             r_noc_rlast;
    reg [1:0]                       r_noc_rresp;
    
    // for AXI AXI2APB Output
    reg                             r_axi2apb_awvalid;
    reg [AXI_AXI2APB.ID_BIT - 1:0]  r_axi2apb_awid;
    reg [ADDR_BIT - 1:0]            r_axi2apb_awaddr;
    reg [7:0]                       r_axi2apb_awlen;
    reg [2:0]                       r_axi2apb_awsize;
    reg [1:0]                       r_axi2apb_awburst;
    reg                             r_axi2apb_wvalid;
    reg [DATA_BIT - 1:0]            r_axi2apb_wdata;
    reg [AXI_AXI2APB.STRB_BIT - 1:0]r_axi2apb_wstrb;
    reg                             r_axi2apb_wlast;
    reg                             r_axi2apb_arvalid;
    reg [AXI_AXI2APB.ID_BIT - 1:0]  r_axi2apb_arid;
    reg [ADDR_BIT - 1:0]            r_axi2apb_araddr;
    reg [7:0]                       r_axi2apb_arlen;
    reg [2:0]                       r_axi2apb_arsize;
    reg [1:0]                       r_axi2apb_arburst;

    `ifdef NOC_DEBUG
    // Data Buffer for Debug
    reg [ADDR_BIT - 1:0]            buf_waddr   [0:BUF_SIZE - 1];
    reg [DATA_BIT - 1:0]            buf_wdata   [0:BUF_SIZE - 1];
    reg [ADDR_BIT - 1:0]            buf_raddr   [0:BUF_SIZE - 1];
    `endif // NOC_DEBUG
    
    // for Previous AxID Store
    reg [AXI_NOC.ID_BIT - 1:0]      r_x1_awid;
    reg [AXI_NOC.ID_BIT - 1:0]      r_x2_awid;
    
    // for Loop Variable
    integer                         buf_idx;
    
    // WADDR DECODER
    addr_decoder #(
        .ADDR_BIT       (AXI_NOC.ADDR_BIT)
    ) u_waddr_decoder (
        .AXVALID        (AXI_NOC.AWVALID),
        .AXADDR         (AXI_NOC.AWADDR),
        .o_boot_rom_en  (w_boot_rom_wren),
        .o_axi2ahb_en   (w_axi2ahb_wren),
        .o_axi2apb_en   (w_axi2apb_wren),
        .o_cache_mem_en (w_cache_mem_wren),
        .o_main_mem_en  (w_main_mem_wren)
    );

    // RADDR DECODER
    addr_decoder #(
        .ADDR_BIT       (AXI_NOC.ADDR_BIT)
    ) u_raddr_decoder (
        .AXVALID        (AXI_NOC.ARVALID),
        .AXADDR         (AXI_NOC.ARADDR),
        .o_boot_rom_en  (w_boot_rom_rden),
        .o_axi2ahb_en   (w_axi2ahb_rden),
        .o_axi2apb_en   (w_axi2apb_rden),
        .o_cache_mem_en (w_cache_mem_rden),
        .o_main_mem_en  (w_main_mem_rden)
    );

    // Store Previous AWID
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_x1_awid   <= {AXI_NOC.ID_BIT{1'b0}};
            r_x2_awid   <= {AXI_NOC.ID_BIT{1'b0}};
        end
        else begin
            r_x1_awid   <= AXI_NOC.AWID;
            r_x2_awid   <= r_x1_awid;
        end
    end

    // AW Channel Logic
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            `ifdef NOC_DEBUG
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_waddr[buf_idx]  <= {ADDR_BIT{1'b0}};
            end
            `endif // NOC_DEBUG
            r_axi2apb_awvalid       <= 1'b0;
            r_axi2apb_awid          <= {AXI_AXI2APB.ID_BIT{1'b0}};
            r_axi2apb_awaddr        <= {ADDR_BIT{1'b0}};
            r_axi2apb_awlen         <= `SINGLE_BURST;
            r_axi2apb_awsize        <= 3'b000;
            r_axi2apb_awburst       <= `AXBURST_FIXED;
        end
        else begin
            if (AXI_NOC.AWVALID == 1'b1) begin
                `ifdef NOC_DEBUG
                buf_waddr[AXI_NOC.AWID[BUF_ADDR_BIT - 1:0]] <= AXI_NOC.AWADDR;  // Suppose Single Burst
                `endif // NOC_DEBUG
                `ifdef NOC_SINGLE_MASTER
                //if (w_boot_rom_wren == 1'b1) begin

                //end
                //else if (w_axi2ahb_wren == 1'b1) begin

                //end
                /*else */if (w_axi2apb_wren == 1'b1) begin
                    r_axi2apb_awvalid   <= 1'b1;
                    r_axi2apb_awid      <= AXI_NOC.AWID;
                    r_axi2apb_awaddr    <= AXI_NOC.AWADDR;
                    r_axi2apb_awlen     <= AXI_NOC.AWLEN;
                    r_axi2apb_awsize    <= AXI_NOC.AWSIZE;
                    r_axi2apb_awburst   <= AXI_NOC.AWBURST;
                end
                //else if (w_cache_mem_wren == 1'b1) begin

                //end
                //else if (w_main_mem_wren == 1'b1) begin

                //end
                `endif // NOC_SINGLE_MASTER
            end
        end
    end

    // W Channel Logic
     always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            `ifdef NOC_DEBUG
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_wdata[buf_idx]  <= {DATA_BIT{1'b0}};
            end
            `endif // NOC_DEBUG
            r_axi2apb_wvalid        <= 1'b0;
            r_axi2apb_wdata         <= {DATA_BIT{1'b0}};
            r_axi2apb_wstrb         <= {AXI_AXI2APB.ID_BIT{1'b0}};
            r_axi2apb_wlast         <= 1'b0;
        end
        else begin
            if (AXI_NOC.WVALID == 1'b1) begin
                `ifdef NOC_DEBUG
                buf_wdata[r_x1_awid[BUF_ADDR_BIT - 1:0]] <= AXI_NOC.WDATA;
                `endif // NOC_DEUBG
                `ifdef NOC_SINGLE_MASTER
                //if (w_boot_rom_wren == 1'b1) begin

                //end
                //else if (w_axi2ahb_wren == 1'b1) begin

                //end
                /*else */if (w_axi2apb_wren == 1'b1) begin
                    r_axi2apb_wvalid    <= 1'b1;
                    r_axi2apb_wdata     <= AXI_NOC.WDATA;
                    r_axi2apb_wstrb     <= AXI_NOC.WSTRB;
                    r_axi2apb_wlast     <= AXI_NOC.WLAST;
                end
                //else if (w_cache_mem_wren == 1'b1) begin

                //end
                //else if (w_main_mem_wren == 1'b1) begin

                //end
                `endif // NOC_SINGLE_MASTER
            end
        end
    end

    // B Channel Logic
   always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_noc_bvalid    <= 1'b0;
            r_noc_bid       <= {AXI_NOC.ID_BIT{1'b0}};
            r_noc_bresp     <= `XRESP_OKAY;
        end
        else begin
            if (AXI_NOC.WVALID == 1'b1) begin
                r_noc_bvalid<= 1'b1;
                r_noc_bid   <= r_x1_awid;   // Suppose No-Wait
            end
            else begin
                r_noc_bvalid<= 1'b0;
            end
        end
   end

    // AR Channel Logic
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            `ifdef NOC_DEBUG
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_raddr[buf_idx]  <= {ADDR_BIT{1'b0}};
            end
            `endif // NOC_DEBUG
            r_axi2apb_arvalid       <= 1'b0;
            r_axi2apb_arid          <= {AXI_AXI2APB.ID_BIT{1'b0}};
            r_axi2apb_araddr        <= {ADDR_BIT{1'b0}};
            r_axi2apb_arlen         <= `SINGLE_BURST;
            r_axi2apb_arsize        <= 3'b000;
            r_axi2apb_arburst       <= `AXBURST_FIXED;
        end
        else begin
            if (AXI_NOC.ARVALID == 1'b1) begin
                `ifdef NOC_DEBUG
                buf_raddr[AXI_NOC.ARID[BUF_ADDR_BIT - 1:0]] <= AXI_NOC.ARADDR;
                `endif
                `ifdef NOC_SINGLE_MASTER
                //if (w_boot_rom_wren == 1'b1) begin

                //end
                //else if (w_axi2ahb_wren == 1'b1) begin

                //end
                /*else */if (w_axi2apb_wren == 1'b1) begin
                    r_axi2apb_arvalid   <= 1'b1;
                    r_axi2apb_arid      <= AXI_NOC.ARID;
                    r_axi2apb_araddr    <= AXI_NOC.ARADDR;
                    r_axi2apb_arlen     <= AXI_NOC.ARLEN;
                    r_axi2apb_arsize    <= AXI_NOC.ARSIZE;
                    r_axi2apb_arburst   <= AXI_NOC.ARBURST;
                end
                //else if (w_cache_mem_wren == 1'b1) begin

                //end
                //else if (w_main_mem_wren == 1'b1) begin

                //end
                `endif // NOC_SINGLE_MASTER
            end
        end
    end

    // R Channel Logic
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_noc_rvalid    <= 1'b0;
            r_noc_rid       <= {AXI_NOC.ID_BIT{1'b0}};
            r_noc_rdata     <= {DATA_BIT{1'b0}};
            r_noc_rlast     <= 1'b0;
            r_noc_rresp     <= `XRESP_OKAY;
        end
        else begin
            if (AXI_NOC.ARVALID == 1'b1) begin
                r_noc_rvalid<= 1'b1;
                r_noc_rid   <= AXI_NOC.ARID;
                `ifdef NOC_DEBUG
                r_noc_rdata <= buf_wdata[AXI_NOC.ARID[BUF_ADDR_BIT - 1:0]];
                `endif // NOC_DEBUG
                `ifdef NOC_SINGLE_MASTER
                r_noc_rdata <= AXI_AXI2APB.RDATA;
                `endif // NOC_SINGLE_MASTER
                r_noc_rlast <= 1'b1;    // Suppose Single Burst
            end
            else begin
                r_noc_rvalid<= 1'b0;
            end
        end
    end
   
    // AXI_NoC Output
    assign AXI_NOC.AWREADY      = 1'b1;
    assign AXI_NOC.WREADY       = 1'b1;
    assign AXI_NOC.BVALID       = r_noc_bvalid;
    assign AXI_NOC.BID          = r_noc_bid;
    assign AXI_NOC.BRESP        = r_noc_bresp;
    assign AXI_NOC.ARREADY      = 1'b1;
    assign AXI_NOC.RVALID       = r_noc_rvalid;
    assign AXI_NOC.RID          = r_noc_rid;
    assign AXI_NOC.RDATA        = r_noc_rdata;
    assign AXI_NOC.RLAST        = r_noc_rlast;
    assign AXI_NOC.RRESP        = r_noc_rresp;
    // AXI_AXI2APB Output
    assign AXI_AXI2APB.AWVALID  = r_axi2apb_awvalid;
    assign AXI_AXI2APB.AWID     = r_axi2apb_awid;
    assign AXI_AXI2APB.AWADDR   = r_axi2apb_awaddr;
    assign AXI_AXI2APB.AWLEN    = r_axi2apb_awlen;
    assign AXI_AXI2APB.AWSIZE   = r_axi2apb_awsize;
    assign AXI_AXI2APB.AWBURST  = r_axi2apb_awburst;
    assign AXI_AXI2APB.WVALID   = r_axi2apb_wvalid;
    assign AXI_AXI2APB.WDATA    = r_axi2apb_wdata;
    assign AXI_AXI2APB.WSTRB    = r_axi2apb_wstrb;
    assign AXI_AXI2APB.WLAST    = r_axi2apb_wlast;
    assign AXI_AXI2APB.BREADY   = 1'b1;
    assign AXI_AXI2APB.ARVALID  = r_axi2apb_arvalid;
    assign AXI_AXI2APB.ARID     = r_axi2apb_arid;
    assign AXI_AXI2APB.ARADDR   = r_axi2apb_araddr;
    assign AXI_AXI2APB.ARLEN    = r_axi2apb_arlen;
    assign AXI_AXI2APB.ARSIZE   = r_axi2apb_arsize;
    assign AXI_AXI2APB.ARBURST  = r_axi2apb_arburst;
    assign AXI_AXI2APB.RREADY   = 1'b1;

endmodule
