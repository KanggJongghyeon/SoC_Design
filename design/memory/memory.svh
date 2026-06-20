///////////////////////////////////////
// Path : .\design\memory\memory.svh //
///////////////////////////////////////
`ifndef MEMORY_SVH
`define MEMORY_SVH
// COMMON
`define BYTE_SIZE   8
// DRAM
`define DRAM_SIZE 4096      // [Byte]
// SRAM
`define SRAM_SIZE 32768     // [Byte]
// BOOR ROM
`define BOOT_ROM_FILE_PATH  ".\\..\\..\\..\\..\\..\\design\\memory\\boot_rom.mem"
`define BOOT_ROM_SIZE       1024  // [Byte]
`endif  // MEMORY_SVH
