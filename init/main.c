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
	early_printf("are %x you %c righ%c t? \n", 1024, 'A', 'B');
	early_printf("are you %s right? \n","shi bu shi\n");
	early_printf("are%s you %d rig%i ht? \n", "no no ", 123, -890);
	early_printf("are you %x right? \n",0x1234dfe);
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}
