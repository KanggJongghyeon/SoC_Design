`include "../amba/AMBA.svh"
`timescale 1ns / 1ps
module cpu_axi_master #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    // cpu if
    input   wire                        i_cpu_en,
    input   wire                        i_cpu_wren,
    input   wire    [ADDR_BIT - 1:0]    i_cpu_addr,
    input   wire    [DATA_BIT - 1:0]    i_cpu_data, // Store(sw)
    output  wire    [DATA_BIT - 1:0]    o_cpu_data, // Load (lw)
    // axi if
    input   wire                        AXREQUEST
    AXI5.MASTER                         AXI
    );

    // Local Parameter
    localparam CPU_ID       = 6'b100000;
    localparam BUF_SIZE     = 32;
    localparam BUF_ADDR_BIT = $clog2(BUF_SIZE);
    // for Buffer
    reg     [ADDR_BIT - 1:0]    buf_cpu_waddr   [0:BUF_SIZE - 1];   // WADDR Buffer 
    reg     [DATA_BIT - 1:0]    buf_cpu_wdata   [0:BUF_SIZE - 1];   // WDATA Buffer 
    reg     [ADDR_BIT - 1:0]    buf_cpu_raddr   [0:BUF_SIZE - 1];   // RADDR Buffer 
    reg     [BUF_ADDR_BIT - 1:0]r_buf_waddr_push_addr,  r_buf_wdata_push_addr,  r_buf_raddr_push_addr;  // Buffer Push ADDR               
    reg     [BUF_ADDR_BIT - 1:0]r_buf_waddr_pop_addr,   r_buf_wdata_pop_addr,   r_buf_raddr_pop_addr;   // Buffer Pop ADDR
    reg     [BUF_ADDR_BIT - 1:0]r_n_buf_waddr_pop_addr, r_n_buf_wdata_pop_addr, r_n_buf_raddr_pop_addr; // Buffer Pop ADDR (Next)
    wire                        w_buf_waddr_empty,      w_buf_wdata_empty,      w_buf_raddr_empty;      // Buffer Empty
    // for AXI Master Output                            
    reg                         r_awvalid,  r_n_awvalid;// AWVALID
    reg     [AXI.ID_BIT - 1:0]  r_awid,     r_n_awid;   // AWID
    reg     [ADDR_BIT - 1:0]    r_awaddr,   r_n_awaddr; // AWADDR
    reg     [7:0]               r_awlen;                // AWLEN
    reg     [2:0]               r_awsize,   r_n_awsize; // AWSIZE
    reg     [1:0]               r_awburst;              // AWBURST
    reg                         r_wvalid,   r_n_wvalid; // WVALID
    reg     [DATA_BIT - 1:0]    r_wdata,    r_n_wdata;  // WDATA
    reg     [AXI.STRB_BIT - 1:0]r_wstrb,    r_n_wstrb;  // WSTRB
    reg                         r_wlast,    r_n_wlast;  // WLAST
    reg                         r_bready;               // BREADY
    reg                         r_arvalid,  r_n_arvalid;// ARVALID
    reg     [AXI.ID_BIT - 1:0]  r_arid,     r_n_arid;   // ARID
    reg     [ADDR_BIT - 1:0]    r_araddr,   r_n_araddr; // ARADDR
    reg     [7:0]               r_arlen;                // ARLEN
    reg     [2:0]               r_arsize,   r_n_arsize; // ARSIZE
    reg     [1:0]               r_arburst;              // ARBURST
    reg                         r_rready;               // RREADY
    // for CPU Output
    reg     [DATA_BIT - 1:0]    r_cpu_data; // CPU Load DATA
    // for Loop Variable
    integer                     buf_idx;
    // for AXI Master State
    reg     [1:0]               r_aw_state, r_n_aw_state;
    reg     [1:0]               r_w_state,  r_n_w_state;
    reg     [1:0]               r_ar_state, r_n_ar_state;

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
            for (buf_idx = 0; buf_idx < BUF_SIZE; buf_idx = buf_idx + 1) begin
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
        r_awlen     <= `SINGLE_BURST;
        r_awburst   <= `AXBURST_FIXED;
        if (~rst_n) begin
            r_aw_state          <= `S_AXI_IDLE;
            r_buf_waddr_pop_addr<= {BUF_ADDR_BIT{1'b0}};
            r_awvalid           <= 1'b0;
            r_awid              <= {AXI.ID_BIT{1'b0}}; 
            r_awaddr            <= {ADDR_BIT{1'b0}};
            r_awsize            <= 3'b000; 
        end
        else begin
            r_aw_state          <= r_n_aw_state;
            r_buf_waddr_pop_addr<= r_n_buf_waddr_pop_addr;
            r_awvalid           <= r_n_awvalid;
            r_awid              <= r_n_awid; 
            r_awaddr            <= r_n_awaddr;
            r_awsize            <= r_n_awsize;
        end
    end
    
    always @ (*) begin
        if (~rst_n) begin
            r_n_aw_state            = `S_AXI_IDLE;
            r_n_buf_waddr_pop_addr  = {BUF_ADDR_BIT{1'b0}};
            r_n_awvalid             = 1'b0;
            r_n_awid                = {AXI.ID_BIT{1'b0}}; 
            r_n_awaddr              = {ADDR_BIT{1'b0}};
            r_n_awsize              = 3'b000; 
        end
        else begin
            case (r_aw_state)
                `S_AXI_IDLE : begin
                    if (w_buf_waddr_empty == 1'b1) begin
                        r_n_aw_state            = `S_AXI_IDLE;
                        r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr;
                        r_n_awvalid             = 1'b0;
                        r_n_awid                = r_awid;
                        r_n_awaddr              = r_awaddr;
                        r_n_awsize              = r_awsize;
                    end
                    else begin
                        r_n_aw_state            = `S_AXI_RUN;
                        r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr + BUF_ADDR_BIT'(1);
                        r_n_awvalid             = 1'b1;
                        r_n_awid                = {CPU_ID, 1'b1, r_buf_waddr_pop_addr};
                        r_n_awaddr              = buf_cpu_waddr[r_buf_waddr_pop_addr];
                        r_n_awsize              = 3'b010;
                    end
                end
                `S_AXI_RUN  : begin
                    if (AXI.AWREADY == 1'b1) begin
                        if (w_buf_waddr_empty != 1'b1) begin
                            r_n_aw_state            = `S_AXI_RUN;
                            r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr + BUF_ADDR_BIT'(1);
                            r_n_awvalid             = 1'b1;
                            r_n_awid                = {CPU_ID, 1'b1, r_buf_waddr_pop_addr};
                            r_n_awaddr              = buf_cpu_waddr[r_buf_waddr_pop_addr];
                            r_n_awsize              = 3'b010;
                        end
                        else begin
                            r_n_aw_state            = `S_AXI_IDLE;
                            r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr;
                            r_n_awvalid             = 1'b0;
                            r_n_awid                = {AXI.ID_BIT{1'b0}};
                            r_n_awaddr              = {ADDR_BIT{1'b0}};
                            r_n_awsize              = 3'b000;
                        end
                    end
                    else begin
                        r_n_aw_state            = `S_AXI_WAIT;
                        r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr;
                        r_n_awvalid             = 1'b1;
                        r_n_awid                = r_awid;
                        r_n_awaddr              = r_awaddr;
                        r_n_awsize              = r_awsize;
                    end
                end
                `S_AXI_WAIT : begin
                    if (AXI.AWREADY == 1'b1) begin
                        r_n_aw_state            = `S_AXI_RUN;
                        r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr + BUF_ADDR_BIT'(1);
                        r_n_awvalid             = 1'b1;
                        r_n_awid                = {CPU_ID, 1'b1, r_buf_waddr_pop_addr};
                        r_n_awaddr              = buf_cpu_waddr[r_buf_waddr_pop_addr];
                        r_n_awsize              = 3'b010;
                    end
                    else begin
                        r_n_aw_state            = `S_AXI_WAIT;
                        r_n_buf_waddr_pop_addr  = r_buf_waddr_pop_addr;
                        r_n_awvalid             = 1'b1;
                        r_n_awid                = r_awid;
                        r_n_awaddr              = r_awaddr;
                        r_n_awsize              = r_awsize;
                    end
                end
                default     : begin
                    r_n_aw_state            = `S_AXI_IDLE;
                    r_n_buf_waddr_pop_addr  = {BUF_ADDR_BIT{1'b0}};
                    r_n_awvalid             = 1'b0;
                    r_n_awid                = {AXI.ID_BIT{1'b0}}; 
                    r_n_awaddr              = {ADDR_BIT{1'b0}};
                    r_n_awsize              = 3'b000; 
                end
            endcase
        end
    end

    // W Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_w_state           <= `S_AXI_IDLE;
            r_buf_wdata_pop_addr<= {BUF_ADDR_BIT{1'b0}};
            r_wvalid            <= 1'b0;
            r_wdata             <= {DATA_BIT{1'b0}};
            r_wstrb             <= {AXI.STRB_BIT{1'b0}};
            r_wlast             <= 1'b0;
        end
        else begin
            r_w_state           <= r_n_w_state;
            r_buf_wdata_pop_addr<= r_n_buf_wdata_pop_addr;
            r_wvalid            <= r_n_wvalid;
            r_wdata             <= r_n_wdata;
            r_wstrb             <= r_n_wstrb;
            r_wlast             <= r_n_wlast;
        end
    end

    always @ (*) begin
        if (~rst_n) begin
            r_n_w_state             = `S_AXI_IDLE;
            r_n_buf_wdata_pop_addr  = {BUF_ADDR_BIT{1'b0}};
            r_n_wvalid              = 1'b0;
            r_n_wdata               = {DATA_BIT{1'b0}};
            r_n_wstrb               = {AXI.STRB_BIT{1'b0}};
            r_n_wlast               = 1'b0;
        end
        else begin
            case (r_w_state)
                `S_AXI_IDLE : begin
                    if (w_buf_wdata_empty == 1'b1) begin
                        r_n_w_state             = `S_AXI_IDLE;
                        r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr;
                        r_n_wvalid              = 1'b0;
                        r_n_wdata               = r_wdata;
                        r_n_wstrb               = r_wstrb;
                        r_n_wlast               = 1'b0;
                    end
                    else begin
                        if (r_buf_waddr_pop_addr != r_buf_wdata_pop_addr) begin
                            r_n_w_state             = `S_AXI_RUN;
                            r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr + BUF_ADDR_BIT'(1);
                            r_n_wvalid              = 1'b1;
                            r_n_wdata               = buf_cpu_wdata[r_buf_wdata_pop_addr];
                            r_n_wstrb               = {AXI.STRB_BIT{1'b1}};
                            r_n_wlast               = 1'b1;
                        end
                        else begin
                            r_n_w_state             = `S_AXI_IDLE;
                            r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr;
                            r_n_wvalid              = 1'b0;
                            r_n_wdata               = r_wdata;
                            r_n_wstrb               = r_wstrb;
                            r_n_wlast               = 1'b0;
                        end
                    end
                end
                `S_AXI_RUN  : begin
                    if (AXI.WREADY == 1'b1) begin
                        if ((w_buf_wdata_empty != 1'b1) && (r_buf_waddr_pop_addr != r_buf_wdata_pop_addr)) begin
                            r_n_w_state             = `S_AXI_RUN;
                            r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr + BUF_ADDR_BIT'(1);
                            r_n_wvalid              = 1'b1;
                            r_n_wdata               = buf_cpu_wdata[r_buf_wdata_pop_addr];
                            r_n_wstrb               = {AXI.STRB_BIT{1'b1}};
                            r_n_wlast               = 1'b1;
                        end
                        else begin
                            r_n_w_state             = `S_AXI_IDLE;
                            r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr;
                            r_n_wvalid              = 1'b0;
                            r_n_wdata               = {DATA_BIT{1'b0}};
                            r_n_wstrb               = {AXI.STRB_BIT{1'b0}};
                            r_n_wlast               = 1'b0;
                        end
                    end
                    else begin
                        r_n_w_state             = `S_AXI_WAIT;
                        r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr;
                        r_n_wvalid              = 1'b1;
                        r_n_wdata               = r_wdata;
                        r_n_wstrb               = r_wstrb;
                        r_n_wlast               = r_wlast;
                    end
                end
                `S_AXI_WAIT : begin
                    if (AXI.WREADY == 1'b1) begin
                        r_n_w_state             = `S_AXI_RUN;
                        r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr + BUF_ADDR_BIT'(1);
                        r_n_wvalid              = 1'b1;
                        r_n_wdata               = buf_cpu_wdata[r_buf_wdata_pop_addr];
                        r_n_wstrb               = {AXI.STRB_BIT{1'b1}};
                        r_n_wlast               = 1'b1;
                    end
                    else begin
                        r_n_w_state             = `S_AXI_WAIT;
                        r_n_buf_wdata_pop_addr  = r_buf_wdata_pop_addr;
                        r_n_wvalid              = 1'b1;
                        r_n_wdata               = r_wdata;
                        r_n_wstrb               = r_wstrb;
                        r_n_wlast               = r_wlast;
                    end
                end
                default     : begin
                    r_n_w_state             = `S_AXI_IDLE;
                    r_n_buf_wdata_pop_addr  = {BUF_ADDR_BIT{1'b0}};
                    r_n_wvalid              = 1'b0;
                    r_n_wdata               = {DATA_BIT{1'b0}};
                    r_n_wstrb               = {AXI.STRB_BIT{1'b0}};
                    r_n_wlast               = 1'b0;
                end
            endcase
        end
    end
    
    // B Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        r_bready    <= 1'b1;
    end

    // AR Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        r_arlen     <= `SINGLE_BURST;
        r_arburst   <= `AXBURST_FIXED;
        if (~rst_n) begin
            r_ar_state          <= `S_AXI_IDLE;
            r_buf_raddr_pop_addr<= {BUF_ADDR_BIT{1'b0}};
            r_arvalid           <= 1'b0;
            r_arid              <= {AXI.ID_BIT{1'b0}};
            r_araddr            <= {ADDR_BIT{1'b0}};
            r_arsize            <= 3'b000;
        end
        else begin
            r_ar_state          <= r_n_ar_state;
            r_buf_raddr_pop_addr<= r_n_buf_raddr_pop_addr;
            r_arvalid           <= r_n_arvalid;
            r_arid              <= r_n_arid;
            r_araddr            <= r_n_araddr;
            r_arsize            <= r_n_arsize;
        end
    end

    always @ (*) begin
        if (~rst_n) begin
            r_n_ar_state            = `S_AXI_IDLE;
            r_n_buf_raddr_pop_addr  = {BUF_ADDR_BIT{1'b0}};
            r_n_arvalid             = 1'b0;
            r_n_arid                = {AXI.ID_BIT{1'b0}};
            r_n_araddr              = {ADDR_BIT{1'b0}};
            r_n_arsize              = 3'b000;
        end
        else begin
            case (r_ar_state)
                `S_AXI_IDLE : begin
                    if (w_buf_raddr_empty == 1'b1) begin
                        r_n_ar_state            = `S_AXI_IDLE;
                        r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr;
                        r_n_arvalid             = 1'b0;
                        r_n_arid                = r_arid;
                        r_n_araddr              = r_araddr;
                        r_n_arsize              = r_arsize;
                    end
                    else begin
                        r_n_ar_state            = `S_AXI_RUN;
                        r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr + BUF_ADDR_BIT'(1);
                        r_n_arvalid             = 1'b1;
                        r_n_arid                = {CPU_ID, 1'b0, r_buf_raddr_pop_addr};
                        r_n_araddr              = buf_cpu_raddr[r_buf_raddr_pop_addr];
                        r_n_arsize              = 3'b010;
                    end
                end
                `S_AXI_RUN  : begin
                    if (AXI.ARREADY == 1'b1) begin
                        if (w_buf_raddr_empty != 1'b1) begin
                            r_n_ar_state            = `S_AXI_RUN;
                            r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr + BUF_ADDR_BIT'(1);
                            r_n_arvalid             = 1'b1;
                            r_n_arid                = {CPU_ID, 1'b0, r_buf_raddr_pop_addr};
                            r_n_araddr              = buf_cpu_raddr[r_buf_raddr_pop_addr];
                            r_n_arsize              = 3'b010;
                        end
                        else begin
                            r_n_ar_state            = `S_AXI_IDLE;
                            r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr;
                            r_n_arvalid             = 1'b0;
                            r_n_arid                = {AXI.ID_BIT{1'b0}};
                            r_n_araddr              = {ADDR_BIT{1'b0}};
                            r_n_arsize              = 3'b000;
                        end
                    end
                    else begin
                        r_n_ar_state            = `S_AXI_WAIT;
                        r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr;
                        r_n_arvalid             = 1'b1;
                        r_n_arid                = r_arid;
                        r_n_araddr              = r_araddr;
                        r_n_arsize              = r_arsize;
                    end
                end
                `S_AXI_WAIT : begin
                    if (AXI.ARREADY == 1'b1) begin
                        r_n_ar_state            = `S_AXI_RUN;
                        r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr + BUF_ADDR_BIT'(1);
                        r_n_arvalid             = 1'b1;
                        r_n_arid                = {CPU_ID, 1'b0, r_buf_raddr_pop_addr};
                        r_n_araddr              = buf_cpu_raddr[r_buf_raddr_pop_addr];
                        r_n_arsize              = 3'b010;
                    end
                    else begin
                        r_n_ar_state            = `S_AXI_WAIT;
                        r_n_buf_raddr_pop_addr  = r_buf_raddr_pop_addr;
                        r_n_arvalid             = 1'b1;
                        r_n_arid                = r_arid;
                        r_n_araddr              = r_araddr;
                        r_n_arsize              = r_arsize;
                    end
                end
                default     : begin
                    r_n_ar_state            = `S_AXI_IDLE;
                    r_n_buf_raddr_pop_addr  = {BUF_ADDR_BIT{1'b0}};
                    r_n_arvalid             = 1'b0;
                    r_n_arid                = {AXI.ID_BIT{1'b0}}; 
                    r_n_araddr              = {ADDR_BIT{1'b0}};
                    r_n_arsize              = 3'b000; 
                end
            endcase
        end
    end

    // R Channel Logic
    always @ (posedge clk or negedge rst_n) begin
        r_rready    <= 1'b1;
        if (~rst_n) begin
            r_cpu_data  <= {DATA_BIT{1'b0}};
        end
        else begin
            r_cpu_data  <= AXI.RDATA;
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
    assign AXI.RREADY       = r_rready;
    // CPU Output
    assign o_cpu_data       = r_cpu_data;

endmodule
