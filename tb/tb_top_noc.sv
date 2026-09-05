`timescale 1ns / 1ps
`include "tb_define.svh"
`include "tb_typedef.svh"
`include "tb_funct.svh"

module tb_top_noc(); 
    
    // Local Pramter
    localparam  AXI5_ID_BIT = 12;

    // Global Signal
    reg                     clk;
    reg                     rst_n;

    // I-MEM Signal for Boot Loader
    reg                     i_i_mem_en;     // I-MEM Enalbe 
    reg                     i_i_mem_wren;   // I-MEM Write Enable
    reg [`ADDR_BIT - 1:0]   i_i_mem_addr;   // I-MEM Address
    reg [`DATA_BIT - 1:0]   i_i_mem_data;   // I-MEM Write Data
    
    // Memory File Path
    string  boot_loader_path= ".\\..\\..\\..\\..\\..\\tb\\boot_loader.mem";
    string  application_path= ".\\..\\..\\..\\..\\..\\tb\\application.mem";    
    string  debug_mode_path = ".\\..\\..\\..\\..\\..\\tb\\for_debug\\debug_mode.mem";

    // Memory File Buffer
    t_memory_buffer nand_flash0,    nand_flash1,    nand_flash2;
    // Total Memory File Line
    integer boot_loader_line,   application_line,   debug_mode_line;

    // Load Memory File
    initial begin
        `ifdef BOOT_LOADER
        nand_flash0 = load_mem_file(boot_loader_path, boot_loader_line);
        `endif  // BOOT_LOADER
        `ifdef APPLICATION
        nand_flash1 = load_mem_file(application_path, application_line);
        `endif  // APPLICATION
        `ifdef DEBUG_MODE
        nand_flash2 = load_mem_file(debug_mode_path, debug_mode_line);
        `endif  // DEBUG_MODE
    end

    // Clock On Forever
    initial begin
        clk = 1'b0;
        forever #(`CLOCK_RATE / 2) clk = ~clk;
    end

    // Memory File Buffer Address
    integer boot_loader_addr, debug_mode_addr, application_addr;
    // I-MEM Address
    reg [`ADDR_BIT - 1:0]   i_mem_addr;      
    // Byte Index
    integer byte_index;

    // Test Case
    initial begin
        #0  rst_n = 1'b0;
        #0  i_i_mem_en = 1'b0; i_i_mem_wren = 1'b0; i_i_mem_addr = {`ADDR_BIT{1'b0}}; i_i_mem_data = {`DATA_BIT{1'b0}};
        #10 i_i_mem_en = 1'b1; i_i_mem_wren = 1'b1;
        #0  i_mem_addr = {`ADDR_BIT{1'b0}};
        `ifdef BOOT_LOADER
        for (boot_loader_addr = i_mem_addr; boot_loader_addr < (4 * boot_loader_line); boot_loader_addr = boot_loader_addr + `STRB_BIT) begin
            i_i_mem_addr = boot_loader_addr;
            for (byte_index = 0; byte_index < `STRB_BIT; byte_index = byte_index + 1) begin
                i_i_mem_data[(byte_index * `BYTE_SIZE)+:`BYTE_SIZE] = nand_flash0[boot_loader_addr - i_mem_addr + byte_index];
            end
            #(`CLOCK_RATE);
        end
        #0 i_mem_addr = i_mem_addr + (4 * boot_loader_line);
        `endif  // BOOT_LOADER
        `ifdef DEBUG_MODE
        for (debug_mode_addr = i_mem_addr; debug_mode_addr < (i_mem_addr + (4 * debug_mode_line)); debug_mode_addr = debug_mode_addr + `STRB_BIT) begin
            i_i_mem_addr = debug_mode_addr;
            for (byte_index = 0; byte_index < `STRB_BIT; byte_index = byte_index + 1) begin
                i_i_mem_data[(byte_index * `BYTE_SIZE)+:`BYTE_SIZE] = nand_flash2[debug_mode_addr - i_mem_addr + byte_index];
            end
            #(`CLOCK_RATE);
        end
        #0 i_mem_addr = i_mem_addr + (4 * debug_mode_line);
        `endif  // DEBUG_MODE
        `ifdef APPLICATION 
        for (application_addr = i_mem_addr; application_addr < (i_mem_addr + (4 * application_line)); application_addr = application_addr + `STRB_BIT) begin
            i_i_mem_addr = application_addr;
            for (byte_index = 0; byte_index < `STRB_BIT; byte_index = byte_index + 1) begin
                i_i_mem_data[(byte_index * `BYTE_SIZE)+:`BYTE_SIZE] = nand_flash1[application_addr - i_mem_addr + byte_index];
            end
            #(`CLOCK_RATE);
        end
        #0 i_mem_addr = i_mem_addr + (4 * application_line);
        `endif  // APPLICATION
        #0  i_i_mem_en = 1'b0; i_i_mem_wren = 1'b0; i_i_mem_addr = {`ADDR_BIT{1'b0}}; i_i_mem_data = {`DATA_BIT{1'b0}};
        #10 rst_n = 1'b1;
        #((i_mem_addr / `STRB_BIT) * `CLOCK_RATE);
        #10 rst_n = 1'b0;
        #10 $finish;
    end

    // Wire for Instance
    wire [`DATA_BIT - 1:0]  w_i_mem_rdata;
    wire [`DATA_BIT - 1:0]  w_d_mem_rdata;
    wire                    w_i_mem_en;
    wire                    w_d_mem_en;
    wire                    w_d_mem_wren;
    wire [`ADDR_BIT - 1:0]  w_i_mem_addr;
    wire [`ADDR_BIT - 1:0]  w_d_mem_addr;
    wire [`DATA_BIT - 1:0]  w_d_mem_wdata;
    wire [`STRB_BIT - 1:0]  w_d_mem_wstrb;
    wire                    w_arbiter_req;

    // I-MEM
    SDRAM #(
        .ADDR_BIT           (`ADDR_BIT),
        .DATA_BIT           (`DATA_BIT)
    ) u_inst_mem (
        .clk                (clk),
        .i_en               (w_i_mem_en     | i_i_mem_en),
        .i_wren             (i_i_mem_wren),
        .i_addr             (w_i_mem_addr   | i_i_mem_addr),
        .i_data             (i_i_mem_data),
        .i_strb             ({`STRB_BIT{1'b1}}),
        .o_data             (w_i_mem_rdata)
    );

    // CPU
    top_cpu #(              
        .ADDR_BIT           (`ADDR_BIT),
        .DATA_BIT           (`DATA_BIT),
        .STRB_BIT           (`STRB_BIT)
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
        .o_d_mem_strb       (w_d_mem_wstrb),
        .o_arbiter_req      (w_arbiter_req),
        .i_arbiter_gnt      (1'b1)
    );

    // D-MEM
    SDRAM #(
        .ADDR_BIT           (`ADDR_BIT),
        .DATA_BIT           (`DATA_BIT)
    ) u_data_mem (
        .clk                (clk),
        .i_en               (w_d_mem_en),
        .i_wren             (w_d_mem_wren),
        .i_addr             (w_d_mem_addr),
        .i_data             (w_d_mem_wdata),
        .i_strb             (w_d_mem_wstrb),
        .o_data             (w_d_mem_rdata)
    );

    // Network on Chip
    top_noc #(
        .AXI5_ADDR_BIT      (`ADDR_BIT),
        .AXI5_DATA_BIT      (`DATA_BIT),
        .AXI5_ID_BIT        (AXI5_ID_BIT)
    ) u_top_noc (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_cpu_en           (w_d_mem_en),
        .i_cpu_wren         (w_d_mem_wren),
        .i_cpu_addr         (w_d_mem_addr),
        .i_cpu_data         (w_d_mem_wdata),
        .i_cpu_strb         (w_d_mem_wstrb),
        .o_cpu_data         ()
    );

endmodule
