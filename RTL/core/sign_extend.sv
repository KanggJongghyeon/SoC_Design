`timescale 1ns / 1ps
module sign_extend #(
    parameter DATA_BIT = 32
    )(
    input  wire                        i_sign_extend,
    input  wire [(DATA_BIT / 2) - 1:0] i_const,
    output wire [DATA_BIT       - 1:0] o_const
    );

    assign o_const = (i_sign_extend == 1'b0) ? {{(DATA_BIT / 2){1'b0}}, i_const} : {{(DATA_BIT / 2){i_const[(DATA_BIT / 2) - 1]}}, i_const};

endmodule
/*
module zero_extend #(
    parameter DATA_BIT = 32
    )(
    input  wire [(DATA_BIT / 2) - 1:0] i_const,
    output wire [DATA_BIT       - 1:0] o_const
    );

    assign o_const = {{(DATA_BIT / 2){1'b0}}, i_const};

endmodule*/
