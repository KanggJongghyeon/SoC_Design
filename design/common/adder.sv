`timescale 1ns / 1ps
module adder21 #(
    parameter DATA_BIT = 8
    )(
        input   wire    [DATA_BIT - 1:0]    i_i0,
        input   wire    [DATA_BIT - 1:0]    i_i1,
        output  wire    [DATA_BIT - 1:0]    o_o
    );

    assign o_o = i_i0 + i_i1;

endmodule
