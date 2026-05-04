///////////////////////////////////////
// Path : .\RTL\core\forward_unit.sv //
///////////////////////////////////////
`timescale 1ns / 1ps
/////////////////////////////////////
// memtoreg Buffer for checking LW //
/////////////////////////////////////
module lw_flag_unit (
    input   wire    clk,
    input   wire    rst_n,
    input   wire    i_memtoreg,
    output  wire    o_lw_flag
    );

    reg     r_memtoreg, r_lw_flag;
    
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_memtoreg <= 1'b0;
        end
        else begin
            r_memtoreg <= i_memtoreg;
        end
    end

    always @ (*) begin
        if (~rst_n) begin
            r_lw_flag = 1'b0;
        end
        else begin
            case ({i_memtoreg, r_memtoreg})
                2'b00 : begin
                    r_lw_flag = 1'b0;
                end
                2'b01 : begin
                    r_lw_flag = 1'b1;
                end
                2'b11 : begin
                    r_lw_flag = 1'b1;
                end
                2'b10 : begin
                    r_lw_flag = r_lw_flag;   // don't care
                end
                default : begin
                    r_lw_flag = r_lw_flag;
                end
            endcase
        end
    end

    assign o_lw_flag = r_lw_flag;

endmodule

////////////////////////////////////////
// rt Register Buffer for Data Hazard //
////////////////////////////////////////
module rd_buffer #(
    REG_BIT = 2
    )(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire [REG_BIT - 1:0]    i_rd,
    output  wire [REG_BIT - 1:0]    o_rd
    );

    reg [REG_BIT - 1:0] r_rd;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_rd <= {REG_BIT{1'b0}};
        end
        else begin
            r_rd <= i_rd;
        end
    end
    
    assign o_rd = r_rd;

endmodule
