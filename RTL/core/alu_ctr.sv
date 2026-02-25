`include "opcodes.sv"
`timescale 1ns / 1ps
module alu_ctr #(
    parameter DATA_BIT = 32
    )(
    input  wire [5:0] i_funct,
    input  wire [1:0] i_aluopa,
    input  wire [3:0] i_aluopb,
    output wire [3:0] o_aluop
    );

    reg [3:0] r_aluop;

    always @ (/*i_funct or i_aluop*/*) begin
        if (i_aluopa == 2'b00)      begin // LW or SW or ADDI
            r_aluop = (`ALU_CTR_ADD);
        end
        else if (i_aluopa == 2'b01) begin // BEQ
            r_aluop = (`ALU_CTR_SUB);
        end
        else if (i_aluopa == 2'b10) begin // RTYPE
            case (i_funct)
                (`FUNCT_ADD)  : begin
                    r_aluop = (`ALU_CTR_ADD);
                end
                (`FUNCT_SUB)  : begin
                    r_aluop = (`ALU_CTR_SUB);
                end
                (`FUNCT_AND)  : begin
                    r_aluop = (`ALU_CTR_AND);
                end
                (`FUNCT_OR)   : begin
                    r_aluop = (`ALU_CTR_OR);
                end
                (`FUNCT_NOR)  : begin
                    r_aluop = (`ALU_CTR_NOR);
                end
                (`FUNCT_XOR)  : begin
                    r_aluop = 4'b1111;
                end
                (`FUNCT_SLT)  : begin
                    r_aluop = (`ALU_CTR_SLT);
                end
                (`FUNCT_SLTU) : begin
                    r_aluop = (`ALU_CTR_SLT);
                end
                (`FUNCT_JR)   : begin
                    r_aluop = 4'b1111;
                end
                default : begin
                    r_aluop = 4'b1111;
                end
            endcase
        end
        else begin
            r_aluop = i_aluopb;
        end
    end

    assign o_aluop = r_aluop;

endmodule
