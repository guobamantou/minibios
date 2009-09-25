#include <stdio.h>
#include <types.h>
#include <io.h>

void main(void)
{
	int i;

	early_printf("ready to erase chip\n");	
	//sst_erase_chip();	
	early_printf("return from erase chip\n");	
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}

void sst_erase_chip()
{
	u32 flash_addr = 0xbfc00000;
	
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x80);
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x10);
	
	return ;
}
