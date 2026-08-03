#include "disassembly.h"

int main()
{
    char input = 0;

    printf("--------Select File---------\n");
    printf("Press Button {1, 2}         \n");
    printf("[1] for Boot Loader File    \n");
    printf("[2] for Application File    \n");
    printf("----------------------------\n");
    
    scanf("%d", &input);
    input = (eInput)input; 

    convert(input);
    
    return 0;
}

/////////////////////////////////////////////////////////
// Path : .\tb\for_debug\disassembly\mainDisassembly.c //
/////////////////////////////////////////////////////////

