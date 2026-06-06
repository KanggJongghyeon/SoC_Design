`include "../amba/AMBA.svh"
module cpu_axi_bridge_master #(
    parameter ADDR_BIT  = 32,
    parameter DATA_BIT  = 32,
    parameter FIFO_BIT  = 64    // FIFO DATA SIZE
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    // tx fifo if
    output  wire                        o_tx_popen,
    input   wire    [FIFO_BIT - 1:0]    i_tx_popdata,                
    input   wire                        i_tx_empty,
    // rx fifo if
    output  wire                        o_rx_pushen,
    output  wire    [DATA_BIT - 1:0]    o_rx_pushdata,
    input   wire                        i_rx_full,
    // axi if
    AXI5.MASTER                         AXI
    );

    localparam CPU_ID = 6'b100000;

    reg r_pop_valid;
    reg [5:0]  r_id;
    reg r_tx_cpu_en;
    reg r_tx_cpu_wren;  
    reg [ADDR_BIT - 1:0]    r_tx_cpu_addr;
    reg [DATA_BIT - 1:0]    r_tx_cpu_data;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_pop_valid <= 1'b0;
        end
        else begin
            if (o_tx_popen == 1'b1) begin
                r_pop_valid <= 1'b1;
            end
            else begin
                r_pop_valid <= 1'b0;
            end
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            r_id            <= 6'b000000;
            r_tx_cpu_en     <= 1'b0;
            r_tx_cpu_wren   <= 1'b0;
            r_tx_cpu_addr   <= {ADDR_BIT{1'b0}};
            r_tx_cpu_data   <= {DATA_BIT{1'b0}};
        end
        else begin
            if (r_pop_valid == 1'b1) begin
                r_id            <= r_id + 6'b000001;
                r_tx_cpu_en     <= i_tx_popdata[FIFO_BIT - 1];
                r_tx_cpu_wren   <= i_tx_popdata[FIFO_BIT - 2];
                r_tx_cpu_addr   <= i_tx_popdata[FIFO_BIT - 3:DATA_BIT];
                r_tx_cpu_data   <= i_tx_popdata[DATA_BIT - 1:0];
            end
        end
    end

    assign o_tx_popen   = (i_tx_empty != 1'b0);

    assign AXI.AWVALID  = r_tx_cpu_en & r_tx_cpu_wren;
    assign AXI.AWID     = {CPU_ID,r_id};
    assign AXI.AWADDR   = r_tx_cpu_addr;
    assign AXI.AWLEN    = SINGLE_BURST;
    assign AXI.AWSIZE   = 3'b010;
    assign AXI.AWBURST  = AXBURST_INCR;

    assign AXI.WVALID   = r_tx_cpu_en & r_tx_cpu_wren;
    assign AXI.WDATA    = r_tx_cpu_data; 
    assign AXI.WSTRB    = {AXI.STRB_BIT{1'b1}};
    assign AXI.WLAST    = 1'b1;

    assign AXI.BREADY   = ;

    assign AXI.ARVALID  = r_tx_cpu_en;
    assign AXI.ARID     = ;
    assign AXI.ARADDR   = r_tx_cpu_addr;
    assign AXI.ARLEN    = SIGNLE_BURST;
    assign AXI.ARSIZE   = 3'b010;
    assign AXI.ARBURST  = AXBURST_INCR;

    assign AXI.RREADY   = ;

endmodule
