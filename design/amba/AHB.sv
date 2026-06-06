interface AHB4 #(
    parameter ADDR_BIT = 32,
    parameter DATA_BIT = 32 // MAX(DATA_BIT) = 128
    );

    localparam STRB_BIT = DATA_BIT / 8;

    /* Control Signal
    HTRANS : Transfer Signal
        {00 : IDLE, 01 : BUSY, 10 : NONSEQ, 11 : SEQ}
    HPROT : Protection Signal
        {000 : OPCODE Fetch, 001 : Data Access, 010 : User Access, 011 : Privileged Access, 100 : Not Bufferable, 101 : Bufferable, 110 : Not Cacheable, 111 : Cacheable}
    HSIZE : Transfer Size
        2^(HSIZE) Byte    
    HBURST : Burst Signal
        {000 : SINGLE, 001 : INCR, 010 : WRAP4, 011 : INCR4, 100 : WRAP8, 101 : INCR8, 110 : WRAP16, 111 : INCR16}
    */

    wire [1:0]              HTRANS; 
    wire [ADDR_BIT - 1:0]   HADDR;
    wire                    HWRITE;
    wire [3:0]              HPROT;  
    wire [2:0]              HSIZE;  
    wire [2:0]              HBURST;
    wire [DATA_BIT - 1:0]   HWDATA;
    wire [STRB_BIT - 1:0]   HWSTRB;
    wire [DATA_BIT - 1:0]   HRDATA;
    wire                    HREADY;
    wire                    HRESP;

    modport MASTER (
        input   HREADY, HRESP, HRDATA,
        output  HTRANS, HADDR, HWRITE, HPROT, HSIZE, HBURST, HWDATA, HWSTRB
    );

    modport SLAVE (
        input   HTRANS, HADDR, HWRITE, HPROT, HSIZE, HBURST, HWDATA, HWSTRB,
        output  HREADY, HRESP, HRDATA
    );

endinterface
