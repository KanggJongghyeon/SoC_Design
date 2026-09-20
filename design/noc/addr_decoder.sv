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
    output  wire                        o_main_mem_en,
    output  wire                        o_aux_mem_en
    );
    
    // Wire
    wire    w_boot_rom_en;
    wire    w_timer_en;
    wire    w_uart_en;
    wire    w_i2c_en;
    wire    w_spi_en;
    wire    w_gpio_en;
    wire    w_dma_en;
    wire    w_cache_mem_en;
    wire    w_main_mem_en;
    wire    w_aux_mem_en;

    // MMIO Enable
    assign w_boot_rom_en    = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_BOOT_ROM)  && (AXADDR < `MMIO_TIMER))      ? 1'b1 : 1'b0;
    assign w_timer_en       = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_TIMER)     && (AXADDR < `MMIO_UART))       ? 1'b1 : 1'b0;
    assign w_uart_en        = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_UART)      && (AXADDR < `MMIO_I2C))        ? 1'b1 : 1'b0;
    assign w_i2c_en         = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_I2C)       && (AXADDR < `MMIO_SPI))        ? 1'b1 : 1'b0;
    assign w_spi_en         = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_SPI)       && (AXADDR < `MMIO_GPIO))       ? 1'b1 : 1'b0;
    assign w_gpio_en        = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_GPIO)      && (AXADDR < `MMIO_DMA))        ? 1'b1 : 1'b0;
    assign w_dma_en         = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_DMA)       && (AXADDR < `MMIO_CACHE_MEM))  ? 1'b1 : 1'b0;
    assign w_cache_mem_en   = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_CACHE_MEM) && (AXADDR < `MMIO_MAIN_MEM))   ? 1'b1 : 1'b0;
    assign w_main_mem_en    = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_MAIN_MEM)  && (AXADDR < `MMIO_AUX_MEM))    ? 1'b1 : 1'b0;
    assign w_aux_mem_en     = ((AXVALID == 1'b1) && (AXADDR >= `MMIO_AUX_MEM))                                  ? 1'b1 : 1'b0;

    // Output
    assign o_boot_rom_en    = w_boot_rom_en;
    assign o_axi2ahb_en     = w_uart_en | w_spi_en;
    assign o_axi2apb_en     = w_timer_en | w_i2c_en | w_gpio_en | w_dma_en; 
    assign o_cache_mem_en   = w_cache_mem_en;
    assign o_main_mem_en    = w_main_mem_en;
    assign o_aux_mem_en     = w_aux_mem_en;

endmodule
