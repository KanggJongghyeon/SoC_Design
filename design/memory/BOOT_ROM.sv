`include "memory.svh"
`timescale 1ns / 1ps
/* 
[Note] Only for Simulation
Impossible Synthesis & Implementation
*/
module BOOT_ROM #(
    parameter ADDR_BIT  = 8,
    parameter DATA_BIT  = 32
    )(
    input  wire                     clk,
    input  wire                     i_en,
    input  wire [ADDR_BIT - 1:0]    i_addr,
    output wire [DATA_BIT - 1:0]    o_data
    );

    localparam WORD_BYTES   = DATA_BIT / `BYTE_SIZE;

    reg [DATA_BIT - 1:0]    r_data;
    reg [`BYTE_SIZE - 1:0]  boot_rom [0:`BOOT_ROM_SIZE - 1];
                 
    initial begin
        $readmemh(`BOOT_ROM_FILE_PATH, boot_rom);
    end

endmodule
