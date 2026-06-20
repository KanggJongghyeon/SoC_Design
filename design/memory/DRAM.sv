`include "memory.svh"
`timescale 1ns / 1ps
module SDRAM #(
    parameter ADDR_SIZE = 8,    // Not Used
    parameter DATA_SIZE = 32
    )(
    input  wire                     clk,
    input  wire                     i_en,
    input  wire                     i_wren,
    input  wire [ADDR_SIZE - 1:0]   i_addr,
    input  wire [DATA_SIZE - 1:0]   i_data,
    output wire [DATA_SIZE - 1:0]   o_data
    );

    localparam WORD_BYTES   = DATA_SIZE / `BYTE_SIZE;
    localparam MEM_SIZE     = `DRAM_SIZE;

    reg [DATA_SIZE - 1:0]   r_data;
    reg [`BYTE_SIZE - 1:0]  mem [0:MEM_SIZE - 1];

    integer byte_cntr;

    always @ (posedge clk) begin
        if (i_en == 1'b1) begin
            if (i_wren == 1'b1) begin
                for (byte_cntr = 0; byte_cntr < WORD_BYTES; byte_cntr = byte_cntr + 1) begin
                    mem[i_addr + byte_cntr] <= i_data[byte_cntr * `BYTE_SIZE +: `BYTE_SIZE];
                end
            end
            else begin
                for (byte_cntr = 0; byte_cntr < WORD_BYTES; byte_cntr = byte_cntr + 1) begin
                    r_data[byte_cntr * `BYTE_SIZE +: `BYTE_SIZE]  <= mem[i_addr + byte_cntr];
                end
            end
        end
    end

    assign o_data = r_data;

endmodule
