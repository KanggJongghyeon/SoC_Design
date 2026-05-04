`timescale 1ns / 1ps
`include "../sfr_table.svh"
module clk_sfr_ctrl #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input  wire                  clk,
    input  wire                  rst_n,
    output wire [ADDR_BIT - 1:0] o_addr,  // => DATA_MEM
    output wire                  o_en,
    output wire                  o_wren,
    input  wire [DATA_BIT - 1:0] i_data,  // => DATA_MEM
    output wire [DATA_BIT - 1:0] o_data,  // => DATA_MEM
    output wire                  o_req,   // => Arbiter
    input  wire                  i_gnt,   // => Arbiter
    output wire [2:0]            o_clk_en // => cmu
    );
    
    reg [ADDR_BIT - 1:0] r_addr;
    reg [DATA_BIT - 1:0] r_data;
    reg [2:0]            r_clk_en;
    reg [2:0]            r_rd_seq;
    reg                  r_en;
    reg                  r_wren;
    
    reg [2:0]            x_state, state;
    localparam           IDLE = 3'b000, RD_APB = 3'b001, RD_AHB = 3'b011, RD_AXI = 3'b010, WR_SFR = 3'b110, WR_WAIT = 3'b111, RD_WAIT = 3'b101;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            x_state <= IDLE;
        end
        else begin
            x_state <= state;
        end
    end

    always @ (*) begin
        if (~rst_n) begin
            state    = IDLE;
            r_addr   = {ADDR_BIT{1'b0}};
            r_en     = 1'b0;
            r_wren   = 1'b0;
            r_data   = {DATA_BIT{1'b0}};
            r_clk_en = 3'b000;
            r_rd_seq = 3'b000;
        end
        else begin
            case (x_state)
                IDLE    : begin
                    r_wren   = 1'b0;
                    r_data   = {DATA_BIT{1'b0}};
                    r_clk_en = 3'b000;
                    r_rd_seq = 3'b000;
                    if (i_gnt == 1'b1) begin
                        state    = RD_APB;
                        r_addr   = `PCLK_ADDR;
                        r_en     = 1'b1;
                    end
                    else begin
                        state    = IDLE;
                        r_addr   = {ADDR_BIT{1'b0}};
                        r_en     = 1'b0;
                    end
                end
                RD_APB  : begin
                    r_clk_en[2:1] = r_clk_en[2:1];
                    r_rd_seq      = 3'b001;
                    if ((i_gnt == 1'b1) && (i_data[16] == 1'b1)) begin
                        state                  = WR_SFR;
                        r_addr                 = `AMBA_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b1;
                        r_data[DATA_BIT - 1:3] = {(DATA_BIT - 3){1'b0}};
                        r_data[2:0]            = r_clk_en;
                        r_clk_en[0]            = 1'b1;
                    end
                    else if ((i_gnt == 1'b0) && (i_data[16] == 1'b1)) begin
                        state                  = WR_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[0]            = 1'b1;
                    end
                    else if ((i_gnt == 1'b1) && (i_data[16] != 1'b1)) begin
                        state                  = RD_AHB;
                        r_addr                 = `HCLK_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[0]            = 1'b0;
                    end
                    else begin
                        state                  = RD_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[0]            = 1'b0;
                    end
                end
                WR_WAIT : begin
                    r_clk_en = r_clk_en;
                    r_rd_seq = r_rd_seq;
                    if (i_gnt == 1'b1) begin
                        state                  = WR_SFR;
                        r_addr                 = `AMBA_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b1;
                        r_data[DATA_BIT - 1:3] = {(DATA_BIT - 3){1'b0}};
                        r_data[2:0]            = r_clk_en;
                    end
                    else begin
                        state                  = WR_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                    end
                end
                RD_WAIT : begin
                    r_clk_en = r_clk_en;
                    r_rd_seq = r_rd_seq;
                    if (i_gnt == 1'b1) begin
                        r_en   = 1'b1;
                        r_wren = 1'b0;
                        r_data = {DATA_BIT{1'b0}};
                        case (r_rd_seq)
                            3'b001  : begin
                                state  = RD_AHB;
                                r_addr = `HCLK_ADDR;
                            end
                            3'b010  : begin
                                state  = RD_AXI;
                                r_addr = `ACLK_ADDR;
                            end
                            3'b100  : begin
                                state  = RD_APB;
                                r_addr = `PCLK_ADDR;
                            end
                            default : begin
                                state  = RD_APB;
                                r_addr = `PCLK_ADDR;
                            end
                        endcase
                    end
                    else begin
                        state                  = RD_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[0]            = 1'b0;
                    end
                end
                RD_AHB  : begin
                    r_clk_en[2] = r_clk_en[2];
                    r_clk_en[0] = r_clk_en[0];
                    r_rd_seq    = 3'b010;
                    if ((i_gnt == 1'b1) && (i_data[16] == 1'b1)) begin
                        state                  = WR_SFR;
                        r_addr                 = `AMBA_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b1;
                        r_data[DATA_BIT - 1:3] = {(DATA_BIT - 3){1'b0}};
                        r_data[2:0]            = r_clk_en;
                        r_clk_en[1]            = 1'b1;
                    end
                    else if ((i_gnt == 1'b0) && (i_data[16] == 1'b1)) begin
                        state                  = WR_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[1]            = 1'b1;
                    end
                    else if ((i_gnt == 1'b1) && (i_data[16] != 1'b1)) begin
                        state                  = RD_AXI;
                        r_addr                 = `ACLK_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[1]            = 1'b0;
                    end
                    else begin
                        state                  = RD_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[1]            = 1'b0;
                    end
                end
                RD_AXI  : begin
                    r_clk_en[1:0] = r_clk_en[1:0];
                    r_rd_seq    = 3'b100;
                    if ((i_gnt == 1'b1) && (i_data[16] == 1'b1)) begin
                        state                  = WR_SFR;
                        r_addr                 = `AMBA_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b1;
                        r_data[DATA_BIT - 1:3] = {(DATA_BIT - 3){1'b0}};
                        r_data[2:0]            = r_clk_en;
                        r_clk_en[2]            = 1'b1;
                    end
                    else if ((i_gnt == 1'b0) && (i_data[16] == 1'b1)) begin
                        state                  = WR_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[2]            = 1'b1;
                    end
                    else if ((i_gnt == 1'b1) && (i_data[16] != 1'b1)) begin
                        state                  = RD_APB;
                        r_addr                 = `PCLK_ADDR;
                        r_en                   = 1'b1;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[2]            = 1'b0;
                    end
                    else begin
                        state                  = RD_WAIT;
                        r_addr                 = {ADDR_BIT{1'b0}};
                        r_en                   = 1'b0;
                        r_wren                 = 1'b0;
                        r_data                 = {DATA_BIT{1'b0}};
                        r_clk_en[2]            = 1'b0;
                    end               
                end
                WR_SFR  : begin
                    r_data   = {DATA_BIT{1'b0}};
                    r_clk_en = r_clk_en;
                    r_rd_seq = r_rd_seq;
                    if (i_gnt == 1'b1) begin
                        r_en   = 1'b1;
                        r_wren = 1'b0;
                        case (r_rd_seq)
                            3'b001  : begin
                                state  = RD_AHB;
                                r_addr = `HCLK_ADDR;
                            end
                            3'b010  : begin
                                state  = RD_AXI;
                                r_addr = `ACLK_ADDR;
                            end
                            3'b100  : begin
                                state  = RD_APB;
                                r_addr = `PCLK_ADDR;
                            end
                            default : begin
                                state  = RD_APB;
                                r_addr = `PCLK_ADDR;
                            end
                        endcase
                    end
                    else begin
                        state  = RD_WAIT;
                        r_addr = {ADDR_BIT{1'b0}};
                        r_en   = 1'b0;
                        r_wren = 1'b0;
                    end
                end
                default : begin
                    state    = IDLE;
                    r_addr   = {ADDR_BIT{1'b0}};
                    r_en     = 1'b0;
                    r_wren   = 1'b0;
                    r_data   = {DATA_BIT{1'b0}};
                    r_clk_en = 3'b000;
                    r_rd_seq = 3'b000;
                end
            endcase
        end
    end

    assign o_addr   = r_addr;
    assign o_en     = r_en;
    assign o_wren   = r_wren;
    assign o_data   = r_data;
    assign o_req    = (rst_n == 1'b1) ? 1'b1 : 1'b0;
    assign o_clk_en = r_clk_en;

endmodule
