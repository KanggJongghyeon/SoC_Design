`timescale 1ns / 1ps
`include "sfr_table.sv"
module cmu #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [ADDR_BIT - 1:0] i_addr,
    input  wire [DATA_BIT - 1:0] i_data,
    output wire [2:0]            o_clk_en
    );

    reg [2:0] r_clk_en;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_clk_en <= 3'b000;
        end
        else begin
            case (i_addr)
                `PCLK_ADDR : begin
                    if (i_data[16] == 1'b1) begin
                        r_clk_en[0] <= 1'b1;
                    end
                    else if (i_data[16] == 1'b0) begin
                        r_clk_en[0] <= 1'b0;
                    end
                end
                `HCLK_ADDR : begin
                    if (i_data[16] == 1'b1) begin
                        r_clk_en[1] <= 1'b1;
                    end
                    else if (i_data[16] == 1'b0) begin
                        r_clk_en[1] <= 1'b0;
                    end
                end
                `ACLK_ADDR : begin
                    if (i_data[16] == 1'b1) begin
                        r_clk_en[2] <= 1'b1;
                    end
                    else if (i_data[16] == 1'b0) begin
                        r_clk_en[2] <= 1'b0;
                    end
                end
                default  : begin
                    r_clk_en <= r_clk_en;
                end
            endcase
        end
    end

    assign o_clk_en   = r_clk_en;

endmodule
