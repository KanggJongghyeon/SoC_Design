`timescale 1ns / 1ps
module inst_decoder #(
    parameter DATA_BIT   = 16,
    parameter OPCODE_BIT = 4,
    parameter REG_BIT    = 2
    )(
    input  wire [DATA_BIT                - 1:0] i_data,
    output wire [OPCODE_BIT              - 1:0] o_opcode,
    output wire [REG_BIT                 - 1:0] o_rs,
    output wire [REG_BIT                 - 1:0] o_rt,
    output wire [REG_BIT                 - 1:0] o_rd,
    output wire [4:0]                           o_shamt,
    output wire [5:0]                           o_funct,
    output wire [(DATA_BIT / 2)          - 1:0] o_const,
    output wire [(DATA_BIT - OPCODE_BIT) - 1:0] o_jaddr
    );

    assign o_opcode = i_data[DATA_BIT - 1:DATA_BIT - OPCODE_BIT];
    assign o_rs     = i_data[DATA_BIT - OPCODE_BIT - 0 * REG_BIT - 1:DATA_BIT - OPCODE_BIT - 1 * REG_BIT];
    assign o_rt     = i_data[DATA_BIT - OPCODE_BIT - 1 * REG_BIT - 1:DATA_BIT - OPCODE_BIT - 2 * REG_BIT];
    assign o_rd     = i_data[DATA_BIT - OPCODE_BIT - 2 * REG_BIT - 1:DATA_BIT - OPCODE_BIT - 3 * REG_BIT];
    assign o_shamt  = i_data[10:6];
    assign o_funct  = i_data[5:0];
    assign o_const  = i_data[(DATA_BIT / 2) - 1:0];
    assign o_jaddr  = i_data[(DATA_BIT - OPCODE_BIT) - 1:0];

endmodule
