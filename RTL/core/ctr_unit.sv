`include "opcodes.sv"
`timescale 1ns / 1ps
module ctr_unit #(
    parameter DATA_BIT   = 16,
    parameter OPCODE_BIT = 4
    )(
    input  wire [OPCODE_BIT - 1:0] i_opcode,
    output wire                    o_regdst,
    output wire                    o_alusrc,
    output wire                    o_memtoreg,
    output wire                    o_regwrite,
    output wire                    o_memread,
    output wire                    o_memwrite,
    output wire                    o_branch,
    output wire [1:0]              o_aluopa,
    output wire [3:0]              o_aluopb,
    output wire                    o_sign_extend,
    output wire                    o_arbiter_req,
    input  wire                    i_arbiter_gnt
    );

    reg       r_regdst, r_alusrc, r_memtoreg, r_regwrite, r_memread, r_memwrite, r_branch, r_sign_extend;
    reg [1:0] r_aluopa;
    reg [3:0] r_aluopb;

    always @ (*) begin
        case(i_opcode)
            `OP_RTYPE : begin
                r_regdst      = 1'b1;
                r_alusrc      = 1'b0;
                r_memtoreg    = 1'b0;
                r_regwrite    = 1'b1;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b10;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
            `OP_ADDI  : begin
                r_regdst      = 1'b0;
                r_alusrc      = 1'b1;
                r_memtoreg    = 1'b0;
                r_regwrite    = 1'b1;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b00;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
            `OP_ADDIU : begin
                r_regdst      = 1'b0;
                r_alusrc      = 1'b1;
                r_memtoreg    = 1'b0;
                r_regwrite    = 1'b1;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b00;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b0;
            end
            `OP_ANDI  : begin
                r_regdst      = 1'b0;
                r_alusrc      = 1'b1;
                r_memtoreg    = 1'b0;
                r_regwrite    = 1'b1;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b11;
                r_aluopb      = `ALU_CTR_AND;
                r_sign_extend = 1'b0;
            end
            `OP_ORI   : begin
                r_regdst      = 1'b0;
                r_alusrc      = 1'b1;
                r_memtoreg    = 1'b0;
                r_regwrite    = 1'b1;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b11;
                r_aluopb      = `ALU_CTR_OR;
                r_sign_extend = 1'b0;
            end
            `OP_BEQ   : begin
                r_regdst      = r_regdst;
                r_alusrc      = 1'b0;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = 1'b0;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b1;
                r_aluopa      = 2'b01;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
            `OP_BNE   : begin
                r_regdst      = r_regdst;
                r_alusrc      = r_alusrc;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = r_regwrite;
                r_memread     = r_memread;
                r_memwrite    = r_memwrite;
                r_branch      = r_branch;
                r_aluopa      = 2'b01;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
            `OP_SLTI  : begin
                r_regdst      = r_regdst;
                r_alusrc      = r_alusrc;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = r_regwrite;
                r_memread     = r_memread;
                r_memwrite    = r_memwrite;
                r_branch      = r_branch;
                r_aluopa      = 2'b11;
                r_aluopb      = `ALU_CTR_SLT;
                r_sign_extend = 1'b1;
            end
            `OP_SLTIU : begin
                r_regdst      = r_regdst;
                r_alusrc      = r_alusrc;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = r_regwrite;
                r_memread     = r_memread;
                r_memwrite    = r_memwrite;
                r_branch      = r_branch;
                r_aluopa      = 2'b11;
                r_aluopb      = `ALU_CTR_SLT;
                r_sign_extend = 1'b0;
            end
            `OP_LW    : begin
                r_regdst      = 1'b0;
                r_alusrc      = 1'b1;
                r_memtoreg    = 1'b1;
                r_regwrite    = 1'b1;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b00;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memread = 1'b1;
                end
                else begin
                    r_memread = 1'b0;
                end
            end
            `OP_SW    : begin
                r_regdst      = r_regdst;
                r_alusrc      = 1'b1;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = 1'b0;
                r_memread     = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b00;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memwrite = 1'b1;
                end
                else begin
                    r_memwrite = 1'b0;
                end
            end
            `OP_LUI   : begin
                r_regdst      = 1'b0;
                r_alusrc      = 1'b1;
                r_memtoreg    = 1'b0;
                r_regwrite    = 1'b1;
                r_memread     = 1'b0;
                r_memwrite    = 1'b0;
                r_branch      = 1'b0;
                r_aluopa      = 2'b11;
                r_aluopb      = `ALU_CTR_LUI;
                r_sign_extend = 1'b1;
            end
            `OP_JUMP  : begin
                r_regdst      = r_regdst;
                r_alusrc      = r_alusrc;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = r_regwrite;
                r_memread     = r_memread;
                r_memwrite    = r_memwrite;
                r_branch      = r_branch;
                r_aluopa      = r_aluopa;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
            `OP_JAL   : begin
                r_regdst      = r_regdst;
                r_alusrc      = r_alusrc;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = r_regwrite;
                r_memread     = r_memread;
                r_memwrite    = r_memwrite;
                r_branch      = r_branch;
                r_aluopa      = r_aluopa;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
            default  : begin
                r_regdst      = r_regdst;
                r_alusrc      = r_alusrc;
                r_memtoreg    = r_memtoreg;
                r_regwrite    = r_regwrite;
                r_memread     = r_memread;
                r_memwrite    = r_memwrite;
                r_branch      = r_branch;
                r_aluopa      = r_aluopa;
                r_aluopb      = 4'h0;
                r_sign_extend = 1'b1;
            end
        endcase
    end

    assign o_regdst      = r_regdst;
    assign o_alusrc      = r_alusrc;
    assign o_memtoreg    = r_memtoreg;
    assign o_regwrite    = r_regwrite;
    assign o_memread     = r_memread;
    assign o_memwrite    = r_memwrite;
    assign o_branch      = r_branch;
    assign o_aluopa      = r_aluopa;
    assign o_aluopb      = r_aluopb;
    assign o_sign_extend = r_sign_extend;
//    assign o_arbiter_req = ((i_opcode == `OP_SW) || (i_opcode == `OP_LW)) ? 1'b1 : 1'b0;
  
    reg r_arbiter_req;  

    always @ (*) begin
        if ((i_opcode != `OP_SW) && (i_opcode != `OP_LW)) begin
            r_arbiter_req = 1'b0;
        end
        else if ((i_opcode == `OP_SW) || (i_opcode == `OP_LW)) begin
            r_arbiter_req = 1'b1;
        end
        else begin
            r_arbiter_req = r_arbiter_req;
        end
    end

    assign o_arbiter_req = r_arbiter_req;

endmodule
