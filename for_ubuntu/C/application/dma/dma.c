#include <stdint.h>
#include "dma.h"

/////////////////////
// Set SFR Address //
/////////////////////
#ifndef NMIPS
static volatile int32_t* sfrDmaVersion  = (volatile int32_t*)MMIO_DMA_VERSION;
static volatile int32_t* sfrDmaSrcAddr  = (volatile int32_t*)MMIO_DMA_SRC_ADDR;
static volatile int32_t* sfrDmaDstAddr  = (volatile int32_t*)MMIO_DMA_DST_ADDR;
static volatile int32_t* sfrDmaLength   = (volatile int32_t*)MMIO_DMA_LEN;
static volatile int32_t* sfrDmaCommand  = (volatile int32_t*)MMIO_DMA_CMD;      
static volatile int32_t* sfrDmaStatus   = (volatile int32_t*)MMIO_DMA_STATUS;  
#else   // NMIPS
static volatile int32_t sfrWin64DmaVersion  = 0;
static volatile int32_t sfrWin64DmaSrcAddr  = 0;
static volatile int32_t sfrWin64DmaDstAddr  = 0;
static volatile int32_t sfrWin64DmaLength   = 0;
static volatile int32_t sfrWin64DmaCommand  = 0;
static volatile int32_t sfrWin64DmaStatus   = 0;
#endif  // NMIPS

//////////////
// Init SFR //
//////////////
void dmaInit(void)
{                   
    #ifndef NMIPS
    *sfrDmaVersion  = 0;
    *sfrDmaSrcAddr  = 0; 
    *sfrDmaDstAddr  = 0;
    *sfrDmaLength   = 0;
    *sfrDmaCommand  = 0;
    //*sfrDmaStatus   = 0; // SW Read-Only
    #else   // NMIPS
    sfrWin64DmaVersion  = 0;
    sfrWin64DmaSrcAddr  = 0;
    sfrWin64DmaDstAddr  = 0;
    sfrWin64DmaLength   = 0;
    sfrWin64DmaCommand  = 0;
    sfrWin64DmaStatus   = 0;
    #endif  // NMIPS

}

/////////////////////
// Set DMA Version //
/////////////////////
void setDmaVersion(void)
{
    #ifndef NMIPS
    *sfrDmaVersion  = DMA_VERSION;
    #else   // NMIPS
    sfrWin64DmaVersion  = DMA_VERSION;
    #endif  //NMIPS
}

/////////////////////
// Get DMA Version //
/////////////////////
void getDmaVersion(uint32_t* dmaVersion)
{
    #ifndef NMIPS
    *dmaVersion = *(uint32_t*)MMIO_DMA_VERSION;
    #else   // NMIPS
    *dmaVersion = sfrWin64DmaVersion;
    printf("DMA VERSION         (0x%08x)\n", sfrWin64DmaVersion);
    #endif  // NMIPS
}

#ifdef NMIPS
/////////////////////////////////////////
// Set DMA Status (Only Used in Win64) //
/////////////////////////////////////////
void setDmaStatus(void)
{
    sfrWin64DmaStatus = DMA_DONE;
}
#endif  // NMIPS

////////////////////
// Get DMA Status //
////////////////////
void getDmaStatus(uint32_t* dmaStatus)
{
    #ifndef NMIPS
    *dmaStatus = *(uint32_t*)MMIO_DMA_STATUS;
    #else   // NMIPS
    *dmaStatus = sfrWin64DmaStatus;
    printf("DMA Status Register (0x%08x)\n", sfrWin64DmaStatus);
    #endif  // NMIPS

}

/////////////////////////////////
// Request to DMA Copying Data //
/////////////////////////////////
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len, uint32_t* done)
{
    #ifndef NMIPS
    *sfrDmaSrcAddr  = src;
    *sfrDmaDstAddr  = dst;
    *sfrDmaLength   = len;
    *sfrDmaCommand  = DMA_START;

    while (DMA_DONE == *done)
    {
        getDmaStatus(done);
    }
    #else   // NMIPS
    sfrWin64DmaSrcAddr  = src;
    sfrWin64DmaDstAddr  = dst;
    sfrWin64DmaLength   = len;
    sfrWin64DmaCommand  = DMA_START;

    setDmaStatus();
    getDmaStatus(done);
    #endif  // NMIPS
}

//////////////
// Main DMA //
//////////////
void mainDma(void)
{
    uint32_t dmaVersion = 0U;
    uint32_t dmaDone    = 0U;

    dmaInit();
    setDmaVersion();
    getDmaVersion(&dmaVersion);
    dmaCopy((uint32_t)MMIO_MAIN_MEM, (uint32_t)MMIO_AUX_MEM, 64U, &dmaDone);
}
