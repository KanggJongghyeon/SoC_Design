`timescale 1ns / 1ps
module mux21 #(
    parameter DATA_BIT = 2
    )(
    input  wire                  i_ctr,
    input  wire [DATA_BIT - 1:0] i_i0,
    input  wire [DATA_BIT - 1:0] i_i1,
    output wire [DATA_BIT - 1:0] o_o
    );

    assign o_o = (i_ctr == 1'b1) ? i_i1 : i_i0;

endmodule
