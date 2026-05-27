`timescale 1ns / 1ps
module apll (
    input  wire       ref_clk,  // 2ns  500MHz
    input  wire       rst_n,
    input  wire [2:0] i_clk_en, // [2] : AXI, [1] : AHB, [0] : APB
    output wire       PCLK,     // 4ns  250MHz
    output wire       HCLK,     // 8ns  125MHz
    output wire       ACLK,     // 16ns 62.5MHz
    output wire       PRESETn,
    output wire       HRESETn,
    output wire       ARESETn
    );

    wire w_htoggle;
    reg  r_htoggle;
    reg  r_PCLK,    r_HCLK,    r_ACLK;

    wire [1:0] w_pcntr;
    reg  [1:0] r_pcntr;

//////////
// PCLK //
//////////
    always @ (posedge ref_clk or negedge rst_n) begin
        if (~rst_n) begin
            r_pcntr <= 2'b00;
        end
        else begin
            if (i_clk_en[0] == 1'b1) begin
                r_pcntr <= r_pcntr + 2'b01;
            end
            else begin
                r_pcntr <= 2'b00;
            end
        end
    end

    always @ (posedge ref_clk or negedge rst_n) begin
        if (~rst_n) begin
            r_PCLK <= 1'b0;
        end
        else begin
            if (i_clk_en[0] == 1'b1) begin
                if (w_pcntr == 2'b11) begin
                    r_PCLK <= ~r_PCLK;
                end
            end
            else begin
                r_PCLK <= 1'b0;
            end
        end
    end

//////////
// HCLK //
//////////
    always @ (posedge ref_clk or negedge rst_n) begin
        if (~rst_n) begin
            r_htoggle <= 1'b0;
        end
        else begin
            if (i_clk_en[1] == 1'b1) begin
                r_htoggle <= ~r_htoggle;
            end
            else begin
                r_htoggle <= 1'b0;
            end
        end
    end

    always @ (posedge ref_clk or negedge rst_n) begin
        if (~rst_n) begin
            r_HCLK <= 1'b0;
        end
        else begin
            if (i_clk_en[1] == 1'b1) begin
                if (w_htoggle == 1'b1) begin
                    r_HCLK <= ~r_HCLK;
                end
            end
            else begin
                r_HCLK <= 1'b0;
            end
        end
    end

//////////    
// ACLK //
//////////
    always @ (posedge ref_clk or negedge rst_n) begin
        if (~rst_n) begin
            r_ACLK <= 1'b0;
        end
        else begin
            if (i_clk_en[2] == 1'b1) begin
                r_ACLK <= ~r_ACLK;
            end
            else begin
                r_ACLK <= 1'b0;
            end
        end
    end

////////////////////////
// Assign Reg to Wire //
////////////////////////
    assign w_pcntr    = r_pcntr;
    assign w_htoggle  = r_htoggle;
    assign PCLK       = r_PCLK;
    assign HCLK       = r_HCLK;
    assign ACLK       = r_ACLK;
    assign PRESETn    = (i_clk_en[0] == 1'b1) ? 1'b1 : 1'b0;
    assign HRESETn    = (i_clk_en[1] == 1'b1) ? 1'b1 : 1'b0;
    assign ARESETn    = (i_clk_en[2] == 1'b1) ? 1'b1 : 1'b0;

endmodule
