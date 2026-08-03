#include "assembly.h"
/////////////////////
// Global Variable //
/////////////////////
static char         assembly[MAX_LINE][MAX_LEN] = {0};          // assembly <= File Data
static unsigned int instruction[MAX_LINE]       = {0};          // hex      <= assembly 
static eOpcodeType  opcodeType[MAX_LINE]        = {TYPE_NONE};  // OPCODE TYPE Storage

////////////////////////
// Load Assembly File //
////////////////////////
bool getAssembly(const char* iFileName, char oAssembly[][MAX_LEN], unsigned char* oCount)
{
    bool fError = false;
    FILE *fp    = fopen(iFileName, "r");
    
    if (NULL == fp)
    {
        fError = true;
        printf("[ERROR] File Open Fail : %s\n", iFileName);
    }
    else
    {
        printf("File Open Complete : %s\n", iFileName);
        *oCount = 0;
        while ((*oCount < MAX_LINE) && (NULL != fgets(oAssembly[*oCount], MAX_LEN, fp)))
        {
            oAssembly[*oCount][strcspn(oAssembly[*oCount], "\n")] = '\0';
            (*oCount)++;
        }
        fclose(fp);
    }

    return fError;
}

////////////////////////
// Get OPCODE Command //
////////////////////////
void getOpcodeStr(char* iLineData, char* oOpcodeStr)
{
    char charCount                  = 0;
    
    if ('n' == (iLineData[0]) | ('o' == iLineData[1]) | ('p' == iLineData[2]))
    {
        strcpy(oOpcodeStr, "nop\0");
    }
    else
    {
        while (' ' != iLineData[charCount])
        {
            oOpcodeStr[charCount] = iLineData[charCount];
            charCount++;
        }
        oOpcodeStr[charCount] = '\0';
    }
}

///////////////////////////////////////////////////////////////////////
// Store OPCODE(6-BIT), FUNCT CODE(6-BIT) Value, and Get OPCODE TYPE //
///////////////////////////////////////////////////////////////////////
void getOpcodeAndTypeAndFunct(char* iOpcodeStr, unsigned int* oInstruction, eOpcodeType* oOpcodeType)
{
    if (0 == strcmp(iOpcodeStr, "sll\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SLL;
        *oOpcodeType    = TYPE_SHIFT;
    }
    else if (0 == strcmp(iOpcodeStr, "srl\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SRL;
        *oOpcodeType    = TYPE_SHIFT;  
    }
    else if (0 == strcmp(iOpcodeStr, "sra\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SRA;
        *oOpcodeType    = TYPE_SHIFT;  
    }
    else if (0 == strcmp(iOpcodeStr, "sllv\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SLLV;
        *oOpcodeType    = TYPE_SHIFT;
    }
    else if (0 == strcmp(iOpcodeStr, "srlv\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SRLV;
        *oOpcodeType    = TYPE_SHIFT;
    }
    else if (0 == strcmp(iOpcodeStr, "srav\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SRAV;
        *oOpcodeType    = TYPE_SHIFT;
    }
    else if (0 == strcmp(iOpcodeStr, "jr\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_JR;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "mfhi\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_MFHI;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "mflo\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_MFLO;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "mul\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_MUL;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "mulu\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_MULU;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "div\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_DIV;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "divu\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_DIVU;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "add\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_ADD;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "addu\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_ADDU;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "sub\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SUB;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "subu\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SUBU;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "and\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_AND;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "or\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_OR;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "xor\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_XOR;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "nor\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_NOR;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "slt\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SLT;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "sltu\0"))
    {
        *oInstruction   = (unsigned int)FUNCT_SLTU;
        *oOpcodeType    = TYPE_R;
    }
    else if (0 == strcmp(iOpcodeStr, "bgezal\0"))
    {
        *oInstruction   = (unsigned int)OP_REGIMM;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;                   // Modify Required
    }
    else if (0 == strcmp(iOpcodeStr, "j\0"))
    {
        *oInstruction   = (unsigned int)OP_J;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_J;
    }
    else if (0 == strcmp(iOpcodeStr, "jal\0"))
    {
        *oInstruction   = (unsigned int)OP_JAL;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_J;  
    }
    else if (0 == strcmp(iOpcodeStr, "beq\0"))
    {
        *oInstruction   = (unsigned int)OP_BEQ;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "bne\0"))
    {
        *oInstruction   = (unsigned int)OP_BNE;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "addi\0"))
    {
        *oInstruction   = (unsigned int)OP_ADDI;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "addiu\0"))
    {
        *oInstruction   = (unsigned int)OP_ADDIU;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "slti\0"))
    {
        *oInstruction   = (unsigned int)OP_SLTI;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "sltiu\0"))
    {
        *oInstruction   = (unsigned int)OP_SLTIU;
        *oInstruction   = *oInstruction << 26;

        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "andi\0"))
    {
        *oInstruction   = (unsigned int)OP_ANDI;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "ori\0"))
    {
        *oInstruction   = (unsigned int)OP_ORI;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "xori\0"))
    {
        *oInstruction   = (unsigned int)OP_XORI;
        *oInstruction   = *oInstruction << 26;

        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "lui\0"))
    {
        *oInstruction   = (unsigned int)OP_LUI;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_I;  
    }
    else if (0 == strcmp(iOpcodeStr, "lw\0"))
    {
        *oInstruction   = (unsigned int)OP_LW;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_LW;  
    }
    else if (0 == strcmp(iOpcodeStr, "sw\0"))
    {
        *oInstruction   = (unsigned int)OP_SW;
        *oInstruction   = *oInstruction << 26;
        *oOpcodeType    = TYPE_SW;  
    }
    else
    {
        *oOpcodeType    = TYPE_NONE;  
    }
}

//////////////////////////
// Get Registers Number //
//////////////////////////
unsigned int getRegNumber(char* iRegStr)
{
    //@ 1. Init Local Variable
    eRegisters oRegNumber = R_NONE;
    //@ 2. Set Register Number
    if (0 == strcmp(iRegStr, "$zero\0"))
    {
        oRegNumber  = R_ZERO;
    }
    else if (0 == strcmp(iRegStr, "$at\0"))
    {
        oRegNumber  = R_AT;
    }
    else if (0 == strcmp(iRegStr, "$v0\0"))
    {
        oRegNumber  = R_V0;
    }
    else if (0 == strcmp(iRegStr, "$v1\0"))
    {
        oRegNumber  = R_V1;
    }
    else if (0 == strcmp(iRegStr, "$a0\0"))
    {
        oRegNumber  = R_A0;
    }
    else if (0 == strcmp(iRegStr, "$a1\0"))
    {
        oRegNumber  = R_A1;
    }
    else if (0 == strcmp(iRegStr, "$a2\0"))
    {
        oRegNumber  = R_A2;
    }
    else if (0 == strcmp(iRegStr, "$a3\0"))
    {
        oRegNumber  = R_A3;
    }
    else if (0 == strcmp(iRegStr, "$t0\0"))
    {
        oRegNumber  = R_T0;
    }
    else if (0 == strcmp(iRegStr, "$t1\0"))
    {
        oRegNumber  = R_T1;
    }
    else if (0 == strcmp(iRegStr, "$t2\0"))
    {
        oRegNumber  = R_T2;
    }
    else if (0 == strcmp(iRegStr, "$t3\0"))
    {
        oRegNumber  = R_T3;
    }
    else if (0 == strcmp(iRegStr, "$t4\0"))
    {
        oRegNumber  = R_T4;
    }
    else if (0 == strcmp(iRegStr, "$t5\0"))
    {
        oRegNumber  = R_T5;
    }
    else if (0 == strcmp(iRegStr, "$t6\0"))
    {
        oRegNumber  = R_T6;
    }
    else if (0 == strcmp(iRegStr, "$t7\0"))
    {
        oRegNumber  = R_T7;
    }
    else if (0 == strcmp(iRegStr, "$s0\0"))
    {
        oRegNumber  = R_S0;
    }
    else if (0 == strcmp(iRegStr, "$s1\0"))
    {
        oRegNumber  = R_S1;
    }
    else if (0 == strcmp(iRegStr, "$s2\0"))
    {
        oRegNumber  = R_S2;
    }
    else if (0 == strcmp(iRegStr, "$s3\0"))
    {
        oRegNumber  = R_S3;
    }
    else if (0 == strcmp(iRegStr, "$s4\0"))
    {
        oRegNumber  = R_S4;
    }
    else if (0 == strcmp(iRegStr, "$s5\0"))
    {
        oRegNumber  = R_S5;
    }
    else if (0 == strcmp(iRegStr, "$s6\0"))
    {
        oRegNumber  = R_S6;
    }
    else if (0 == strcmp(iRegStr, "$s7\0"))
    {
        oRegNumber  = R_S7;
    }
    else if (0 == strcmp(iRegStr, "$t8\0"))
    {
        oRegNumber  = R_T8;
    }
    else if (0 == strcmp(iRegStr, "$t9\0"))
    {
        oRegNumber  = R_T9;
    }
    else if (0 == strcmp(iRegStr, "$k0\0"))
    {
        oRegNumber  = R_K0;
    }
    else if (0 == strcmp(iRegStr, "$k1\0"))
    {
        oRegNumber  = R_K1;
    }
    else if (0 == strcmp(iRegStr, "$gp\0"))
    {
        oRegNumber  = R_GP;
    }
    else if (0 == strcmp(iRegStr, "sp\0"))
    {
        oRegNumber  = R_SP;
    }
    else if (0 == strcmp(iRegStr, "$fp\0"))
    {
        oRegNumber  = R_FP;
    }
    else if (0 == strcmp(iRegStr, "$ra\0"))
    {
        oRegNumber  = R_RA;
    }
    else if (iRegStr[0] == '\0')   // case for lui
    {
        //printf("[DEBUG] LUI\n");
        oRegNumber  = R_ZERO;
    }
    else
    {
        oRegNumber  = R_NONE;
        printf("[ERROR] Could Not Find Registers Numbers");
        printf(" : %s\n", iRegStr);
    }

    return (unsigned int)oRegNumber;
}

////////////////////////////
// Store rd or rs (5-BIT) //
////////////////////////////
void getRdOrRs(char* iLineData, unsigned int* oInstruction)
{
    //@ 1. Init Local Variable
    char            charCount           = 0;
    char            regCount            = 0;
    char            regStr[REG_STR_LEN] = {0};
    unsigned int    regNumber           = (unsigned int)R_NONE;
    unsigned int    functCode           = 0;
    //@ 2. Skip OPCODE Part
    while (' ' != iLineData[charCount])
    {
        charCount++;
    }
    charCount++;
    //@ 3. Get Funct Code Number
    functCode = *oInstruction;
    //@ 3a. If Funct Code is not FUNCT_JR:
    if ((unsigned int)FUNCT_JR != functCode)
    {
        //@ 3a1. Get Register Number until Find ','
        while (',' != iLineData[charCount])
        {                   
            regStr[regCount]= iLineData[charCount];
            charCount++;
            regCount++;
        }
        regStr[regCount]= '\0';
        regNumber       = getRegNumber(regStr) << 11;
    }
    //@ 3b. In All Other Cases:
    else
    {
        //@ 3b1. Get Register Number until End of Line
        while ('\0' != iLineData[charCount])
        {                   
            regStr[regCount]= iLineData[charCount];
            charCount++;
            regCount++;
        }
        regStr[regCount]= '\0';
        regNumber       = getRegNumber(regStr) << 21;
    }
    //@ 4. Save Register Number in Instruction
    *oInstruction   = *oInstruction | regNumber;
}

///////////////////////////
// Store rt & rs (5-BIT) //
///////////////////////////
void getRtRs(char* iLineData, eOpcodeType iOpcodeType, unsigned int* oInstruction)
{
    //@ 1. Init Local Variable
    char            charCount           = 0;
    char            rtCount             = 0;
    char            rsCount             = 0;
    char            rtStr[REG_STR_LEN]  = {0};
    char            rsStr[REG_STR_LEN]  = {0};
    unsigned int    rtNumber            = (unsigned int)R_NONE;
    unsigned int    rsNumber            = (unsigned int)R_NONE;
    unsigned int    opcode              = (unsigned int)OP_NONE;
    //@ 2. Skip OPCODE Part
    while (' ' != iLineData[charCount])
    {
        charCount++;
    }
    charCount++;
    //@ 3. Get Rt and Rs Register for each Opcode Type
    switch(iOpcodeType)
    {
        //@ 3a. For the TYPE_R:
        case TYPE_R:
            //@ 3a1. Skip Rd Register Part
            while (',' != iLineData[charCount])
            {
                charCount++;
            }
            charCount = charCount + 2;
            //@ 3a2. Get Rs Register
            while (',' != iLineData[charCount])
            {
                rsStr[rsCount] = iLineData[charCount];
                charCount++;
                rsCount++;
            }
            rsStr[rsCount]  = '\0';
            //@ 3a3. Get Rs Register Number
            rsNumber        = getRegNumber(rsStr) << 21;
            //@ 3a4. Save Rs Register Number in Instruction
            *oInstruction   = *oInstruction | rsNumber;
            charCount = charCount + 2;
            //@ 3a5. Get Rt Register
            while ('\0' != iLineData[charCount])
            {
                rtStr[rtCount] = iLineData[charCount];
                charCount++;
                rtCount++;
            }
            rtStr[rtCount]  = '\0';
            //@ 3a6. Get Rt Register Number
            rtNumber        = getRegNumber(rtStr) << 16;
            //@ 3a7. Save Rt Register Number in Instruction
            *oInstruction   = *oInstruction | rtNumber;
            break;
        //@ 3b. For the TYPE_SHIFT:
        case TYPE_SHIFT:
            //@ 3b1. TBD
            break;
        //@ 3c. For the TYPE_I:
        case TYPE_I:
            //@ 3c1. Get Opcode Number 
            opcode = *oInstruction >> 26;
            //@ 3c1a. If Opocde Number is OP_BEQ or OP_BNE:
            if (((unsigned int)OP_BEQ == opcode) | ((unsigned int)OP_BNE == opcode))
            {
                //@ 3c1a1. Get Rs - Rt Register
                while (',' != iLineData[charCount])
                {
                    rsStr[rsCount] = iLineData[charCount];
                    charCount++;
                    rsCount++;
                }
                rsStr[rsCount]  = '\0';
                charCount       = charCount + 2;
                while (',' != iLineData[charCount])
                {
                    rtStr[rtCount] = iLineData[charCount];
                    charCount++;
                    rtCount++;
                }
                rtStr[rtCount]  = '\0';
            }
            //@ 3c1b. If Opcode Number is OP_LUI:
            else if ((unsigned int)OP_LUI == opcode)
            {
                //@ 3c1b1. Get Rt Register
                while (',' != iLineData[charCount])
                {
                    rtStr[rtCount] = iLineData[charCount];
                    charCount++;
                    rtCount++;
                }
                rtStr[rtCount] = '\0';
                rsStr[rsCount] = '\0';  // lui doesn't have rs
            }
            //@ 3c1c. In All Other Cases:
            else
            {
                //@ 3c1c1. Get Rt - Rs Register
                while (',' != iLineData[charCount])
                {
                    rtStr[rtCount] = iLineData[charCount];
                    charCount++;
                    rtCount++;
                }
                rtStr[rtCount]  = '\0';
                charCount       = charCount + 2;
                while (',' != iLineData[charCount])
                {
                    rsStr[rsCount] = iLineData[charCount];
                    charCount++;
                    rsCount++;
                }
                rsStr[rsCount]  = '\0';
            }
            //@ 3c2. Get Rt and Rs Register Number
            rtNumber    = getRegNumber(rtStr) << 16;
            rsNumber    = getRegNumber(rsStr) << 21;
            //@ 3c3. Save Rt and Rs Register Number in Instruction
            *oInstruction   = *oInstruction | rtNumber;
            *oInstruction   = *oInstruction | rsNumber;            
            break;
        //@ 3d. For the TYPE_LW or TYPE_SW:
        case TYPE_LW:
        case TYPE_SW:
            //@ 3d1. Get Rt and Rs Register
            while (',' != iLineData[charCount])
            {
                rtStr[rtCount] = iLineData[charCount];
                charCount++;
                rtCount++;
            }
            rtStr[rtCount] = '\0';
            while ('(' != iLineData[charCount])
            {
                charCount++;
            }
            charCount++;
            while (')' != iLineData[charCount])
            {
                rsStr[rsCount] = iLineData[charCount];
                charCount++;
                rsCount++;
            }
            rsStr[rsCount]  = '\0';
            //@ 3d2. Get Rt and Rs Register Number
            rtNumber        = getRegNumber(rtStr) << 16;
            rsNumber        = getRegNumber(rsStr) << 21;
            //@ 3d3. Save Rt and Rs Register Number in Instruction
            *oInstruction   = *oInstruction | rtNumber;
            *oInstruction   = *oInstruction | rsNumber;
            break;
        default:
            break;
    }
}

////////////////////////////
// Store Imm(16-BIT) Data //
////////////////////////////
void getImm(char* iLineData, eOpcodeType iOpcodeType, unsigned int* oInstruction)
{
    //@ 1. Init Local Variable
    char            charCount           = 0;
    char            immCount            = 0;
    char            immStr[IMM_STR_LEN] = {0};  
    int             immData             = 0;
    int             negOffset           = 0x0000FFFF;
    unsigned int    opcode              = (unsigned int)OP_NONE; 
    //@ 2. Skip OPCODE Part
    while (',' != iLineData[charCount])
    {
        charCount++;
    }
    charCount++;
    //@ 3. Get Imm Data for each Opcode Type
    switch (iOpcodeType)
    {
        //@ 3a. For the TYPE_I:
        case TYPE_I:
            //@ 3a1. Get Opcode Number
            opcode = *oInstruction >> 26;
            //@ 3a1a. If Opcode Number is OP_LUI:
            if ((unsigned int)OP_LUI == opcode)
            {
                //@ 3a1a1. Get Imm String
                while ('\0' != iLineData[charCount])
                {
                    immStr[immCount] = iLineData[charCount];
                    charCount++;
                    immCount++;
                }
            }
            //@ 3a1b. In All Other Cases:
            else
            {
                //@ 3a1b1. Get Imm String
                while (',' != iLineData[charCount])
                {
                    charCount++;
                }
                charCount = charCount + 2;
                while ('\0' != iLineData[charCount])
                {
                    immStr[immCount] = iLineData[charCount];
                    charCount++;
                    immCount++;
                }
            }
            break;
        //@ 3b. For the TYPE_LW or TYPE_SW:
        case TYPE_LW:
        case TYPE_SW:
            charCount++;
            //@ 3b1. Get Imm String
            while ('(' != iLineData[charCount])
            {
                immStr[immCount] = iLineData[charCount];
                charCount++;
                immCount++;
            }
            break;
        default:
            break;
    }
    immStr[immCount]    = '\0';
    //@ 4. Convert Imm Data String to Integer
    immData             = atoi(immStr);
    //@ 4a. If Imm Data is Positive Value:
    if (immData > 0)
    {
        //@ 4a1. Add Imm Data to Instruction
        *oInstruction   = *oInstruction | immData;
    }
    //@ 4b. In All Other Cases:
    else
    {
        //@ 4b1. Set Neative Offset to Imm Data
        immData         = immData       & negOffset;
        //@ 4b2. Add Imm Data to Instruction
        *oInstruction   = *oInstruction | immData;
    }
    //printf("DEBUG : immData : %08x\n", immData);
}

/////////////////////////////////
// Store Jump Address (26-BIT) //
/////////////////////////////////
void getJaddr(char* iLineData, unsigned int* oInstruction)
{
    //@ 1. Init Local Variable
    char            charCount               = 0;
    char            jaddrCount              = 0;
    char            jaddrStr[JADDR_STR_LEN] = {0};
    unsigned int    jaddrData               = 0;
    //@ 2. Skip OPCODE Part
    while (' ' != iLineData[charCount])
    {
        charCount++;
    }
    charCount++;
    //@ 3. Get Jump Address String Value
    while ('\0' != iLineData[charCount])
    {
        jaddrStr[jaddrCount] = iLineData[charCount];
        charCount++;
        jaddrCount++;
    }
    jaddrStr[jaddrCount]    = '\0';
    //@ 4. Convert Jump Address Data String to Unsigned Integer
    jaddrData               = (unsigned int)atoi(jaddrStr);
    //@ 5. Add Jump Address to Instruction
    *oInstruction   = *oInstruction | jaddrData;
}

////////////////////
// Make Text File //
////////////////////
void setHexTextFile(const char* oFileName, unsigned int* iInstruction, unsigned char iCount, eInput iInput)
{
    FILE*           fp = fopen(oFileName, "w");
    if (NULL == fp)
    {
        printf("[ERROR] File Open Fail : %s\n", oFileName);
    }
    if (I_BOOT_ROM == iInput)
    {
        unsigned int lineBuffer     = 0;
        unsigned int bytesOffset[4] = {0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000};
        for (unsigned char count = 0; count < iCount; count++)
        {
            for (unsigned char bytes = 0; bytes < 4; bytes++)
            {
                lineBuffer = bytesOffset[bytes] & iInstruction[count];
                lineBuffer = lineBuffer >> (8 * bytes);
                fprintf(fp, "%02x\n", lineBuffer);
            }
        }
        // Zero-Setting
        iCount = (unsigned int)iCount;
        if (iCount < BOOT_ROM_SIZE / 4)
        {
            for (unsigned int count = iCount * 4; count < BOOT_ROM_SIZE; count++)
            {
                fprintf(fp, "%02x\n", 0);   // Set Zero
            }
        }
    }
    else
    {
        for (char count = 0; count < iCount; count++)
        {
            fprintf(fp, "%08x\n", iInstruction[count]);
        }
    }
    fclose(fp);
    printf("Create %s Complete\n", oFileName);
}

//////////////////
// Convert Main //
//////////////////
void convert(eInput iInput)
{
    //@ 1. Init Local Variable
    unsigned char   lineCount  = 0;     // Text File Line Counter
    bool            error      = false; // File Open Error Flag
    
    //@ 2.  Check User Input
    switch (iInput)
    {
        //@ 2a. For the I_NONE:
        case I_NONE:
            //@ 2a1. Print ERROR
            printf("[ERROR] Invalid Input (%d)\n", iInput);
            break;
        //@ 2b. For the I_BOOT_ROM:
        case I_BOOT_ROM:
            //@ 2b1. Call getAssembly() and Get Error Flag
            error   = getAssembly(BOOT_ROM_TEXT_PATH, assembly, &lineCount);
            break;
        //@ 2c. For the I_BOOT_LOADER:
        case I_BOOT_LOADER:
            //@ 2c1. Call getAssembly() and Get Error Flag
            error   = getAssembly(BOOT_LOADER_TEXT_PATH, assembly, &lineCount);
            break;
        //@ 2d. For the I_APPLICATION:
        case I_APPLICATION:
            //@ 2d1. Call getAssembly() and Get Error Flag
            error   = getAssembly(APPLICATION_TEXT_PATH, assembly, &lineCount);
            break;
        //@ 2e. For the I_DEBUG_MODE:
        case I_DEBUG_MODE:
            //@ 2e1. Call getAssembly() and Get Error Flag
            error   = getAssembly(DEBUG_MODE_TEXT_PATH, assembly, &lineCount);
            break;
        //@ 2f. In All Other Cases:
        default:
            //@ 2f1. Print ERROR
            error   = true;
            printf("[ERROR] Invalid Input (%d)\n", iInput);
            break;
    }
    //@ 3. Check Error Flag
    //@ 3a. If File Open Flag is not Error:
    if (false == error)
    {
        for (unsigned char line = 0; line < lineCount; line++)
        {
            //@ 3a1. Call getOpcodeStr(), and Get OPCODE String Value
            char opcodeStr[OPCODE_STR_LEN] = {0};   // OPCODE Command
            getOpcodeStr(assembly[line], opcodeStr);
            //printf("%s\n", opcodeStr); // DEBUG
            //@ 3a2. Check OPCODE String Value
            //@ 3a2a. If OPCODE String is not NOP:
            if (0 != strcmp(opcodeStr, "nop\0"))
            {
                //printf("Before : %08x\n", instruction[line]); // DEBUG
                //@ 3a2a1. Get OPCODE & OPCODE Type & FUNCT CODE
                getOpcodeAndTypeAndFunct(opcodeStr, &instruction[line], &opcodeType[line]);
            }
            //@ 3a2b. In All Other Cases:
            else
            {
                //@ 3a2b1. Set OPCODE TYPE for TYPE_NOP
                opcodeType[line] = TYPE_NOP;
            }
            //printf("After1  : %08x\n", instruction[line]);   // DEBUG
            //@ 3a3. Check OPCODE Type
            switch(opcodeType[line])
            {
                //@ 3a3a. For the TYPE_NONE:
                case TYPE_NONE:
                    //@ 3a3a1. Print ERROR
                    printf("[ERROR] Could Not Find OPCODE Type, (Line %d)");
                    printf(" : %s\n", line, assembly[line]);
                    break;
                //@ 3a3b. For the TYPE_R:
                case TYPE_R:
                    //@ 3a3b1. Call getRdOrRs() and Get Rd or Rs Register
                    getRdOrRs(assembly[line], &instruction[line]);
                    //@ 3a3b2. Check OPCODE String Value
                    //@ 3a3b2a. If OPCODE is not JUMP:
                    if (0 != strcmp(opcodeStr, "jr\0"))
                    {
                        //@ 3a3b2a1. Call getRtRs() and Get rt and rs Register
                        getRtRs(assembly[line], opcodeType[line], &instruction[line]);
                    }
                    //printf("After2  : %08x\n", instruction[line]);   // DEBUG
                    break;
                //@ 3a3c. For the TYPE_SHIFT:
                case TYPE_SHIFT:
                    //@ 3a3c1. TBD
                    printf("SHIFT Event (line %d)\n", line + 1);
                    break;
                //@ 3a3d. For the TYPE_I orTYPE_LW or TYPE_SW:
                case TYPE_I:
                case TYPE_LW:
                case TYPE_SW:
                    //@ 3a3d1. Get rt and rs Register, and Imm  Data
                    getRtRs(assembly[line], opcodeType[line], &instruction[line]);
                    getImm(assembly[line], opcodeType[line], &instruction[line]);
                    break;
                //@ 3a3e. For the TYPE_J:
                case TYPE_J:
                    //@ 3a3e1. TBD
                    getJaddr(assembly[line], &instruction[line]);
                    break;
                //@ 3a3f. For the TYPE_NOP:
                case TYPE_NOP:
                    //@ 3a3f1. Do Nothing
                    // Do - Nothing
                    break;
                default:
                    break;
            }
            //printf("[%d] After1  : %08x\n", line+1, instruction[line]);   // DEBUG
        }
        //@ 3a4. Check User Input Again and Call setHexTextFile()
        switch (iInput)
        {
            case I_NONE:
                break;
            case I_BOOT_ROM:
                setHexTextFile(BOOT_ROM_MEM_PATH, instruction, lineCount, iInput);
                break;
            case I_BOOT_LOADER:
                setHexTextFile(BOOT_LOADER_MEM_PATH, instruction, lineCount, iInput);
                break;
            case I_APPLICATION:
                setHexTextFile(APPLICATION_MEM_PATH, instruction, lineCount, iInput);
                break;
            case I_DEBUG_MODE:
                setHexTextFile(DEBUG_MODE_MEM_PATH, instruction, lineCount, iInput);
                break;
            default:
                break;
        }
    }
    //@ 3b. In All Other Cases:
    else
    {
        // 3b1. Print "Converting Fail" Info
        printf("Fail Converting...\nquit\n");
    }
}

//////////////////////////////////////
// Path : .\tb\TEST_CASE\convert.c //
//////////////////////////////////////
