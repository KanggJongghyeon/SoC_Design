`timescale 1ns / 1ps
module cpu_axi_bridge_master #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    // cpu if
    input   wire                        i_cpu_en,
    input   wire                        i_cpu_wren,
    input   wire    [ADDR_BIT - 1:0]    i_cpu_addr,
    input   wire    [DATA_BIT - 1:0]    i_cpu_data,
    output  wire    [DATA_BIT - 1:0]    o_cpu_data,
    // axi if
    AXI5.MASTER                         AXI
    );

    assign AXI.AWVALID  = i_cpu_en & i_cpu_wren;
    assign AXI.AWID     = ;
    assign AXI.AWADDR   = i_cpu_addr;
    assign AXI.AWLEN    = 8'h00;
    assign AXI.AWSIZE   = 3'b010;
    assign AXI.AWBURST  = 2'b01;

    assign AXI.WVALID   = i_cpu_en & i_cpu_wren;
    assign AXI.WID      = ;
    assign AXI.WDATA    = i_cpu_data; 
    assign AXI.WSTRB    = {AXI.STRB_BIT{1'b1}};
    assign AXI.WLAST    = 1'b1;

    assign AXI.BREADY   = ;

    assign AXI.ARVALID  = i_cpu_en;
    assign AXI.ARID     = ;
    assign AXI.ARADDR   = i_cpu_addr;
    assign AXI.ARLEN    = 8'h00;
    assign AXI.ARSIZE   = 3'b010;
    assign AXI.ARBURST  = 2'b01;

    assign AXI.RREADY   = ;

endmodule
