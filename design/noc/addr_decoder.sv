`include "mmio.svh"
`timescale 1ns / 1ps
module addr_decoder #(
    parameter ADDR_BIT = 32
    )(
    input   wire                        AXVALID,
    input   wire    [ADDR_BIT - 1:0]    AXADDR,
    output  wire                        o_boot_rom_en,
    output  wire                        o_axi2ahb_en,
    output  wire                        o_axi2apb_en,
    output  wire                        o_cache_mem_en,
    output  wire                        o_main_mem_en
    );

    wire    w_timer_uart_en, w_gpio_dma_en, w_aux_mem_en;

    // MMIO
    assign o_boot_rom_en    = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_BOOT_ROM)  && (AXADDR < `MMIO_TIMER))      ? 1'b1 : 1'b0;
    assign o_axi2ahb_en     = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_I2C)       && (AXADDR < `MMIO_GPIO))       ? 1'b1 : 1'b0;
    assign w_timer_uatr_en  = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_TIMER)     && (AXADDR < `MMIO_I2C))        ? 1'b1 : 1'b0;
    assign w_gpio_dma_en    = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_GPIO)      && (AXADDR < `MMIO_CACHE_MEM))  ? 1'b1 : 1'b0;
    assign o_axi2apb_en     = w_axi2apb_en | w_axi2apb_en | w_aux_mem_en; 
    assign o_cache_mem_en   = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_CACHE_MEM) && (AXADDR < `MMIO_MAIN_MEM))   ? 1'b1 : 1'b0;
    assign o_main_mem_en    = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_MAIN_MEM)  && (AXADDR < `MMIO_AUX_MEM))    ? 1'b1 : 1'b0;
    assign w_aux_mem_en     = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_AUX_MEM))                                  ? 1'b1 : 1'b0;

endmodule
