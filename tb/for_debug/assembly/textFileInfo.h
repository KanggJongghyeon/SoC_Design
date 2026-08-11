#ifndef TEXT_FILE_INFO_H
#define TEXT_FILE_INFO_H

// File Info
#define MAX_LINE                1000
#define MAX_LEN                 50
#define BOOT_ROM_SIZE           1024
#define BOOT_ROM_TEXT_PATH      "textFile/bootRom.txt"
#define BOOT_LOADER_TEXT_PATH   "textFile/bootLoader.txt"
#define APPLICATION_TEXT_PATH   "textFile/application.txt"
#define DEBUG_MODE_TEXT_PATH    "textFile/debugMode.txt"
#define BOOT_ROM_MEM_PATH       "./../../../design/memory/boot_rom.mem" 
#define BOOT_LOADER_MEM_PATH    "./../../boot_loader.mem"
#define APPLICATION_MEM_PATH    "./../../application.mem"
#define DEBUG_MODE_MEM_PATH     "./../debug_mode.mem"

// File enum
typedef enum
{
    I_NONE,         // 0
    I_BOOT_ROM,     // 1
    I_BOOT_LOADER,  // 2
    I_APPLICATION,  // 3
    I_DEBUG_MODE    // 4
} eInput;

#endif  // TEXT_FILE_INFO_H
