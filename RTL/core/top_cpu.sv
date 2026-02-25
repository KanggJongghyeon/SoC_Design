`timescale 1ns / 1ps
module top_cpu #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  i_start_flag, // tb flag signal
    input  wire [DATA_BIT - 1:0] i_mem_data [0:1],
    output wire                  o_mem_en   [0:1],
    output wire                  o_mem_wren [0:1],
    output wire [ADDR_BIT - 1:0] o_mem_addr [0:1],
    output wire [DATA_BIT - 1:0] o_data_mem_data,
    output wire                  o_arbiter_req,
    input  wire                  i_arbiter_gnt
    );

    wire [ADDR_BIT - 1:0] w_inst_mem_addr;
    wire                  w_inst_mem_wren, w_inst_mem_en;

    pc #(
        .ADDR_BIT (ADDR_BIT) 
    ) u_pc (
        .clk          (clk),
.rst_n        (rst_n),
        .i_start_flag (i_start_flag),
        .o_mem_en     (w_inst_mem_en),
        .o_mem_wren   (w_inst_mem_wren),
        .o_mem_addr   (w_inst_mem_addr)
    );
    
    localparam OPCODE_BIT = (DATA_BIT == 32) ? 6 : 4;
    localparam REG_BIT    = (DATA_BIT == 32) ? 5 : 2;
    
    wire [OPCODE_BIT - 1:0]              w_inst_opcode;
    wire [REG_BIT    - 1:0]              w_inst_rs,    w_inst_rt,    w_inst_rd;
    wire [4:0]                           w_inst_shamt;
    wire [5:0]                           w_inst_funct;
    wire [(DATA_BIT / 2) - 1:0]          w_inst_const;
    wire [(DATA_BIT - OPCODE_BIT) - 1:0] w_inst_jaddr;

    inst_decoder #(
        .DATA_BIT   (DATA_BIT),
        .OPCODE_BIT (OPCODE_BIT),
        .REG_BIT    (REG_BIT)
    ) u_inst_decoder (
        .i_data     (i_mem_data[0]),
        .o_opcode   (w_inst_opcode),
        .o_rs       (w_inst_rs),
        .o_rt       (w_inst_rt),
        .o_rd       (w_inst_rd),
        .o_shamt    (w_inst_shamt),
        .o_funct    (w_inst_funct),
        .o_const    (w_inst_const),
        .o_jaddr    (w_inst_jaddr)
    );

    wire [3:0] w_aluopb;
    wire [1:0] w_aluopa;
    wire       w_regdst, w_alusrc, w_memtoreg, w_regwrite, w_memread, w_memwrite, w_branch, w_sign_extend;

    ctr_unit #(
        .DATA_BIT   (DATA_BIT),
        .OPCODE_BIT (OPCODE_BIT)
    ) u_control_unit (
        .i_opcode      (w_inst_opcode),
        .o_regdst      (w_regdst),
        .o_alusrc      (w_alusrc),
        .o_memtoreg    (w_memtoreg),
        .o_regwrite    (w_regwrite),
        .o_memread     (w_memread),
        .o_memwrite    (w_memwrite),
        .o_branch      (w_branch),
        .o_aluopa      (w_aluopa),
        .o_aluopb      (w_aluopb),
        .o_sign_extend (w_sign_extend),
        .o_arbiter_req (o_arbiter_req),
        .i_arbiter_gnt (i_arbiter_gnt)
    );

    wire [3:0] w_alu_ctr;

    alu_ctr #(
        .DATA_BIT (DATA_BIT)
    ) u_alu_control (
        .i_funct  (w_inst_funct),
        .i_aluopa (w_aluopa),
        .i_aluopb (w_aluopb),
        .o_aluop  (w_alu_ctr)
    );

    wire [DATA_BIT - 1:0] w_sign_extend_const;

    sign_extend #(
        .DATA_BIT (DATA_BIT)
    ) u_sing_extend (
        .i_sign_extend (w_sign_extend),
        .i_const       (w_inst_const),
        .o_const       (w_sign_extend_const)
    );

    wire [REG_BIT - 1:0] w_regdst_wr_reg;

    mux21 #(
        .DATA_BIT (REG_BIT)
    ) u_regdst_mux (
        .i_ctr    (w_regdst),
        .i_i0     (w_inst_rt),
        .i_i1     (w_inst_rd),
        .o_o      (w_regdst_wr_reg)
    );

    wire [DATA_BIT - 1:0] w_reg_rd_data1, w_reg_rd_data2, w_memtoreg_wr_data;

    registers #(
        .DATA_BIT   (DATA_BIT),
        .REG_BIT    (REG_BIT)
    ) u_registers (
        .clk        (clk),
        .rst_n      (rst_n),
        .i_regwrite (w_regwrite),
        .i_rd_reg1  (w_inst_rs),
        .i_rd_reg2  (w_inst_rt),
        .i_wr_reg   (w_regdst_wr_reg),
        .i_wr_data  (w_memtoreg_wr_data),
        .o_rd_data1 (w_reg_rd_data1),
        .o_rd_data2 (w_reg_rd_data2)
    );

    wire [DATA_BIT - 1:0] w_alusrc_alu_i_in1;

    mux21 #(
        .DATA_BIT (DATA_BIT)
    ) u_alusrc_mux (
        .i_ctr    (w_alusrc),
        .i_i0     (w_reg_rd_data2),
        .i_i1     (w_sign_extend_const),
        .o_o      (w_alusrc_alu_i_in1)
    );

    wire [DATA_BIT - 1:0] w_alu_out;
    wire                  w_alu_carry_out, w_alu_zero;

    alu #(
        .DATA_BIT (DATA_BIT)
    ) u_alu (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_in0    (w_reg_rd_data1),
        .i_in1    (w_alusrc_alu_i_in1),
        .i_carry  (1'b0),
        .i_aluop  (w_alu_ctr),
        .o_out    (w_alu_out),
        .o_carry  (w_alu_carry_out),
        .o_zero   (w_alu_zero)
    );

    mux21 #(
        .DATA_BIT (DATA_BIT)
    ) u_memtoreg_mux (
        .i_ctr    (w_memtoreg),
        .i_i0     (w_alu_out),
        .i_i1     (i_mem_data[1]),
        .o_o      (w_memtoreg_wr_data)
    );

    assign o_mem_en[0]     = w_inst_mem_en;
    assign o_mem_en[1]     = w_memwrite | w_memread;
    assign o_mem_wren[0]   = w_inst_mem_wren;
    assign o_mem_wren[1]   = w_memwrite;
    assign o_mem_addr[0]   = w_inst_mem_addr;
    assign o_mem_addr[1]   = w_alu_out[ADDR_BIT - 1:0];
    assign o_data_mem_data = w_reg_rd_data2;

endmodule
