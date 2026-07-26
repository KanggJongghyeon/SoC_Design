#ifndef MMIO_H
#define MMIO_H
#include "mips_cpu.h"

#ifndef MIPS_CPU_32BIT 
#define MMIO_BOOT_ROM   0x0000
#define MMIO_TIMER      0x0A00
#define MMIO_UART       0x0B00
#define MMIO_I2C        0x0C00 
#define MMIO_SPI        0x0D00
#define MMIO_GPIO       0x0E00
#define MMIO_DMA        0x1000
#define MMIO_CACHE_MEM  0x2000
#define MMIO_MAIN_MEM   0x3000
#define MMIO_AUX_MEM    0x8000
#else
#define MMIO_BOOT_ROM   0x00000000
#define MMIO_TIMER      0x00D00A00
#define MMIO_UART       0x00D00B00
#define MMIO_I2C        0x00D00C00 
#define MMIO_SPI        0x00D00D00
#define MMIO_GPIO       0x00D00E00
#define MMIO_DMA        0x10000000
#define MMIO_CACHE_MEM  0x20000000
#define MMIO_MAIN_MEM   0x30000000
#define MMIO_AUX_MEM    0x80000000
#endif  // MIPS_CPU_32BIT

#endif  // MMIO_H
