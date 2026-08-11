#ifndef MEM_FILE_INFO_H
#define MEM_FILE_INFO_H

#include "osInfo.h"

// File Info
#define MAX_LINE        (1000U)
#define MAX_LEN         (50U)
#define MAX_LEN_HEX     (8U)                
#define LINE_FEED       (0x0A)  // UNICODE of '\n' (Both Used in Linux(LF) and Windows(CRLF))
#define CARRIAGE_RETURN (0x0D)  // UNICODE of '\r' (Only Used in Windows)
#define FILE_ERROR      (255U)  // ERROR VALUE

// File Path
#ifndef CRLF_FLAG
#define BOOT_LOADER_MEM_PATH    ("../../boot_loader.mem")
#define APPLICATION_MEM_PATH    ("../../application.mem")
#define BOOT_LOADER_TEXT_PATH   ("textFile/bootLoader.txt")
#define APPLICATION_TEXT_PATH   ("textFile/application.txt")
#else   // CRLF_FLAG
#define BOOT_LOADER_MEM_PATH    ("memFile/windowsBootLoader.mem")
#define APPLICATION_MEM_PATH    ("memFile/windowsApplication.mem")
#define BOOT_LOADER_TEXT_PATH   ("textFile/windowsBootLoader.txt")
#define APPLICATION_TEXT_PATH   ("textFile/windowsApplication.txt")
#endif  // CRLF_FLAG

// File Input enum
typedef enum
{
    I_NONE,         // 0
    I_BOOT_LOADER,  // 1
    I_APPLICATION,  // 2
} eInput;

#endif  // MEM_FILE_INFO_H
