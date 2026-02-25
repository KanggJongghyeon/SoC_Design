`timescale 1ns / 1ps
module async_fifo #(
    parameter DATA_SIZE = 32,
    parameter FIFO_SIZE = 32
    )(
    input  wire                   push_clk,
    input  wire                   push_rst_n,
    input  wire                   pop_clk,
    input  wire                   pop_rst_n,
    input  wire                   i_pushen,
    input  wire                   i_popen,
    input  wire [DATA_SIZE - 1:0] i_pushdata,
    output wire [DATA_SIZE - 1:0] o_popdata,
    output wire                   o_empty,
    output wire                   o_full
    );

    reg  [DATA_SIZE - 1:0] r_popdata;
    reg                    r_empty, r_full;

    localparam PTR_SIZE = $clog2(FIFO_SIZE) + 1;
    reg  [PTR_SIZE - 1:0]  r_wptr_b, r_wptr_g_cdc_e, r_wptr_g_cdc_f;
    reg  [PTR_SIZE - 1:0]  r_rptr_b, r_rptr_g_cdc_e, r_rptr_g_cdc_f;
    wire [PTR_SIZE - 1:0]  w_wptr_g, w_rptr_g;

    reg [DATA_SIZE - 1:0]  fifo [0:FIFO_SIZE - 1];
    
    always @ (posedge push_clk or negedge push_rst_n) begin
        if (~push_rst_n) begin
            r_wptr_b <= {PRT_SIZE{1'b0}};
        end
        else begin
            if (i_pushen) begin
                r_wptr_b <= r_wptr_b + {{(PRT_SIZE - 1){1'b0}}, 1'b1};
            end
        end
    end

    always @ (posedge pop_clk or negedge pop_rst_n) begin
        if (~pop_rst_n) begin
            r_rptr_b <= {PRT_SIZE{1'b0}};
        end
        else begin
            if (i_popen) begin
                r_rptr_b <= r_rptr_b + {{(PRT_SIZE - 1){1'b0}}, 1'b1};
            end
        end
    end

    genvar w, r;

    assign w_wptr_g[PTR_SIZE - 1] = r_wptr_b[PTR_SIZE - 1];
    
    generate
        for (w = PTR_SIZE - 2; w > 0; w = w - 1) begin
            assign w_wptr_g[w] = r_wptr_b[w + 1] ^ r_wptr_b[w];
        end
    endgenerate

    generate
        for (r = PTR_SIZE - 2; r > 0; r = r - 1) begin
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
                fifo[i] = {DATA_SIZE{1'b0}};
            end
        end
        else begin
            if (i_pushen) begin
                fifo[r_wptr_b] <= i_pushdata;
            end
        end
    end

    always @ (posdege pop_clk or negedge pop_rst_n) begin
        if (~pop_rst_n) begin
            r_popdata <= {DATA_SIZE{1'b0}};
        end
        else begin
            if (i_popen) begin
                r_popdata <= fifo[r_rptr_b];
                fifo[r_rptr_b] <= {DATA_SIZE{1'b0}};
            end
        end
    end

    assign o_popdata = r_popdata;
    assign o_empty   = (r_wptr_g_cdc_e == r_rptr_g_cdc_e);
    assign o_full    = ((r_wptr_g_cdc_f[PTR_SIZE - 1] != r_rptr_g_cdc_f[PTR_SIZE - 1]) && (r_wptr_g_cdc_f[PTR_SIZE - 2] != r_rptr_g_cdc_f[PTR_SIZE - 2]) && (r_wptr_g_cdc_f[PTR_SIZE - 3:0] == r_rptr_g_cdc_f[PTR_SIZE - 3:0]));

endmodule
