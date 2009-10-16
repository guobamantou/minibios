#include <stdio.h>
#include <pci.h>
#include <pci-conf.h>
#include <device/flash.h>

extern int boot_flash_init(struct flash_device *);
extern int init_cs5536_rtc(void);
extern void init_cpu_freq(void);
int set_date(u8 year, u8 month, u8 day, u8 hour, u8 min, u8 sec);
int week_day(u8 year, u8 month, u8 day);

extern void rdmsr(u32, u32*, u32*);
extern void wrmsr(u32, u32, u32);

void main(void)
{
	int i;
	struct flash_device flash_dev;
	pci_reg cs5536_dev;
	u32 lo, hi;

	i = boot_flash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	init_cpu_freq();
	init_cs5536_rtc();
	rdmsr(0x80000000, &hi, &lo);
	printf("lo is %x, hi is %x\n", lo, hi);
	wrmsr(0x8000000d, 0, 0x1234);
	rdmsr(0x8000000d, &hi, &lo);
	printf("hi is %x, hi is %x\n", lo, hi);
	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


