`timescale 1ns / 1ps
`define CLOCK_RATE 2
module TOP_tb #(
    parameter ADDR_BIT = 12,
    parameter DATA_BIT = 32
    )();

    reg                  clk,   rst_n, i_en, i_wren, inst_mem_write_finish;
    reg [ADDR_BIT - 1:0] i_addr;
    reg [DATA_BIT - 1:0] i_data;  

    initial begin
        clk = 1'b0;
        forever #(`CLOCK_RATE / 2) clk = ~clk;
    end

    localparam TXT_LINE = 1000;
    reg [31:0] inst_mem [0:TXT_LINE - 1];
    string     inst_txt;

    initial begin
        $sformat (inst_txt, "C:/new/computer_architecture/new/SIM/inst_mem.txt");
        $readmemh(inst_txt, inst_mem);    
    end

    initial begin
        #0 inst_mem_write_finish = 1'b0;
        #0   rst_n = 1'b0; i_en = 1'b0; i_wren = 1'b0; i_addr = {ADDR_BIT{1'b0}}; i_data = {DATA_BIT{1'b0}};
        #20  rst_n = 1'b1;
        #10                i_en = 1'b1; i_wren = 1'b1;
        for (integer i = 0; i < TXT_LINE; i = i + 1) begin
            i_addr = 4 * i;
            i_data = inst_mem[i];
            #(`CLOCK_RATE);
        end
        #0                 i_en = 1'b0; i_wren = 1'b0; i_addr = {ADDR_BIT{1'b0}}; i_data = {DATA_BIT{1'b0}};
        #0 inst_mem_write_finish = 1'b1;
        /*
        #10                i_en = 1'b1;             
        for (integer j = 0; j < TXT_LINE; j = j + 1) begin
            i_addr = 4 * j;
            #(`CLOCK_RATE);
        end
        #0  i_en = 1'b0; i_wren = 1'b0;
        */
        #800 $finish;
    end

    top #(
        .ADDR_BIT                (ADDR_BIT),
        .DATA_BIT                (DATA_BIT)
    ) dut (
        .clk                     (clk),
        .rst_n                   (rst_n),
        .i_inst_mem_write_finish (inst_mem_write_finish),
        .i_inst_mem_en           (i_en),
        .i_inst_mem_wren         (i_wren),
        .i_inst_mem_addr         (i_addr),
        .i_inst_mem_data         (i_data)
    );

endmodule
