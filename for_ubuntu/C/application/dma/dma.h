#ifndef DMA_H
#define DMA_H

#include "../common/mipsCpu.h"
#include "../common/mmio.h"

// DMA MMIO (Special Function Register Map)
#define DMA_OFFSET      (MMIO_DMA)
#define DMA_VERSION     (DMA_OFFSET + 0x0000)        
#define DMA_SRC_ADDR    (DMA_OFFSET + 0x0100)
#define DMA_DST_ADDR    (DMA_OFFSET + 0x0104)
#define DMA_LEN         (DMA_OFFSET + 0x0108)   // Only Used LSB 16 Bits
#define DMA_CMD         (DMA_OFFSET + 0x010C)   // Only Used LSB 1 Bit, SW Write, HW Read
#define DMA_STATUS      (DMA_OFFSET + 0x0110)   // Only Used LSB 1 Bit, HW Write, SW Read

// DMA Command
#define DMA_START       (1U)

// Main DMA
void mainDma(void);

// Init DMA
void dmaInit(void);

// Set DMA Version
void setDmaVersion(void);

// Request to DMA Copying Data 
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len);

#endif  // DMA_H
