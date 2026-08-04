#include "array.h"
/////////////////////
// Global Variable //
/////////////////////
static const unsigned int mem32LineShiftLeft[MAX_LEN_HEX] = 
{
    28, 
    24, 
    20, 
    16, 
    12, 
    8, 
    4, 
    0
};

static const char* opcodeStr[MAX_OPCODE_NUM] =
{
    '\0',       // 0    Specify at functCodeStr (R-Type)
    "bgezal\0", // 1    Modify-Required, It distinguished by $rt {bltz, bgez, bltzal, bgezal ...}
    "j\0",      // 2
    "jal\0",    // 3 
    "beq\0",    // 4
    "bne\0",    // 5
    TBD,        // 6
    TBD,        // 7
    "addi\0",   // 8
    "addiu\0",  // 9
    "slti\0",   // 10
    "sltiu\0",  // 11
    "andi\0",   // 12
    "ori\0",    // 13
    "xori\0",   // 14
    "lui\0",    // 15
    TBD,        // 16   
    TBD,        // 17
    TBD,        // 18
    TBD,        // 19
    TBD,        // 20
    TBD,        // 21
    TBD,        // 22
    TBD,        // 23
    TBD,        // 24
    TBD,        // 25
    TBD,        // 26
    TBD,        // 27
    TBD,        // 28
    TBD,        // 29
    TBD,        // 30
    TBD,        // 31
    TBD,        // 32
    TBD,        // 33
    TBD,        // 34
    "lw\0",     // 35
    TBD,        // 36
    TBD,        // 37
    TBD,        // 38
    TBD,        // 39
    TBD,        // 40
    TBD,        // 41
    TBD,        // 42
    "sw\0",     // 43
    TBD,        // 44
    TBD,        // 45
    TBD,        // 46
    TBD,        // 47
    TBD,        // 48
    TBD,        // 49
    TBD,        // 50
    TBD,        // 51
    TBD,        // 52
    TBD,        // 53
    TBD,        // 54
    TBD,        // 55
    TBD,        // 56
    TBD,        // 57
    TBD,        // 58
    TBD,        // 59
    TBD,        // 60
    TBD,        // 61
    TBD,        // 62
    TBD         // 63
};

static const char* functCodeStr[MAX_OPCODE_NUM] =
{
    "sll\0",    // 0
    TBD,        // 1
    "srl\0",    // 2
    "sra\0",    // 3
    "sllv\0",   // 4
    TBD,        // 5
    "srlv\0",   // 6
    "srav\0",   // 7
    "jr\0",     // 8
    TBD,        // 9        
    TBD,        // 10        
    TBD,        // 11      
    TBD,        // 12        
    TBD,        // 13        
    TBD,        // 14        
    TBD,        // 15
    "mfhi\0",   // 16
    TBD,        // 17
    "mflo\0",   // 18
    TBD,        // 19
    TBD,        // 20
    TBD,        // 21
    TBD,        // 22
    TBD,        // 23
    "mul\0",    // 24
    "mulu\0",   // 25
    "div\0",    // 26
    "divu\0",   // 27
    TBD,        // 28
    TBD,        // 29
    TBD,        // 30
    TBD,        // 31
    "add\0",    // 32
    "addu\0",   // 33
    "sub\0",    // 34
    "subu\0",   // 35
    "and\0",    // 36
    "or\0",     // 37
    "xor\0",    // 38
    "nor\0",    // 39
    TBD,        // 40
    TBD,        // 41
    "slt\0",    // 42
    "sltu\0",   // 43
    TBD,        // 44
    TBD,        // 45
    TBD,        // 46
    TBD,        // 47
    TBD,        // 48
    TBD,        // 49
    TBD,        // 50
    TBD,        // 51
    TBD,        // 52
    TBD,        // 53
    TBD,        // 54
    TBD,        // 55
    TBD,        // 56
    TBD,        // 57
    TBD,        // 58
    TBD,        // 59
    TBD,        // 60
    TBD,        // 61
    TBD,        // 62
    TBD         // 63
};

/////////////////////////////
// Get Shift Left Constant //
/////////////////////////////
unsigned int getShiftLeftConstant(unsigned int iInput)
{
    //@ 1. Init Local Variable
    unsigned int oShiftLeft = 0;
    //@ 2. Set Output Data Using Shift Left Array 
    oShiftLeft = mem32LineShiftLeft[iInput % 10];
    
    #ifndef NDEBUG
    printf("bufferIndex (%d) ShiftLeft (%d)\n", iInput, oShiftLeft);    
    #endif  // NDEBUG

    return oShiftLeft;
}

////////////////////////////////
// Get OPCODE Character Array //
////////////////////////////////
void getOpcodeStr(eOpcode iOpcode, eFunctCode iFunctCode, char* oOpcodeStr)
{
    //@ 1. Check OPCODE Type
    //@ 1a. If OPCODE is R-Type:
    if (OP_RTYPE == iOpcode)
    {
        //@ 1a1. Set OPCODE String Using FUNCT CODE Table
        //strcpy(oOpcodeStr, functCodeStr[iFunctCode]);   
        oOpcodeStr = (char*)functCodeStr[iFunctCode];
    }
    //@ 1b. In All Other Cases:
    else
    {
        //@ 1b1. Set OPCODE String Using OPCODE Table
        //strcpy(oOpcodeStr, opcodeStr[iOpcode]);
        oOpcodeStr = (char*)opcodeStr[iOpcode];
    }

    #ifndef NDEBUG
    printf("OPCODE String %s\n", oOpcodeStr);
    #endif  // NDEBUG
}
