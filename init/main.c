#include <stdio.h>
#include <device/flash.h>

extern int boot_flash_init(struct flash_device *);
extern void print_flash_device(struct flash_device *);

void main(void)
{
	int i;
	struct flash_device flash_dev;

	early_printf("ready to erase chip\n");	
	i = boot_flash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	else 
		print_flash_device(&flash_dev);	
	early_printf("return from erase chip\n");	
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


