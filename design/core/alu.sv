`include "instruction.svh"
`timescale 1ns / 1ps
module alu #(
    parameter DATA_BIT = 16
    )(
    input  wire [DATA_BIT - 1:0] i_in0,
    input  wire [DATA_BIT - 1:0] i_in1,
    input  wire                  i_carry,
    input  wire [3:0]            i_aluop,
    output wire [DATA_BIT - 1:0] o_out,
    output wire                  o_carry,
    output wire                  o_zero
    );

    reg [DATA_BIT    :0] r_temp;
    reg [DATA_BIT - 1:0] r_out;
    reg                  r_carry, r_zero;                

    always @ (*) begin
        case (i_aluop)
             (`ALU_CTR_AND) : begin // 4'd0
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 & i_in1;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_OR)   : begin // 4'd1
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 | i_in1;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_ADD)  : begin // 4'd2
                r_temp  = {1'b0, i_in0} + {1'b0, i_in1} + {{(DATA_BIT){1'b0}}, i_carry};
                r_out   = r_temp[DATA_BIT - 1:0];
                r_carry = r_temp[DATA_BIT];
                r_zero  = 1'b0;
            end
            (`ALU_CTR_XOR)  : begin // 4'd3
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 ^ i_in1;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_LUI)  : begin // 4'd4
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = /*{i_in1, (DATA_BIT / 2){1'b0}}*/ i_in1 << (DATA_BIT / 2);
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_SUB)  : begin // 4'd6
                r_temp  = {1'b0, i_in0} - {1'b0, i_in1} - {{(DATA_BIT){1'b0}}, i_carry};
                r_out   = r_temp[DATA_BIT - 1:0];
                r_carry = r_temp[DATA_BIT];
                if (r_out == {DATA_BIT{1'b0}}) begin    // BEQ or BNE
                    r_zero  = 1'b1;
                end
                else begin
                    r_zero  = 1'b0;
                end
            end
            (`ALU_CTR_SLT)  : begin // 4'd7
                r_temp                  = {1'b0, i_in0} - {1'b0, i_in1} - {{(DATA_BIT){1'b0}}, i_carry};
                r_out[DATA_BIT - 1 : 1] = {(DATA_BIT - 1){1'b0}};
                r_out[0]                = (r_temp < {(DATA_BIT + 1){1'b0}}) ? 1'b1 : 1'b0;
                r_carry                 = 1'b0;
                r_zero                  = 1'b0;
            end
            (`ALU_CTR_SLL)  : begin // 4'd9
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 << i_in1;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_SRL)  : begin // 4'd10
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 >>> i_in1;  // unsinged
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
             (`ALU_CTR_SRA) : begin // 4'd11
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 >> i_in1;   // signed
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end           
            (`ALU_CTR_NOR)  : begin // 4'd12
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = ~(i_in0 | i_in1);
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_XXX)  : begin // 4'd15
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = {DATA_BIT{1'b0}};
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            default         : begin
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = {DATA_BIT{1'b0}};
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
        endcase
    end

    assign o_out   = r_out;
    assign o_carry = r_carry;
    assign o_zero  = r_zero;

endmodule
