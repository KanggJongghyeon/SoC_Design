#ifndef MIPS_H
#define MIPS_H

#define MAX_REG_NUM     (32)
#define MAX_OPCODE_NUM  (64)
#define OPCODE_STR_LEN  (7)
#define REG_STR_LEN     (6)
#define IMM_STR_LEN     (7)
#define JADDR_STR_LEN   (9)

typedef enum 
{
    R_ZERO, // 0
    R_AT,   // 1
    R_V0,   // 2
    R_V1,   // 3
    R_A0,   // 4
    R_A1,   // 5
    R_A2,   // 6
    R_A3,   // 7
    R_T0,   // 8
    R_T1,   // 9
    R_T2,   // 10
    R_T3,   // 11
    R_T4,   // 12
    R_T5,   // 13
    R_T6,   // 14
    R_T7,   // 15
    R_S0,   // 16
    R_S1,   // 17
    R_S2,   // 18
    R_S3,   // 19
    R_S4,   // 20
    R_S5,   // 21
    R_S6,   // 22
    R_S7,   // 23
    R_T8,   // 24
    R_T9,   // 25
    R_K0,   // 26
    R_K1,   // 27
    R_GP,   // 28
    R_SP,   // 29
    R_FP,   // 30
    R_RA,   // 31
    R_NONE  // 32 
} eRegisters;

typedef enum 
{
    OP_RTYPE    = 0,
    OP_REGIMM   = 1,
    OP_J        = 2,
    OP_JAL      = 3,
    OP_BEQ      = 4,
    OP_BNE      = 5,
    OP_ADDI     = 8,
    OP_ADDIU    = 9,
    OP_SLTI     = 10,
    OP_SLTIU    = 11,
    OP_ANDI     = 12,
    OP_ORI      = 13,
    OP_XORI     = 14,
    OP_LUI      = 15,
    OP_LW       = 35,
    OP_SW       = 43,
    OP_NONE     = 64
} eOpcode;

typedef enum 
{
    TYPE_NONE,  // 0
    TYPE_R,     // 1
    TYPE_SHIFT, // 2
    TYPE_I,     // 3
    TYPE_LW,    // 4
    TYPE_SW,    // 5
    TYPE_J,     // 6
    TYPE_BRANCH,// 7
    TYPE_NOP    // 8
} eOpcodeType;

typedef enum
{
    FUNCT_SLL   = 0,    
    FUNCT_SRL   = 2,
    FUNCT_SRA   = 3,
    FUNCT_SLLV  = 4,
    FUNCT_SRLV  = 6,
    FUNCT_SRAV  = 7,
    FUNCT_JR    = 8,
    FUNCT_JALR  = 9,
    FUNCT_MFHI  = 16,
    FUNCT_MFLO  = 18,
    FUNCT_MULT  = 24,
    FUNCT_MULTU = 25,
    FUNCT_DIV   = 26,
    FUNCT_DIVU  = 27,
    FUNCT_ADD   = 32,
    FUNCT_ADDU  = 33,
    FUNCT_SUB   = 34,
    FUNCT_SUBU  = 35,
    FUNCT_AND   = 36,
    FUNCT_OR    = 37,
    FUNCT_XOR   = 38,
    FUNCT_NOR   = 39,
    FUNCT_SLT   = 42,
    FUNCT_SLTU  = 43,
    FUNCT_NONE  = 64
} eFunctCode;

#endif
