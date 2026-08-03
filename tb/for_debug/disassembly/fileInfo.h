#ifndef FILE_INFO_H
#define FILE_INFO_H

// File Info
#define MAX_LINE            1000U
#define MAX_LEN             50U
#define MAX_LEN_HEX         8U                
#define LINE_FEED           0x0A    // \n
#define CARRIAGE_RETURN     0x0D    // \r

// File Path
#define BOOT_LOADER_MEM_PATH    "mem_file/boot_loader.mem"
#define APPLICATION_MEM_PATH    "mem_file/application.mem"
#define BOOT_LOADER_TEXT_PATH   "text_file/boot_loader.txt"
#define APPLICATION_TEXT_PATH   "text_file/application.txt"

// File Input enum
typedef enum
{
    I_NONE,         // 0
    I_BOOT_LOADER,  // 1
    I_APPLICATION,  // 2
} eInput;

// File Info for 32 Bit Memory File
static unsigned int mem32LineShift[8]  = {28, 24, 20, 16, 12, 8, 4, 0};

#endif
