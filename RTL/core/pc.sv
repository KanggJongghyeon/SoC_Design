`timescale 1ns / 1ps
// Program Counter
module pc #(
    parameter ADDR_BIT = 8
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [ADDR_BIT - 1:0]    i_n_mem_addr,
    output  wire                        o_mem_en,
    output  wire    [ADDR_BIT - 1:0]    o_mem_addr
    );

    localparam S_RESET = 1'b0, S_BOOT = 1'b1;
    reg                     state,      n_state;
    reg                     r_mem_en,   r_n_mem_en;
    reg [ADDR_BIT - 1:0]    r_mem_addr, r_n_mem_addr;
    
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state       <= S_RESET;
            r_mem_en    <= 1'b0;
            r_mem_addr  <= {ADDR_BIT{1'b0}};
        end
        else begin
            state       <= n_state;
            r_mem_en    <= r_n_mem_en;
            r_mem_addr  <= r_n_mem_addr; 
        end
    end

    always @ (*) begin
        if (~rst_n) begin
            n_state     = S_RESET;
            r_n_mem_en  = 1'b0;
            r_n_mem_addr= {ADDR_BIT{1'b0}};
        end
        else begin
            n_state     = S_BOOT;
            r_n_mem_en  = 1'b1;
            case(state)
                S_RESET     : begin
                    r_n_mem_addr= {ADDR_BIT{1'b0}};
                end
                S_BOOT      : begin
                    r_n_mem_addr= i_n_mem_addr;
                end
                default    : begin
                    r_n_mem_addr= r_n_mem_addr;
                end
            endcase
        end
    end

    assign o_mem_en     = r_mem_en;
    assign o_mem_addr   = r_mem_addr;

endmodule
