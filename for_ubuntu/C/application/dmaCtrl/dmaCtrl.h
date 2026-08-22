#ifndef DMA_CTRL_H
#define DMA_CTRL_H

#include "../common/mipsCpu.h"
#include "../common/mmio.h"

// DMA Controller MMIO (Special Function Register Map)
#define DMA_OFFSET      (MMIO_DMA)
#define DMA_VERSION     (DMA_OFFSET + 0x0000)        
#define DMA_SRC_ADDR    (DMA_OFFSET + 0x0100)
#define DMA_DST_ADDR    (DMA_OFFSET + 0x0104)
#define DMA_LEN         (DMA_OFFSET + 0x0108)   // Only Used LSB 16 Bits
#define DMA_CMD         (DMA_OFFSET + 0x010C)   // Only Used LSB 1 Bit, SW Write, HW Read
#define DMA_STATUS      (DMA_OFFSET + 0x0110)   // Only Used LSB 1 Bit, HW Write, SW Read

// DMA Controller Command
#define DMA_START       (1U)

// Main DMA Controller
void mainDmaCtrl(void);

// Init DMA Controller
void dmaCtrlInit(void);

// Set DMA Controller Version
void setDmaCtrlVersion(void);

// Request to DMA Controller Copying Data 
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len);

#endif  // DMA_CTRL_H
