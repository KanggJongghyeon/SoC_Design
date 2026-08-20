`include "instruction.svh"
`timescale 1ns / 1ps
module alu_ctr #(
    parameter DATA_BIT = 32
    )(
    input  wire [5:0] i_funct,
    input  wire [3:0] i_aluop,
    output wire [3:0] o_aluop
    );

    reg [3:0] r_aluop;

    always @ (/*i_funct or i_aluop*/*) begin
        if (i_aluop == `ALUOP_ADD)      begin   // 4'd0 (LW or SW or ADDI or ADDIU)
            r_aluop = `ALU_CTR_ADD;
        end
        else if (i_aluop == `ALUOP_SUB) begin   // 4'd1 (BEQ or BNE or BLT or BGE)
            r_aluop = `ALU_CTR_SUB;
        end
        else if (i_aluop == `ALUOP_RTYPE) begin // 4'd2 (RTYPE)
            case (i_funct)
                (`FUNCT_SLL)    : begin // 6'd0
                    r_aluop = `ALU_CTR_SLL;
                end
                (`FUNCT_SRL)    : begin // 6'd2
                    r_aluop = `ALU_CTR_SRL;
                end
                (`FUNCT_SRA)    : begin // 6'd3
                    r_aluop = `ALU_CTR_SRA;
                end
                (`FUNCT_SLLV)   : begin // 6'd4
                    r_aluop = `ALU_CTR_SLL;
                end
                (`FUNCT_SRLV)   : begin // 6'd6
                    r_aluop = `ALU_CTR_SRL;
                end
                (`FUNCT_SRAV)   : begin // 6'd7
                    r_aluop = `ALU_CTR_SRA;
                end
                (`FUNCT_MFHI)   : begin // 6'd16
                    r_aluop = `ALU_CTR_MFHI;
                end
                (`FUNCT_MFLO)   : begin // 6'd18
                    r_aluop = `ALU_CTR_MFLO;
                end
                (`FUNCT_MUL)    : begin // 6'd24
                    r_aluop = `ALU_CTR_MUL;
                end
                (`FUNCT_MULU)   : begin // 6'd25
                    r_aluop = `ALU_CTR_MUL;
                end
                (`FUNCT_DIV)    : begin // 6'd26
                    r_aluop = `ALU_CTR_DIV;
                end
                (`FUNCT_DIVU)   : begin // 6'd27
                    r_aluop = `ALU_CTR_DIV;
                end
                (`FUNCT_ADD)    : begin // 6'd32
                    r_aluop = `ALU_CTR_ADD;
                end
                (`FUNCT_ADDU)   : begin // 6'd33
                    r_aluop = `ALU_CTR_ADD;
                end
                (`FUNCT_SUB)    : begin // 6'd34
                    r_aluop = `ALU_CTR_SUB;
                end
                (`FUNCT_SUBU)   : begin // 6'd35
                    r_aluop = `ALU_CTR_SUB;
                end
                (`FUNCT_AND)  : begin   // 6'd36
                    r_aluop = `ALU_CTR_AND;
                end
                (`FUNCT_OR)   : begin   // 6'd37
                    r_aluop = `ALU_CTR_OR;
                end
                (`FUNCT_XOR)  : begin   // 6'd38
                    r_aluop = `ALU_CTR_XOR;
                end
                (`FUNCT_NOR)  : begin   // 6'd39
                    r_aluop = `ALU_CTR_NOR;
                end
                (`FUNCT_SLT)  : begin   // 6'd42
                    r_aluop = `ALU_CTR_SLT;
                end
                (`FUNCT_SLTU) : begin   // 6'd43
                    r_aluop = `ALU_CTR_SLT;
                end
                default : begin
                    r_aluop = `ALU_CTR_XXX;
                end
            endcase
        end
        else if (i_aluop == `ALUOP_SLTI) begin  // 4'd3 (SLTI, SLTIU)
            r_aluop = `ALU_CTR_SLT;
        end
        else if (i_aluop == `ALUOP_ANDI) begin  // 4'd4 (ANDI)
            r_aluop = `ALU_CTR_AND;
        end
        else if (i_aluop == `ALUOP_ORI) begin   // 4'd5 (ORI)
            r_aluop = `ALU_CTR_OR;
        end
        else if (i_aluop == `ALUOP_XORI) begin  // 4'd6 (XORI)
            r_aluop = `ALU_CTR_XOR;
        end
        else if (i_aluop == `ALUOP_LUI) begin   // 4'd7 (LUI)
            r_aluop = `ALU_CTR_LUI;
        end
        else if (i_aluop == `ALU_BZ) begin      // 4'd8 (BLTZ, BGEZ)
            r_aluop = `ALU_CTR_BZ;
        end
        else begin
            r_aluop = 4'h0;
        end
    end

    assign o_aluop = r_aluop;

endmodule
