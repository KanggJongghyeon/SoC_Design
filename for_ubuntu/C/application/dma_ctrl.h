#ifndef DMA_CTRL_H
#define DMA_CTRL_H
#include "mips_cpu.h"
#include "mmio.h"

#define DMA_OFFSET      (MMIO_DMA)
#define DMA_VERSION     (DMA_OFFSET + 0x0000)        
#define DMA_SRC_ADDR    (DMA_OFFSET + 0x0100)
#define DMA_DST_ADDR    (DMA_OFFSET + 0x0104)
#define DMA_LEN         (DMA_OFFSET + 0x0108)   // Only Used LSB 16 Bits
#define DMA_CMD         (DMA_OFFSET + 0x010C)   // Only Used LSB 1 Bit, SW Write, HW Read
#define DMA_STATUS      (DMA_OFFSET + 0x0110)   // Only Used LSB 1 Bit, HW Write, SW Read

#define DMA_START       (1U)

//void dmaCopy(*void dest, *void src, *void len);

#endif  // DMA_CTRL_H
