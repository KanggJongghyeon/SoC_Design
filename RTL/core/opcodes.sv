/***************************************
 * INSTRUCTION OPCODE
 ***************************************/
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

`define OP_RTYPE  6'b000000
`define OP_ADDI   6'b001000
`define OP_ADDIU  6'b001001
`define OP_ANDI   6'b001100
`define OP_ORI    6'b001101
`define OP_BEQ    6'b000100
`define OP_BNE    6'b000101
`define OP_SLTI   6'b001010
`define OP_SLTIU  6'b001011
`define OP_LW     6'b100011
`define OP_SW     6'b101011
`define OP_LUI    6'b001111 // $rs is not used, Upper to Constant Lower 16 bit all zero
// sll / srl is RTYPE and $rs is not used, funct is zero, Only used "shamt"
`define OP_JUMP   6'b000010
`define OP_JAL    6'b000011

/***************************************
 * INSTRUCTION FUNCTION CODE
 ***************************************/
`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7
`define FUNC_RWD 6'd27
`define FUNC_WWD 6'd28
`define FUNC_JPR 6'd25
`define FUNC_JRL 6'd26
`define FUNC_HLT 6'd29
`define FUNC_ENI 6'd30
`define FUNC_DSI 6'd31

`define FUNCT_ADD  6'b100000
`define FUNCT_ADDU 6'b100001
`define FUNCT_SUB  6'b100010
`define FUNCT_SUBU 6'b100011
`define FUNCT_AND  6'b100100
`define FUNCT_OR   6'b100101
`define FUNCT_NOR  6'b100111
`define FUNCT_XOR  6'b100110
`define FUNCT_SLT  6'b101010
`define FUNCT_SLTU 6'b101011
`define FUNCT_SLL  6'b000000
`define FUNCT_SRL  6'b000000
`define FUNCT_SRA  6'b000011
`define FUNCT_SLLV 6'b000100
`define FUNCT_SRLV 6'b000110
`define FUNCT_SRAV 6'b000111
`define FUNCT_JR   6'b001000
`define FUNCT_JALR 6'b001001
`define FUNCT_MUL  6'b011000
`define FUNCT_MULU 6'b011001
`define FUNCT_DIV  6'b011010
`define FUNCT_DIVU 6'b011011

/***************************************
 * ALU OPCODE
 ***************************************/
`define ALU_OP_ADD   5'b00000
`define ALU_OP_SUB   5'b00001
`define ALU_OP_ID    5'b01000
`define ALU_OP_NAND  5'b01001 
`define ALU_OP_NOR   5'b01010
`define ALU_OP_XNOR  5'b01011
`define ALU_OP_NOT   5'b01100
`define ALU_OP_AND   5'b01101 
`define ALU_OP_OR    5'b01110
`define ALU_OP_XOR   5'b01111
`define ALU_OP_LRS   5'b00010
`define ALU_OP_ARS   5'b00100
`define ALU_OP_RR    5'b00110
`define ALU_OP_LLS   5'b00011
`define ALU_OP_ALS   5'b00101
`define ALU_OP_RL    5'b00111
`define ALU_OP_TCP   5'b10100
`define ALU_OP_SHL   5'b11011
`define ALU_OP_NE    5'b10000
`define ALU_OP_EQ    5'b10001
`define ALU_OP_GZ    5'b10010
`define ALU_OP_LZ    5'b10011


`define ALUOP_LW    2'b00
`define ALUOP_SW    2'b00
`define ALUOP_BEQ   2'b01
`define ALUOP_RTYPE 2'b10

`define ALU_CTR_LW  4'b0010
`define ALU_CTR_SW  4'b0010
`define ALU_CTR_BEQ 4'b0110
`define ALU_CTR_AND 4'b0000
`define ALU_CTR_OR  4'b0001
`define ALU_CTR_ADD 4'b0010
`define ALU_CTR_SUB 4'b0110
`define ALU_CTR_SLT 4'b0111
`define ALU_CTR_NOR 4'b1100
`define ALU_CTR_LUI 4'b0100
`define ALU_CTR_SLL 4'b0011
