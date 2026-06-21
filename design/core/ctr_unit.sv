//////////////////////////////////////
// Path : .\design\core\ctr_unit.sv //
//////////////////////////////////////
`include "instruction.svh"
`timescale 1ns / 1ps
module ctr_unit #(
    parameter DATA_BIT   = 16,
    parameter OPCODE_BIT = 4
    )(
    input  wire [OPCODE_BIT - 1:0]  i_opcode,
    input  wire [5:0]               i_funct,    // Add because of jr
    output wire                     o_regdst,
    output wire                     o_alusrc,
    output wire                     o_memtoreg,
    output wire                     o_regwrite,
    output wire                     o_memread,
    output wire                     o_memwrite,
    output wire [1:0]               o_branch,   // {00 : none, 01 : beq, 10 : bne,  11 : Reserved}
    output wire [2:0]               o_aluop,
    output wire [1:0]               o_jump,     // {00 : none, 01 : j,   10 : jr,   11 : jal}
    output wire                     o_sign_extend,
    output wire                     o_arbiter_req,
    input  wire                     i_arbiter_gnt
    );

    reg         r_regdst, r_alusrc, r_memtoreg, r_regwrite, r_memread, r_memwrite, r_sign_extend;
    reg [1:0]   r_branch, r_jump;
    reg [2:0]   r_aluop;

    always @ (*) begin
        case(i_opcode)
            `OP_RTYPE   : begin // 6'd0
                if (i_funct != `FUNCT_JR) begin
                    r_regdst        = 1'b1;
                    r_alusrc        = 1'b0;
                    r_memtoreg      = 1'b0;
                    r_regwrite      = 1'b1;
                    r_memread       = 1'b0;
                    r_memwrite      = 1'b0;
                    r_branch        = 2'b00;
                    r_aluop         = `ALUOP_RTYPE;
                    r_jump          = 2'b00;
                    r_sign_extend   = 1'b0;
                end
                else begin  // jr
                    r_regdst        = 1'b0;
                    r_alusrc        = 1'b0;
                    r_memtoreg      = 1'b0;
                    r_regwrite      = 1'b0;
                    r_memread       = 1'b0;
                    r_memwrite      = 1'b0;
                    r_branch        = 1'b0;
                    r_aluop         = `ALUOP_RTYPE;
                    r_jump          = 2'b10;
                    r_sign_extend   = 1'b0;
                end
            end
            `OP_REGIMM  : begin // 6'd1
                r_regdst        = r_regdst;
                r_alusrc        = r_alusrc;
                r_memtoreg      = r_memtoreg;
                r_regwrite      = r_regwrite;
                r_memread       = r_memread;
                r_memwrite      = r_memwrite;
                r_branch        = r_branch;
                r_aluop         = r_aluop;
                r_jump          = r_jump;
                r_sign_extend   = r_sign_extend;
            end
            `OP_J       : begin // 6'd2
                r_regdst        = 1'b0; 
                r_alusrc        = 1'b1; // don't care
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = 3'b000;  
                r_jump          = 2'b01;
                r_sign_extend   = 1'b1;
            end
            `OP_JAL     : begin // 6'd3
                r_regdst        = 1'b0; 
                r_alusrc        = 1'b1; // don't care
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = 3'b000;  
                r_jump          = 2'b11;
                r_sign_extend   = 1'b1;
            end
            `OP_BEQ   : begin   // 6'd4
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b01;
                r_aluop         = `ALUOP_SUB;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
            end
            `OP_BNE   : begin   // 6'd5
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b10;
                r_aluop         = `ALUOP_SUB;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
            end
            `OP_ADDI  : begin   // 6'd8
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_ADD;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
            end
            `OP_ADDIU : begin   // 6'd9
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_ADD;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b0;
            end
            `OP_SLTI  : begin   // 6'd10
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_SLTI;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
            end
            `OP_SLTIU : begin   // 6'd11
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_SLTI;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b0;
            end
            `OP_ANDI  : begin   // 6'd12
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_ANDI;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b0;
            end
            `OP_ORI   : begin   // 6'd13
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_ORI;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b0;
            end
            `OP_XORI    : begin // 6'd14
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_XORI;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b0;
            end
            `OP_LUI   : begin   // 6'd15
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_LUI;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
            end
            `OP_LW    : begin   // 6'd35
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b1;
                r_regwrite      = 1'b1;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_ADD;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memread   = 1'b1;
                end
                else begin
                    r_memread   = 1'b0;
                end
            end
            `OP_SW    : begin   // 6'd43
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = `ALUOP_ADD;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memwrite  = 1'b1;
                end
                else begin
                    r_memwrite  = 1'b0;
                end
            end
            default  : begin
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memwrite      = 1'b0;
                r_branch        = 2'b00;
                r_aluop         = 3'b000;
                r_jump          = 2'b00;
                r_sign_extend   = 1'b1;
            end
        endcase
    end

    assign o_regdst         = r_regdst;
    assign o_alusrc         = r_alusrc;
    assign o_memtoreg       = r_memtoreg;
    assign o_regwrite       = r_regwrite;
    assign o_memread        = r_memread;
    assign o_memwrite       = r_memwrite;
    assign o_branch         = r_branch;
    assign o_aluop          = r_aluop;
    assign o_jump           = r_jump;
    assign o_sign_extend    = r_sign_extend;
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
