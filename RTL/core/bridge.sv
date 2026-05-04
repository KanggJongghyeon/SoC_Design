`timescale 1ns / 1ps
//////////////////
// IF-ID Bridge //
//////////////////
module if_id #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [ADDR_BIT - 1:0]    i_pc_add4_addr, // from PC+4 ADDER
    input   wire    [DATA_BIT - 1:0]    i_i_mem_data,   // from I-MEM
    output  wire    [ADDR_BIT - 1:0]    o_pc_add4_addr, // to   ID-EX Bridge
    output  wire    [DATA_BIT - 1:0]    o_i_mem_data    // to   I-Decoder
    );

    reg [ADDR_BIT - 1:0]    r_pc_add4_addr;
    reg [DATA_BIT - 1:0]    r_i_mem_data;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_pc_add4_addr  <= {(ADDR_BIT){1'b0}};
            r_i_mem_data    <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_pc_add4_addr  <= i_pc_add4_addr;
            r_i_mem_data    <= i_i_mem_data;
        end
    end

    assign o_pc_add4_addr   = r_pc_add4_addr;
    assign o_i_mem_data     = r_i_mem_data;

endmodule

//////////////////
// ID-EX Bridge //
//////////////////
module id_ex #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        i_alusrc,       // from Control Unit
    input   wire                        i_memtoreg,     // from Control Unit
    input   wire                        i_memread,      // from Control Unit
    input   wire                        i_memwrite,     // from Control Unit
    input   wire                        i_branch,       // from Control Unit
    input   wire    [2:0]               i_aluop,        // from Control Unit
    input   wire                        i_jump,         // from Control Unit
    input   wire    [ADDR_BIT - 1:0]    i_pc_add4_addr, // from IF-ID Bridge
    input   wire    [5:0]               i_funct,        // from I-Decoder
    input   wire    [DATA_BIT - 1:0]    i_reg_rdata1,   // from Registers
    input   wire    [DATA_BIT - 1:0]    i_reg_rdata2,   // from Registers
    input   wire    [DATA_BIT - 1:0]    i_sign_extend,  // from Sign-Extend Unit
    input   wire    [DATA_BIT - 1:0]    i_jump_addr,    // from I-Decoder
    output  wire                        o_alusrc,       // to   ALUSrc  MUX
    output  wire                        o_memtoreg,     // to   EX-MEM Bridge
    output  wire                        o_memread,      // to   EX-MEM Bridge
    output  wire                        o_memwrite,     // to   EX-MEM Bridge
    output  wire                        o_branch,       // to   be Contorl Input of Branch MUX
    output  wire    [2:0]               o_aluop,        // to   ALU Control
    output  wire                        o_jump,         // to   Jump MUX
    output  wire    [ADDR_BIT - 1:0]    o_pc_add4_addr, // to   ?? Adder
    output  wire    [5:0]               o_funct,        // to   ALU Control
    output  wire    [DATA_BIT - 1:0]    o_reg_rdata1,   // to   ALU
    output  wire    [DATA_BIT - 1:0]    o_reg_rdata2,   // to   ALUSrc  MUX & ex_mem
    output  wire    [DATA_BIT - 1:0]    o_sign_extend,  // to   ALUSrc  MUX & Branch ShiftLef2
    output  wire    [DATA_BIT - 1:0]    o_jump_addr     // to   EX-MEM Brdige or Jump    Mux 
    );
    
    reg [2:0]               r_aluop;
    reg                     r_alusrc,       r_memtoreg;
    reg                     r_memread,      r_memwrite;     
    reg                     r_branch,       r_jump;
    reg [ADDR_BIT - 1:0]    r_pc_add4_addr;
    reg [5:0]               r_funct;
    reg [DATA_BIT - 1:0]    r_reg_rdata1,   r_reg_rdata2;
    reg [DATA_BIT - 1:0]    r_sign_extend;
    reg [DATA_BIT - 1:0]    r_jump_addr;

        always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_alusrc        <= 1'b0;
            r_memtoreg      <= 1'b0;
            r_memread       <= 1'b0;
            r_memwrite      <= 1'b0;
            r_branch        <= 1'b0;
            r_aluop         <= 3'b000;
            r_jump          <= 1'b0;
            r_pc_add4_addr  <= {(ADDR_BIT){1'b0}};
            r_funct         <= 6'b000000;
            r_reg_rdata1    <= {(DATA_BIT){1'b0}};
            r_reg_rdata2    <= {(DATA_BIT){1'b0}};
            r_sign_extend   <= {(DATA_BIT){1'b0}};
            r_jump_addr     <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_alusrc        <= i_alusrc;
            r_memtoreg      <= i_memtoreg;
            r_memread       <= i_memread;
            r_memwrite      <= i_memwrite;
            r_branch        <= i_branch;
            r_aluop         <= i_aluop;
            r_jump          <= i_jump;
            r_pc_add4_addr  <= i_pc_add4_addr;
            r_funct         <= i_funct;
            r_reg_rdata1    <= i_reg_rdata1;
            r_reg_rdata2    <= i_reg_rdata2;
            r_sign_extend   <= i_sign_extend;
            r_jump_addr     <= i_jump_addr;
        end
    end

    assign o_alusrc         = r_alusrc;
    assign o_memtoreg       = r_memtoreg;
    assign o_memread        = r_memread;
    assign o_memwrite       = r_memwrite;
    assign o_branch         = r_branch;
    assign o_aluop          = r_aluop;
    assign o_jump           = r_jump;
    assign o_pc_add4_addr   = r_pc_add4_addr;
    assign o_funct          = r_funct;
    assign o_reg_rdata1     = r_reg_rdata1;
    assign o_reg_rdata2     = r_reg_rdata2;
    assign o_sign_extend    = r_sign_extend;
    assign o_jump_addr      = r_jump_addr;

endmodule

///////////////////
// EX-MEM Bridge //
///////////////////
module ex_mem #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 16
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        i_memtoreg,     // from ID-EX Bridge
    input   wire                        i_memread,      // from ID-EX Bridge
    input   wire                        i_memwrite,     // from ID-EX Bridge
    input   wire    [DATA_BIT - 1:0]    i_alu_out,      // from ALU
    input   wire    [DATA_BIT - 1:0]    i_reg_rdata2,   // from Registers
    output  wire                        o_memtoreg,     // to   MEM_WB Bridge
    output  wire                        o_memread,      // to   be D-MEM Read  Enable
    output  wire                        o_memwrite,     // to   be D-MEM Write Enable
    output  wire    [DATA_BIT - 1:0]    o_alu_out,      // to D-MEM
    output  wire    [DATA_BIT - 1:0]    o_reg_rdata2    // to D-MEM
    );

    reg                     r_memtoreg,     r_memread,      r_memwrite;
    reg [DATA_BIT - 1:0]    r_alu_out;
    reg [DATA_BIT - 1:0]    r_reg_rdata2;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_memtoreg      <= 1'b0;
            r_memread       <= 1'b0;
            r_memwrite      <= 1'b0;
            r_alu_out       <= {(DATA_BIT){1'b0}};
            r_reg_rdata2    <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_memtoreg      <= i_memtoreg;
            r_memread       <= i_memread;
            r_memwrite      <= i_memwrite;
            r_alu_out       <= i_alu_out;
            r_reg_rdata2    <= i_reg_rdata2;
        end
    end

    assign o_memtoreg       = r_memtoreg;
    assign o_memread        = r_memread;
    assign o_memwrite       = r_memwrite;
    assign o_alu_out        = r_alu_out;
    assign o_reg_rdata2     = r_reg_rdata2;

endmodule

///////////////////
// MEM-WB Bridge //
///////////////////
module mem_wb #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        i_memtoreg,     // form EX-MEM Bridge
    //input   wire    [DATA_BIT - 1:0]    i_d_mem_rdata,  // from D-MEM
    input   wire    [DATA_BIT - 1:0]    i_alu_out,      // from ALU
    output  wire                        o_memtoreg,     // to   MemtoReg MUX Control Input
    //output  wire    [DATA_BIT - 1:0]    o_d_mem_rdata,  // to   MemtoReg MUX Input (1)
    output  wire    [DATA_BIT - 1:0]    o_alu_out       // to   MemtoReg MUX Input (0)
    );

    reg                     r_memtoreg;
    reg [DATA_BIT - 1:0]    /*r_d_mem_rdata,*/  r_alu_out;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_memtoreg      <= 1'b0;
            //r_d_mem_rdata   <= {(DATA_BIT){1'b0}};
            r_alu_out       <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_memtoreg      <= i_memtoreg;
            //r_d_mem_rdata   <= i_d_mem_rdata;
            r_alu_out       <= i_alu_out;
        end
    end

    assign o_memtoreg       = r_memtoreg;
    //assign o_d_mem_rdata    = r_d_mem_rdata;
    assign o_alu_out        = r_alu_out;

endmodule
