#include <stdio.h>

int test[256];

void main(void)
{
	int i;
	
	i= 0;	
//	early_printf("print");
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}
