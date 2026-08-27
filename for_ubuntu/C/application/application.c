#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include "common/mmio.h"
#include "dma/dma.h"

int main() 
{   
    // AUX Memory WR TEST
    for (uint16_t i = 0U; i < 1000U; i = i + 4U)
    {
        *(volatile uint32_t*)(MMIO_AUX_MEM + i) = 0x00000000U + (uint32_t)i;
    }

    // DMA TEST 
    mainDma();

    return 0;
}
