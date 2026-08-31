#include "assembly.h"

int main()
{
    unsigned char   input = 0;
    bool            error = false;

    printf("--------Select File---------\n");
    printf("Press Button {1, 2, 3, 4}   \n");
    printf("[1] for Boot ROM File       \n");
    printf("[2] for Boot Loader File    \n");
    printf("[3] for Application File    \n");
    printf("[4] for Debug Mode File     \n");
    printf("----------------------------\n");
   
    do
    {   
        printf(": ");
        scanf("%hhu", &input);
        input = (eInput)input; 
        switch ((eInput)input)
        {
            case I_BOOT_ROM:
            case I_BOOT_LOADER:
            case I_APPLICATION:
            case I_DEBUG_MODE:
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

///////////////////////////////////////////////////
// Path : .\tb\for_debug\assembly\mainAssembly.c //
///////////////////////////////////////////////////
