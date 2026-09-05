`timescale 1ns / 1ps
`include "../memory/memory.svh"
module registers #(
    DATA_BIT    = 16,
    STRB_BIT    = 2,
    REG_BIT     = 2
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  i_regwrite,
    input  wire                  i_unsigned,
    input  wire [REG_BIT  - 1:0] i_rd_reg1,
    input  wire [REG_BIT  - 1:0] i_rd_reg2,
    input  wire [REG_BIT  - 1:0] i_wr_reg,
    input  wire [DATA_BIT - 1:0] i_wr_data,
    input  wire [STRB_BIT - 1:0] i_wr_strb,
    output wire [DATA_BIT - 1:0] o_rd_data1,
    output wire [DATA_BIT - 1:0] o_rd_data2
    );

    localparam NUM_REG = 2 ** REG_BIT;

    //reg [DATA_BIT - 1:0] r_rd_data1, r_rd_data2;
    reg [DATA_BIT - 1:0] register [0:NUM_REG - 1]; 

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (integer i = 0; i < NUM_REG; i = i + 1) begin
                register[i] <= {DATA_BIT{1'b0}};
            end
        end
        else begin
            if (i_regwrite == 1'b1) begin
                if (i_wr_strb == {STRB_BIT{1'b1}}) begin    // LW
                    register[i_wr_reg] <= i_wr_data;
                end
                else if (i_wr_strb == STRB_BIT'(3)) begin
                    if (i_unsigned == 1'b1) begin           // LHU
                        register[i_wr_reg][DATA_BIT/2+:DATA_BIT/2]  <= {(DATA_BIT/2){1'b0}};
                    end
                    else begin                              // LH
                        register[i_wr_reg][DATA_BIT/2+:DATA_BIT/2]  <= {(DATA_BIT/2){1'b1}};
                    end
                    register[i_wr_reg][0+:DATA_BIT/2]   <= i_wr_data[DATA_BIT/2 - 1:0];
                end
                else if (i_wr_strb == STRB_BIT'(1)) begin
                    if (i_unsigned == 1'b1) begin           // LBU
                        register[i_wr_reg][`BYTE_SIZE+:(DATA_BIT-`BYTE_SIZE)]   <= {(DATA_BIT-`BYTE_SIZE){1'b0}};
                    end
                    else begin                              // LB
                        register[i_wr_reg][`BYTE_SIZE+:(DATA_BIT-`BYTE_SIZE)]   <= {(DATA_BIT-`BYTE_SIZE){1'b0}};
                    end
                    register[i_wr_reg][0+:`BYTE_SIZE]   <= i_wr_data[`BYTE_SIZE - 1:0];
                end
            end
        end
    end

    assign o_rd_data1 = ((i_regwrite == 1'b1) && (i_rd_reg1 == i_wr_reg)) ? i_wr_data : register[i_rd_reg1];
    assign o_rd_data2 = ((i_regwrite == 1'b1) && (i_rd_reg2 == i_wr_reg)) ? i_wr_data : register[i_rd_reg2];
    
/*
MIPS SW Conventions for Registers
|-------------------------------------------------------|
|   No      |   Name    |    Description                |
|-------------------------------------------------------|
|   0       |   zero    |   constant 0                  |
|   1       |   at      |   reserved for assembler      |
|-------------------------------------------------------|
|   2       |   v0      |   expression eval&fct results |
|   3       |   v1      |                               |
|-------------------------------------------------------|
|   4       |   a0      |   arguments                   |
|   5       |   a1      |                               |
|   6       |   a2      |                               |
|   7       |   a3      |                               |
|-------------------------------------------------------|
|   8 ~     |   t0 ~    |   temporary: caller saves     |
|   ~ 15    |   ~ t7    |   (callee can clobber)        |
|-------------------------------------------------------|
|   16 ~    |   s0 ~    |   callee saves                |
|   ~ 23    |   ~ s7    |   (caller can clobber)        |
|-------------------------------------------------------|
|   24      |   t8      |   temporary                   |
|   25      |   t9      |                               |
|-------------------------------------------------------|
|   26      |   k0      |   reserved for OS kernel      |
|   27      |   k1      |                               |
|-------------------------------------------------------|
|   28      |   gp      |   Pointer to global area      |
|   29      |   sp      |   Stack Pointer               |
|   30      |   fp      |   Frame Pointer               |
|-------------------------------------------------------|
|   31      |   ra      |   Return Address (HW)         |
|-------------------------------------------------------|
*/
endmodule
