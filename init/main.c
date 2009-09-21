#include <stdio.h>

void main(void)
{
	int i;
	char test[10];

	test[0] = '1';
	test[1] = '1';
	test[2] = '1';
	test[3] = '\n';
	test[4] = '\0';
	early_printf("are you right? %% %s xixi\n","ni hao ma");
	early_printf("are you right? \n");
	early_printf("are you right? \n");
	early_printf("are you right? \n");
	early_printf("are you right? \n");
	early_printf("are you right? \n");
	early_printf("are you right? \n");
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}
