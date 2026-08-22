`ifndef TB_DEFINE_SVH
`define TB_DEFINE_SVH

`include "../design/memory/memory.svh"

`define CLOCK_RATE  2   // Reference Clock Rate

//`define BOOT_LOADER     // Flag for Load boot_loader.mem
//`define APPLICATION     // Flag for Load application.mem
`define DEBUG_MODE      // Flag for Load debug_mode.mem

`ifndef XILINX_CPU_32BIT// Vivado define Option 
`define ADDR_BIT    16
`define DATA_BIT    16
`else   // XILINX_CPU_32BIT
`define ADDR_BIT    32
`define DATA_BIT    32
`endif  // XILINX_CPU_32BIT

`define WORD_BYTES  (`DATA_BIT / `BYTE_SIZE)

`endif  // TB_DEFINE_SVH
