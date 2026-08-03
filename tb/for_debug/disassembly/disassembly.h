#ifndef DISASSEMBLY_H
#define DISASSEMBLY_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "./../include/mips.h"
#include "fileInfo.h"

// Global Variable
static unsigned int instruction[MAX_LINE];          // MEM Data Integer 
static char         disassembly[MAX_LINE][MAX_LEN]; // Disassembly Data
static eOpcodeType  opcodeType[MAX_LINE];           // OPCODE Type per Line

// Get OPCODE Type
eOpcodeType getOpcodeType(eOpcode iOpcode, eFunctCode iFunctCode);

// Get OPCODE
void getOpcode(unsigned int *iInstruction, char (*oDisassembly)[MAX_LEN], eOpcodeType *oOpcodeType);

// Convert Hexa Alphabet to Integer
unsigned char convertAlphabetCharToInteger(char iChar);

// Get Instruction from Memory File
bool getInstruction(const char *iFile, unsigned int *oInstruction, unsigned char *oCount);

// Disassembly main
void convert(eInput iInput);

#endif  // DISASSEMBLY_H
