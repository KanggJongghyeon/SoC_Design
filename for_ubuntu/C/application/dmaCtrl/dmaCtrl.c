#include <stdint.h>
#include <stdio.h>

#include "dmaCtrl.h"

/////////////////////
// Set SFR Address //
/////////////////////
static volatile uint32_t* sfrDmaVersion = (volatile uint32_t*)DMA_VERSION;
static volatile uint32_t* sfrDmaSrcAddr = (volatile uint32_t*)DMA_SRC_ADDR;
static volatile uint32_t* sfrDmaDstAddr = (volatile uint32_t*)DMA_DST_ADDR;
static volatile uint32_t* sfrDmaLength  = (volatile uint32_t*)DMA_LEN;
static volatile uint32_t* sfrDmaCommand = (volatile uint32_t*)DMA_CMD;      
static volatile uint32_t* sfrDmaStatus  = (volatile uint32_t*)DMA_STATUS;  

//////////////
// Init SFR //
//////////////
void dmaCtrlInit(void)
{                   
    *sfrDmaVersion  = 0U;
    *sfrDmaSrcAddr  = 0U; 
    *sfrDmaDstAddr  = 0U;
    *sfrDmaLength   = 0U;
    *sfrDmaCommand  = 0U;
    //*sfrDmaStatus   = 0U; // SW Read-Only
}

////////////////////////////////
// Set DMA Controller Version //
////////////////////////////////
void setDmaCtrlVersion(void)
{
    *sfrDmaVersion  = 0x20260812U;
}

////////////////////////////////////////////
// Request to DMA Controller Copying Data //
////////////////////////////////////////////
void dmaCopy(uint32_t dst, uint32_t src, uint32_t len)
{
    *sfrDmaSrcAddr = src;
    *sfrDmaDstAddr = dst;
    *sfrDmaLength  = len;
    *sfrDmaCommand = DMA_START;
}

/////////////////////////
// Main DMA Controller //
/////////////////////////
void mainDmaCtrl(void)
{
    dmaCtrlInit();
    setDmaCtrlVersion();
    dmaCopy((uint32_t)MMIO_MAIN_MEM, (uint32_t)MMIO_AUX_MEM, 64U);
    printf("finish\n");
}
