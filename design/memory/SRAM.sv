/* 
    CACHE Spec
Cache Size  = 32KB = 512 Block x 
# of Block  = 512 Line
Association = 2-way = 256 Set
*/
`include "memory.svh"
`timescale 1ns / 1ps
module CACHE #(
    parameter   ADDR_SIZE   = 8,    // Not Used`
    parameter   DATA_SIZE   = 512
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        i_en,
    input   wire                        i_wren,
    input   wire    [ADDR_SIZE - 1:0]   i_addr,
    input   wire    [DATA_SIZE - 1:0]   i_data,
    output  wire    [DATA_SIZE - 1:0]   o_data   
    );
    
/*
    i_addr
    [5:0]   : OFFSET    (Byte ADDR in Block)
    [13:6]  : INDEX     (Set ADDR)
    [31:14] : TAG       
    SRAM Array ADDR
    sram[INDEX][2][OFFSET] = 8 Bit = 1 Byte
*/
    reg [7:0]               sram  [0:255][0:1][0:63];
    reg [DATA_SIZE - 1:0]   r_data;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            sram    <= {(256 * 2 * 64 * 8){1'b0}};
            r_data  <= {(DATA_SIZE){1'b0}};
        end
        else begin
            if (i_en) begin
                if (i_wren) begin
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 0  + 0)  % 64] <= i_data[1  * `BYTE_SIZE - 1:0  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 1  + 0)  % 64] <= i_data[2  * `BYTE_SIZE - 1:1  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 2  + 0)  % 64] <= i_data[3  * `BYTE_SIZE - 1:2  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 3  + 0)  % 64] <= i_data[4  * `BYTE_SIZE - 1:3  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 4  + 0)  % 64] <= i_data[5  * `BYTE_SIZE - 1:4  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 5  + 0)  % 64] <= i_data[6  * `BYTE_SIZE - 1:5  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 6  + 0)  % 64] <= i_data[7  * `BYTE_SIZE - 1:6  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 7  + 0)  % 64] <= i_data[8  * `BYTE_SIZE - 1:7  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 8  + 0)  % 64] <= i_data[9  * `BYTE_SIZE - 1:8  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 9  + 0)  % 64] <= i_data[10 * `BYTE_SIZE - 1:9  * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 10 + 0)  % 64] <= i_data[11 * `BYTE_SIZE - 1:10 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 11 + 0)  % 64] <= i_data[12 * `BYTE_SIZE - 1:11 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 12 + 0)  % 64] <= i_data[13 * `BYTE_SIZE - 1:12 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 13 + 0)  % 64] <= i_data[14 * `BYTE_SIZE - 1:13 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 14 + 0)  % 64] <= i_data[15 * `BYTE_SIZE - 1:14 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 15 + 0)  % 64] <= i_data[16 * `BYTE_SIZE - 1:15 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 0  + 16) % 64] <= i_data[17 * `BYTE_SIZE - 1:16 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 1  + 16) % 64] <= i_data[18 * `BYTE_SIZE - 1:17 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 2  + 16) % 64] <= i_data[19 * `BYTE_SIZE - 1:18 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 3  + 16) % 64] <= i_data[20 * `BYTE_SIZE - 1:19 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 4  + 16) % 64] <= i_data[21 * `BYTE_SIZE - 1:20 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 5  + 16) % 64] <= i_data[22 * `BYTE_SIZE - 1:21 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 6  + 16) % 64] <= i_data[23 * `BYTE_SIZE - 1:22 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 7  + 16) % 64] <= i_data[24 * `BYTE_SIZE - 1:23 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 8  + 16) % 64] <= i_data[25 * `BYTE_SIZE - 1:24 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 9  + 16) % 64] <= i_data[26 * `BYTE_SIZE - 1:25 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 10 + 16) % 64] <= i_data[27 * `BYTE_SIZE - 1:26 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 11 + 16) % 64] <= i_data[28 * `BYTE_SIZE - 1:27 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 12 + 16) % 64] <= i_data[29 * `BYTE_SIZE - 1:28 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 13 + 16) % 64] <= i_data[30 * `BYTE_SIZE - 1:29 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 14 + 16) % 64] <= i_data[31 * `BYTE_SIZE - 1:30 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 15 + 16) % 64] <= i_data[32 * `BYTE_SIZE - 1:31 * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 0  + 32) % 64] <= i_data[(1  + 32) * `BYTE_SIZE - 1:(0  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 1  + 32) % 64] <= i_data[(2  + 32) * `BYTE_SIZE - 1:(1  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 2  + 32) % 64] <= i_data[(3  + 32) * `BYTE_SIZE - 1:(2  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 3  + 32) % 64] <= i_data[(4  + 32) * `BYTE_SIZE - 1:(3  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 4  + 32) % 64] <= i_data[(5  + 32) * `BYTE_SIZE - 1:(4  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 5  + 32) % 64] <= i_data[(6  + 32) * `BYTE_SIZE - 1:(5  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 6  + 32) % 64] <= i_data[(7  + 32) * `BYTE_SIZE - 1:(6  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 7  + 32) % 64] <= i_data[(8  + 32) * `BYTE_SIZE - 1:(7  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 8  + 32) % 64] <= i_data[(9  + 32) * `BYTE_SIZE - 1:(8  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 9  + 32) % 64] <= i_data[(10 + 32) * `BYTE_SIZE - 1:(9  + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 10 + 32) % 64] <= i_data[(11 + 32) * `BYTE_SIZE - 1:(10 + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 11 + 32) % 64] <= i_data[(12 + 32) * `BYTE_SIZE - 1:(11 + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 12 + 32) % 64] <= i_data[(13 + 32) * `BYTE_SIZE - 1:(12 + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 13 + 32) % 64] <= i_data[(14 + 32) * `BYTE_SIZE - 1:(13 + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 14 + 32) % 64] <= i_data[(15 + 32) * `BYTE_SIZE - 1:(14 + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 15 + 32) % 64] <= i_data[(16 + 32) * `BYTE_SIZE - 1:(15 + 32) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 0  + 48) % 64] <= i_data[(1  + 48) * `BYTE_SIZE - 1:(0  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 1  + 48) % 64] <= i_data[(2  + 48) * `BYTE_SIZE - 1:(1  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 2  + 48) % 64] <= i_data[(3  + 48) * `BYTE_SIZE - 1:(2  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 3  + 48) % 64] <= i_data[(4  + 48) * `BYTE_SIZE - 1:(3  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 4  + 48) % 64] <= i_data[(5  + 48) * `BYTE_SIZE - 1:(4  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 5  + 48) % 64] <= i_data[(6  + 48) * `BYTE_SIZE - 1:(5  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 6  + 48) % 64] <= i_data[(7  + 48) * `BYTE_SIZE - 1:(6  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 7  + 48) % 64] <= i_data[(8  + 48) * `BYTE_SIZE - 1:(7  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 8  + 48) % 64] <= i_data[(9  + 48) * `BYTE_SIZE - 1:(8  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 9  + 48) % 64] <= i_data[(10 + 48) * `BYTE_SIZE - 1:(9  + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 10 + 48) % 64] <= i_data[(11 + 48) * `BYTE_SIZE - 1:(10 + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 11 + 48) % 64] <= i_data[(12 + 48) * `BYTE_SIZE - 1:(11 + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 12 + 48) % 64] <= i_data[(13 + 48) * `BYTE_SIZE - 1:(12 + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 13 + 48) % 64] <= i_data[(14 + 48) * `BYTE_SIZE - 1:(13 + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 14 + 48) % 64] <= i_data[(15 + 48) * `BYTE_SIZE - 1:(14 + 48) * `BYTE_SIZE];
                    sram[i_addr[13:6]][0][(i_addr[5:0] + 15 + 48) % 64] <= i_data[(16 + 48) * `BYTE_SIZE - 1:(15 + 48) * `BYTE_SIZE];
                end
                else begin
                    r_data  <= sram[i_addr[13:6]][0];
                end
            end
        end
    end

    assign o_data = r_data;

endmodule
