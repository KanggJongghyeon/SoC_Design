`timescale 1ns / 1ps
// Shift Left
module shift_left #(
    parameter LEFT_CNT  = 2,
    parameter ADDR_BIT  = 8
    )(
    input   wire    [ADDR_BIT + LEFT_CNT - 1:0] i_i,
    output  wire    [ADDR_BIT + LEFT_CNT - 1:0] o_o
    );

    assign o_o = i_i << LEFT_CNT;

endmodule
