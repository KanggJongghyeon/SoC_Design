`timescale 1ns / 1ps
////////////////
// 2-to-1 MUX //
////////////////
module mux21 #(
    parameter DATA_BIT = 2
    )(
    input   wire                    i_ctr,
    input   wire [DATA_BIT - 1:0]   i_i0,
    input   wire [DATA_BIT - 1:0]   i_i1,
    output  wire [DATA_BIT - 1:0]   o_o
    );

    assign o_o  = (i_ctr == 1'b1) ? i_i1 : i_i0;

endmodule

////////////////
// 4-to-1 MUX //
////////////////
module mux41 #(
    parameter DATA_BIT = 2
    )(
        input   wire [1:0]              i_ctr,
        input   wire [DATA_BIT - 1:0]   i_i00,
        input   wire [DATA_BIT - 1:0]   i_i01,
        input   wire [DATA_BIT - 1:0]   i_i11,
        input   wire [DATA_BIT - 1:0]   i_i10,
        output  wire [DATA_BIT - 1:0]   o_o
    );
    
    genvar i;
    generate
        for (i = 0; i < DATA_BIT; i = i +1) begin : MUX41
            assign o_o[i] = (~i_ctr[0] & ~i_ctr[1] & i_i00[i]) | (i_ctr[0] & ~i_ctr[1] & i_i01[i]) | (i_ctr[0] & i_ctr[1] & i_i11[i]) | (~i_ctr[0] & i_ctr[1] & i_i10[i]); 
        end
    endgenerate

endmodule
