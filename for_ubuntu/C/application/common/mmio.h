#ifndef MMIO_H
#define MMIO_H
#include "mipsCpu.h"

#ifndef MIPS_CPU_32BIT 
#define MMIO_BOOT_ROM   0x0000U
#define MMIO_TIMER      0x0A00U
#define MMIO_UART       0x0B00U
#define MMIO_I2C        0x0C00U
#define MMIO_SPI        0x0D00U
#define MMIO_GPIO       0x0E00U
#define MMIO_DMA        0x1000U
#define MMIO_CACHE_MEM  0x2000U
#define MMIO_MAIN_MEM   0x3000U
#define MMIO_AUX_MEM    0x8000U
#else
#define MMIO_BOOT_ROM   0x00000000U
#define MMIO_TIMER      0x00D00A00U
#define MMIO_UART       0x00D00B00U
#define MMIO_I2C        0x00D00C00U 
#define MMIO_SPI        0x00D00D00U
#define MMIO_GPIO       0x00D00E00U
#define MMIO_DMA        0x10000000U
#define MMIO_CACHE_MEM  0x20000000U
#define MMIO_MAIN_MEM   0x30000000U
#define MMIO_AUX_MEM    0x80000000U
#endif  // MIPS_CPU_32BIT

#endif  // MMIO_H
