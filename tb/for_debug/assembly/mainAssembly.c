#include "assembly.h"

int main()
{
    char input = 0;

    printf("--------Select File---------\n");
    printf("Press Button {1, 2, 3, 4}   \n");
    printf("[1] for Boot ROM File       \n");
    printf("[2] for Boot Loader File    \n");
    printf("[3] for Application File    \n");
    printf("[4] for Debug Mode File     \n");
    printf("----------------------------\n");
    
    scanf("%d", &input);
    input = (eInput)input; 

    convert(input);
    
    return 0;
}

///////////////////////////////////////////////////
// Path : .\tb\for_debug\assembly\mainAssembly.c //
///////////////////////////////////////////////////
