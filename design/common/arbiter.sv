`include "arbiter.svh"
`timescale 1ns / 1ps
module arbiter21_fixed (
    input   wire i_req0,     
    input   wire i_req1,    
    output  wire o_gnt0,     
    output  wire o_gnt1,     
    output  wire o_master   
    );

    assign o_gnt0   = i_req0;
    assign o_gnt1   = ((i_req0 == 1'b0) && (i_req1 == 1'b1)) ? 1'b1 : 1'b0;
    assign o_master = ((i_req0 == 1'b0) && (i_req1 == 1'b1)) ? 1'b1 : 1'b0;

endmodule
