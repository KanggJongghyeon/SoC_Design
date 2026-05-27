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
    input   wire                        i_flush,
    input   wire                        i_stall,
    input   wire    [DATA_BIT - 1:0]    i_i_mem_data,   
    input   wire    [ADDR_BIT - 1:0]    i_pc_addr, 
    output  wire    [DATA_BIT - 1:0]    o_i_mem_data,   
    output  wire    [ADDR_BIT - 1:0]    o_pc_addr  
    );

    reg [DATA_BIT - 1:0]    r_i_mem_data;
    reg [ADDR_BIT - 1:0]    r_pc_addr;
    reg                     r_flushing;                     // for 2-Cycle IF Flush
    reg                     r_wait_1c_n,    r_wait_2c_n;    // for 2-Cycle Waiting

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_pc_addr       <= {(ADDR_BIT){1'b0}};
            r_i_mem_data    <= {(DATA_BIT){1'b0}};
        end
        else begin
            if (~r_wait_2c_n) begin
                r_pc_addr       <= i_pc_addr;
                if (i_flush | r_flushing) begin
                    r_i_mem_data<= {(DATA_BIT){1'b0}};
                end
                else if (~i_stall) begin      
                    r_i_mem_data<= i_i_mem_data;
                end
            end
            else begin
                r_pc_addr       <= {(ADDR_BIT){1'b0}};
                r_i_mem_data    <= {(DATA_BIT){1'b0}};
            end
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_flushing  <= 1'b0;
        end
        else begin
            if (i_flush == 1'b1) begin
                r_flushing  <= 1'b1;
            end
            else begin
                r_flushing  <= 1'b0;
            end
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_wait_1c_n <= 1'b1;
            r_wait_2c_n <= 1'b1;
        end
        else begin
            r_wait_1c_n <= 1'b0;
            r_wait_2c_n <= r_wait_1c_n;
        end
    end

    assign o_pc_addr        = r_pc_addr;
    assign o_i_mem_data     = r_i_mem_data;

endmodule

//////////////////
// ID-EX Bridge //
//////////////////
module id_ex #(
    parameter REG_BIT   = 4,
    parameter ADDR_BIT  = 8,
    parameter DATA_BIT  = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        i_flush,
    input   wire    [ADDR_BIT - 1:0]    i_pc_addr, 
    input   wire    [REG_BIT - 1:0]     i_rs,           
    input   wire    [REG_BIT - 1:0]     i_rt,           
    input   wire    [REG_BIT - 1:0]     i_rd,           
    input   wire    [5:0]               i_funct,        
    input   wire    [DATA_BIT - 1:0]    i_jump_addr,    
    input   wire                        i_regdst,       
    input   wire                        i_alusrc,       
    input   wire                        i_memtoreg,     
    input   wire                        i_regwrite,     
    input   wire                        i_memread,      
    input   wire                        i_memwrite,     
    input   wire    [1:0]               i_branch,       
    input   wire    [2:0]               i_aluop,        
    input   wire                        i_jump,         
    input   wire    [DATA_BIT - 1:0]    i_reg_rdata1,   
    input   wire    [DATA_BIT - 1:0]    i_reg_rdata2,   
    input   wire    [DATA_BIT - 1:0]    i_sign_extend,  
    output  wire    [1:0]               o_branch,       
    output  wire                        o_jump,         
    output  wire    [DATA_BIT - 1:0]    o_jump_addr,    
    output  wire    [2:0]               o_aluop,        
    output  wire    [5:0]               o_funct,        
    output  wire                        o_alusrc,       
    output  wire    [DATA_BIT - 1:0]    o_reg_rdata1,   
    output  wire    [DATA_BIT - 1:0]    o_reg_rdata2,   
    output  wire    [DATA_BIT - 1:0]    o_sign_extend,  
    output  wire    [ADDR_BIT - 1:0]    o_pc_addr, 
    output  wire    [REG_BIT - 1:0]     o_rs,           
    output  wire    [REG_BIT - 1:0]     o_rt,           
    output  wire    [REG_BIT - 1:0]     o_rd,   
    output  wire                        o_regdst,       
    output  wire                        o_memtoreg,     
    output  wire                        o_regwrite,     
    output  wire                        o_memread,      
    output  wire                        o_memwrite      
    );
   
    reg [REG_BIT - 1:0]     r_rs,           r_rt,       r_rd;
    reg [2:0]               r_aluop,        r_jump;;
    reg                     r_regdst,       r_regwrite;
    reg                     r_alusrc,       r_memtoreg;
    reg                     r_memread,      r_memwrite;     
    reg [1:0]               r_branch;      
    reg [ADDR_BIT - 1:0]    r_pc_addr;
    reg [5:0]               r_funct;
    reg [DATA_BIT - 1:0]    r_reg_rdata1,   r_reg_rdata2;
    reg [DATA_BIT - 1:0]    r_sign_extend;
    reg [DATA_BIT - 1:0]    r_jump_addr;

        always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_rs            <= {REG_BIT{1'b0}};
            r_rt            <= {REG_BIT{1'b0}};
            r_rd            <= {REG_BIT{1'b0}};
            r_regdst        <= 1'b0;
            r_alusrc        <= 1'b0;
            r_memtoreg      <= 1'b0;
            r_regwrite      <= 1'b0;
            r_memread       <= 1'b0;
            r_memwrite      <= 1'b0;
            r_branch        <= 2'b00;
            r_aluop         <= 3'b000;
            r_jump          <= 1'b0;
            r_pc_addr       <= {(ADDR_BIT){1'b0}};
            r_funct         <= 6'b000000;
            r_reg_rdata1    <= {(DATA_BIT){1'b0}};
            r_reg_rdata2    <= {(DATA_BIT){1'b0}};
            r_sign_extend   <= {(DATA_BIT){1'b0}};
            r_jump_addr     <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_rs            <= i_rs;
            r_rt            <= i_rt;
            r_rd            <= i_rd;
            r_regdst        <= i_regdst;
            r_alusrc        <= i_alusrc;
            r_memtoreg      <= i_memtoreg;
            r_memread       <= i_memread;
            r_aluop         <= i_aluop;
            r_pc_addr       <= i_pc_addr;
            r_funct         <= i_funct;
            r_reg_rdata1    <= i_reg_rdata1;
            r_reg_rdata2    <= i_reg_rdata2;
            r_sign_extend   <= i_sign_extend;
            r_jump_addr     <= i_jump_addr;
            if (i_flush == 1'b1) begin
                r_regwrite  <= 1'b0;
                r_memwrite  <= 1'b0;
                r_branch    <= 2'b00;
                r_jump      <= 1'b0;
            end
            else begin
                r_regwrite  <= i_regwrite;
                r_memwrite  <= i_memwrite;
                r_branch    <= i_branch;
                r_jump      <= i_jump;
            end
        end
    end

    assign o_rs             = r_rs;
    assign o_rt             = r_rt;
    assign o_rd             = r_rd;
    assign o_regdst         = r_regdst;
    assign o_alusrc         = r_alusrc;
    assign o_memtoreg       = r_memtoreg;
    assign o_regwrite       = r_regwrite;
    assign o_memread        = r_memread;
    assign o_memwrite       = r_memwrite;
    assign o_branch         = r_branch;
    assign o_aluop          = r_aluop;
    assign o_jump           = r_jump;
    assign o_pc_addr        = r_pc_addr;
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
    parameter REG_BIT   = 4,
    parameter ADDR_BIT  = 8,
    parameter DATA_BIT  = 16
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [REG_BIT - 1:0]     i_rt,           
    input   wire    [REG_BIT - 1:0]     i_wr_reg,
    input   wire                        i_memtoreg,     
    input   wire                        i_regwrite,     
    input   wire                        i_memread,      
    input   wire                        i_memwrite,     
    input   wire    [DATA_BIT - 1:0]    i_reg_rdata2,   
    input   wire    [DATA_BIT - 1:0]    i_alu_out,  
    input   wire                        i_fw_ctr_wdata_2c,
    input   wire    [DATA_BIT - 1:0]    i_wdata_fw_mux_data,
    output  wire    [REG_BIT - 1:0]     o_rt,           
    output  wire    [REG_BIT - 1:0]     o_wr_reg,
    output  wire                        o_memtoreg,     
    output  wire                        o_regwrite,     
    output  wire                        o_memread,      
    output  wire                        o_memwrite,     
    output  wire    [DATA_BIT - 1:0]    o_alu_out,      
    output  wire    [DATA_BIT - 1:0]    o_reg_rdata2,
    output  wire                        o_fw_ctr_wdata_2c,
    output  wire    [DATA_BIT - 1:0]    o_wdata_fw_mux_data
    );

    reg [REG_BIT - 1:0]     r_rt;
    reg [REG_BIT - 1:0]     r_wr_reg;
    reg                     r_memtoreg,     r_regwrite;
    reg                     r_memread,      r_memwrite;
    reg [DATA_BIT - 1:0]    r_alu_out;
    reg [DATA_BIT - 1:0]    r_reg_rdata2;
    reg                     r_fw_ctr_wdata_2c;
    reg [DATA_BIT - 1:0]    r_wdata_fw_mux_data;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_rt                <= {REG_BIT{1'b0}};
            r_wr_reg            <= {REG_BIT{1'b0}};
            r_memtoreg          <= 1'b0;
            r_regwrite          <= 1'b0;
            r_memread           <= 1'b0;
            r_memwrite          <= 1'b0;
            r_alu_out           <= {(DATA_BIT){1'b0}};
            r_reg_rdata2        <= {(DATA_BIT){1'b0}};
            r_fw_ctr_wdata_2c   <= 1'b0;
            r_wdata_fw_mux_data <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_rt                <= i_rt;
            r_wr_reg            <= i_wr_reg;
            r_memtoreg          <= i_memtoreg;
            r_regwrite          <= i_regwrite;
            r_memread           <= i_memread;
            r_memwrite          <= i_memwrite;
            r_alu_out           <= i_alu_out;
            r_reg_rdata2        <= i_reg_rdata2;
            r_fw_ctr_wdata_2c   <= i_fw_ctr_wdata_2c;
            r_wdata_fw_mux_data <= i_wdata_fw_mux_data;
        end
    end

    assign o_rt                 = r_rt;
    assign o_wr_reg             = r_wr_reg;
    assign o_memtoreg           = r_memtoreg;
    assign o_regwrite           = r_regwrite;
    assign o_memread            = r_memread;
    assign o_memwrite           = r_memwrite;
    assign o_alu_out            = r_alu_out;
    assign o_reg_rdata2         = r_reg_rdata2;
    assign o_fw_ctr_wdata_2c    = r_fw_ctr_wdata_2c;
    assign o_wdata_fw_mux_data  = r_wdata_fw_mux_data;

endmodule

///////////////////
// MEM-WB Bridge //
///////////////////
module mem_wb #(
    parameter REG_BIT   = 4,
    parameter ADDR_BIT  = 8,
    parameter DATA_BIT  = 32
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [REG_BIT - 1:0]     i_wr_reg,
    input   wire                        i_memtoreg,     
    input   wire                        i_regwrite,     
    input   wire    [DATA_BIT - 1:0]    i_alu_out,      
    output  wire    [REG_BIT - 1:0]     o_wr_reg,           
    output  wire                        o_memtoreg,     
    output  wire                        o_regwrite,     
    output  wire    [DATA_BIT - 1:0]    o_alu_out       
    );
    
    reg [REG_BIT - 1:0]     r_wr_reg;
    reg                     r_memtoreg,     r_regwrite;
    reg [DATA_BIT - 1:0]    r_alu_out;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_wr_reg        <= {REG_BIT{1'b0}};
            r_memtoreg      <= 1'b0;
            r_regwrite      <= 1'b0;
            r_alu_out       <= {(DATA_BIT){1'b0}};
        end
        else begin
            r_wr_reg        <= i_wr_reg;
            r_memtoreg      <= i_memtoreg;
            r_regwrite      <= i_regwrite;
            r_alu_out       <= i_alu_out;
        end
    end

    assign o_wr_reg         = r_wr_reg;
    assign o_memtoreg       = r_memtoreg;
    assign o_regwrite       = r_regwrite;
    assign o_alu_out        = r_alu_out;

endmodule
