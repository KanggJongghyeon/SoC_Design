`include "../amba/AMBA.svh"
module top_noc #(
    parameter AXI5_ADDR_BIT = 32,
    parameter AXI5_DATA_BIT = 32,
    parameter AXI5_ID_BIT   = 12
    )(
    input   wire                            clk,
    input   wire                            rst_n,
    // cpu interface
    input   wire                            i_cpu_en,
    input   wire                            i_cpu_wren,
    input   wire    [AXI5_ADDR_BIT - 1:0]   i_cpu_adddr,
    input   wire    [AXI5_DATA_BIT - 1:0]   i_cpu_data,
    output  wire    [AXI5_DATA_BIT - 1:0]   o_cpu_data
    );

    AXI5 #(
        .ADDR_BIT   (AXI5_ADDR_BIT),
        .DATA_BIT   (AXI5_DATA_BIT),
        .ID_BIT     (AXI5_ID_BIT)
    ) b_axi_cpu_noc ();

    cpu_axi_master #(
        .ADDR_BIT   (ADDR_BIT),
        .DATA_BIT   (DATA_BIT)
    ) u_cpu_axi_master (
        .clk        (clk),
        .rst_n      (rst_n),
        .i_cpu_en   (i_cpu_en),
        .i_cpu_wren (i_cpu_wren),
        .i_cpu_addr (i_cpu_addr),
        .i_cpu_data (i_cpu_data),
        .o_cpu_data (o_cpu_data),
        .AXI        (b_axi_cpu_noc)
    );

    noc #(
        .ADDR_BIT   (AXI5_ADDR_BIT),
        .DATA_BIT   (AXI5_DATA_BIT)
    ) u_noc (
        .ACLK       (clk),
        .ARESET_N   (rst_n),
        .AXI        (b_axi_cpu_noc)
    );

endmodule
