`timescale 1ns / 1ps
module DRAM #(
    parameter ADDR_SIZE = 8,
    parameter DATA_SIZE = 32
    )(
    input  wire                     clk,
    input  wire                     i_en,
    input  wire                     i_wren,
    input  wire [ADDR_SIZE - 1:0]   i_addr,
    input  wire [DATA_SIZE - 1:0]   i_data,
    output wire [DATA_SIZE - 1:0]   o_data
    );

    localparam MEMORY_SIZE  = 8;
    localparam MEM_SIZE     = 2 ** ADDR_SIZE;

    reg [DATA_SIZE   - 1:0] r_data;
    reg [MEMORY_SIZE - 1:0] mem [0:MEM_SIZE - 1];

    always @ (posedge clk) begin
        if (i_en == 1'b1) begin
            if (i_wren == 1'b1) begin
                mem[i_addr + 0] <= i_data[1 * MEMORY_SIZE - 1:0 * MEMORY_SIZE];
                mem[i_addr + 1] <= i_data[2 * MEMORY_SIZE - 1:1 * MEMORY_SIZE];
                mem[i_addr + 2] <= i_data[3 * MEMORY_SIZE - 1:2 * MEMORY_SIZE];
                mem[i_addr + 3] <= i_data[4 * MEMORY_SIZE - 1:3 * MEMORY_SIZE];
            end
            else begin
                r_data[1 * MEMORY_SIZE -1:0 * MEMORY_SIZE]  <= mem[i_addr + 0];
                r_data[2 * MEMORY_SIZE -1:1 * MEMORY_SIZE]  <= mem[i_addr + 1];
                r_data[3 * MEMORY_SIZE -1:2 * MEMORY_SIZE]  <= mem[i_addr + 2];
                r_data[4 * MEMORY_SIZE -1:3 * MEMORY_SIZE]  <= mem[i_addr + 3];
            end
        end
    end

    assign o_data = r_data;

endmodule
