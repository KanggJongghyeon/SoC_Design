`timescale 1ns / 1ps
module pc #(
    parameter ADDR_BIT = 8
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  i_start_flag, // tb flag signal
    output wire                  o_mem_en,
    output wire                  o_mem_wren,
    output wire [ADDR_BIT - 1:0] o_mem_addr
    );

    reg                  r_mem_en,   r_mem_wren;
    reg [ADDR_BIT - 1:0] r_mem_addr, r_mem_addr_temp;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_mem_en        <= 1'b0;
            r_mem_wren      <= 1'b0;
            r_mem_addr      <= {ADDR_BIT{1'b0}};
            r_mem_addr_temp <= {ADDR_BIT{1'b0}};
        end
        else begin
            r_mem_addr      <= r_mem_addr_temp; 
            if (i_start_flag) begin
                r_mem_en        <= 1'b1;
                r_mem_addr_temp <= r_mem_addr_temp + 'd4;
            end
            else begin
                r_mem_en        <= 1'b0;
                r_mem_addr_temp <= {ADDR_BIT{1'b0}};
            end
        end
    end

    assign o_mem_en   = r_mem_en;
    assign o_mem_wren = r_mem_wren;
    assign o_mem_addr = r_mem_addr;

endmodule
