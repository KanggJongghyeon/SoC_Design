`timescale 1ns / 1ps
module cpu_axi_bridge #(
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

    assign AXI.AWADDR = i_cpu_addr;
    assign AXI.WDATA = (1'b1 == (i_cpu_wren & i_cpu_en)) ? i_cpu_data : {DATA_SIZE{1'b0}};

    assign AXI.ARADDR   = i_cpu_addr;

endmodule
