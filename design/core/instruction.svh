//////////////////////////////////////////
// Path : .\design\core\instruction.svh //
//////////////////////////////////////////
`ifndef INSTRUCTION_SVH // Header Guard
`define INSTRUCTION_SVH
`timescale 1ns / 1ps
// INSTRUCTION OPCODE
// 16-Bit System
`define OPCODE_ADI   4'b0100
`define OPCODE_ORI   4'b0101
`define OPCODE_LHI   4'b0110
`define OPCODE_LWD   4'b0111
`define OPCODE_SWD   4'b1000
`define OPCODE_BNE   4'b0000
`define OPCODE_BEQ   4'b0001
`define OPCODE_BGZ   4'b0010
`define OPCODE_BLZ   4'b0011
`define OPCODE_JMP   4'b1001
`define OPCODE_JAL   4'b1010
`define OPCODE_RTYPE 4'b1111

// 32-Bit System
`define OP_RTYPE    6'b000000   // 0
// sll / srl is RTYPE and $rs is not used, funct is zero, Only used "shamt"
`define OP_REGIMM   6'b000001   // 1
`define OP_J        6'b000010   // 2
`define OP_JAL      6'b000011   // 3
`define OP_BEQ      6'b000100   // 4
`define OP_BNE      6'b000101   // 5
`define OP_ADDI     6'b001000   // 8
`define OP_ADDIU    6'b001001   // 9
`define OP_SLTI     6'b001010   // 10
`define OP_SLTIU    6'b001011   // 11
`define OP_ANDI     6'b001100   // 12
`define OP_ORI      6'b001101   // 13
`define OP_XORI     6'b001110   // 14
`define OP_LUI      6'b001111   // 15 $rs is not used, Upper to Constant Lower 16 bit all zero
`define OP_LW       6'b100011   // 35
`define OP_SW       6'b101011   // 43

// INSTRUCTION FUNCTION CODE
`define FUNCT_SLL   6'b000000   // 0
`define FUNCT_SRL   6'b000010   // 2
`define FUNCT_SRA   6'b000011   // 3
`define FUNCT_SLLV  6'b000100   // 4
`define FUNCT_SRLV  6'b000110   // 6
`define FUNCT_SRAV  6'b000111   // 7
`define FUNCT_JR    6'b001000   // 8
`define FUNCT_MFHI  6'b010000   // 16
`define FUNCT_MFLO  6'b010010   // 18
`define FUNCT_MUL   6'b011000   // 24
`define FUNCT_MULU  6'b011001   // 25
`define FUNCT_DIV   6'b011010   // 26
`define FUNCT_DIVU  6'b011011   // 27
`define FUNCT_ADD   6'b100000   // 32
`define FUNCT_ADDU  6'b100001   // 33
`define FUNCT_SUB   6'b100010   // 34
`define FUNCT_SUBU  6'b100011   // 35
`define FUNCT_AND 6'b100100   // 36
`define FUNCT_OR    6'b100101   // 37
`define FUNCT_XOR   6'b100110   // 38
`define FUNCT_NOR   6'b100111   // 39
`define FUNCT_SLT   6'b101010   // 42
`define FUNCT_SLTU  6'b101011   // 43

// Ctrl Unit => ALU Control (1 Bit Extansion) <= My Rule
`define ALUOP_ADD   3'b000  // 0    LW,      SW,     ADDI,   ADDIU
`define ALUOP_SUB   3'b001  // 1    BEQ,     BNE
`define ALUOP_RTYPE 3'b010  // 2    R-TYPE
`define ALUOP_SLTI  3'b011  // 3    SLTI,    SLTIU
`define ALUOP_ANDI  3'b100  // 4    ANDI
`define ALUOP_ORI   3'b101  // 5    ORI
`define ALUOP_XORI  3'b110  // 6    XORI
`define ALUOP_LUI   3'b111  // 7    LUI

// ALU CONTROL Output Signal
`define ALU_CTR_AND     4'b0000 // 0    AND,    ANDI
`define ALU_CTR_OR      4'b0001 // 1    OR,     ORI
`define ALU_CTR_ADD     4'b0010 // 2    ADD,    ADDI,   ADDIU,  LW,     SW
`define ALU_CTR_XOR     4'b0011 // 3    XOR,    XORI
`define ALU_CTR_LUI     4'b0100 // 4    LUI
`define ALU_CTR_MFHI    4'b0101 // 5    MFHI
`define ALU_CTR_SUB     4'b0110 // 6    SUB,    BEQ,    BNE,
`define ALU_CTR_SLT     4'b0111 // 7    SLT,    SLTU,   SLTI,   SLTIU
`define ALU_CTR_MFLO    4'b1000 // 8    MFLO
`define ALU_CTR_SLL     4'b1001 // 9    SLL,    SLLV
`define ALU_CTR_SRL     4'b1010 // 10   SRL,    SRLV
`define ALU_CTR_SRA     4'b1011 // 11   SRA,    SRAV
`define ALU_CTR_NOR     4'b1100 // 12   NOR,    NORI
`define ALU_CTR_MUL     4'b1101 // 13   MUL,    MULU
`define ALU_CTR_DIV     4'b1110 // 14   DIV,    DIVU
`define ALU_CTR_XXX     4'b1111 // 15   Not Defined

`endif  // INSTRUCTION_SVH
/*
ALUOP[1]    ALUOP[0]    FUNCT CODE  ALU CONTROL
0           0           XXXXXX      0010
X           1           XXXXXX      0110
1           X           XX0000      0010
1           X           XX0010      0110
1           X           XX0100      0000
1           X           XX0101      0001
1           X           XX1010      0111
*/
