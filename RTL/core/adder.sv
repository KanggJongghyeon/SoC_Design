`timescale 1ns/1ps
// ADDR Adder
module adder21 #(
    parameter ADDR_BIT = 8
    )(
        input   wire    [ADDR_BIT - 1:0]    i_i0,
        input   wire    [ADDR_BIT - 1:0]    i_i1,
        output  wire    [ADDR_BIT - 1:0]    o_o
    );

    assign o_o = i_i0 + i_i1;

endmodule
