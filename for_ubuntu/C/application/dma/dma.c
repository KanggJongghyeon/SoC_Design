#include <stdint.h>
#include "dma.h"

/////////////////////
// Set SFR Address //
/////////////////////
static volatile uint32_t* sfrDmaVersion = (volatile uint32_t*)MMIO_DMA_VERSION;
static volatile uint32_t* sfrDmaSrcAddr = (volatile uint32_t*)MMIO_DMA_SRC_ADDR;
static volatile uint32_t* sfrDmaDstAddr = (volatile uint32_t*)MMIO_DMA_DST_ADDR;
static volatile uint32_t* sfrDmaLength  = (volatile uint32_t*)MMIO_DMA_LEN;
static volatile uint32_t* sfrDmaCommand = (volatile uint32_t*)MMIO_DMA_CMD;      
static volatile uint32_t* sfrDmaStatus  = (volatile uint32_t*)MMIO_DMA_STATUS;  

//////////////
// Init SFR //
//////////////
void dmaInit(void)
{                   
    *sfrDmaVersion  = 0U;
    *sfrDmaSrcAddr  = 0U; 
    *sfrDmaDstAddr  = 0U;
    *sfrDmaLength   = 0U;
    *sfrDmaCommand  = 0U;
    //*sfrDmaStatus   = 0U; // SW Read-Only
}

/////////////////////
// Set DMA Version //
/////////////////////
void setDmaVersion(void)
{
    *sfrDmaVersion  = DMA_VERSION;
}

/////////////////////
// Get DMA Version //
/////////////////////
void getDmaVersion(uint32_t* dmaVersion)
{
    *dmaVersion = *(uint32_t*)MMIO_DMA_VERSION;
}

////////////////////
// Get DMA Status //
////////////////////
void getDmaStatus(uint32_t* dmaStatus)
{
    *dmaStatus = *(uint32_t*)MMIO_DMA_STATUS;
}

/////////////////////////////////
// Request to DMA Copying Data //
/////////////////////////////////
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len, uint32_t* done)
{
    *sfrDmaSrcAddr  = src;
    *sfrDmaDstAddr  = dst;
    *sfrDmaLength   = len;
    *sfrDmaCommand  = DMA_START;

    while (DMA_DONE == *done)
    {
        getDmaStatus(done);
    }
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
