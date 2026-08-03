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
static char         disassmebly[MAX_LINE][MAX_LEN]; // Disassembly Data
static eOpcodeType  opcodeType[MAX_LINE];           // OPCODE Type per Line


#endif  // DISASSEMBLY_H
