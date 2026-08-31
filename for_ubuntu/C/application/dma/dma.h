#ifndef DMA_H
#define DMA_H

#include "../common/mipsCpu.h"
#include "../common/mmio.h"

// DMA MMIO (Special Function Register Map)
#define MMIO_DMA_OFFSET     (MMIO_DMA)
#define MMIO_DMA_VERSION    (MMIO_DMA_OFFSET + 0x0000)        
#define MMIO_DMA_SRC_ADDR   (MMIO_DMA_OFFSET + 0x0100)
#define MMIO_DMA_DST_ADDR   (MMIO_DMA_OFFSET + 0x0104)
#define MMIO_DMA_LEN        (MMIO_DMA_OFFSET + 0x0108)  // Only Used LSB 16 Bits
#define MMIO_DMA_CMD        (MMIO_DMA_OFFSET + 0x010C)  // Only Used LSB 1 Bit, SW Write, HW Read
#define MMIO_DMA_STATUS     (MMIO_DMA_OFFSET + 0x0110)  // Only Used LSB 1 Bit, HW Write, SW Read

// DMA Verison
#define DMA_VERSION (0x20260812U)
// DMA Command
#define DMA_START   (1U)
// DMA Status
#define DMA_DONE    (1U)

// Main DMA
void mainDma(void);

// Init DMA
void dmaInit(void);

// Set DMA Version
void setDmaVersion(void);

// Get DMA Version
void getDmaVersion(uint32_t* dmaVersion);

// Get DMA Status
void getDmaStatus(uint32_t* dmaStatus);

// Request to DMA Copying Data 
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len, uint32_t* done);

#endif  // DMA_H
