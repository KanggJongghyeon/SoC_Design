`timescale 1ns / 1ps
interface AHB5 #(           
    parameter ADDR_BIT  = 32,   // Recommended 10 ~ 64  Bit    
    parameter DATA_BIT  = 32,   // Recommended 32 ~ 256 Bit, DATA_BIT = {8, 16, 32, 64, 128, 256, 512, 1024} Bit
    parameter PROT_BIT  = 4     // PROT_BIT = {0, 4, 7}
    );

    localparam STRB_BIT = DATA_BIT / 8;

    /* Control Signal
    HTRANS : Transfer Signal
        {00 : IDLE, 01 : BUSY, 10 : NONSEQ, 11 : SEQ}
            NONSEQ  : None Sequential   (New Transfer)
            SEQ     : Sequential        (Related Previous Transfer)

    HSIZE : Transfer Size
        2^(HSIZE) Byte    
    
    HBURST : Burst Signal
        {000 : SINGLE, 001 : INCR, 010 : WRAP4, 011 : INCR4, 100 : WRAP8, 101 : INCR8, 110 : WRAP16, 111 : INCR16}

    HPROT : Protection Signal
        HPROT[3:0] : Recommended 4'h3 (4'b0011)
            [0] : Data/Instruction
                {0 : Instruction Fetch,                 1 : Data Access}
            [1] : Privileged
                {0 : User/Unprivileged,                 1 : Privileged}
            [2] : Bufferable
                {0 : Non-Bufferable,                    1 : Bufferable}
            [3] : Modifiable
                {0 : Non-Modifiable Charateristic,      1 : Modifiable Characteristic}
        HPROT[6:0] : Recommended 7'd3 (7'b0000011)
            [4] : Lookup
                {0 : UnNeeded Cache Lookup,             1 : Needed Cache Lookup}
            [5] : Allocate
                {0 : Non-Recommended Cache Allocation,  1 : Recommended Cache Allocation}
            [6] : Shareable
                {0 : Non-Shareable,                     1 : Shareable with other Master}
    */

    /*  HREADY = Selected Slave's HREADYOUT  ______________              _________
     _______________________                |              |   HREADY   |         |
    |                       |               |              |----------->|   AHB   |
    |                       |               |              |<-----------|  SLAVE  |
    |                       |    HREADY     |              |  HREADYOUT |_________|
    |       AHB MASTER      |<--------------| Interconnect |             _________
    |                       |               |              |   HREADY   |         |
    |                       |               |              |----------->|   AHB   |
    |_______________________|               |              |<-----------|  SLAVE  |
                                            |______________|  HREADYOUT |_________|
    */

    /*
       HREP HREADYOUT   Description 
        0       0       OKAY...ing (Not Complete)
        0       1       OKAY
        1       0       1st Cycle of ERROR
        1       1       2nd Cycle of ERRO
    */

    wire [ADDR_BIT - 1:0]   HADDR;  // MOSI
    wire [1:0]              HTRANS; // MOSI
    wire                    HWRITE; // MOSI
    wire [2:0]              HSIZE;  // MOSI 
    wire [2:0]              HBURST; // MOSI
    wire [PROT_BIT - 1:0]   HPROT;  // MOSI 
    wire [DATA_BIT - 1:0]   HWDATA; // MOSI
    wire [STRB_BIT - 1:0]   HWSTRB; // MOSI

    wire [DATA_BIT - 1:0]   HRDATA; // MISO
    wire                    HRESP;  // MISO

    modport MASTER (
        input   HRDATA, HRESP,  
        output  HADDR,  HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HWSTRB
    );

    modport SLAVE (
        input   HADDR,  HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HWSTRB,
        output  HRDATA, HRESP
    );

endinterface
