#include <stdio.h>
#include <pci.h>
#include <pci-conf.h>
#include <device/flash.h>

extern int boot_flash_init(struct flash_device *);
extern void init_cpu_freq(void);
extern u32 cpu_freq;
extern void *malloc(size_t);
extern void free(void *);

void main(void)
{
	int i;
	struct flash_device flash_dev;
	char *p, *q, *r;

	i = boot_flash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	
	init_cpu_freq();

	printf("cpu freq is %d\n", cpu_freq);
	p = malloc(100);
	q = malloc(0x10000);
	r = malloc(12);
	free(p);
	free(q);
	free(r);
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


