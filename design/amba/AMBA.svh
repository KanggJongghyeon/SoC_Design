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
// HTRANS
`define HTRANS_IDLE     2'b00
`define HTRANS_BUSY     2'b01
`define HTRANS_NONSEQ   2'b10
`define HTRANS_SEQ      2'b11
// HSIZE
`define HSIZE_BYTE      3'b000
`define HSIZE_2BYTE     3'b001
`define HSIZE_HALF      3'b001
`define HSIZE_4BYTE     3'b010
`define HSIZE_WORD      3'b010
`define HSIZE_8BYTE     3'b011
`define HSIZE_16BYTE    3'b100
`define HSIZE_32BYTE    3'b101
`define HSIZE_64BYTE    3'b110
`define HSIZE_128BYTE   3'b111
// HBURST
`define HBURST_SINGLE   3'b000
`define HBURST_INCR     3'b001
`define HBURST_WARP4    3'b010
`define HBURST_INCR4    3'b011
`define HBURST_WRAP8    3'b100
`define HBURST_INCR8    3'b101
`define HBURST_WRAP16   3'b110
`define HBURST_INCR16   3'b111
// HPROT BIT
`define HPROT_DATA_BIT          0
`define HPROT_PRIVILEGED_BIT    1
`define HPROT_BUFFERABLE_BIT    2
`define HPROT_MODIFIABLE_BIT    3
`define HPROT_LOOKUP_BIT        4
`define HPROT_ALLOCATE_BIT      5
`define HPROT_SHAREABLE_BIT     6
// HPROT[0] Description
`define HPROT_INSTRUCTION_FETCH             1'b0
`define HPROT_DATA_ACCESS                   1'b1
// HPROT[1] Description
`define HPROT_USER_ACCESS                   1'b0
`define HPROT_PRIVILEGED_ACCESS             1'b1
// HPROT[2] Description
`define HPROT_NON_BUFFERABLE                1'b0
`define HPROT_BUFFERABLE                    1'b1
// HPROT[3] Description
`define HPROT_NON_MODIFIABLE                1'b0
`define HPTOR_MODIFIABLE                    1'b1
// HPROT[4] Description
`define HPROT_UNNEDDED_LOOKUP               1'b0
`define HPROT_NEDDED_LOOKUP                 1'b1
// HPROT[5] Description
`define HPROT_NON_RECOMMENDED_ALLOCATION    1'b0
`define HPROT_RECOMMENDED_ALLOCATION        1'b1
// HPROT[6] Description
`define HPROT_NON_SHAREABLE                 1'b0
`define HPROT_SHAREABLE                     1'b1
// HPROT Default Value
`define HPROT4_DEFAULT      4'h0
`define HPROT7_DEFAULT      7'b0000000
// HPROT Recommended Value
`define HPROT4_RECOMMENDED  4'h3
`define HPROT7_RECOMMENDED  7'b0000011

/////////
// AXI //
/////////
// FSM
`define S_AXI_IDLE      2'b00
`define S_AXI_RUN       2'b01
`define S_AXI_WAIT      2'b11
//`define S_AXI_PENDING   2'b10

// AxLEN
`define SINGLE_BURST    8'h00
// AxSIZE
`define AXSIZE_BYTE     3'b000
`define AXSIZE_2BYTE    3'b001
`define AXSIZE_HALF     3'b001
`define AXSIZE_4BYTE    3'b010
`define AXSIZE_WORD     3'b010
`define AXSIZE_8BYTE    3'b011
`define AXSIZE_16BYTE   3'b100
`define AXSIZE_32BYTE   3'b101
`define AXSIZE_64BYTE   3'b110
`define AXSIZE_128BYTE  3'b111
// AxBURST
`define AXBURST_FIXED       2'b00
`define AXBURST_INCR        2'b01
`define AXBURST_WRAP        2'b10
`define AXBURST_RESERVED    2'b11
// xRESP
`define XRESP_OKAY          2'b00
`define XRESP_EXOKAY        2'b01
`define XRESP_SLVERR        2'b10
`define XRESP_DECERR        2'b11

`endif  // AMBA_SVH
