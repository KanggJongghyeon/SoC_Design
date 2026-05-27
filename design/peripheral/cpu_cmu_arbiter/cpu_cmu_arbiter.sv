`timescale 1ns / 1ps
module cpu_cmu_arbiter ( 
    input  wire i_req [0:1],
    output wire o_gnt [0:1],
    output wire o_master
    );

    assign o_gnt[0] = i_req[0];
    assign o_gnt[1] = ((i_req[0] == 1'b0) && (i_req[1] == 1'b1)) ? 1'b1 : 1'b0;
    assign o_master = ((i_req[0] == 1'b0) && (i_req[1] == 1'b1)) ? 1'b1 : 1'b0;

endmodule
