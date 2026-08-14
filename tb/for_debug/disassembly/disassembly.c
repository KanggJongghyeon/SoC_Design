#include "disassembly.h"
/////////////////////
// Global Variable //
/////////////////////
// Init Global Variable
static unsigned int instruction[MAX_LINE]           = {0};
static char         disassembly[MAX_LINE][MAX_LEN]  = {0};
static eOpcodeType  opcodeType[MAX_LINE]            = {TYPE_NONE};

////////////////////////////
// Generate Assembly File //
////////////////////////////
void genAsm(const char *iOutFile, char (*oDisassembly)[MAX_LEN], unsigned int oCount)
{
    //@ 1. Init Local Variabele
    FILE*   filePointer = NULL;

    //@ 2. Check File Pointer
    //@ 2a. If File Pointer is NULL:
    filePointer = fopen(iOutFile, "w");
    if (NULL == filePointer)
    {
        //@ 2a1. Print ERROR Log
        printf("[ERROR] File Open Fail : %s\n", iOutFile);
    }
    //@ 2b. In All Other Cases:
    else
    {
        //@ 2b1. Write Text File
        for (unsigned short count = 0; count < (unsigned short)oCount; count++)
        {
            fprintf(filePointer, "%s\n", &oDisassembly[count][0]);
        }
        
        //@ 2b2. Print INFO Log
        printf("[INFO] Create %s Complete\n", iOutFile);
    }

    //@ 3. Close File
    fclose(filePointer);
}

////////////////////////
// Disassemble R-Type //
////////////////////////
void disassembleRType(unsigned int instructionLine, char *oDisassemblyLine)
{
    /* R-Type Disassembling Rule 
    <HEX <=> ASM> :
        <opcode_rs_rt_rd_00000_funct <=> opcode rd, rs, rt>
    */

    //@ 1. Init Local Variable
    const char* space       = " \0";    // SPACE
    const char* commaSpace  = ", \0";   // COMMA-SPACE
    eRegisters  rs          = R_NONE;   // Register Number
    eRegisters  rt          = R_NONE;
    eRegisters  rd          = R_NONE;
    char*       rsStr       = NULL;     // Register String
    char*       rtStr       = NULL; 
    char*       rdStr       = NULL; 

    //@ 2. Compute Register Number                                                       
    rs  = (eRegisters)((instructionLine & 0x03E00000) >> 21);// 0000_00ss_sss0_0000_0000_0000_0000_0000
    rt  = (eRegisters)((instructionLine & 0x001F0000) >> 16);// 0000_0000_000t_tttt_0000_0000_0000_0000
    rd  = (eRegisters)((instructionLine & 0x0000F800) >> 11);// 0000_0000_0000_0000_dddd_d000_0000_0000

    //@ 3. Get Register String
    rsStr   = getRegistersStr(rs);
    rtStr   = getRegistersStr(rt);
    rdStr   = getRegistersStr(rd);

    //@ 4. Make Disassembly Text
    strcat(oDisassemblyLine, space);
    strcat(oDisassemblyLine, rdStr);
    strcat(oDisassemblyLine, commaSpace);
    strcat(oDisassemblyLine, rsStr);
    strcat(oDisassemblyLine, commaSpace);
    strcat(oDisassemblyLine, rtStr);

    #ifndef NDEBUG
    printf("R-Type : %s\n", oDisassemblyLine);
    #endif  // NDEBUG
}

////////////////////////////
// Disassemble Shift-Type //
////////////////////////////
void disassembleShiftType(unsigned int instructionLine, char *oDisassemblyLine)
{
    /* Shift-Type Disassembling Rule 
    <HEX <=> ASM> : for Using Register (sllv, srlv, srav)
        <opcode_rs_rt_rd_00000_funct <=> opcode rd, rt, rs>
    <HEX <=> ASM> : for Using Shift Amount (sll, srl, sra)
        <opcode_00_rt_rd_shamt_funct <=> opcode rd, rt, shamt>
     */

    //@ 1. Init Local Variable
    const char*     space       = " \0";        // SPACE
    const char*     commaSpace  = ", \0";       // COMMA-SPACE
    eRegisters      rs          = R_NONE;       // Register Number
    eRegisters      rt          = R_NONE;
    eRegisters      rd          = R_NONE;
    unsigned char   shamt       = 0;            // Shift Amount
    char            shamtStr[3] = {0};          // Shift Amount String
    eFunctCode      funct       = FUNCT_NONE;   // FUNCT CODE
    char*           rsStr       = NULL;         // Register String
    char*           rtStr       = NULL; 
    char*           rdStr       = NULL; 
    char*           r3Str       = NULL;         // Final Third String {rsStr or shamtStr}
   
    //@ 2. Compute rt, rd Register Number and FUNCT CODE
    rt      = (eRegisters)((instructionLine & 0x001F0000) >> 16);   // 0000_0000_000t_tttt_0000_0000_0000_0000
    rd      = (eRegisters)((instructionLine & 0x0000F800) >> 11);   // 0000_0000_0000_0000_dddd_d000_0000_0000
    funct   = (eFunctCode)(instructionLine & 0x0000003F);           // 0000_0000_0000_0000_0000_0000_00ff_ffff

    //@ 3. Get Register String of rt, and rd
    rtStr   = getRegistersStr(rt);
    rdStr   = getRegistersStr(rd);

    //@ 4. Check FUNCT CODE
    //@ 4a. If Disassembling needs Shift Amount:
    if ((FUNCT_SLL == funct) || (FUNCT_SRL == funct) || (FUNCT_SRA == funct))
    {
        //@ 4a1. Compute Shift Amount and Convert to String             
        shamt   = (unsigned char)((instructionLine & 0x000007C0) >> 6); // 0000_0000_0000_0000_0000_0hhh_hh00_0000
        snprintf(&shamtStr[0], sizeof(shamtStr), "%u", shamt);
        r3Str   = &shamtStr[0];
    }
    //@ 4b. If Disassembling needs rs Register:
    else if ((FUNCT_SLLV == funct) || (FUNCT_SRLV == funct) || (FUNCT_SRAV == funct))
    {
        //@ 4b1. Compute rs Register Number and Get rs Register String
        rs      = (eRegisters)((instructionLine & 0x03E00000) >> 21);   // 0000_00ss_sss0_0000_0000_0000_0000_0000
        rsStr   = getRegistersStr(rs);
        r3Str   = &rsStr[0];
    }
    
    //@ 5. Make Disassembly Text
    strcat(oDisassemblyLine, space);
    strcat(oDisassemblyLine, rdStr);
    strcat(oDisassemblyLine, commaSpace);
    strcat(oDisassemblyLine, rtStr);
    strcat(oDisassemblyLine, commaSpace);
    strcat(oDisassemblyLine, r3Str);

    #ifndef NDEBUG
    printf("Shift-Type : %s\n", oDisassemblyLine);
    #endif  // NDEBUG

}

////////////////////////
// Disassemble I-Type //
////////////////////////
void disassembleIType(unsigned int instructionLine, char *oDisassemblyLine, eOpcodeType iOpcodeType)
{
    /* I-Type Disassembling Rule 
    <HEX <=> ASM> : except branch, load/store
        <opcode_rs_rt_imm <=> opcode rt, rs, imm>
    <HEX <=> ASM> : branch
        <opcode_rs_rt_imm <=> opcode rs, rt, imm>
    <HEX <=> ASM> : load/store
        <opcode_rs_rt_imm <=> opcode rt, imm(rs)>
     */

    //@ 1. Init Local Variable
    const char* space               = " \0";    // SPACE
    const char* commaSpace          = ", \0";   // COMMA-SPACE
    const char* openParenthesis     = "(\0";    // Open Parenthesis
    const char* closeParenthesis    = ")\0";    // Close Parenthesis
    eRegisters  rs                  = R_NONE;   // Register Number
    eRegisters  rt                  = R_NONE;
    char*       rsStr               = NULL;     // Register String
    char*       rtStr               = NULL;     
    short       imm                 = 0;        // Imm Data
    char        immStr[IMM_STR_LEN] = {0};      // Imm String

    //@ 2. Compute Imm Data and Convert to String
    imm     = (short)(instructionLine & 0x0000FFFF);
    snprintf(&immStr[0], sizeof(immStr), "%d", imm);

    //@ 3. Check OPCODE Type
    //@ 3a. If OPCODE Type is TYPE_I:
    if (TYPE_I == iOpcodeType)
    {
        //@ 3a1. Compute Register Number and Get Register String                             
        rs      = (eRegisters)((instructionLine & 0x03E00000) >> 21);   // 0000_00ss_sss0_0000_0000_0000_0000_0000
        rt      = (eRegisters)((instructionLine & 0x001F0000) >> 16);   // 0000_0000_000t_tttt_0000_0000_0000_0000
        rsStr   = getRegistersStr(rs);
        rtStr   = getRegistersStr(rt);

        //@ 3b2. Make Disassembly Text
        strcat(oDisassemblyLine, space);
        strcat(oDisassemblyLine, rtStr);
        strcat(oDisassemblyLine, commaSpace);
        strcat(oDisassemblyLine, rsStr);
        strcat(oDisassemblyLine, commaSpace);
        strcat(oDisassemblyLine, immStr);
    }
    //@ 3b. If OPCODE Type is TYPE_LOAD/STORE:
    else if ((TYPE_LOAD == iOpcodeType) || (TYPE_STORE == iOpcodeType))
    {
        //@ 3b1. Compute Register Number and Get Register String                             
        rs      = (eRegisters)((instructionLine & 0x03E00000) >> 21);   // 0000_00ss_sss0_0000_0000_0000_0000_0000
        rt      = (eRegisters)((instructionLine & 0x001F0000) >> 16);   // 0000_0000_000t_tttt_0000_0000_0000_0000
        rsStr   = getRegistersStr(rs);
        rtStr   = getRegistersStr(rt);

        //@ 3b2. Make Disassembly Text
        strcat(oDisassemblyLine, space);
        strcat(oDisassemblyLine, rtStr);
        strcat(oDisassemblyLine, commaSpace);
        strcat(oDisassemblyLine, immStr);
        strcat(oDisassemblyLine, openParenthesis);
        strcat(oDisassemblyLine, rsStr);
        strcat(oDisassemblyLine, closeParenthesis);
    }
    //@ 3c. If OPCODE Type is TYPE_BRANCH:
    else if (TYPE_BRANCH == iOpcodeType)
    {
        //@ 3c1. Compute Register Number and Get Register String                                 
        rs      = (eRegisters)((instructionLine & 0x03E00000) >> 21);   // 0000_00ss_sss0_0000_0000_0000_0000_0000
        rt      = (eRegisters)((instructionLine & 0x001F0000) >> 16);   // 0000_0000_000t_tttt_0000_0000_0000_0000
        rsStr   = getRegistersStr(rs);
        rtStr   = getRegistersStr(rt);

        //@ 3c2. Make Disassembly Text
        strcat(oDisassemblyLine, space);
        strcat(oDisassemblyLine, rsStr);
        strcat(oDisassemblyLine, commaSpace);
        strcat(oDisassemblyLine, rtStr);
        strcat(oDisassemblyLine, commaSpace);
        strcat(oDisassemblyLine, immStr);
    }

    #ifndef NDEBUG
    printf("I-Type : %s\n", oDisassemblyLine);
    #endif  // NDEBUG
}

////////////////////////
// Disassemble J-Type //
////////////////////////
void disassembleJType(unsigned int instructionLine, char *oDisassemblyLine)
{
    /* J-Type Disassembling Rule 
    <HEX <=> ASM> : R-Type (jr)
        <opcode_rs_00_00_00000_funct <=> opcode rs>
    <HEX <=> ASM> : R-Type (jalr)
        <opcode_rs_00_rd_00000_funct <=> opcode rd, rs>
    <HEX <=> ASM> : I-Type (j, jal)
        <opcode_jImm <=> opcode jImm>
     */

    //@ 1. Init Local Variable
    const char*     space                   = " \0";        // SPACE
    const char*     commaSpace              = ", \0";       // COMMA-SPACE
    eRegisters      rs                      = R_NONE;       // Register Number
    eRegisters      rd                      = R_NONE;
    char*           rsStr                   = NULL;         // Register String
    char*           rtStr                   = NULL;     
    char*           rdStr                   = NULL;                 
    eFunctCode      funct                   = FUNCT_NONE;   // FUNCT CODE
    eOpcode         opcode                  = OP_NONE;      // OPCODE
    unsigned int    jImm                    = 0;            // Jump Target
    char            jImmStr[JADDR_STR_LEN]  = {0};          // Jump Target String

    //@ 2. Check OPCODE
    //@ 2a. If OPCODE Type is TYPE_R:
    opcode = (eOpcode)((instructionLine & 0xFC000000) >> 26);   // oooo_oo00_0000_0000_0000_0000_0000_0000
    if (OP_RTYPE == opcode)
    {
        //@ 2a1. Compute rs Register Number and Get Register String                            
        rs      = (eRegisters)((instructionLine & 0x03E00000) >> 21);   // 0000_00ss_sss0_0000_0000_0000_0000_0000
        rsStr   = getRegistersStr(rs);
        
        //@ 2a2. Check FUNCT CODE
        //@ 2a2a. If FUNCT CODE is FUNCT_JR:
        funct = (eFunctCode)(instructionLine & 0x0000003F);
        if (FUNCT_JR == funct)
        {
            //@ 2a2a1. Make Disassembly Text
            strcat(&oDisassemblyLine[0], space);
            strcat(&oDisassemblyLine[0], rsStr);            
        }
        //@ 2a2b. If FUNCT CODE is FUNCT_JALR:
        else if (FUNCT_JALR == funct)
        {
            //@ 2a2b1. Check rd Register Number
            //@ 2a2b1a. If rd is R_RA:
            rd  = (eRegisters)((instructionLine & 0x0000F800) >> 11);   // 0000_0000_0000_0000_dddd_d000_0000_0000
            if (R_RA == rd)
            {
                //@ 2a2b1a1. Make Disassembly Text
                strcat(&oDisassemblyLine[0], space);
                strcat(&oDisassemblyLine[0], rsStr);   
            }
            //@ 2a2b1b. In All Other Cases:
            else
            {
                //@ 2a2b1b1. Get rd Register String
                rdStr   = getRegistersStr(rd);

                //@ 2a2b1b2. Make Disassembly Text
                strcat(&oDisassemblyLine[0], space);
                strcat(&oDisassemblyLine[0], rdStr);   
                strcat(&oDisassemblyLine[0], commaSpace);
                strcat(&oDisassemblyLine[0], rsStr);   
            }
        }
    }
    //@ 2b. In All Other Cases:
    else
    {
        //@ 2b1. Compute Jump Target and Convert to String
        jImm    = (instructionLine & 0x03FFFFFF);
        snprintf(&jImmStr[0], sizeof(jImmStr), "%u", jImm);

        //@ 2b2. Make Disassembly Text
        strcat(&oDisassemblyLine[0], space);
        strcat(&oDisassemblyLine[0], jImmStr);
    }
                                                                
    #ifndef NDEBUG
    printf("J-Type : %s\n", oDisassemblyLine);
    #endif  // NDEBUG
}

void disassembleRegimmType(unsigned int instructionLine, char *oDisassemblyLine)
{
    /* REGIMM-Type Disassembling Rule 
    <HEX <=> ASM> : except branch, load/store
        <opcode_rs_rt_imm <=> opcode rs, imm>
     */

    //@ 1. Init Local Variable
    const char* space               = " \0";    // SPACE
    const char* commaSpace          = ", \0";   // COMMA-SPACE
    eRegisters  rs                  = R_NONE;   // Register Number
    char*       rsStr               = NULL;     // Register String
    short       imm                 = 0;        // Imm Data
    char        immStr[IMM_STR_LEN] = {0};      // Imm String

    //@ 2. Compute rs Register Number and Get Register String                                                       
    rs      = (eRegisters)((instructionLine & 0x03E00000) >> 21);// 0000_00ss_sss0_0000_0000_0000_0000_0000
    rsStr   = getRegistersStr(rs);

    //@ 3. Compute Imm Data and Convert to String
    imm     = (short)(instructionLine & 0x0000FFFF);
    snprintf(&immStr[0], sizeof(immStr), "%d", imm);

    //@ 4. Make Disassembly Text
    strcat(oDisassemblyLine, space);
    strcat(oDisassemblyLine, rsStr);
    strcat(oDisassemblyLine, commaSpace);
    strcat(oDisassemblyLine, immStr);

    #ifndef NDEBUG
    printf("REGIMM-Type : %s\n", &oDisassemblyLine[0]);
    #endif  // NDEBUG    

}

/////////////////////
// Get OPCODE Type //
/////////////////////
eOpcodeType getOpcodeType(eOpcode iOpcode, eFunctCode iFunctCode)
{
    //@ 1. Init Local Variable
    eOpcodeType oOpcodeType = TYPE_NONE;    // Output

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
                //@ 2a1b. For the FUNCT_MFHI/MFLO/MUL/MULU/DIV/DIVU/ADD/ADDU/SUB/SUBU/AND/OR/XOR/NOR/SLT/SLTU:
                case FUNCT_MFHI:
                case FUNCT_MFLO:
                case FUNCT_MULT: 
                case FUNCT_MULTU:
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
                    //@ 2a1b1. Set OPCODE Type to TYPE_R
                    oOpcodeType = TYPE_R;
                    break;
                //@ 2a1c. For the FUNCT_JR:
                case FUNCT_JR:
                case FUNCT_JALR:
                    //@ 2a1c1. Set OPCODE Type to TYPE_J
                    oOpcodeType = TYPE_J;
                    break;
                //@ 2a1d. In All Other Cases:
                default:
                    //@ 2a1d1. Print ERROR LOG and Set OPCODE TYPE to TYPE_NOP
                    printf("[ERROR] Unknown FUNCT CODE (0x%02x)(=%d)\n", iFunctCode, iFunctCode);
                    oOpcodeType = TYPE_NOP;
                    break;
            }
            break;
        //@ 2b. For the ADDI/ADDIU/SLTI/SLTIU/ANDI/ORI/XORI/LUI:
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
        //@ 2d. For the OP_LB/LH/LW/LBU/LHU:
        case OP_LB:
        case OP_LH:
        case OP_LW:
        case OP_LBU:
        case OP_LHU:
            //@ 2d1. Set OPCODE Type to TYPE_LOAD
            oOpcodeType = TYPE_LOAD;
            break;
        //@ 2e. For the OP_SB/SH/SW:
        case OP_SB:
        case OP_SH:
        case OP_SW:
            //@ 2e1. Set OPCODE Type to TYPE_STORE
            oOpcodeType = TYPE_STORE;
            break;
        //@ 2f. For the OP_BEQ/BNE:
        case OP_BEQ:  
        case OP_BNE:        
            //@ 2f1. Set OPCODE Type to TYPE_BRANCH
            oOpcodeType = TYPE_BRANCH;
            break;
        //@ 2g. For the OP_REGIMM:
        case OP_REGIMM:
            //@ 2g1. Set OPCODE Type to TYPE_REGIMM
            oOpcodeType = TYPE_REGIMM;
            break;
        //@ 2h. In All Other Cases:
        default:
            //@ 2h1. Print ERROR LOG and Set OPCODE Type to TYPE_NOP
            printf("[ERROR] Unknown OPCODE (0x%02x)(=%d)\n", iOpcode, iOpcode);
            oOpcodeType = TYPE_NOP;
            break;
    }

    return oOpcodeType;
}


////////////////
// Get OPCODE //
////////////////
void getOpcode(unsigned int *iInstruction, char (*oDisassembly)[MAX_LEN], eOpcodeType *oOpcodeType, unsigned int iTotalLine)
{
    //@ 1. Init Local Variable
    unsigned int    instructionCount    = 0;            // Instruction Count
    eOpcode         opcode              = OP_NONE;      // OPCODE
    eFunctCode      functCode           = FUNCT_NONE;   // FUNCT CODE
    char*           nop                 = "nop\0";      // NOP
    char*           error               = "error\0";    // ERROR
    eRegimm         regimm              = REGIMM_NONE;  // REGIMM Type OPCODE

    //@ 2. Check Instruction Count
    //@ 2a. If Current Count is End of Instruction Line:
    while (instructionCount < iTotalLine)
    {   
        //@ 2a1. Check Instruction
        //@ 2a1a. If Instruction is 0x00000000:
        if (0 == iInstruction[instructionCount])
        {   
            //@ 2a1a1. Store "nop" into Disassembly Array
            oOpcodeType[instructionCount]   = TYPE_NOP;
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
                strcpy(oDisassembly[instructionCount], error);
                printf("So Set \"error\" in instruction[%d] line\n", instructionCount);
            }
            //@ 2a1b2b. If OPCODE Type is TYPE_REGIMM
            else if (TYPE_REGIMM == oOpcodeType[instructionCount])
            {
                //@ 2a1b2b1. Compute rt Register for Decide REGIMM OPCODE and Store OPCODE String into Disassembly Array
                regimm  = (eRegimm)((*(instruction + instructionCount) & 0x001F0000) >> 16);   // rt Register can decide regimm opcode 
                getRegimmOpcodeStr(regimm, &oDisassembly[instructionCount][0]);
            }
            //@ 2a1b2c. In All Other Cases:
            else
            {
                //@ 2a1b2c1. Store OPCODE String into Disassembly Array
                getOpcodeStr(opcode, functCode, &oDisassembly[instructionCount][0]);
            }
        }
        instructionCount++;
        //@ 2a2. Go to 2
        #ifndef NDEBUG
        printf("[%d] %s\n", (instructionCount - 1), oDisassembly[(instructionCount - 1)]);
        #endif  // NDEBUG        
    }
}

//////////////////////////////////////
// Convert Hexa Alphabet to Integer //
//////////////////////////////////////
unsigned int convertAlphabetCharToInteger(char iChar)
{
    //@ 1. Init Local Variable
    unsigned int oInteger;  // Output
    
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
bool getInstruction(const char *iFile, unsigned int *oInstruction, unsigned int *oCount)
{
    //@ 1. Init Local Variable
    bool            oFileError      = false;    // Output Value
    FILE*           filePointer     = NULL;     // File Pointer
    char*           fileBuffer      = NULL;     // File Data Buffer
    unsigned int    bufferSize      = 0;        // Size of FileBuffer
    bool            endOfBuffer     = false;    // Flag of End of Buffer
    unsigned int    bufferIdx       = 0;        // Buffer Index
    unsigned int    instructionIdx  = 0;        // Instruction Index
    unsigned int    alphabetInt     = 0;        // Output Value of convertAlphabetCharToInteger()

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
        for (unsigned int bufferCount = 0; bufferCount < bufferSize; bufferCount++)
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
            for (unsigned int charCount = 0; charCount < MAX_LEN_HEX; charCount++)
            {
                //@ 2b6a1a1. Check Current File Data Buffer's Character
                //@ 2b6a1a1a. If Current Character is not Alphabet:
                if (10 > (unsigned int)(fileBuffer[bufferIdx + charCount] - '0'))
                {
                    //@ 2b6a1a1a1. Convert Character to Integer Calling getShiftLeftConstatnt() and Save to Instruction Array
                    oInstruction[instructionIdx] |= (unsigned int)((fileBuffer[bufferIdx + charCount] - '0') << getShiftLeftConstant((bufferIdx + charCount)));
                }
                //@ 2b6a1a1b. In All Other Cases:
                else
                {
                    //@ 2b6a1a1b1. Call convertAlphabetCharToInteger() and get Alphabet Integer
                    alphabetInt = convertAlphabetCharToInteger(fileBuffer[bufferIdx + charCount]);
                    //@ 2b6a1a1b2. Check Alphabet
                    //@ 2b6a1a1b2a. If Alphabet is not between 'a'('A') and 'f'('F'):
                    if ((unsigned int)FILE_ERROR == alphabetInt)
                    {
                        // 2b6a1a1b2a1. Set File Error Flag to Positive
                        oFileError = true;
                    }
                    //@ 2b6a1a1b3. Call getShiftLeftConstant() and Store Alphabet Data to Instruction Array
                    oInstruction[instructionIdx] |= alphabetInt << getShiftLeftConstant((bufferIdx + charCount));
                }
                //@ 2b6a1a2. Go to 2b6a1
            }
            
            #ifndef NDEBUG
            printf("[%d] : Buffer Index = %d\n", instructionIdx, bufferIdx);
            #endif  // NDEBUG

            //@ 2b6a2. Check Current File Data Buffer's Character
            #ifndef CRLF_FLAG   // Case 0 : Memory File Made by Linux
            //@ 2b6a2a. If Current Character is not LINE FEED UNICODE('\n'):
            while (LINE_FEED != fileBuffer[bufferIdx])
            {
                //@ 2b6a2a1. Add 1 to Buffer Index
                bufferIdx++;
                //@ 2b6a2a2. Go to 2b6a2
            }

            //@ 2b6a3. Add Buffer Index and Instruction Index
            bufferIdx = bufferIdx + 1;  // Jump Only LF
            instructionIdx++;
            #else   // CRLF_FLAG    // Case 1 : Memory File Made by Windows
            //@ 2b6a2a. If Current Character is not LINE FEED UNICODE('\n') or Next Characetr is not Carriage Return('\r'):
            while ((CARRIAGE_RETURN != fileBuffer[bufferIdx]) || (LINE_FEED != fileBuffer[(bufferIdx + 1)]))
            {
                //@ 2b6a2a1. Add 1 to Buffer Index
                bufferIdx++;
                //@ 2b6a2a2. Go to 2b6a2
            }

            //@ 2b6a3. Add Buffer Index and Instruction Index
            bufferIdx = bufferIdx + 2;  // Jump CR and LF
            instructionIdx++;
            #endif  // CRLF_FLAG

            //@ 2b6a4. Check Buffer Index
            //@ 2b6a4a. If Buffer Index is bigger than Buffer Size:
            if ((bufferIdx + MAX_LEN_HEX) > bufferSize)
            {
                //@ 2b6a4a1. Set End of Buffer Flag to Positive
                endOfBuffer = true;
            }
            //@ 2b6a5. Go to 2b6
        }
        oInstruction[instructionIdx]    = '\0';
        *oCount                         = instructionIdx;
        
        #ifndef NDEBUG
        for (unsigned short instructionCount = 0; instructionCount < instructionIdx; instructionCount++)
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
    unsigned int    lineCount   = 0;    // Total Line of File
    bool            error       = false;// ERROR Flag

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
            //@ 2b1. Call getInstruction() and Get Error Flag
            error   = getInstruction(&BOOT_LOADER_MEM_PATH[0], &instruction[0], &lineCount);
            break;
        //@ 2c. For the I_APPLICATION:
        case I_APPLICATION:
            //@ 2c1. Call getInstruction() and Get Error Flag
            error   = getInstruction(&APPLICATION_MEM_PATH[0], &instruction[0], &lineCount);
            break;
        //@ 2d. In All Other Cases:
        default:
            //@ 2d1. Print ERROR LOG
            error   = true;
            printf("[ERROR] Invalid Input (%d)\n", iInput);
            break;
    }

    #ifndef NDEBUG
    printf("Number of MEM File Line (%d)\n", lineCount);
    #endif  // NDEBUG

    //@ 3. Check Error Flag
    //@ 3a. If Flag is Neagtive:
    if (false == error)
    {
        //@ 3a1. Call getOpcode() and Store OPCODE Type per Line
        getOpcode(&instruction[0], &disassembly[0], &opcodeType[0], lineCount);
        
        //@ 3a2. Check OPCODE Type for each Line
        for (unsigned short line = 0; line < lineCount; line++)
        {
            switch(opcodeType[line])
            {
                //@ 3a2a. For the TYPE_NONE:
                case TYPE_NONE:
                    //@ 3a2a1. Print ERROR LOG
                    printf("[ERROR] Line [%d] : Undefined OPCODE %02x\n", line, (instruction[line] >> 26));
                    break;
                //@ 3a2b. For the TYPE_R:
                case TYPE_R:
                    disassembleRType(instruction[line], &disassembly[line][0]);
                    break;
                // 3a2c. For the TYPE_SHIFT: 
                case TYPE_SHIFT:
                    disassembleShiftType(instruction[line], &disassembly[line][0]);
                    break;
                //@ 3a2d. For the TYPE_I/BRANCH/LOAD/STORE:
                case TYPE_I:
                case TYPE_BRANCH:
                case TYPE_LOAD:
                case TYPE_STORE:
                    disassembleIType(instruction[line], &disassembly[line][0], opcodeType[line]);
                    break;
                //@ 3a2e. For the TYPE_J:
                case TYPE_J:
                    disassembleJType(instruction[line], &disassembly[line][0]);
                    break;
                //@ 3a2f. For the TYPE_REGIMM:
                case TYPE_REGIMM:
                    disassembleRegimmType(*(instruction + line), &disassembly[line][0]);
                    break;
                //@ 3a2g. In All Other Cases:
                case TYPE_NOP:
                default:
                    //@ 3a2g1. Do-Nothing
                    break;
            }
        }
        
        //@ 3a3. Check User Input Again and Call ...()
        switch (iInput)
        {
            //@ 3a3a. For the I_BOOT_LOADER:
            case I_BOOT_LOADER:
                genAsm(&BOOT_LOADER_TEXT_PATH[0], &disassembly[0], lineCount);
                break;
            //@ 3a3b. For the I_APPLICATION:
            case I_APPLICATION:
                genAsm(&APPLICATION_TEXT_PATH[0], &disassembly[0], lineCount);
                break;
            //@ 3a3c. In All Other Cases:
            default:
                break;
        }
    }
    //@ 3b. In All Other Cases:
    else
    {
        //@ 3b1. Print ERROR LOG
        printf("Fail Converting HEX to ASM...\nquit\n");
    }

    #ifndef NDEBUG
    unsigned short disassembleLine = 0;
    printf("----------Disassemble Complete---------\n");
    for (disassembleLine = 0; disassembleLine < lineCount; disassembleLine++)
    {
        printf("[%d] %s\n", disassembleLine, disassembly[disassembleLine]);
    }
    #endif  // NDEBUG

}
