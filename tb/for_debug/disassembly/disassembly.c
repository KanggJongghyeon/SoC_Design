#include "disassembly.h"
/////////////////////
// Global Variable //
/////////////////////
// Init Global Variable
static unsigned int instructiono[MAX_LINE]          = {0};
static char         disassembly[MAX_LINE][MAX_LEN]  = {0};
static eOpcodeType  opcodeType[MAX_LINE]            = {TYPE_NONE};

/////////////////////
// Get OPCODE Type //
/////////////////////
eOpcodeType getOpcodeType(eOpcode iOpcode, eFunctCode iFunctCode)
{
    //@ 1. Init Local Variable
    eOpcodeType oOpcodeType = TYPE_NONE;

    //@ 2. Check Input OPCODE
    switch (iOpcode)
    {
        //@ 2a. For the OP_RTYPE:
        case OP_RTYPE:
            //@ 2a1. Check Input FUNCT CODE
            switch (iFunctCode)
            {
                //@ 2a1a. For the FUNCT_SLL/SRL/SRA/SLLV/SRLV/SRAV:
                case FUNCT_SLL:
                case FUNCT_SRL:                     
                case FUNCT_SRA:
                case FUNCT_SLLV:
                case FUNCT_SRLV:
                case FUNCT_SRAV:
                    //@ 2a1a1. Set OPCODE Type to TYPE_SHIFT
                    oOpcodeType = TYPE_SHIFT;
                    break;
                //@ 2a1b. For the FUNCT_JR/MFHI/MFLO/MUL/MULU/DIV/DIVU/ADD/ADDU/SUB/SUBU/AND/OR/XOR/NOR/SLT/SLTU:
                case FUNCT_JR:  
                case FUNCT_MFHI:
                case FUNCT_MFLO:
                case FUNCT_MUL: 
                case FUNCT_MULU:
                case FUNCT_DIV: 
                case FUNCT_DIVU:
                case FUNCT_ADD: 
                case FUNCT_ADDU:
                case FUNCT_SUB: 
                case FUNCT_SUBU:
                case FUNCT_AND: 
                case FUNCT_OR:  
                case FUNCT_XOR: 
                case FUNCT_NOR: 
                case FUNCT_SLT: 
                case FUNCT_SLTU:
                    //@ 2a1b1. Set OPCODE TYPE to TYPE_R
                    oOpcodeType = TYPE_R;
                    break;
                //@ 2a1c. In All Other Cases:
                default:
                    //@ 2a1c1. Print ERROR LOG and Set OPCODE TYPE to TYPE_NOP
                    printf("[ERROR] Unknown OPCODE (%02x)\n", iOpcode);
                    oOpcodeType = TYPE_NOP;
                    break;
            }
            break;
        //@ 2b. For the OP_REGIMM/BEQ/BNE/ADDI/ADDIU/SLTI/SLTIU/ANDI/ORI/XORI/LUI:
        case OP_REGIMM:
        case OP_BEQ:  
        case OP_BNE:        
        case OP_ADDI: 
        case OP_ADDIU:
        case OP_SLTI: 
        case OP_SLTIU:
        case OP_ANDI: 
        case OP_ORI:  
        case OP_XORI: 
        case OP_LUI:  
            //@ 2b1. Set OPCODE Type to TYPE_I
            oOpcodeType = TYPE_I;
            break;
        //@ 2c. For the OP_J/JAL Type:
        case OP_J:
        case OP_JAL:
            //@ 2c1. Set OPCODE Type to TYPE_J
            oOpcodeType = TYPE_J;
            break;
        //@ 2d. For the OP_LW:
        case OP_LW:
            //@ 2d1. Set OPCODE Type to TYPE_LW
            oOpcodeType = TYPE_LW;
        //@ 2e. For the OP_SW:
        case OP_SW:
            //@ 2e1. Set OPCODE Type to TYPE_SW
            oOpcodeType = TYPE_SW;
        //@ 2f. In All Other Cases:
        default:
            //@ 2f1. Print ERROR LOG and Set OPCODE Type to TYPE_NOP
            printf("[ERROR] Unknown OPCODE (%02x)\n", iOpcode);
            oOpcodeType = TYPE_NOP;
            break;
    }

    return oOpcodeType
}


////////////////
// Get OPCODE //
////////////////
void getOpcode(unsigned int *iInstruction, char (*oDisassembly)[MAX_LEN], eOpcodeType *oOpcodeType)
{
    //@ 1. Init Local Variable
    unsigned char   instructionCount    = 0;            // Instruction Count
    eOpcode         opcode              = OP_NONE;      // OPCODE
    eFunctCode      functCode           = FUNCT_NONE;   // FUNCT CODE
    const char      nop[4]              = "nop\0";      // NOP

    //@ 2. Check Instruction Count
    //@ 2a. If Current Count is End of Instruction Line:
    while ('/0' != iInstruction[instructionCount])
    {   
        //@ 2a1. Check Instruction
        //@ 2a1a. If Instruction is 0x00000000:
        if (0 == iInstruction[instructionCount])
        {   
            //@ 2a1a1. Store "nop" into Disassembly Array
            oOpcodeType[instructionCount] = TYPE_NOP;
            strcpy(oDisassembly[instructionCount], nop);
        }
        //@ 2a1b. In All Other Cases:
        else
        {
            //@ 2a1b1. Call getOpcodeType() and get OPCODE Type
            opcode                          = (eOpcode)(iInstruction[instructionCount] >> 26); 
            functCode                       = (eFunctCode)(iInstruction[instructionCount] & 0x0000003F);
            oOpcodeType[instructionCount]   = getOpcodeType(opcode, functCode);
            //@ 2a1b2. Check OPCODE Type
            //@ 2a1b2a. If OPCODE Type is TYPE_NOP
            if (TYPE_NOP == oOpcodeType[instructionCount])
            {
                //@ 2a1b2a1. Print ERROR LOG and Store "nop" into Disassembly Array
                strcpy(oDisassembly[instructionCount], nop);              
                printf("So Set \"nop\" in [%d] line", (instructionCount + 1));
            }
            //@ 2a1b2b. In All Other Cases:
            else
            {

            }
        }
        instructionCount++;
    }
}

//////////////////////////////////////
// Convert Hexa Alphabet to Integer //
//////////////////////////////////////
unsigned char convertAlphabetCharToInteger(char iChar)
{
    //@ 1. Init Local Variable
    unsigned int oInteger;
    
    //@ 2. Check Input Character
    switch (iChar)
    {
        //@ 2a. For the 'a' or 'A':
        case 'a':
        case 'A':   
            //@ 2a1. Set Output to 10
            oInteger    = 10;    
            break;
        //@ 2b. For the 'b' or 'B':
        case 'b':
        case 'B':
            //@ 2b1. Set Output to 11
            oInteger    = 11;
            break;
        //@ 2c. For the 'c' or 'C':
        case 'c':
        case 'C':
            //@ 2c1. Set Output to 12
            oInteger    = 12;
            break;
        //@ 2d. For the 'd' or 'D':
        case 'd':
        case 'D':
            //@ 2d1. Set Output to 13
            oInteger    = 13;
            break;
        //@ 2e. For the 'e' or 'E':
        case 'e':
        case 'E':
            //@ 2e1. Set Output to 14
            oInteger    = 14;
            break;
        //@ 2f. For the 'f' or 'F':
        case 'f':
        case 'F':
            //@ 2f1. Set Output to 15
            oInteger    = 15;
            break;
        //@ 2g. In All Other Cases:
        default:
            //@ 2g1. Print ERROR LOG
            printf("[ERROR] MEM File Alphabet Character must be a(A) to f(F)\n");
            oInteger    = (unsigned char)FILE_ERROR;
            break;
    }
    
    return oInteger;
}

//////////////////////////////////////
// Get Instruction from Memory File //
//////////////////////////////////////
bool getInstruction(const char *iFile, unsigned int *oInstruction, unsigned char *oCount)
{
    //@ 1. Init Local Variable
    bool            oFileError      = false;    // Output Value
    FILE*           filePointer     = NULL;     // File Pointer
    char*           fileBuffer      = NULL;     // File Data Buffer
    unsigned int    bufferSize      = 0;        // Size of FileBuffer
    bool            endOfBuffer     = false;    // Flag of End of Buffer
    unsigned int    bufferIdx       = 0;        // Buffer Index
    unsigned int    instructionIdx  = 0;        // Instruction Index
    unsigned char   charCount       = 0;        // Character Counter per File Line
    unsigned char   alphabetInt     = 0;        // Output Value of convertAlphabetCharToInteger()

    //@ 2. Check File Pointer
    //@ 2a. If File Pointer is NULL:
    filePointer = fopen(iFile, "rb");
    if (NULL == filePointer)
    {
        //@ 2a1. Print ERROR LOG and Set File Error Flag to Positive
        oFileError   = true;
        printf("[ERROR] File Open Fail : %s\n", iFile);
    }
    //@ 2b. In All Other Cases:
    else
    {
        printf("File Open Complete : %s\n", iFile);
        
        //@ 2b1. Move filePointer Location to End of File
        fseek(filePointer, 0, SEEK_END);
        
        //@ 2b2. Get File Size
        bufferSize  = (unsigned int)ftell(filePointer);
        
        #ifndef NDEBUG
        printf("bufferSize (%d)\n", bufferSize);
        #endif  // NDEBUG
        
        //@ 2b3. Replace File Pointer Location to Start of File
        rewind(filePointer);
        
        //@ 2b4. Allocate File Data Buffer Memory
        fileBuffer  = malloc(bufferSize + 1);
        
        //@ 2b5. Store File Data into File Data Buffer
        fread(fileBuffer, 1, bufferSize, filePointer);
        fileBuffer[bufferSize] = '\0';
        
        #ifndef NDEBUG
        unsigned int bufferCount = 0;
        for (bufferCount = 0; bufferCount < bufferSize; bufferCount++)
        {
            printf("%d : %02x\n", bufferCount, fileBuffer[bufferCount]);
        }
        #endif  // NDEBUG

        //@ 2b6. Check Enf of Buffer Flag
        //@ 2b6a. If Flag is Negative
        while (false == endOfBuffer)
        {
            //@ 2b6a1. Check Character Counter
            //@ 2b6a1a. If Counter is less than MAX_LEN_HEX:
            for (charCount = 0; charCount < MAX_LEN_HEX; charCount++)
            {
                //@ 2b6a1a1. Check Current File Data Buffer's Character
                //@ 2b6a1a1a. If Current Character is not Alphabet:
                if (10 > (unsigned int)(fileBuffer[bufferIdx + charCount] - '0'))
                {
                    //@ 2b6a1a1a1. Convert Character to Integer and Save to Instruction Array
                    oInstruction[instructionIdx] |= (unsigned int)((fileBuffer[bufferIdx + charCount] - '0') << mem32LineShift[(bufferIdx + charCount) % 10]);
                }
                //@ 2b6a1a1b. In All Other Cases:
                else
                {
                    //@ 2b6a1a1b1. Call convertAlphabetCharToInteger() and get Alphabet Integer
                    alphabetInt = convertAlphabetCharToInteger(fileBuffer[bufferIdx + charCount]);
                    //@ 2b6a1a1b2. Check Alphabet
                    //@ 2b6a1a1b2a. If Alphabet is not between 'a'('A') and 'f'('F'):
                    if ((unsigned char)FILE_ERROR == alphabetInt)
                    {
                        // 2b6a1a1b2a1. Set File Error Flag to Positive
                        oFileError = true;
                    }
                    //@ 2b6a1a1b3. Store Alphabet Data to Instruction Array
                    oInstruction[instructionIdx] |= (unsigned int)(alphabetInt << mem32LineShift[(bufferIdx + charCount) % 10]);
                }
                //@ 2b6a1a2. Go to 2b6a1
            }
            
            //@ 2b6a2. Check Current File Data Buffer's Character
            //@ 2b6a2a. If Current Character is not CARRIAGE RETURN UNICODE('\r') and is not LINE FEED UNICODE('\n'):
            while ((CARRIAGE_RETURN != fileBuffer[bufferIdx]) && (LINE_FEED != fileBuffer[(bufferIdx + 1)]))
            {
                //@ 2b6a2a1. Add 1 to Buffer Index
                bufferIdx++;
                //@ 2b6a2a2. Go to 2b6a2
            }

            //@ 2b6a3. Add 2 to Buffer Index and Add 1 to Instruction Index
            bufferIdx = bufferIdx + 2;
            instructionIdx++;

            //@ 2b6a4. Check Buffer Index
            //@ 2b6a4a. If Buffer Index is bigger than Buffer Size:
            if ((bufferIdx + 10) > bufferSize)
            {
                //@ 2b6a4a1. Set End of Buffer Flag to Positive
                endOfBuffer = true;
            }
            //@ 2b6a5. Go to 2b6
        }
        oInstruction[instructionIdx]    = '\0';
        *oCount                         = instructionIdx;
        #ifndef NDEBUG
        unsigned char instructionCount = 0;
        for (instructionCount = 0; instructionCount < instructionIdx; instructionCount++)
        {
            printf("%d %08x\n", instructionCount, oInstruction[instructionCount]);
        }        
        #endif  // NDEBUG
    }
    
    //@ 3. Free Allocating File Data Buffer's Memory
    free(fileBuffer);
    fileBuffer = NULL;

    fclose(filePointer);

    return oFileError;
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
            #endif  // NDEBUG
            //@ 2b1. Call getInstruction() and Get Error Flag
            error   = getInstruction(BOOT_LOADER_MEM_PATH, instruction, &lineCount);
            break;
        //@ 2c. For the I_APPLICATION:
        case I_APPLICATION:
            //@ 2c1. Call getInstruction() and Get Error Flag
            error   = getInstruction(APPLICATION_MEM_PATH, instruction, &lineCount);
            break;
        //@ 2d. In All Other Cases:
        default:
            //@ 2d1. Print ERROR LOG
            error   = true;
            printf("[ERROR] Invalid Input (%d)\n", iInput);
            break;
    }
    #ifndef NDEBUG
    printf("MEM File Line (%d)\n", lineCount);
    #endif  // NDEBUG


    //@ 3. Check Error Flag
    //@ 3a. If Flag is Neagtive:
    if (false == error)
    {
        //@ 3a1. Call getOpcode() and Store OPCODE Type per Line
        getOpcode(instruction, disassembly, opcodeType);
    }
    //@ 3b. In All Other Cases:
    else
    {
        //@ 3b1. Print ERROR LOG
        printf("Fail Converting HEX to ASM...\nquit\n");
    }
}
