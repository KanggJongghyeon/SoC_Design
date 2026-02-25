`timescale 1ns / 1ps
module registers #(
    DATA_BIT   = 16,
    REG_BIT    = 2
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  i_regwrite,
    input  wire                  i_memtoreg,
    input  wire [REG_BIT  - 1:0] i_rd_reg1,
    input  wire [REG_BIT  - 1:0] i_rd_reg2,
    input  wire [REG_BIT  - 1:0] i_wr_reg,
    input  wire [DATA_BIT - 1:0] i_wr_data,
    output wire [DATA_BIT - 1:0] o_rd_data1,
    output wire [DATA_BIT - 1:0] o_rd_data2
    );

    localparam NUM_REG = 2 ** REG_BIT;

    //reg [DATA_BIT - 1:0] r_rd_data1, r_rd_data2;
    reg [DATA_BIT - 1:0] register [0:NUM_REG - 1]; 

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            //r_rd_data1 <= {DATA_BIT{1'b0}};
            //r_rd_data2 <= {DATA_BIT{1'b0}};
            for (integer i = 0; i < NUM_REG; i = i + 1) begin
                register[i] <= {DATA_BIT{1'b0}};
            end
        end
        else begin
            //r_rd_data1 <= register[i_rd_reg1];
            //r_rd_data2 <= register[i_rd_reg2];
            if (i_regwrite == 1'b1) begin
                register[i_wr_reg] <= i_wr_data;
            end
        end
    end

    assign o_rd_data1 = /*r_rd_data1*/register[i_rd_reg1];
    assign o_rd_data2 = /*r_rd_data2*/register[i_rd_reg2];
    
endmodule
