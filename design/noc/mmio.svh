`ifndef MMIO_SVH    // Header Guard
`define MMIO_SVH

// 32-Bit System
`ifndef CPU_32BIT
`define MMIO_BOOT_ROM   16'h0000
`define MMIO_TIMER      16'h0A00
`define MMIO_UART       16'h0B00
`define MMIO_I2C        16'h0C00
`define MMIO_SPI        16'h0D00
`define MMIO_GPIO       16'h0E00
`define MMIO_DMA        16'h1000
`define MMIO_SRAM       16'h2000
`define MMIO_DDR_CTRL   16'h3000
//`define MMIO_INTERRUPT  TBD
`else
`define MMIO_BOOT_ROM   32'h0000_0000
`define MMIO_TIMER      32'h00D0_A000
`define MMIO_UART       32'h00D0_B000
`define MMIO_I2C        32'h00D0_C000
`define MMIO_SPI        32'h00D0_D000
`define MMIO_GPIO       32'h00D0_E000
`define MMIO_DMA        32'h1000_0000
`define MMIO_SRAM       32'h2000_0000
`define MMIO_DDR_CTRL   32'h3000_0000
//`define MMIO_INTERRUPT  TBD
`endif  // CPU_32BIT

`endif  // MMIO_SVH
