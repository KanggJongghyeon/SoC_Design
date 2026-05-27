#include "convert.h"

/////////////////////
// Global Variable //
/////////////////////
static char         assembly[MAX_LINE][MAX_LEN] = {0};          // assembly <= File Data
static unsigned int instruction[MAX_LINE]       = {0};          // hex      <= assembly 
static eOpcodeType  opcodeType[MAX_LINE]        = {TYPE_NONE};  // OPCODE TYPE Storage

////////////////////////
// Load Assembly File //
////////////////////////
void getAssembly(const char* iFileName, char oAssembly[][MAX_LEN], char* oCount)
{
    FILE *fp = fopen(iFileName, "r");
    if (fp == NULL)
    {
        printf("[ERROR] File Open Fail : %s\n", iFileName);
    }
    else
    {
        printf("File Open Complete : %s\n", iFileName);
    }
    *oCount = 0;
    while (*oCount < MAX_LINE && fgets(oAssembly[*oCount], MAX_LEN, fp) != NULL)
    {
        oAssembly[*oCount][strcspn(oAssembly[*oCount], "\n")] = '\0';
        (*oCount)++;
    }
    fclose(fp);
}

////////////////////////
// Get OPCODE Command //
////////////////////////
void getOpcodeStr(char* iLineData, char* oOpcodeStr)
{
    char charCount                  = 0;
    
    if ((iLineData[0] == 'n') | (iLineData[1] == 'o') | (iLineData[2] == 'p'))
    {
        strcpy(oOpcodeStr, "nop\0");
    }
    else
    {
        while (iLineData[charCount] != ' ')
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
    eRegisters oRegNumber = R_NONE;
    
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
    else
    {
        oRegNumber  = R_NONE;
        printf("[ERROR] Could Not Find Registers Numbers");
        printf(" : %s\n", iRegStr);
    }

    return (unsigned int)oRegNumber;
}

/////////////////////
// Store rd(5-BIT) //
/////////////////////
void getRd(char* iLineData, unsigned int* oInstruction)
{
    char            charCount           = 0;
    char            rdCount             = 0;
    char            rdStr[REG_STR_LEN]  = {0};
    unsigned int    rdNumber            = (unsigned int)R_NONE;
    while (iLineData[charCount] != ' ')
    {
        charCount++;
    }
    charCount++;
    while (iLineData[charCount] != ',')
    {
        rdStr[rdCount] = iLineData[charCount];
        charCount++;
        rdCount++;
    }
    rdStr[rdCount]  = '\0';
    rdNumber        = getRegNumber(rdStr) << 11;
    *oInstruction   = *oInstruction | rdNumber;
}

///////////////////////////
// Store rt & rs (5-BIT) //
///////////////////////////
void getRtRs(char* iLineData, eOpcodeType iOpcodeType, unsigned int* oInstruction)
{
    //@ 1. Init Member Variable
    char            charCount           = 0;
    char            rtCount             = 0;
    char            rsCount             = 0;
    char            rtStr[REG_STR_LEN]  = {0};
    char            rsStr[REG_STR_LEN]  = {0};
    unsigned int    rtNumber            = (unsigned int)R_NONE;
    unsigned int    rsNumber            = (unsigned int)R_NONE;
    unsigned int    opcode              = (unsigned int)OP_NONE;
    //@ 2. Skip OPCODE Part
    while (iLineData[charCount] != ' ')
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
            while (iLineData[charCount] != ',')
            {
                charCount++;
            }
            charCount = charCount + 2;
            //@ 3a2. Get Rs Register
            while (iLineData[charCount] != ',')
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
            while (iLineData[charCount] != '\0')
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
            if ((opcode == (unsigned int)OP_BEQ) | (opcode == (unsigned int)OP_BNE))
            {
                //@ 3c1a1. Get Rs - Rt Register
                while (iLineData[charCount] != ',')
                {
                    rsStr[rsCount] = iLineData[charCount];
                    charCount++;
                    rsCount++;
                }
                rsStr[rsCount]  = '\0';
                charCount       = charCount + 2;
                while (iLineData[charCount] != ',')
                {
                    rtStr[rtCount] = iLineData[charCount];
                    charCount++;
                    rtCount++;
                }
                rtStr[rtCount]  = '\0';
            }
            //@ 3c1b. In All Other Cases:
            else
            {
                //@ 3c1b1. Get Rt - Rs Register
                while (iLineData[charCount] != ',')
                {
                    rtStr[rtCount] = iLineData[charCount];
                    charCount++;
                    rtCount++;
                }
                rtStr[rtCount]  = '\0';
                charCount       = charCount + 2;
                while (iLineData[charCount] != ',')
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
            while (iLineData[charCount] != ',')
            {
                rtStr[rtCount] = iLineData[charCount];
                charCount++;
                rtCount++;
            }
            rtStr[rtCount] = '\0';
            while (iLineData[charCount] != '(')
            {
                charCount++;
            }
            charCount++;
            while (iLineData[charCount] != ')')
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
    char    charCount           = 0;
    char    immCount            = 0;
    char    immStr[IMM_STR_LEN] = {0};  
    int     immData             = 0;
    int     negOffset           = 0x0000FFFF;

    while (iLineData[charCount] != ',')
    {
        charCount++;
    }
    charCount++;
    switch (iOpcodeType)
    {
        case TYPE_I:
            while (iLineData[charCount] != ',')
            {
                charCount++;
            }
            charCount = charCount + 2;
            while (iLineData[charCount] != '\0')
            {
                immStr[immCount] = iLineData[charCount];
                charCount++;
                immCount++;
            }
            break;
        case TYPE_LW:
        case TYPE_SW:
            charCount++;
            while (iLineData[charCount] != '(')
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
    immData             = atoi(immStr);
    if (immData > 0)
    {
        *oInstruction   = *oInstruction | immData;
    }
    else
    {
        immData         = immData       & negOffset;
        *oInstruction   = *oInstruction | immData;
    }
    //printf("DEBUG : immData : %08x\n", immData);
}

////////////////////
// Make Text File //
////////////////////
void setHexTextFile(const char* oFileName, unsigned int* iInstruction, char iCount)
{
    FILE *fp = fopen(oFileName, "w");
    if (fp == NULL)
    {
        printf("[ERROR] File Open Fail : %s\n", oFileName);
    }
    for (char count = 0; count < iCount; count++)
    {
        fprintf(fp, "%08x\n", iInstruction[count]);
    }
    fclose(fp);
    printf("Make %s Complete\n", oFileName);
}

//////////////////
// Convert Main //
//////////////////
void convert()
{
    char lineCount = 0; // Text File Line Counter

    // getAssembly()
    getAssembly("test_case_s.txt", assembly, &lineCount);

    for (char line = 0; line < lineCount; line++)
    {
        // getOpcodeStr()
        char opcodeStr[OPCODE_STR_LEN] = {0};   // OPCODE Command
        getOpcodeStr(assembly[line], opcodeStr);
        //printf("%s\n", opcodeStr); // DEBUG
        
        if (0 != strcmp(opcodeStr, "nop\0"))
        {
            //printf("Before : %08x\n", instruction[line]); // DEBUG
            // getOpcodeAndTypeAndFunct()
            getOpcodeAndTypeAndFunct(opcodeStr, &instruction[line], &opcodeType[line]);
        }
        else
        {
            opcodeType[line] = TYPE_NOP;
        }
        //printf("After1  : %08x\n", instruction[line]);   // DEBUG
        switch(opcodeType[line])
        {
            case TYPE_NONE:
                printf("[ERROR] Could Not Find OPCODE Type, (Line %d)");
                printf(" : %s\n", line, assembly[line]);
                break;
            case TYPE_R:
                getRd(assembly[line], &instruction[line]);
                getRtRs(assembly[line], opcodeType[line], &instruction[line]);
                //printf("After2  : %08x\n", instruction[line]);   // DEBUG
                break;
            case TYPE_SHIFT:
                printf("SHIFT Event (line %d)\n", line + 1);
                // TBD
                break;
            case TYPE_I:
                getRtRs(assembly[line], opcodeType[line], &instruction[line]);
                getImm(assembly[line], opcodeType[line], &instruction[line]);
                break;
            case TYPE_LW:
                getRtRs(assembly[line], opcodeType[line], &instruction[line]);
                getImm(assembly[line], opcodeType[line], &instruction[line]);
                break;
            case TYPE_SW:
                getRtRs(assembly[line], opcodeType[line], &instruction[line]);
                getImm(assembly[line], opcodeType[line], &instruction[line]);
                break;
            case TYPE_J:
                printf("JUMP Event (line %d)\n", line + 1);
                // TBD
                break;
            case TYPE_NOP:
                // Do - Nothing
                break;
            default:
                break;
        }
        //printf("[%d] After1  : %08x\n", line+1, instruction[line]);   // DEBUG
    }

    setHexTextFile("test_case_x.txt", instruction, lineCount);
}

//////////////////////////////////////
// Path : .\SIM\TEST_CASE\convert.c //
//////////////////////////////////////
