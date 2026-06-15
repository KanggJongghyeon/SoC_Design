`include "../amba/AMBA.svh"
module noc #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32
    )(
    input   wire    ACLK,
    input   wire    ARESET_N,
    AXI5.SLAVE      AXI
    );

    // Local Parameter
    localparam BUF_SIZE     = 32;
    localparam BUF_ADDR_BIT = $clog2(BUF_SIZE);
    // for AXI Slave Output
    reg                     r_awready;
    reg                     r_wready;
    reg                     r_bvalid;
    reg [AXI.ID_BIT - 1:0]  r_bid;
    reg [1:0]               r_bresp;
    reg                     r_arready;
    reg                     r_rvalid;
    reg [AXI.ID_BIT - 1:0]  r_rid;
    reg [DATA_BIT - 1:0]    r_rdata;
    reg                     r_rlast;
    reg [1:0]               r_rresp;
    // Data Buffer
    reg [ADDR_BIT - 1:0]    buf_waddr   [0:BUF_SIZE - 1];
    reg [DATA_BIT - 1:0]    buf_wdata   [0:BUF_SIZE - 1];
    reg [ADDR_BIT - 1:0]    buf_raddr   [0:BUF_SIZE - 1];
    // for Previous AxID Store
    reg [AXI.ID_BIT - 1:0]  r_x1_awid;
    reg [AXI.ID_BIT - 1:0]  r_x2_awid;
    // for Loop Variable
    integer                 buf_idx;

    // Store Previous AWID
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_x1_awid   <= {AXI.ID_BIT{1'b0}};
            r_x2_awid   <= {AXI.ID_BIT{1'b0}};
        end
        else begin
            r_x1_awid   <= AXI.AWID;
            r_x2_awid   <= r_x1_awid;
        end
    end

    // AW Channel Logic
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_awready               <= 1'b1;
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_waddr[buf_idx]  <= {ADDR_BIT{1'b0}};
            end
        end
        else begin
            if (AXI.AWVALID == 1'b1) begin
                buf_waddr[AXI.AWID[BUF_ADDR_BIT - 1:0]] <= AXI.AWADDR;  // Suppose Single Burst
            end
        end
    end

    // W Channel Logic
     always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_wready                <= 1'b1;
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_wdata[buf_idx]  <= {DATA_BIT{1'b0}};
            end
        end
        else begin
            if (AXI.WVALID == 1'b1) begin
                buf_wdata[r_x1_awid[BUF_ADDR_BIT - 1:0]] <= AXI.WDATA;
            end
        end
    end

    // B Channel Logic
   always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_bvalid    <= 1'b0;
            r_bid       <= {AXI.ID_BIT{1'b0}};
            r_bresp     <= `XRESP_OKAY; 
        end
        else begin
            if (AXI.WVALID == 1'b1) begin
                r_bvalid    <= 1'b1;
                r_bid       <= r_x1_awid;   // Suppose No-Wait
            end
            else begin
                r_bvalid    <= 1'b0;
            end
        end
   end

    // AR Channel Logic
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_arready   <= 1'b1;
             for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_raddr[buf_idx]  <= {ADDR_BIT{1'b0}};
            end
        end
        else begin
            if (AXI.ARVALID == 1'b1) begin
                buf_raddr[AXI.ARID[BUF_ADDR_BIT - 1:0]] <= AXI.ARADDR;
            end
        end
    end

    // R Channel Logic
    always @ (posedge ACLK or negedge ARESET_N) begin
        if (~ARESET_N) begin
            r_rvalid    <= 1'b0;
            r_rid       <= {AXI.ID_BIT{1'b0}};
            r_rdata     <= {DATA_BIT{1'b0}};
            r_rlast     <= 1'b0;
            r_rresp     <= `XRESP_OKAY;
        end
        else begin
            if (AXI.ARVALID == 1'b1) begin
                r_rvalid    <= 1'b1;
                r_rid       <= AXI.ARID;
                r_rdata     <= buf_wdata[AXI.ARID[BUF_ADDR_BIT - 1:0]];
                r_rlast     <= 1'b1;    // Suppose Single Burst
            end
            else begin
                r_rvalid    <= 1'b0;
            end
        end
    end

    assign AXI.AWREADY  = r_awready;
    assign AXI.WREADY   = r_wready;
    assign AXI.BVALID   = r_bvalid;
    assign AXI.BID      = r_bid;
    assign AXI.BRESP    = r_bresp;
    assign AXI.ARREADY  = r_arready;
    assign AXI.RVALID   = r_rvalid;
    assign AXI.RID      = r_rid;
    assign AXI.RDATA    = r_rdata;
    assign AXI.RLAST    = r_rlast;
    assign AXI.RRESP    = r_rresp;

endmodule
