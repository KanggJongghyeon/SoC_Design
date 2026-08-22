`ifndef TB_TYPEDEF_SVH
`define TB_TYPEDEF_SVH

`include "../design/memory/memory.svh"
`include "tb_define.svh"

// Buffer Array for Load Memory File
typedef reg [`BYTE_SIZE - 1:0] 
    t_memory_buffer[];

`endif  // TB_TYPEDEF_SVH
