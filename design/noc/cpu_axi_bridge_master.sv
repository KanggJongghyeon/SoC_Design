`include "../amba/AMBA.svh"
module cpu_axi_bridge_master #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    // cpu if
    input   wire                        i_cpu_en,
    input   wire                        i_cpu_wren,
    input   wire                        i_cpu_addr,
    input   wire    [DATA_BIT - 1:0]    i_cpu_data, // Store(sw)
    output  wire    [DATA_BIT - 1:0]    o_cpu_data, // Load (lw)
    // axi if
    AXI5.MASTER                         AXI
    );

    // Local Parameter
    localparam CPU_ID       = 6'b100000;
    localparam BUF_SIZE     = 32;
    localparam BUF_ADDR_BIT = $clog2(BUF_SIZE);
    // for Buffer
    reg     [DATA_BIT - 1:0]    buf_cpu_waddr   [0:BUF_SIZE - 1];   // WADDR Buffer 
    reg     [DATA_BIT - 1:0]    buf_cpu_wdata   [0:BUF_SIZE - 1];   // WDATA Buffer 
    reg     [DATA_BIT - 1:0]    buf_cpu_raddr   [0:BUF_SIZE - 1];   // RADDR Buffer 
    reg     [BUF_ADDR_BIT - 1:0]r_buf_waddr_push_addr,  r_buf_wdata_push_addr,  r_buf_raddr_push_addr;  // Buffer Push ADDR               
    reg     [BUF_ADDR_BIT - 1:0]r_buf_waddr_pop_addr,   r_buf_wdata_pop_addr,   r_buf_raddr_pop_addr;   // Buffer Pop ADDR
    wire                        w_buf_waddr_empty,      w_buf_wdata_empty,      w_buf_raddr_empty;      // Buffer Empty
    // for AXI Output
    reg                         r_awvalid;  // AWVALID
    reg     [AXI.ID_BIT - 1:0]  r_awid;     // AWID
    reg     [ADDR_BIT - 1:0]    r_awaddr;   // AWADDR
    reg     [7:0]               r_awlen;    // AWLEN
    reg     [2:0]               r_awsize;   // AWSIZE
    reg     [1:0]               r_awburst;  // AWBURST
    reg                         r_wvalid;   // WVALID
    reg     [DATA_BIT - 1:0]    r_wdata;    // WDATA
    reg     [AXI.STRB_BIT - 1:0]r_wstrb;    // WSTRB
    reg                         r_wlast;    // WLAST
    reg                         r_bready;   // BREADY
    reg                         r_arvalid;  // ARVALID
    reg     [AXI.ID_BIT - 1:0]  r_arid;     // ARID
    reg     [ADDR_BIT - 1:0]    r_araddr;   // ARADDR
    reg     [7:0]               r_arlen;    // ARLEN
    reg     [2:0]               r_arsize;   // ARSIZE
    reg     [1:0]               r_arburst;  // ARBURST
    reg                         r_ready;    // RREADY
    // for CPU Output
    reg     [DATA_BIT - 1:0]    r_cpu_data; // CPU Load DATA
    // for Loop Variable
    integer                     buf_idx;

    // WADDR/WDATA Buffer
    always @ (posedge clk or  negedge rst_n) begin
        if (~rst_n) begin
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_cpu_waddr[buf_idx]  <= {DATA_BIT{1'b0}};
                buf_cpu_wdata[buf_idx]  <= {DATA_BIT{1'b0}};
            end
            r_buf_waddr_push_addr       <= {BUF_ADDR_BIT{1'b0}}; 
            r_buf_wdata_push_addr       <= {BUF_ADDR_BIT{1'b0}};
        end
        else begin
            if ((i_cpu_en == 1'b1) && (i_cpu_wren == 1'b1)) begin
                buf_cpu_waddr[r_buf_waddr_push_addr]<= i_cpu_addr;
                buf_cpu_wdata[r_buf_wdata_push_addr]<= i_cpu_data;
                r_buf_waddr_push_addr               <= r_buf_waddr_push_addr + BUF_ADDR_BIT'(1);
                r_buf_wdata_push_addr               <= r_buf_wdata_push_addr + BUF_ADDR_BIT'(1);
            end
        end
    end

    // RADDR Buffer
    always @ (posedge clk or  negedge rst_n) begin
        if (~rst_n) begin
            for (buf_idx == 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
                buf_cpu_raddr[buf_idx]  <= {DATA_BIT{1'b0}};
            end
            r_buf_raddr_push_addr       <= {BUF_ADDR_BIT{1'b0}}; 
        end
        else begin
            if ((i_cpu_en == 1'b1) && (i_cpu_wren != 1'b1)) begin
                buf_cpu_raddr[r_buf_raddr_push_addr]<= i_cpu_addr;
                r_buf_raddr_push_addr               <= r_buf_raddr_push_addr + BUF_ADDR_BIT'(1);
            end
        end
    end

    // AW Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_buf_waddr_pop_addr<= {BUF_ADDR_BIT{1'b0}}; 
            r_awvalid           <= 1'b0;
            r_awid              <= {AXI.ID_BIT{1'b0}}; 
            r_awaddr            <= {ADDR_BIT{1'b0}};
            r_awlen             <= `SINGLE_BURST;
            r_awsize            <= 3'b000; 
            r_awburst           <= `AXBURST_FIXED;
        end
        else begin
            if (w_buf_waddr_empty == 1'b1) begin
                r_awvalid           <= 1'b0;
            end
            else if (AXI.AWREADY == 1'b1)begin
                r_buf_waddr_pop_addr<= r_buf_waddr_pop_addr + BUF_ADDR_BIT'(1);
                r_awvalid           <= 1'b1;
                r_awid              <= {CPU_ID, 1'b1, r_buf_waddr_pop_addr};
                r_awaddr            <= buf_cpu_waddr[r_buf_waddr_pop_addr];
                r_awsize            <= 3'b010;
                r_awburst           <= `AXBURST_INCR;
            end
        end
    end

    // W Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_buf_wdata_pop_addr<= {BUF_ADDR_BIT{1'b0}};
            r_wvalid            <= 1'b0;
            r_wdata             <= {DATA_BIT{1'b0}};
            r_wstrb             <= {AXI.STRB_BIT{1'b0}};
            r_wlast             <= 1'b0;
        end
        else begin
            if (w_buf_wdata_empty == 1'b1) begin
                r_wvalid            <= 1'b0;
            end
            else if ((AXI.WREADY == 1'b1) && (r_buf_waddr_pop_addr != r_buf_wdata_pop_addr)) begin
                r_buf_wdata_pop_addr<= r_buf_wdata_pop_addr + BUF_ADDR_BIT'(1);
                r_wvalid            <= 1'b1;
                r_wdata             <= buf_cpu_wdata[r_buf_wdata_pop_addr];
                r_wstrb             <= {AXI.STRB_BIT{1'b1}};
                r_wlast             <= 1'b1;
            end
        end
    end

    // B Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_bready    <= 1'b0;
        end
        else begin
            if ((AXI.BVALID == 1'b1) && (AXI.BRESP != `XRESP_SLVERR) && (AXI.BRESP != `XRESP_DECERR)) begin
                r_bready    <= 1'b1;
            end         
                r_bready    <= 1'b0;
            end
        end
    end

    // AR Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_buf_raddr_pop_addr<= {BUF_ADDR_BIT{1'b0}};
            r_arvalid           <= 1'b0;
            r_arid              <= {AXI.ID_BIT{1'b0}};
            r_araddr            <= {ADDR_BIT{1'b0}};
            r_arlen             <= `SINGLE_BURST;
            r_arsize            <= 3'b000;
            r_arburst           <= `AXBURST_FIXED;
        end
        else begin
            if (w_buf_raddr_empty == 1'b1) begin
                r_arvalid           <= 1'b0;
            end
            else if (AXI.ARREADY == 1'b1)begin
                r_buf_raddr_pop_addr<= r_buf_raddr_pop_addr + BUF_ADDR_BIT'(1);
                r_arvalid           <= 1'b1;
                r_arid              <= {CPU_ID, 1'b0, r_buf_raddr_pop_addr};
                r_araddr            <= buf_cpu_raddr[r_buf_raddr_pop_addr];
                r_arsize            <= 3'b010;
                r_arburst           <= `AXBURST_INCR;
            end
        end
    end

    // R Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_rready    <= 1'b0;
            r_cpu_data  <= {DATA_BIT{1'b0}};
        end
        else begin
            if ((AXI.RVALID == 1'b1) && (AXI.RRESP != `XRESP_SLVERR) && (AXI.RRESP != `XRESP_DECERR)) begin
                r_bready    <= 1'b1;
                r_cpu_data  <= AXI.RDATA;
            end         
            else begin
                r_bready    <= 1'b0;
                r_cpu_data  <= AXI.RDATA;
            end
        end
    end

    // Buffer Empty Singal
    assign w_buf_waddr_empty= (r_buf_waddr_push_addr == r_buf_waddr_pop_addr);
    assign w_buf_wdata_empty= (r_buf_wdata_push_addr == r_buf_wdata_pop_addr);
    assign w_buf_raddr_empty= (r_buf_raddr_push_addr == r_buf_raddr_pop_addr);
    // AXI AW Output        
    assign AXI.AWVALID      = r_awvalid;
    assign AXI.AWID         = r_awid;
    assign AXI.AWADDR       = r_awaddr;
    assign AXI.AWLEN        = r_awlen;
    assign AXI.AWSIZE       = r_awsize;
    assign AXI.AWBURST      = r_awburst;
    // AXI W Output
    assign AXI.WVALID       = r_wvalid;
    assign AXI.WDATA        = r_wdata;
    assign AXI.WSTRB        = r_wstrb;
    assign AXI.WLAST        = r_wlast;
    // AXI B Output
    assign AXI.BREADY       = r_bready;
    // AXI AR Output
    assign AXI.ARVALID      = r_arvalid; 
    assign AXI.ARID         = r_arid;
    assign AXI.ARADDR       = r_araddr;
    assign AXI.ARLEN        = r_arlen;
    assign AXI.ARSIZE       = r_arsize;
    assign AXI.ARBURST      = r_arburst;
    // AXI R Output
    assign AXI.RREADY       = r_ready;
    // CPU Output
    assign o_cpu_data       = r_cpu_data;

endmodule
