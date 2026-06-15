`timescale 1ns / 1ps
`define CLOCK_RATE 2
module tb_top_noc #(
    parameter ADDR_BIT  = 32,    
    parameter DATA_BIT  = 32,
    parameter LINE_CNTR = 120
    )();
    
    // Local Parameter
    localparam  AXI5_ID_BIT = 12;

    // Global Signal
    reg                     clk;
    reg                     rst_n;

    // I-MEM Signal for Boot Loader
    reg                     i_i_mem_en, i_i_mem_wren;
    reg [ADDR_BIT - 1:0]    i_i_mem_addr;
    reg [DATA_BIT - 1:0]    i_i_mem_data;
    
    // for Loading Boot File
    string  boot_file_path  = "V:\\SoC_Design\\tb\\boot.txt";
    string  temp_file_path  = "V:\\SoC_Design\\tb\\test_case\\test_case_x.txt";
    string                  boot_file;                  // .txt File
    reg [DATA_BIT - 1:0]    boot_rom [0:LINE_CNTR - 1]; // .txt File Memory
    
    initial begin
        #1;
        //$sformat (boot_file, boot_file_path);
        $sformat (boot_file, temp_file_path);
        $readmemh(boot_file, boot_rom);                 // Store to boot_rom
    end

    // Clock On
    initial begin
        clk = 1'b0;
        forever #(`CLOCK_RATE / 2) clk = ~clk;
    end

    // Test Code
    // I-MEM <= BOOT ROM
    initial begin
        #0  rst_n = 1'b0;
        #0  i_i_mem_en = 1'b0; i_i_mem_wren = 1'b0; i_i_mem_addr = {ADDR_BIT{1'b0}}; i_i_mem_data = {DATA_BIT{1'b0}};
        #10 i_i_mem_en = 1'b1; i_i_mem_wren = 1'b1;
        for (integer addr = 0; addr < LINE_CNTR; addr = addr + 1) begin
            i_i_mem_addr = 4 * addr;
            i_i_mem_data = boot_rom[addr];
            #(`CLOCK_RATE);
        end
        #0  i_i_mem_en = 1'b0; i_i_mem_wren = 1'b0; i_i_mem_addr = {ADDR_BIT{1'b0}}; i_i_mem_data = {DATA_BIT{1'b0}};
        #10 rst_n = 1'b1;
        #(4 * LINE_CNTR / `CLOCK_RATE);
        #10 rst_n = 1'b0;
        #10 $finish;
    end

    // wire
    wire [DATA_BIT - 1:0]   w_i_mem_rdata;
    wire [DATA_BIT - 1:0]   w_d_mem_rdata;
    wire                    w_i_mem_en;
    wire                    w_d_mem_en;
    wire                    w_d_mem_wren;
    wire [ADDR_BIT - 1:0]   w_i_mem_addr;
    wire [ADDR_BIT - 1:0]   w_d_mem_addr;
    wire [DATA_BIT - 1:0]   w_d_mem_wdata;
    wire                    w_arbiter_req;

    // AXI MASTER BUS (CPU<=>)
    AXI5 #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT),
        .ID_BIT             (AXI5_ID_BIT)
    ) b_axi_cpu_noc ();

    // I-MEM
    DRAM #(
        .ADDR_SIZE          (ADDR_BIT),
        .DATA_SIZE          (DATA_BIT)
    ) u_inst_mem (
        .clk                (clk),
        .i_en               (w_i_mem_en     | i_i_mem_en),
        .i_wren             (i_i_mem_wren),
        .i_addr             (w_i_mem_addr   | i_i_mem_addr),
        .i_data             (i_i_mem_data),
        .o_data             (w_i_mem_rdata)
    );

    // CPU
    top_cpu #(              
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT)
    ) u_cpu_top (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_i_mem_data       (w_i_mem_rdata),
        .o_i_mem_en         (w_i_mem_en),
        .o_i_mem_addr       (w_i_mem_addr),
        .i_d_mem_data       (w_d_mem_rdata),
        .o_d_mem_en         (w_d_mem_en),
        .o_d_mem_wren       (w_d_mem_wren),
        .o_d_mem_addr       (w_d_mem_addr),
        .o_d_mem_data       (w_d_mem_wdata),
        .o_arbiter_req      (w_arbiter_req),
        .i_arbiter_gnt      (1'b1)
    );

    // D-MEM
    DRAM #(
        .ADDR_SIZE          (ADDR_BIT),
        .DATA_SIZE          (DATA_BIT)
    ) u_data_mem (
        .clk                (clk),
        .i_en               (w_d_mem_en),
        .i_wren             (w_d_mem_wren),
        .i_addr             (w_d_mem_addr),
        .i_data             (w_d_mem_wdata),
        .o_data             (w_d_mem_rdata)
    );

    // AXI MASTER
    cpu_axi_bridge_master #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT)
    ) u_axi_master (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_cpu_en           (w_d_mem_en),
        .i_cpu_wren         (w_d_mem_wren),
        .i_cpu_addr         (w_d_mem_addr),
        .i_cpu_data         (w_d_mem_wdata),
        .o_cpu_data         (),
        .AXI                (b_axi_cpu_noc)
    );

    // NOC
    noc #(
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT)
    ) u_noc (
        .ACLK               (clk),
        .ARESET_N           (rst_n),
        .AXI                (b_axi_cpu_noc)
    );

endmodule
