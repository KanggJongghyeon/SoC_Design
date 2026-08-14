#ifndef DISASSEMBLY_H
#define DISASSEMBLY_H

#include <stdbool.h>
#include "./../common/mips.h"
#include "memFileInfo.h"
#include "array.h"

// Global Variable
static unsigned int instruction[MAX_LINE];          // MEM Data Integer 
static char         disassembly[MAX_LINE][MAX_LEN]; // Disassembly Data
static eOpcodeType  opcodeType[MAX_LINE];           // OPCODE Type per Line

// Generate Assembly File
void genAsm(const char *iOutFile, char (*oDisassembly)[MAX_LEN], unsigned int oCount);

// Disassemble R-Type
void disassembleRType(unsigned int instructionLine, char *oDisassemblyLine);

// Disassemble Shift-Type
void disassembleShiftType(unsigned int instructionLine, char *oDisassemblyLine);

// Disassemble I-Type
void disassembleIType(unsigned int instructionLine, char *oDisassemblyLine, eOpcodeType iOpcodeType);

// Disassemble J-Type
void disassembleJType(unsigned int instructionLine, char *oDisassemblyLine);

// Disassemble REGIMM-Type
void disassembleRegimmType(unsigned int insturctionLine, char *oDisassemblyLine);

// Get OPCODE Type
eOpcodeType getOpcodeType(eOpcode iOpcode, eFunctCode iFunctCode);

// Get OPCODE
void getOpcode(unsigned int *iInstruction, char (*oDisassembly)[MAX_LEN], eOpcodeType *oOpcodeType, unsigned int iTotalLine);

// Convert Hexa Alphabet to Integer
unsigned int convertAlphabetCharToInteger(char iChar);

// Get Instruction from Memory File
bool getInstruction(const char *iFile, unsigned int *oInstruction, unsigned int *oCount);

// Disassembly main
void convert(eInput iInput);

#endif  // DISASSEMBLY_H
