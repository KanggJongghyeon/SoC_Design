#ifndef ASSEMBLY_H
#define ASSEMBLY_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "./../include/mips.h"
#include "textFileInfo.h"

// Global Variable
static char         assembly[MAX_LINE][MAX_LEN];// assembly <= File Data
static unsigned int instruction[MAX_LINE];      // hex      <= assembly 
static eOpcodeType  opcodeType[MAX_LINE];       // OPCODE Type per Line

// Load Assembly File
bool getAssembly(const char* iFileName, char oAssembly[][MAX_LEN], unsigned char* oCount);

// Get Opcode Command
void getOpcodeStr(char* iLineData, char* oOpcodeStr);

// Store OPCODE(6-BIT), FUNCT CODE(6-BIT), and Get OPCODE TYPE
void getOpcodeAndTypeAndFunct(char* iOpcodeStr, unsigned int* oInstruction, eOpcodeType* oOpcodeType);

// Get Registers' Number
unsigned int getRegNumber(char* iRegStr);

// Store rd or rs(5-BIT)
void getRdOrRs(char* iLineData, unsigned int* oInstruction);

// Store rt(5-BIT), rs(5-BIT)
void getRtRs(char* iLineData, eOpcodeType iOpcodeType, unsigned int* oInstruction);

// Store Imm(16-BIT) Data
void getImm(char* iLineData, eOpcodeType iOpcodeType, unsigned int* oInstruction);

// Store JADDR(26-BIT) Data
void getJaddr(char* iLineData, unsigned int* oInstruction);

// Make Text File
void setHexTextFile(const char* oFileName, unsigned int* iInstruction, unsigned char iCount, eInput iInput);

// Assembly main
void convert(eInput iInput);

/*
add rd, rs, rt
31-26   25-21 20-16 15-11 10-6  5-0
000000  00000 00000 00000 00000 000000
opcode  rs      rt  rd    shamt funct    

addi rt, rs, imm
31-26   25-21 20-16 15-0
000000  00000 00000 0000000000000000
opcode  rs      rt      imm

lw/sw rt, imm(rs)
31-26   25-21 20-16 15-0
000000  00000 00000 0000000000000000
opcode  rs      rt      imm

*/

#endif  // ASSEMBLY_H
