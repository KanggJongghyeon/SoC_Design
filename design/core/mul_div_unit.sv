`timescale 1ns / 1ps
`include "instruction.svh"
module mul_div_unit #(
    parameter DATA_BIT = 64
    )(
    input   wire    [DATA_BIT - 1:0]    i_in0,
    input   wire    [DATA_BIT - 1:0]    i_in1,
    input   wire    [3:0]               i_aluop,
    output  wire    [DATA_BIT - 1:0]    o_hi,
    output  wire    [DATA_BIT - 1:0]    o_lo
    );

    reg [2 * DATA_BIT - 1:0]    r_temp;
    reg [DATA_BIT - 1:0]        r_high_reg, r_low_reg;  // Register
    reg [DATA_BIT - 1:0]        r_hi,       r_lo;       // I/O

    always @ (*) begin
        case (i_aluop)
            (`ALU_CTR_MFHI) : begin // 4'd5
                r_temp      = {(2 * DATA_BIT){1'b0}};
                r_high_reg  = r_high_reg;
                r_low_reg   = r_low_reg;
                r_hi        = r_high_reg;
                r_lo        = {DATA_BIT{1'b0}};
            end
            (`ALU_CTR_MFLO) : begin // 4'd8
                r_temp      = {(2 * DATA_BIT){1'b0}};
                r_high_reg  = r_high_reg;
                r_low_reg   = r_low_reg;
                r_hi        = {DATA_BIT{1'b0}};
                r_lo        = r_low_reg;
            end
            (`ALU_CTR_MUL)  : begin // 4'd13
                r_temp      = {{DATA_BIT{1'b0}}, i_in0} * {{DATA_BIT{1'b0}}, i_in1};
                r_high_reg  = r_temp[2 * DATA_BIT - 1:DATA_BIT];
                r_low_reg   = r_temp[1 * DATA_BIT - 1:0];
                r_hi        = {DATA_BIT{1'b0}};
                r_lo        = {DATA_BIT{1'b0}};
            end
            (`ALU_CTR_DIV)  : begin // 4'd14
                r_hi        = {DATA_BIT{1'b0}};
                r_lo        = {DATA_BIT{1'b0}};
                if (i_in1 == {DATA_BIT{1'b0}}) begin
                    r_temp      = {(2 * DATA_BIT){1'b0}};
                    r_high_reg  = {DATA_BIT{1'b0}};
                    r_low_reg   = {DATA_BIT{1'b0}};
                end
                else begin
                    r_temp      = {(2 * DATA_BIT){1'b0}};
                    r_high_reg  = i_in0 % i_in1;
                    r_low_reg   = i_in0 / i_in1;
                end
            end
            default         : begin      
                r_temp      = {(2 * DATA_BIT){1'b0}};
                r_high_reg  = r_high_reg;
                r_low_reg   = r_low_reg;
                r_hi        = {DATA_BIT{1'b0}};
                r_lo        = {DATA_BIT{1'b0}};
            end
        endcase
    end

    assign o_hi = r_hi;
    assign o_lo = r_lo;

endmodule
