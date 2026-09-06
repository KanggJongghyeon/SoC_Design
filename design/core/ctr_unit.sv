//////////////////////////////////////
// Path : .\design\core\ctr_unit.sv //
//////////////////////////////////////
`include "instruction.svh"
`include "ctr_unit.svh"
`timescale 1ns / 1ps
module ctr_unit #(
    parameter DATA_BIT  = 16,
    parameter STRB_BIT  = 2,
    parameter OPCODE_BIT= 4,
    parameter REG_BIT   = 5
    )(
    input  wire [OPCODE_BIT - 1:0]  i_opcode,
    input  wire [5:0]               i_funct,    // Add because of jr
    input  wire [REG_BIT - 1:0]     i_rt,       // Add Because of REGIMM OPCODE 
    output wire                     o_regdst,
    output wire                     o_alusrc,
    output wire                     o_memtoreg,
    output wire                     o_regwrite,
    output wire                     o_memread,
    output wire [STRB_BIT - 1:0]    o_memrstrb,
    output wire                     o_load_unsigned,
    output wire                     o_memwrite,
    output wire [STRB_BIT - 1:0]    o_memwstrb,
    output wire [2:0]               o_branch,   
    output wire [3:0]               o_aluop,
    output wire [1:0]               o_jump,     // {00 : none, 01 : j,   10 : jr, jral,     11 : jal}
    output wire                     o_sign_extend,
    output wire                     o_arbiter_req,
    input  wire                     i_arbiter_gnt
    );

    reg                 r_regdst,   r_alusrc;
    reg                 r_memtoreg, r_regwrite; 
    reg                 r_memread,  r_memwrite;
    reg                 r_load_unsigned;
    reg [STRB_BIT - 1:0]r_memrstrb, r_memwstrb;
    reg [1:0]           r_jump;
    reg [2:0]           r_branch;
    reg [3:0]           r_aluop;
    reg                 r_sign_extend;
    reg                 r_arbiter_req;  

    /*
    Sign-Extend Rule
    Zero-Padding : Only andi, ori, xori, nori, ... (Combinational Logic)
    Sign-Padding : In All Other Cases (Arthimatic Logic ...)
    */

    always @ (*) begin
        case(i_opcode)
            `OP_RTYPE   : begin // 6'd0
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_RTYPE;
                r_sign_extend   = 1'b0; // don't care
                r_arbiter_req   = 1'b0;
                if (i_funct == `FUNCT_JR) begin
                    r_regdst        = 1'b0;
                    r_regwrite      = 1'b0;
                    r_jump          = `JUMP_JR_AL;
                end
                else if (i_funct == `FUNCT_JALR) begin
                    r_regdst        = 1'b0;
                    r_regwrite      = 1'b1;
                    r_jump          = `JUMP_JR_AL;
                end
                else begin
                    r_regdst        = 1'b1;
                    r_regwrite      = 1'b1;
                    r_jump          = `JUMP_NONE;
                end
            end
            `OP_REGIMM  : begin // 6'd1
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0; // don't care
                r_memtoreg      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_aluop         = `ALUOP_BZ;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
                case(i_rt)
                    `REGIMM_BLTZ    : begin
                        r_regwrite  = 1'b0;
                        r_branch    = `BRANCH_BLT;
                    end
                    `REGIMM_BGEZ    : begin
                        r_regwrite  = 1'b0;
                        r_branch    = `BRANCH_BGE;
                    end
                    `REGIMM_BLTZL   : begin
                        r_regwrite  = 1'b0;
                        r_branch    = `BRANCH_BLT;
                    end
                    `REGIMM_BGEZL   : begin
                        r_regwrite  = 1'b0;
                        r_branch    = `BRANCH_BGE;
                    end
                    `REGIMM_BLTZAL  : begin
                        r_regwrite  = 1'b1;
                        r_branch    = `BRANCH_BLT;
                    end
                    `REGIMM_BGEZAL  : begin
                        r_regwrite  = 1'b1;
                        r_branch    = `BRANCH_BGE;
                    end
                    `REGIMM_BLTZALL : begin
                        r_regwrite  = 1'b1;
                        r_branch    = `BRANCH_BLT;
                    end
                    `REGIMM_BGEZALL : begin
                        r_regwrite  = 1'b1;
                        r_branch    = `BRANCH_BGE;
                    end
                    default         : begin
                        r_regwrite  = 1'b0;
                        r_branch    = `BRANCH_NONE;
                    end
                endcase
            end
            `OP_J       : begin // 6'd2
                r_regdst        = 1'b0; 
                r_alusrc        = 1'b1;     // don't care
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = 3'b000;   // don't care  
                r_jump          = `JUMP_J;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_JAL     : begin // 6'd3
                r_regdst        = 1'b0; 
                r_alusrc        = 1'b1;     // don't care
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = 3'b000;   // don't care
                r_jump          = `JUMP_JAL;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_BEQ     : begin // 6'd4
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_BEQ;
                r_aluop         = `ALUOP_SUB;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_BNE     : begin // 6'd5
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_BNE;
                r_aluop         = `ALUOP_SUB;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_ADDI    : begin // 6'd8
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_ADDIU   : begin // 6'd9
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_SLTI    : begin // 6'd10
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_SLTI;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_SLTIU   : begin // 6'd11
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_SLTI;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
            `OP_ANDI    : begin // 6'd12
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ANDI;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b0;
                r_arbiter_req   = 1'b0;
            end
            `OP_ORI     : begin // 6'd13
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ORI;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b0;
                r_arbiter_req   = 1'b0;
            end
            `OP_XORI    : begin // 6'd14
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_XORI;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b0;
                r_arbiter_req   = 1'b0;
            end
            `OP_LUI     : begin // 6'd15
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b1;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_LUI;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1; // don't care
                r_arbiter_req   = 1'b0;
            end
            `OP_LB      : begin // 6'd32
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b1;
                r_regwrite      = 1'b1;
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt == 1'b1) begin
                    r_memread   = 1'b1;
                    r_memrstrb  = STRB_BIT'(1);
                end
                else begin
                    r_memread   = 1'b0;
                    r_memrstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_LH      : begin // 6'd33
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b1;
                r_regwrite      = 1'b1;
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt == 1'b1) begin
                    r_memread   = 1'b1;
                    r_memrstrb  = STRB_BIT'(3);
                end
                else begin
                    r_memread   = 1'b0;
                    r_memrstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_LW      : begin // 6'd35
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b1;
                r_regwrite      = 1'b1;
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt == 1'b1) begin
                    r_memread   = 1'b1;
                    r_memrstrb  = {STRB_BIT{1'b1}};
                end
                else begin
                    r_memread   = 1'b0;
                    r_memrstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_LBU     : begin // 6'd36
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b1;
                r_regwrite      = 1'b1;
                r_load_unsigned = 1'b1;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt == 1'b1) begin
                    r_memread   = 1'b1;
                    r_memrstrb  = STRB_BIT'(1);
                end
                else begin
                    r_memread   = 1'b0;
                    r_memrstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_LHU     : begin // 6'd37
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b1;
                r_regwrite      = 1'b1;
                r_load_unsigned = 1'b1;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt == 1'b1) begin
                    r_memread   = 1'b1;
                    r_memrstrb  = STRB_BIT'(3);
                end
                else begin
                    r_memread   = 1'b0;
                    r_memrstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_SB      : begin // 6'd40
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memwrite  = 1'b1;
                    r_memwstrb  = STRB_BIT'(1);
                end
                else begin
                    r_memwrite  = 1'b0;
                    r_memwstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_SH      : begin // 6'd41
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memwrite  = 1'b1;
                    r_memwstrb  = STRB_BIT'(3);
                end
                else begin
                    r_memwrite  = 1'b0;
                    r_memwstrb  = {STRB_BIT{1'b0}};
                end
            end
            `OP_SW      : begin // 6'd43
                r_regdst        = 1'b0;
                r_alusrc        = 1'b1;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_branch        = `BRANCH_NONE;
                r_aluop         = `ALUOP_ADD;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b1;
                if (i_arbiter_gnt) begin
                    r_memwrite  = 1'b1;
                    r_memwstrb  = {STRB_BIT{1'b1}};
                end
                else begin
                    r_memwrite  = 1'b0;
                    r_memwstrb  = {STRB_BIT{1'b0}};
                end
            end
            default  : begin
                r_regdst        = 1'b0;
                r_alusrc        = 1'b0;
                r_memtoreg      = 1'b0;
                r_regwrite      = 1'b0;
                r_memread       = 1'b0;
                r_memrstrb      = {STRB_BIT{1'b0}};
                r_load_unsigned = 1'b0;
                r_memwrite      = 1'b0;
                r_memwstrb      = {STRB_BIT{1'b0}};
                r_branch        = `BRANCH_NONE;
                r_aluop         = 3'b000;
                r_jump          = `JUMP_NONE;
                r_sign_extend   = 1'b1;
                r_arbiter_req   = 1'b0;
            end
        endcase
    end

    assign o_regdst         = r_regdst;
    assign o_alusrc         = r_alusrc;
    assign o_memtoreg       = r_memtoreg;
    assign o_regwrite       = r_regwrite;
    assign o_memread        = r_memread;
    assign o_memrstrb       = r_memrstrb;
    assign o_load_unsigned  = r_load_unsigned;
    assign o_memwrite       = r_memwrite;
    assign o_memwstrb       = r_memwstrb;
    assign o_branch         = r_branch;
    assign o_aluop          = r_aluop;
    assign o_jump           = r_jump;
    assign o_sign_extend    = r_sign_extend;
    assign o_arbiter_req    = r_arbiter_req; 

endmodule
