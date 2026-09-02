#ifndef DMA_H
#define DMA_H

#include "../common/mipsCpu.h"
#include "../common/mmio.h"

#ifdef NMIPS
#include <stdio.h>
#include <time.h>
#endif  // NMIPS

// DMA MMIO (Special Function Register Map)
#define MMIO_DMA_OFFSET     (MMIO_DMA)
#define MMIO_DMA_VERSION    (MMIO_DMA_OFFSET + 0x0000U)        
#define MMIO_DMA_SRC_ADDR   (MMIO_DMA_OFFSET + 0x0100U)
#define MMIO_DMA_DST_ADDR   (MMIO_DMA_OFFSET + 0x0104U)
#define MMIO_DMA_LEN        (MMIO_DMA_OFFSET + 0x0108U) // Only Used LSB 16 Bits
#define MMIO_DMA_CMD        (MMIO_DMA_OFFSET + 0x010CU) // Only Used LSB 1 Bit, SW Write, HW Read
#define MMIO_DMA_STATUS     (MMIO_DMA_OFFSET + 0x0110U) // Only Used LSB 1 Bit, HW Write, SW Read

// DMA Verison
#define DMA_VERSION (0x20260812)
// DMA Command
#define DMA_START   (1)
// DMA Status
#define DMA_DONE    (1)

// Main DMA
void mainDma(void);

// Init DMA
void dmaInit(void);

// Set DMA Version
void setDmaVersion(void);

// Get DMA Version
void getDmaVersion(uint32_t* dmaVersion);

#ifdef NMIPS
// Set DMA Status (Only Used in Win64);
void setDmaStatus(void);
#endif  // NMIPS

// Get DMA Status
void getDmaStatus(uint32_t* dmaStatus);

// Request to DMA Copying Data 
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len, uint32_t* done);

#endif  // DMA_H
