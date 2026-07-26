`ifndef DMAC_MMIO_SVH   // Header Guard
`define DMAC_MMIO_SVH
`include "./../noc/mmio.svh"

`ifndef CPU_32BIT
`define DMA_OFFSET      (MMIO_DMA)
`define DMA_VERSION     (DMA_OFFSET + 16'h0000)
`define DMA_SRC_ADDR    (DMA_OFFSET + 16'h0100)
`define DMA_DST_ADDR    (DMA_OFFSET + 16'h0104)
`define DMA_LEN         (DMA_OFFSET + 16'h0108)
`define DMA_CMD         (DMA_OFFSET + 16'h010C) // Only Used LSB 1 Bit, SW Write, HW Read
`define DMA_STATUS      (DMA_OFFSET + 16'h0110) // Only Used LSB 1 Bit, HW Write, SW Read
`else
`define DMA_OFFSET      (MMIO_DMA)
`define DMA_VERSION     (DMA_OFFSET + 32'h0000_0000)
`define DMA_SRC_ADDR    (DMA_OFFSET + 32'h0000_0100)
`define DMA_DST_ADDR    (DMA_OFFSET + 32'h0000_0104)
`define DMA_LEN         (DMA_OFFSET + 32'h0000_0108)
`define DMA_CMD         (DMA_OFFSET + 32'h0000_010C) // Only Used LSB 1 Bit, SW Write, HW Read
`define DMA_STATUS      (DMA_OFFSET + 32'h0000_0110) // Only Used LSB 1 Bit, HW Write, SW Read
`endif  // CPU_32BIT


`endif  // DMAC_MMIO_SVH
