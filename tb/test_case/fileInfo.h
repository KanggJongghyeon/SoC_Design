#ifndef FILE_INFO_H
#define FILE_INFO_H

// Input File Info
#define MAX_LINE 1000
#define MAX_LEN  50
#define BOOT_ROM_SIZE 1024
//#define ASM                 ".txt"
//#define HEX                 ".mem"
//#define BOOT_ROM_PATH       "./../../design/memory/boot_rom"
//#define BOOT_LOADER_PATH    "./../boot_loader"
//#define APPLICATION_PATH    "./../application"
//#define DEBUG_MODE_PATH     "./test_case"

// Input enum
typedef enum
{
    I_NONE,         // 0
    I_BOOT_ROM,     // 1
    I_BOOT_LOADER,  // 2
    I_APPLICATION,  // 3
    I_DEBUG_MODE    // 4
} eInput;

#endif
