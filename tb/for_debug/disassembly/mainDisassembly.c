#include "disassembly.h"

int main()
{
    unsigned char   input  = 0;
    bool            error  = false;

    printf("--------Select File---------\n");
    printf("Press Button {1, 2}         \n");
    printf("[1] for Boot Loader File    \n");
    printf("[2] for Application File    \n");
    printf("----------------------------\n");
    
    do
    {
        printf(": ");
        scanf("%hhu", &input);
        switch ((eInput)input)
        {
            case I_BOOT_LOADER:
            case I_APPLICATION:
                error = false;
                convert(input);
                break;
            default:
                error = true;        
                printf("Wrong Input...Try Again\n");
                break;
        }
    } while(true == error);
    
    return 0;
}

/////////////////////////////////////////////////////////
// Path : .\tb\for_debug\disassembly\mainDisassembly.c //
/////////////////////////////////////////////////////////
