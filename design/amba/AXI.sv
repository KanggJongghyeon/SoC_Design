`timescale 1ns / 1ps
interface AXI5 #(
    parameter ADDR_BIT  = 32,   // Must 1 ~ 64  Bit                                                     ,
    parameter DATA_BIT  = 32,   // DATA_BIT = {8, 16, 32, 64, 128, 256, 512, 1024} Bit,
    parameter ID_W_BIT  = 12,   // Must 0 ~ 32 Bit
    parameter ID_R_BIT  = 12,   // Must 0 ~ 32 Bit
    );                      

    localparam STRB_BIT = DATA_BIT / 8;

    /*
    Control Signal Description
    1. Burst Length= AxLEN + 1
    2. Data Beat   = 2^(AxSIZE) Byte
    3. AxBURST     = {00 : FIXED, 01 : INCR,   10 : WRAP,   11 : RESERVED}
    4. xRESP       = {00 : OKAY,  01 : EXOKAY, 10 : SLVERR, 11 : DECERR}
    */

    // AW Channel   (WRITE ADDRESS)
    wire                    AWVALID;
    wire                    AWREADY;
    wire [ID_W_BIT - 1:0]   AWID;
    wire [ADDR_BIT - 1:0]   AWADDR;
    wire [7:0]              AWLEN;  
    wire [2:0]              AWSIZE; 
    wire [1:0]              AWBURST;

    // W Channel    (WRITE)
    wire                    WVALID;
    wire                    WREADY;
    wire [DATA_BIT - 1:0]   WDATA;
    wire [STRB_BIT - 1:0]   WSTRB;
    wire                    WLAST;

    // B Channel    (WRITE RESPONSE)
    wire                    BVALID;
    wire                    BREADY;
    wire [ID_W_BIT - 1:0]   BID;
    wire [1:0]              BRESP;

    // AR Channel   (READ ADDRESS)
    wire                    ARVALID;
    wire                    ARREADY;
    wire [ID_R_BIT - 1:0]   ARID;
    wire [ADDR_BIT - 1:0]   ARADDR;
    wire [7:0]              ARLEN;   
    wire [2:0]              ARSIZE; 
    wire [1:0]              ARBURST;

    // R Channel (READ and READ RESPONSE)
    wire                    RVALID;
    wire                    RREADY;
    wire [ID_R_BIT - 1:0]   RID;
    wire [DATA_BIT - 1:0]   RDATA;
    wire                    RLAST;
    wire [1:0]              RRESP;
   
    modport MASTER (
        // AW
        input   AWREADY,
        output  AWVALID, AWID, AWADDR, AWLEN, AWSIZE, AWBURST,
        
        // W
        input   WREADY,
        output  WVALID, WDATA, WSTRB, WLAST,

        // B
        input   BVALID, BID, BRESP,  
        output  BREADY,

        // AR
        input   ARREADY,
        output  ARVALID, ARID, ARADDR, ARLEN, ARSIZE, ARBURST,

        // R
        input   RVALID, RID, RDATA, RLAST, RRESP,
        output  RREADY
    );

    modport SLAVE (
        // AW
        input   AWVALID, AWID, AWADDR, AWLEN, AWSIZE, AWBURST,
        output  AWREADY,

        // W
        input   WVALID, WDATA, WSTRB, WLAST,
        output  WREADY,

        // B
        input   BREADY,
        output  BVALID, BID, BRESP,  
        
        // AR
        input   ARVALID, ARID, ARADDR, ARLEN, ARSIZE, ARBURST,
        output  ARREADY,

        // R
        input   RREADY,
        output  RVALID, RID, RDATA, RLAST, RRESP
    );

endinterface
