#include <stdio.h>
#include <pci.h>
#include <pci-conf.h>
#include <device/flash.h>

extern int bootflash_init(struct flash_device *);
extern void init_cpu_freq(void);
extern u32 cpu_freq;
extern void *malloc(size_t);
extern void free(void *);
extern void poll_output(int);
extern void delay(int);

void main(void)
{
	int i;
	struct flash_device flash_dev;

	init_cpu_freq();
	delay(1000);

	i = bootflash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	flash_dev.ops->flash_erase_chip(&flash_dev);

#if 0
	flash_dev.ops->flash_program(&flash_dev, 0, 0xf0);
	flash_dev.ops->flash_program(&flash_dev, 0, 0x0f);
	
	flash_dev.ops->flash_program(&flash_dev, 1, 0x00);

	flash_dev.ops->flash_program(&flash_dev, 2, 0xf0);

	flash_dev.ops->flash_program(&flash_dev, 3, 0xf0);
	flash_dev.ops->flash_program(&flash_dev, 3, 0xc0);
	flash_dev.ops->flash_program(&flash_dev, 3, 0x80);
#endif
	while(1)
		poll_output(1000000);

	printf("cpu freq is %d\n", cpu_freq);
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


