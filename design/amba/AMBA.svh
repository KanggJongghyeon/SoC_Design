`ifndef AMBA_SVH    // Header Guard
`define AMBA_SVH    
/////////
// APB //
/////////
// FSM
`define S_APB_IDLE      2'b00
`define S_APB_SETUP     2'b01
`define S_APB_ACCESS    2'b11

/////////
// AHB //
/////////
// Signal
`define HTRANS_IDLE         2'b00
`define HTRANS_BUST         2'b01
`define HTRANS_NONSEQ       2'b10
`define HTRANS_SEQ          2'b11
`define HPROT_OPCODE_FETCH      3'b000
`define HPROT_DATA_ACCESS       3'b001
`define HPROT_USER_ACCESS       3'b010
`define HPROT_PRIVILEGED_ACCESS 3'b011
`define HPROT_NOT_BUFFERABLE    3'b100
`define HPROT_BUFFERABLE        3'b101
`define HPROT_NOT_CACHEABLE     3'b110
`define HPTOR_CACHEABLE         3'b111
`define HBURST_SINGLE   3'b000
`define HBURST_INCR     3'b001
`define HBURST_WARP4    3'b010
`define HBURST_INCR4    3'b011
`define HBURST_WRAP8    3'b100
`define HBURST_INCR8    3'b101
`define HBURST_WRAP16   3'b110
`define HBURST_INCR16   3'b111

// FSM

/////////
// AXI //
/////////
// FSM
`define S_AXI_IDLE      2'b00
`define S_AXI_RUN       2'b01
`define S_AXI_WAIT      2'b11
//`define S_AXI_PENDING   2'b10
// Signal
`define SINGLE_BURST    8'h00
`define AXBURST_FIXED       2'b00
`define AXBURST_INCR        2'b01
`define AXBURST_WRAP        2'b10
`define AXBURST_RESERVED    2'b11
`define XRESP_OKAY          2'b00
`define XRESP_EXOKAY        2'b01
`define XRESP_SLVERR        2'b10
`define XRESP_DECERR        2'b11

`endif  // AMBA_SVH
