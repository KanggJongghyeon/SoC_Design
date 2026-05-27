///////////////////////////////////////////
// Path : .\RTL\peripheral\sfr_table.svh //
///////////////////////////////////////////

/////////////////////////
// AMBA Clock Generate //
/////////////////////////
`define PCLK_ADDR 'd2048 // 12'h800, APB ON
`define HCLK_ADDR 'd2560 // 12'hA00, AHB ON
`define ACLK_ADDR 'd3072 // 12'hC00, AXI ON
`define AMBA_ADDR 'd2556 // 12'h9FC, Read {APB, AHB, AXI} Enable 

/////////
// AHB //
/////////
`define AHB_ADDR  'd2564 // 12'hA04
