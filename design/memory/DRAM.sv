`include "memory.svh"
`timescale 1ns / 1ps
module SDRAM #(
    parameter ADDR_BIT  = 8,
    parameter DATA_BIT  = 32
    )(
    input  wire                                 clk,
    input  wire                                 i_en,
    input  wire                                 i_wren,
    input  wire [ADDR_BIT - 1:0]                i_addr,
    input  wire [DATA_BIT - 1:0]                i_data,
    input  wire [DATA_BIT / `BYTE_SIZE - 1:0]   i_strb,
    output wire [DATA_BIT - 1:0]                o_data
    );

    localparam MEM_SIZE = `DRAM_SIZE;
    localparam STRB_BIT = DATA_BIT / `BYTE_SIZE; 

    reg [DATA_BIT - 1:0]    r_data;
    reg [`BYTE_SIZE - 1:0]  mem [0:MEM_SIZE - 1];

    integer byte_cntr;

    always @ (posedge clk) begin
        if (i_en == 1'b1) begin
            if (i_wren == 1'b1) begin
                for (byte_cntr = 0; byte_cntr < STRB_BIT; byte_cntr = byte_cntr + 1) begin
                    if (i_strb[byte_cntr] == 1'b1) begin
                        mem[i_addr + byte_cntr] <= i_data[byte_cntr * `BYTE_SIZE +: `BYTE_SIZE];
                    end
                end
            end
            else begin
                for (byte_cntr = 0; byte_cntr < STRB_BIT; byte_cntr = byte_cntr + 1) begin
                    r_data[byte_cntr * `BYTE_SIZE +: `BYTE_SIZE]  <= mem[i_addr + byte_cntr];
                end
            end
        end
    end

    assign o_data = r_data;

endmodule
