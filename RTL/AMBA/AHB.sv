`timescale 1ns / 1ps
`include "..\peripheral\sfr_table.svh"
module ahb3 #(
    parameter DATA_SIZE = 32,
    parameter NUM_SLAVE = 32 
    )(
    input  wire                   HCLK,
    input  wire                   HRESETn,
    input  wire                   i_empty,
    input  wire                   i_full,
    output wire                   o_popen,
    output wire                   o_pushen,
    input  wire [DATA_SIZE - 1:0] i_popdata,
    output wire [DATA_SIZE - 1:0] o_pushdata,
    output wire                   HREADYIN,
    output wire [NUM_SLAVE - 1:0] HSEL,
    output wire [31:0]            HADDR,
    output wire [2:0]             HBURST,
    output wire [1:0]             HSIZE,
    output wire [1:0]             HTRANS,
    output wire                   HWRITE,
    output wire [31:0]            HWDATA,
    input  wire [31:0]            HRDATA,
    input  wire [1:0]             HRESP,
    input  wire [NUM_SLAVE - 1:0] HREADYOUT
    );

/*
    //Step 0 (IDLE)
    if (signal)
        goto Step1
    //Step 1 (ADDR Phase) 
    i_popdata[15]    : HWRITE
    i_popdata[14:13] : HTRANS
    i_popdata[12:11] : HSIZE
    i_popdata[10:8]  : HBURST
    i_popdata[7:0]   : HADDR
    goto Step2
    //Step 2 (DATA Phase)
    if (HWRITE == 1)
        i_popdata[31:0]  : HWDATA
        goto Step3
    else (HWRITE == 0)
    //Step 3 (Waiting Response)
    if (HRESP == 2'b00)
        goto Step 0
    //Step 4 (Waiting HRDATA)
    o_pushdata = HRDATA
    goto Step 0
*/



endmodule
