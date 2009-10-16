#include <stdio.h>
#include <pci.h>
#include <pci-conf.h>
#include <device/flash.h>

extern int boot_flash_init(struct flash_device *);
extern int init_cs5536_rtc(void);
extern void init_cpu_freq(void);
int set_date(u8 year, u8 month, u8 day, u8 hour, u8 min, u8 sec);
int week_day(u8 year, u8 month, u8 day);

void main(void)
{
	int i;
	struct flash_device flash_dev;
	pci_reg cs5536_dev;

	i = boot_flash_init(&flash_dev);
	if(i == 0)
		early_printf("error\n");
	init_cpu_freq();
	init_cs5536_rtc();
	cs5536_dev = MAKE_PCI_DEV(0, 9, 0);
	printf("reg 0x10 is %x\n", pci_conf_read32(cs5536_dev, 0x10));
	pci_conf_write32(cs5536_dev, 0x10, 0x12340000);
	printf("reg 0x10 is %x\n", pci_conf_read32(cs5536_dev, 0x10));
	pci_conf_write8(cs5536_dev, 0x12, 0x78);
	printf("reg 0x10 is %x\n", pci_conf_read32(cs5536_dev, 0x10));

	while(1);
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}


