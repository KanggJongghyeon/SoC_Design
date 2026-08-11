#ifndef FILE_INFO_H
#define FILE_INFO_H

// File Info
#define MAX_LINE            1000U
#define MAX_LEN             50U
#define MAX_LEN_HEX         8U                
#define LINE_FEED           0x0A    // UNICODE of '\n'
#define CARRIAGE_RETURN     0x0D    // UNICODE of '\r'
#define FILE_ERROR          255U    // ERROR VALUE

// File Path
#define BOOT_LOADER_MEM_PATH    "memFile/bootLoader.mem"
#define APPLICATION_MEM_PATH    "memFile/application.mem"
#define BOOT_LOADER_TEXT_PATH   "textFile/bootLoader.txt"
#define APPLICATION_TEXT_PATH   "textFile/application.txt"

// File Input enum
typedef enum
{
    I_NONE,         // 0
    I_BOOT_LOADER,  // 1
    I_APPLICATION,  // 2
} eInput;

#endif
