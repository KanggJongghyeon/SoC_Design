`include "arbiter.svh"
`timescale 1ns / 1ps
module arbiter21_fixed (
/*
    Priority : MASTER0 > MASTER1
*/
    input   wire clk,       // Global
    input   wire rst_n,     // Global
    input   wire i_req0,    // Master0 Request     
    input   wire i_req1,    // Master1 Request
    input   wire i_done,    // Bus Using Done Flag
    output  wire o_gnt0,    // Master0 Grant     
    output  wire o_gnt1,    // Master1 Grant
    output  wire o_master   // Master Flag
    );

/////////
// Reg //
/////////
    reg r_bus_using;    // Bus Using Flag
    reg r_master;       // Master    Flag

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_bus_using <= `BUS_AVAILABLE;
            r_master    <= 1'b0;
        end
        else begin
            if (i_done == 1'b1) begin
                r_bus_using <= `BUS_AVAILABLE;
            end
            else begin
                if (i_req0 == 1'b1) begin
                    if (r_bus_using == `BUS_AVAILABLE) begin
                        r_bus_using <= `BUS_USING;
                        r_master    <= `MASTER0;
                    end
                end
                else begin
                    if (i_req1 == 1'b1) begin
                        if (r_bus_using == `BUS_AVAILABLE) begin
                            r_bus_using <= `BUS_USING;
                            r_master    <= `MASTER1;
                        end
                    end
                end
            end
        end
    end

    assign o_master = r_master;
    assign o_gnt0   = (r_bus_using == `BUS_USING) && (r_master == 1'b0); 
    assign o_gnt1   = (r_bus_using == `BUS_USING) && (r_master == 1'b1); 

endmodule
