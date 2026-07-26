#include <stdlib.h>
#include <stdint.h>
#include "mmio.h"
#include "dma_ctrl.h"
int main() 
{
    *(volatile uint32_t *)(DMA_VERSION) = 0x20260726;
    *(volatile uint32_t *)(DMA_SRC_ADDR)= 0x80000000;
    *(volatile uint32_t *)(DMA_DST_ADDR)= 0x30000000;
    *(volatile uint32_t *)(DMA_LEN)     = 64U;  // 64 Byte
    *(volatile uint32_t *)(DMA_CMD)     = DMA_START;
    
    //*(volatile uint32_t *)0x00000D04 = 0x00010000;
    /*
    *(volatile uint32_t *)0x00000D00 = 0x00010000;
    *(volatile uint32_t *)0x00000D04 = 0x00010000;
    *(volatile uint32_t *)0x00000D08 = 0x00010000;
    *(volatile uint32_t *)0x00000000 = 0x00001234;
    *(volatile uint32_t *)0x00000004 = 0x00005678;
    *(volatile uint32_t *)0x00000008 = 0x00009ABC;
    *(volatile uint32_t *)0x0000000C = 0x0000DEF0;
    *(volatile uint32_t *)0x00000000;
    *(volatile uint32_t *)0x00000004;
    *(volatile uint32_t *)0x00000008;
    *(volatile uint32_t *)0x0000000C;
    *(volatile uint32_t *)0x00000010 = 0x11111111;
    *(volatile uint32_t *)0x00000014 = 0x22222222;
    *(volatile uint32_t *)0x00000018 = 0x33333333;
    *(volatile uint32_t *)0x00000010;
    *(volatile uint32_t *)0x00000014;
    *(volatile uint32_t *)0x00000018;
    *(volatile uint32_t *)0x00D0D000 = 0x00001000;
    *(volatile uint32_t *)0x00000800 = 0x00010000;
    *(volatile uint32_t *)0x00000A00 = 0x00010000;
    *(volatile uint32_t *)0x00000C00 = 0x00010000;
    *(volatile uint32_t *)0x000009FC;
    *(volatile uint32_t *)0x000009FC;
    *(volatile uint32_t *)0x000009FC;
    *(volatile uint32_t *)0x000009FC;
    *(volatile uint32_t *)0x000009FC;
    *(volatile uint32_t *)0x000009FC;
    *(volatile uint32_t *)0x000009FC;
    */
    //uint32_t val = *ptr;
    return 0;
}
