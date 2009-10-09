#include <stdio.h>
#include <device/flash.h>

extern int boot_flash_init(struct flash_device *);
extern void print_flash_device(struct flash_device *);

void main(void)
{
	int i;
	struct flash_device flash_dev;
	char str[0x1000]; 

	i = 0;
	while(i < 0x1000)
		str[i++] = (i % 10) + '0';

	early_printf("ready to erase chip\n");	
	i = boot_flash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	flash_write(&flash_dev, 0x4000, str, 0x1000);
	flash_write(&flash_dev, 0x4004, str, 0x1000);

	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


