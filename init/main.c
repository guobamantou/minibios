#include <stdio.h>

void main(void)
{
	int i;

	early_printf("ready to erase chip\n");	
	for(i= 0 ; i < 0xfffffff; i++);
	sst_erase_sector(8*4*1024);	
	for(i= 0 ; i < 0xfffffff; i++);
	sst_erase_sector(10*4*1024);	
	early_printf("return from erase chip\n");	
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


