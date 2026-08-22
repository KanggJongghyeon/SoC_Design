`ifndef CTR_UNIT_H
`define CTR_UNIT_H

// Control Unit Output for Branch
`define BRANCH_NONE 3'b000
`define BRANCH_BEQ  3'b001 // ==
`define BRANCH_BNE  3'b010 // !=
`define BRANCH_BLT  3'b011 // <
`define BRANCH_BGE  3'b100 // >=
                    
// Control Unit Output for Jump
`define JUMP_NONE   2'b00
`define JUMP_J      2'b01 // I-Type
`define JUMP_JR_AL  2'b10 // R-Type
`define JUMP_JAL    2'b11 // I-Type

`endif  // CTR_UNIT_H
