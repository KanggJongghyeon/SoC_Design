`timescale 1ns / 1ps
module top #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  i_inst_mem_write_finish, // tb flag signal
    input  wire                  i_inst_mem_en,
    input  wire                  i_inst_mem_wren,
    input  wire [ADDR_BIT - 1:0] i_inst_mem_addr,
    input  wire [DATA_BIT - 1:0] i_inst_mem_data
    );

    wire                  w_arbiter_req   [0:1]; // {CPU, CMU}           =>  Arbiter
    wire                  w_arbiter_gnt   [0:1]; //  Arbiter             => {CMU,       CPU}
    wire [ADDR_BIT - 1:0] w_arbiter_addr;        //  Arbiter             =>  Data Mem
    wire                  w_arbiter_en;          //  Arbiter             =>  Data Mem
    wire                  w_arbiter_wren;        //  Arbiter             =>  Data Mem
    wire [DATA_BIT - 1:0] w_arbiter_wdata;       //  Arbiter             =>  Data Mem
    wire [ADDR_BIT - 1:0] w_cpu_addr      [0:1]; //  CPU                 => {Inst Mem,  Arbiter}
    wire                  w_cpu_en        [0:1]; //  CPU                 => {Inst Mem,  Arbiter}
    wire                  w_cpu_wren      [0:1]; //  CPU                 => {Inst Mem,  Arbiter}
    wire [DATA_BIT - 1:0] w_cpu_wdata;           //  CPU                 =>  Arbiter
    wire [DATA_BIT - 1:0] w_mem_rdata     [0:1]; // {Inst Mem, Data Mem} => {CPU,      {CMU, CPU}}
    wire [ADDR_BIT - 1:0] w_cmu_addr;            //  CMU                 =>  Arbiter
    wire                  w_cmu_en;              //  CMU                 =>  Arbiter
    wire                  w_cmu_wren;            //  CMU                 =>  Arbiter
    wire [DATA_BIT - 1:0] w_cmu_wdata;           //  CMU                 =>  Arbiter
    wire                  PCLK,         PRESETn; //  CMU                 =>     
    wire                  HCLK,         HRESETn; //  CMU                 =>
    wire                  ACLK,         ARESETn; //  CMU                 =>

    DRAM #(
        .ADDR_BIT (ADDR_BIT),
        .DATA_BIT (DATA_BIT)
    ) u_inst_memory (
        .clk      (clk),
        .i_en     (i_inst_mem_en   | w_cpu_en[0]),
        .i_wren   (i_inst_mem_wren | w_cpu_wren[0]),
        .i_addr   (i_inst_mem_addr | w_cpu_addr[0]),
        .i_data   (i_inst_mem_data),
        .o_data   (w_mem_rdata[0])
    );

    top_cpu_cmu_arbiter #(
        .ADDR_BIT    (ADDR_BIT),
        .DATA_BIT    (DATA_BIT)
    ) u_cpu_cmu_arbiter_top (
        .i_req       (w_arbiter_req),
        .o_gnt       (w_arbiter_gnt),
        .i_cpu_addr  (w_cpu_addr[1]),
        .i_cmu_addr  (w_cmu_addr),
        .o_dm_addr   (w_arbiter_addr),
        .i_cpu_en    (w_cpu_en[1]),
        .i_cmu_en    (w_cmu_en),
        .o_dm_en     (w_arbiter_en),
        .i_cpu_wren  (w_cpu_wren[1]),
        .i_cmu_wren  (w_cmu_wren),
        .o_dm_wren   (w_arbiter_wren),
        .i_cpu_wdata (w_cpu_wdata),
        .i_cmu_wdata (w_cmu_wdata),
        .o_dm_wdata  (w_arbiter_wdata)
    );

    top_cpu #(
        .ADDR_BIT        (ADDR_BIT),
        .DATA_BIT        (DATA_BIT)
    ) u_cpu_top (
        .clk             (clk),
        .rst_n           (rst_n),
        .i_start_flag    (i_inst_mem_write_finish),
        .i_mem_data      (w_mem_rdata),
        .o_mem_en        (w_cpu_en),
        .o_mem_wren      (w_cpu_wren),
        .o_mem_addr      (w_cpu_addr),
        .o_data_mem_data (w_cpu_wdata),
        .o_arbiter_req   (w_arbiter_req[0]),
        .i_arbiter_gnt   (w_arbiter_gnt[0])
    );

    top_cmu #(
        .ADDR_BIT      (ADDR_BIT),
        .DATA_BIT      (DATA_BIT)
    ) u_cmu_top (
        .clk           (clk),
        .rst_n         (rst_n),
        .o_addr        (w_cmu_addr),
        .o_en          (w_cmu_en),
        .o_wren        (w_cmu_wren),
        .i_data        (w_mem_rdata[1]),
        .o_data        (w_cmu_wdata),
        .PCLK          (PCLK),
        .HCLK          (HCLK),
        .ACLK          (ACLK),
        .PRESETn       (PRESETn),
        .HRESETn       (HRESETn),
        .ARESETn       (ARESETn),
        .o_arbiter_req (w_arbiter_req[1]),
        .i_arbiter_gnt (w_arbiter_gnt[1])
    );

    DRAM #(
        .ADDR_BIT (ADDR_BIT),
        .DATA_BIT (DATA_BIT)
    ) u_data_memory (
        .clk      (clk),
        .i_en     (w_arbiter_en),
        .i_wren   (w_arbiter_wren),
        .i_addr   (w_arbiter_addr),
        .i_data   (w_arbiter_wdata),
        .o_data   (w_mem_rdata[1])
    );

endmodule
