#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include "common/mmio.h"
#include "dmaCtrl/dmaCtrl.h"

int main() 
{   
    // AUX Memory WR TEST
    for (uint16_t i = 0U; i < 200U; i = i + 4U)
    {
        *(volatile uint32_t*)(MMIO_AUX_MEM + i) = 0x00000000U + i;
    }

    // DMA TEST 
    mainDmaCtrl();

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

    return 0;
}
