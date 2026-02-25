`timescale 1ns / 1ps
`include "opcodes.sv"
module alu #(
    parameter DATA_BIT = 16
    )(
    input  wire                  clk,
    input  wire                  rst_n,   
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
        /*
            ALU_OP_ADD  : begin
                w_temp  = {1'b0, i_in0} + {1'b0, i_in1} + {16'h0000, i_carry};
                o_out   = w_temp[15:0];
                o_carry = w_temp[16];
            end
            ALU_OP_SUB  : begin
                w_temp  = {1'b0, i_in0} - {1'b0, i_in1} - {16'h0000, i_carry};
                o_out   = w_temp[15:0];
                o_carry = w_temp[16];
            end
            ALU_OP_ID   : begin // output ?넀 input1
                w_temp  = 17'b00000000000000000;
                o_out   = i_in0;
                o_carry = 1'b0; 
            end  
            ALU_OP_NAND : begin
                w_temp  = 17'b00000000000000000;
                o_out   = ~(i_in0 & i_in1);
                o_carry = 1'b0;
            end
            ALU_OP_NOR  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = ~(i_in0 | i_in1);
                o_carry = 1'b0;
            end
            ALU_OP_XNOR : begin
                w_temp  = 17'b00000000000000000;
                o_out   = ~(i_in0 ^ i_in1);
                o_carry = 1'b0;
            end
            ALU_OP_NOT  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = ~i_in0;
                o_carry = 1'b0;
            end
            ALU_OP_AND  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = i_in0 & i_in1;
                o_carry = 1'b0;
            end
            ALU_OP_OR   : begin
                w_temp  = 17'b00000000000000000;
                o_out   = i_in0 | i_in1;
                o_carry = 1'b0;
            end
            ALU_OP_XOR  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = i_in0 ^ i_in1;
                o_carry = 1'b0;
            end
            ALU_OP_LRS  : begin // Shift Right
                w_temp  = 17'b00000000000000000;
                o_out   = {1'b0, i_in0[15:1]}; // i_in0 >> 1
                o_carry = i_in0[0];
            end
            ALU_OP_ARS  : begin // Arithmetic Right
                w_temp  = 17'b00000000000000000;
                o_out   = {i_in0[15], i_in0[15:1]}; // i_in0 >>> 1
                o_carry = i_in0[0];
            end
            ALU_OP_RR   : begin // Rotate Right
                w_temp  = 17'b00000000000000000;
                o_out   = {i_in0[0], i_in0[15:1]};
                o_carry = 1'b0;
            end
            ALU_OP_LLS  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = {i_in0[14:0], 1'b0}; // i_in0 << 1
                o_carry = i_in0[15];
            end
            ALU_OP_ALS  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = {i_in0[14:0], 1'b0}; // i_in0 <<< 1
                o_carry = i_in0[15]; 
            end
            ALU_OP_RL   : begin
                w_temp  = 17'b00000000000000000;
                o_out   = {i_in0[14:0], i_in0[15]};
                o_carry = 1'b0;
            end
            ALU_OP_TCP  : begin // output ?넀 ~input1 +1
                w_temp  = {1'b0, ~i_in0} + 17'b00000000000000001;
                o_out   = w_temp[15:0];
                o_carry = w_temp[16];
            end
            ALU_OP_SHL  : begin
                w_temp  = 17'b00000000000000000;
                o_out   = i_in1 << 8;
                o_carry = 1'b0;
            end
            ALU_OP_NE   : begin
                w_temp  = 17'b00000000000000000;
                o_out   = o_out;
                o_carry = o_carry;
            end
            ALU_OP_EQ   : begin
                w_temp  = 17'b00000000000000000;
                o_out   = o_out;
                o_carry = o_carry;
            end
            ALU_OP_GZ   : begin
                w_temp  = 17'b00000000000000000;
                o_out   = o_out;
                o_carry = o_carry;
            end
            ALU_OP_LZ   : begin
                w_temp  = 17'b00000000000000000;
                o_out   = o_out;
                o_carry = o_carry;
            end
            default     : begin
                w_temp  = 17'b00000000000000000;
                o_out   = 16'h0000;
                o_carry = 1'b0;
            end
            */
            (`ALU_CTR_AND) : begin
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 & i_in1;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_OR)  : begin
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = i_in0 | i_in1;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_NOR) : begin
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = ~(i_in0 | i_in1);
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_ADD) : begin
                r_temp  = {1'b0, i_in0} + {1'b0, i_in1} + {{(DATA_BIT){1'b0}}, i_carry};
                r_out   = r_temp[DATA_BIT - 1:0];
                r_carry = r_temp[DATA_BIT];
                r_zero  = 1'b0;
            end
            (`ALU_CTR_SUB) : begin
                r_temp  = {1'b0, i_in0} - {1'b0, i_in1} - {{(DATA_BIT){1'b0}}, i_carry};
                r_out   = r_temp[DATA_BIT - 1:0];
                r_carry = r_temp[DATA_BIT];
                r_zero  = 1'b1;
            end
            (`ALU_CTR_SLT) : begin
                r_temp  = {1'b0, i_in0} - {1'b0, i_in1} - {{(DATA_BIT){1'b0}}, i_carry};
                r_out   = (r_temp < {(DATA_BIT + 1){1'b0}}) ? 1'b1 : 1'b0;
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            (`ALU_CTR_LUI) : begin
                r_temp  = {(DATA_BIT + 1){1'b0}};
                r_out   = /*{i_in1, (DATA_BIT / 2){1'b0}}*/ i_in1 << (DATA_BIT / 2);
                r_carry = 1'b0;
                r_zero  = 1'b0;
            end
            default        : begin
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
