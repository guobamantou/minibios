#include <stdio.h>
#include <pci.h>
#include <pci-conf.h>
#include <device/flash.h>

extern int boot_flash_init(struct flash_device *);
extern void init_cpu_freq(void);
extern u32 cpu_freq;

void main(void)
{
	int i;
	struct flash_device flash_dev;

	i = boot_flash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	init_cpu_freq();

	printf("cpu freq is %d\n", cpu_freq);

	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


