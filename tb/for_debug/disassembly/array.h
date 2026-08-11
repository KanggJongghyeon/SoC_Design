#ifndef ARRAY_H
#define ARRAY_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "./../common/mips.h"
#include "memFileInfo.h"

// Global Macro
#define TBD ("XXX\0")   // To-Be-Determined

// Global Variable      
static const unsigned int   mem32LineShiftLeft[MAX_LEN_HEX];    // Shift Left Array
static const char*          opcodeStr[MAX_OPCODE_NUM];          // OPCODE STR
static const char*          functCodeStr[MAX_OPCODE_NUM];       // OPCODE STR (for R-Type)   
static const char*          registersStr[MAX_REG_NUM];          // Registers STR

// Get Shift Left Constant
unsigned int getShiftLeftConstant (unsigned int iInput);

// Get OPCODE Character Array
void getOpcodeStr(eOpcode iOpcde, eFunctCode iFunctCode, char *oOpcodeStr);

// Get Registers Character Array
char* getRegistersStr(eRegisters iRegisters);

#endif  // ARRAY_H
