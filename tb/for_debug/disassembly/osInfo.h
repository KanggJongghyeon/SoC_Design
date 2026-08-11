#ifndef OS_INFO_H
#define OS_INFO_H

// OS Info
#define OS_LINUX    (1U)
#define OS_WINDOWS  (2U)

#if (CRLF == OS_WINDOWS)
#define CRLF_FLAG
#define OS_OFFSET   (OS_WINDOWS)
#else   // (CRLF == OS_WINDOWS)
#define OS_OFFSET   (OS_LINUX)   
#endif  // (CRLF == OS_WINDOWS)

#endif  // OS_INFO_H
