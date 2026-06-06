`timescale 1ns / 1ps
module async_fifo #(
    parameter DATA_BIT  = 32,
    parameter FIFO_SIZE = 32
    )(
    input  wire                     push_clk,
    input  wire                     push_rst_n,
    input  wire                     pop_clk,
    input  wire                     pop_rst_n,
    input  wire                     i_pushen,
    input  wire                     i_popen,
    input  wire [DATA_BIT - 1:0]    i_pushdata,
    output wire [DATA_BIT - 1:0]    o_popdata,
    output wire                     o_empty,
    output wire                     o_full
    );

    reg  [DATA_BIT - 1:0] r_popdata;

    localparam PTR_BIT = $clog2(FIFO_SIZE) + 1;
    reg  [PTR_BIT - 1:0]  r_wptr_b, r_wptr_g_cdc_e, r_wptr_g_cdc_f;
    reg  [PTR_BIT - 1:0]  r_rptr_b, r_rptr_g_cdc_e, r_rptr_g_cdc_f;
    wire [PTR_BIT - 1:0]  w_wptr_g, w_rptr_g;

    reg [DATA_BIT - 1:0]  fifo [0:FIFO_SIZE - 1];
    
    always @ (posedge push_clk or negedge push_rst_n) begin
        if (~push_rst_n) begin
            r_wptr_b <= {PTR_BIT{1'b0}};
        end
        else begin
            if (i_pushen) begin
                r_wptr_b <= r_wptr_b + {{(PTR_BIT - 1){1'b0}}, 1'b1};
            end
        end
    end

    always @ (posedge pop_clk or negedge pop_rst_n) begin
        if (~pop_rst_n) begin
            r_rptr_b <= {PTR_BIT{1'b0}};
        end
        else begin
            if (i_popen) begin
                r_rptr_b <= r_rptr_b + {{(PTR_BIT - 1){1'b0}}, 1'b1};
            end
        end
    end

    genvar w, r;

    assign w_wptr_g[PTR_BIT - 1] = r_wptr_b[PTR_BIT - 1];
    
    generate
        for (w = PTR_BIT - 2; w > 0; w = w - 1) begin
            assign w_wptr_g[w] = r_wptr_b[w + 1] ^ r_wptr_b[w];
        end
    endgenerate

    generate
        for (r = PTR_BIT - 2; r > 0; r = r - 1) begin
            assign w_wptr_g[r] = r_wptr_b[r + 1] ^ r_wptr_b[r];
        end
    endgenerate

    always @ (posedge pop_clk or negedge pop_rst_n) begin // CDC for empty situation
        if (~rst_n) begin
            r_wptr_g_cdc_e <= 5'b00000;
            r_rptr_g_cdc_e <= 5'b00000;
        end
        else begin
            r_wptr_g_cdc_e <= w_wptr_g;
            r_rptr_g_cdc_e <= w_rptr_g;
        end
    end

    always @ (posedge push_clk or negedge push_rst_n) begin // CDC for full situation
        if (~rst_n) begin
            r_wptr_g_cdc_f <= 3'b00000;
            r_rptr_g_cdc_f <= 3'b00000;
        end
        else begin
            r_wptr_g_cdc_f <= w_wptr_g;
            r_rptr_g_cdc_f <= w_rptr_g;
        end
    end    

    always @ (posedge push_clk or negedge push_rst_n) begin
        if (~push_rst_n) begin
            for (integer i = 0; i < FIFO_SIZE; i = i + 1) begin
                fifo[i] = {DATA_BIT{1'b0}};
            end
        end
        else begin
            if (i_pushen) begin
                fifo[r_wptr_b] <= i_pushdata;
            end
        end
    end

    always @ (posedge pop_clk or negedge pop_rst_n) begin
        if (~pop_rst_n) begin
            r_popdata <= {DATA_BIT{1'b0}};
        end
        else begin
            if (i_popen) begin
                r_popdata <= fifo[r_rptr_b];
            end
        end
    end
                    
    assign o_popdata= r_popdata;
    assign o_empty  = (r_wptr_g_cdc_e == r_rptr_g_cdc_e);
    assign o_full   = ((r_wptr_g_cdc_f[PTR_BIT - 1] != r_rptr_g_cdc_f[PTR_BIT - 1]) && (r_wptr_g_cdc_f[PTR_BIT - 2] != r_rptr_g_cdc_f[PTR_BIT - 2]) && (r_wptr_g_cdc_f[PTR_BIT - 3:0] == r_rptr_g_cdc_f[PTR_BIT - 3:0]));

endmodule

module sync_fifo #(
    parameter DATA_BIT  = 32,
    parameter FIFO_SIZE = 128
    )(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_pushen,
    input  wire                     i_popen,
    input  wire [DATA_BIT - 1:0]    i_pushdata,
    output wire [DATA_BIT - 1:0]    o_popdata,
    output wire                     o_empty,
    output wire                     o_full
    );

    localparam PTR_BIT = $clog2(FIFO_SIZE) + 1;
    reg [DATA_BIT - 1:0]    fifo    [0:FIFO_SIZE - 1];
    reg [DATA_BIT - 1:0]    r_popdata;
    reg [PTR_BIT - 1:0]     r_wptr, r_rptr;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_wptr  <= {PTR_BIT{1'b0}}; 
            r_rptr  <= {PTR_BIT{1'b0}}; 
        end
        else begin
            if (i_pushen) begin
                r_wptr  <= r_wptr + {(PTR_BIT - 1){1'b0}, 1'b1};
            end
            else if (i_popen) begin
                r_rptr  <= r_rptr + {(PTR_BIT - 1){1'b0}, 1'b1};
            end
        end
    end

    integer fifo_index;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (fifo_index = 0; fifo_index < FIFO_SIZE; fifo_index = fifo_index + 1) begin
                fifo[fifo_index]<= {DATA_BIT{1'b0}};
            end                 
        end
        else begin
            if (i_pushen) begin
                fifo[r_wptr]    <= i_pushdata;
            end
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_popdata   <= {DATA_BIT{1'b0}};
        end
        else begin
            if (i_popen) begin
                r_popdata   <= fifo[r_rptr];
            end
        end
    end

    assign o_popdata= r_popdata;
    assign o_empty  = (r_wptr == r_rptr);
    assign o_full   = (r_wptr[PTR_BIT - 1] != r_rptr[PTR_BIT - 1]) && (r_wptr[PTR_BIT - 2:0] == r_rptr[PTR_BIT - 2:0]);

endmodule

