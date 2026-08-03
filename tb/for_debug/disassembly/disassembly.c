#include "disassembly.h"
/////////////////////
// Global Variable //
/////////////////////
// Init Global Variable
static unsigned int instructiono[MAX_LINE]          = {0};
static char         disassembly[MAX_LINE][MAX_LEN]  = {0};
static eOpcodeType  opcodeType[MAX_LINE]            = {TYPE_NONE};

//////////////////////////////////////
// Get Instruction from Memory File //
//////////////////////////////////////
bool getInstruction(const char* iFile, unsigned int* oInstruction, unsigned char* oCount)
{
    bool            fileError       = false;
    FILE*           filePointer     = fopen(iFile, "rb");
    char*           fileBuffer      = NULL;
    char*           linePointer     = NULL;
    unsigned int    bufferSize      = 0;
    bool            endOfBuffer     = false;
    unsigned int    bufferIdx       = 0;
    unsigned int    instructionIdx  = 0;
    unsigned char   charCount       = 0;

    if (NULL == filePointer)
    {
        fileError   = true;
        printf("[ERROR] File Open Fail : %s\n", iFile);
    }
    else
    {
        printf("File Open Complete : %s\n", iFile);
        //@ Move filePointer Location to End of File
        fseek(filePointer, 0, SEEK_END);
        //@ Get File Size
        bufferSize  = (unsigned int)ftell(filePointer);
        #ifndef NDEBUG
        printf("bufferSize (%d)\n", bufferSize);
        #endif
        //@ Remove filePointer Location to Start of File
        rewind(filePointer);
        //@ Allocate fileBuffer
        fileBuffer  = malloc(bufferSize + 1);
        //@ Store File Data into fileBuffer
        fread(fileBuffer, 1, bufferSize, filePointer);
        fileBuffer[bufferSize] = '\0';
        #ifndef NDEBUG
        unsigned int bufferCount = 0;
        for (bufferCount = 0; bufferCount < bufferSize; bufferCount++)
        {
            printf("%d : %02x\n", bufferCount, fileBuffer[bufferCount]);
        }
        #endif
        while (false == endOfBuffer)
        {
            for (charCount = 0; charCount < 8; charCount++)
            {
                #ifndef NDEBUG
                unsigned int tempBuffer = (unsigned int)atoi(&fileBuffer[bufferIdx + charCount]);
                printf("%d %c %d\n", (bufferIdx + charCount), fileBuffer[bufferIdx + charCount], tempBuffer);
                tempBuffer = 0;
                #endif
                //oInstruction[instructionIdx] = (unsigned int)((fileBuffer[bufferIdx + charCount] - '0') >> mem32LineShift[(bufferIdx + charCount) % 10]);
            }
            while ((CARRIAGE_RETURN != fileBuffer[bufferIdx]) && (LINE_FEED != fileBuffer[(bufferIdx + 1)]))
            {
                bufferIdx++;
            }
            bufferIdx = bufferIdx + 2;
            instructionIdx++;
            if ((bufferIdx + 10) > bufferSize)
            {
                endOfBuffer = true;
            }
        }
        oInstruction[instructionIdx] == '\0';
    }
    free(fileBuffer);
    fileBuffer = NULL;
    fclose(filePointer);

    return fileError;
}

//////////////////////
// disassembly main //
//////////////////////
void convert(eInput iInput)
{
    //@ 1. Init Local Variable
    unsigned char   lineCount = 0;
    bool            error   = false;

    //@ 2. Check User Input
    switch (iInput)
    {
        //@ 2a. For the I_NONE:
        case I_NONE:
            //@ 2a1. Print ERROR LOG
            error   = true;
            printf("[ERROR] Invalid Input (%d)\n", iInput);
            break;
        //@ 2b. For the I_BOOT_LOADER:
        case I_BOOT_LOADER:
            #ifndef NDEBUG
            printf("Select I_BOOT_LOADER\n");
            #endif
            error   = getInstruction(BOOT_LOADER_MEM_PATH, instruction, &lineCount);
            break;
        //@ 2c. For the I_APPLICATION:
        case I_APPLICATION:
            error   = getInstruction(APPLICATION_MEM_PATH, instruction, &lineCount);
            break;
        //@ 2d. In All Other Cases:
        default:
            //@ 2d1. Print ERROR LOG
            error   = true;
            printf("[ERROR] Invalid Input (%d)\n", iInput);
            break;
    }
}
