#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include "common/mmio.h"
#include "dma/dma.h"

#ifdef NMIPS
#include <stdio.h>
#include <time.h>
#endif  // NMIPS

int main() 
{   
    ////////////////////////
    // AUX Memory WR TEST //
    ////////////////////////
    #ifdef NMIPS
    printf("System Clock Tick (%u tick per 1 sec)...\n", (uint32_t)CLOCKS_PER_SEC);
    printf("1. AUX MEMORY WRITE TEST ...\n");
    clock_t StartTick = clock();
    
    int8_t win64AuxMem[10000 * 4] = {0};
    #endif  // NMIPS    
                    
    for (uint16_t i = 0U; i < 10000U; i = i + 4U)
    {
        #ifndef NMIPS
        *(volatile int32_t*)(MMIO_AUX_MEM + i) = 0x00000000 + (int32_t)i;
        #else   // NMIPS
        win64AuxMem[i + 0] = (int8_t)(((int32_t)i & 0x000000FF) >> 0);
        win64AuxMem[i + 1] = (int8_t)(((int32_t)i & 0x0000FF00) >> 8);
        win64AuxMem[i + 2] = (int8_t)(((int32_t)i & 0x00FF0000) >> 16);
        win64AuxMem[i + 3] = (int8_t)(((int32_t)i & 0xFF000000) >> 24);
        #endif  // NMIPS
    }
    
    #ifdef NMIPS
    clock_t EndTick         = clock();
    uint32_t auxMemTestTime = EndTick - StartTick; 
    printf("AUX MEM WRITE TEST COMPLETE [%llu]\n", auxMemTestTime);
    #endif  // NMIPS
   
    //////////////
    // DMA TEST //
    //////////////
    #ifdef NMIPS
    printf("2. DMA TEST ...\n");
    StartTick   = clock();
    #endif  // NMIPS    

    mainDma();

    #ifdef NMIPS
    EndTick             = clock();
    uint32_t dmaTestTime= EndTick - StartTick;
    printf("DMA TEST COMPLETE [%llu]\n", dmaTestTime);
    printf("\n");
    printf("|-----------All Test Finish-----------|\n");
    printf("| AUX MEM WRITE TEST Time : %llu tick \n");
    printf("| DMA           TEST Time : %llu tick \n");
    printf("|-------------------------------------|\n");
    #endif  // NMIPS
    
    return 0;
}
