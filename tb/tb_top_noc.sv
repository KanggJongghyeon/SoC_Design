`timescale 1ns / 1ps
`define CLOCK_RATE 2
//`define BOOT_LOADER
`define APPLICATION
`define DEBUG_MODE
module tb_top_noc(); 
    
    // local parameter
    `ifndef CPU_32BIT
        localparam ADDR_BIT = 16;
        localparam DATA_BIT = 16;
    `else
        localparam ADDR_BIT = 32;
        localparam DATA_BIT = 32;
    `endif  // CPU_32BIT (vivado define option)
    localparam  AXI5_ID_BIT = 12;
    localparam  LINE_CNTR   = 120;

    // Global Signal
    reg                     clk;
    reg                     rst_n;

    // I-MEM Signal for Boot Loader
    reg                     i_i_mem_en, i_i_mem_wren;
    reg [ADDR_BIT - 1:0]    i_i_mem_addr;
    reg [DATA_BIT - 1:0]    i_i_mem_data;
    reg [ADDR_BIT - 1:0]    i_mem_addr;
    
    // for Loading Text File
    string  boot_loader_path= ".\\..\\..\\..\\..\\..\\tb\\boot_loader.mem";
    string  application_path= ".\\..\\..\\..\\..\\..\\tb\\application.mem";    
    string  debug_mode_path = ".\\..\\..\\..\\..\\..\\tb\\test_case\\test_case.mem";

    reg [DATA_BIT - 1:0]    nand_flash0    [0:LINE_CNTR - 1];  // boot_loader.mem File Memory
    reg [DATA_BIT - 1:0]    nand_flash1 [0:LINE_CNTR - 1];  // application.mem File Memory
    reg [DATA_BIT - 1:0]    nand_flash2 [0:LINE_CNTR - 1];  // test_case.mem File Memory
    
    initial begin
        `ifdef BOOT_LOADER
        $readmemh(boot_loader_path, nand_flash0);
        `endif  // BOOT_LOADER
        `ifdef APPLICATION
        $readmemh(application_path, nand_flash1);
        `endif  // APPLICATION
        `ifdef DEBUG_MODE
        $readmemh(debug_mode_path, nand_flash2);
        `endif  // DEBUG_MODE
    end

    // Clock On
    initial begin
        clk = 1'b0;
        forever #(`CLOCK_RATE / 2) clk = ~clk;
    end

    // Test Code
    // I-MEM <= {BOOT ROM, NAND_FLASH0, NAND_FLASH1}
    integer boot_rom_addr, debug_mode_addr, application_addr;
    initial begin
        #0  rst_n = 1'b0;
        #0  i_i_mem_en = 1'b0; i_i_mem_wren = 1'b0; i_i_mem_addr = {ADDR_BIT{1'b0}}; i_i_mem_data = {DATA_BIT{1'b0}};
        #10 i_i_mem_en = 1'b1; i_i_mem_wren = 1'b1;
        #0  i_mem_addr = {ADDR_BIT{1'b0}};
        `ifdef BOOT_LOADER
        for (boot_rom_addr = i_mem_addr; boot_rom_addr < LINE_CNTR; boot_rom_addr = boot_rom_addr + 1) begin
            i_i_mem_addr = 4 * boot_rom_addr;
            i_i_mem_data = nand_flash0[boot_rom_addr];
            #(`CLOCK_RATE);
        end
        #0 i_mem_addr = i_mem_addr + LINE_CNTR;
        `endif  // BOOT_LOADER
        `ifdef DEBUG_MODE
        for (debug_mode_addr = i_mem_addr; debug_mode_addr < i_mem_addr + LINE_CNTR; debug_mode_addr = debug_mode_addr + 1) begin
            i_i_mem_addr = 4 * debug_mode_addr;
            i_i_mem_data = nand_flash2[debug_mode_addr - i_mem_addr];
            #(`CLOCK_RATE);
        end
        #0 i_mem_addr = i_mem_addr + LINE_CNTR;
        `endif  // DEBUG_MODE
        `ifdef APPLICATION 
        for (application_addr = i_mem_addr; application_addr < i_mem_addr + LINE_CNTR; application_addr = application_addr + 1) begin
            i_i_mem_addr = 4 * application_addr;
            i_i_mem_data = nand_flash1[application_addr - i_mem_addr];
            #(`CLOCK_RATE);
        end
        #0 i_mem_addr = i_mem_addr + LINE_CNTR;
        `endif  // APPLICATION
        #0  i_i_mem_en = 1'b0; i_i_mem_wren = 1'b0; i_i_mem_addr = {ADDR_BIT{1'b0}}; i_i_mem_data = {DATA_BIT{1'b0}};
        #10 rst_n = 1'b1;
        #(4 * i_mem_addr / `CLOCK_RATE);
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

    // I-MEM
    SDRAM #(
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
    SDRAM #(
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

    // Network on Chip
    top_noc #(
        .AXI5_ADDR_BIT  (ADDR_BIT),
        .AXI5_DATA_BIT  (DATA_BIT),
        .AXI5_ID_BIT    (AXI5_ID_BIT)
    ) u_top_noc (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_cpu_en       (w_d_mem_en),
        .i_cpu_wren     (w_d_mem_wren),
        .i_cpu_addr     (w_d_mem_addr),
        .i_cpu_data     (w_d_mem_wdata),
        .o_cpu_data     ()
    );

endmodule
