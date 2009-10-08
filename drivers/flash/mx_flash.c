#include <io.h>
#include <device/flash.h>
#if 0
/* return non-zero means busy*/
int sst_erase_busy(struct flash_device *dev, u32 offset)
{
	u8 poll;
	u32 flash_addr = dev->vaddr;

	poll = inb(flash_addr + offset);	
	if(poll & 0x80) // see sst flash datasheet Data# Polling (DQ7) 
		return 1;
	return 0;	
}

/* return non-zero means busy*/
int sst_program_busy(struct flash_device *dev, u32 offset)
{
	u8 poll1, poll2;
	u32 flash_addr = dev->vaddr;

	poll1 = inb(flash_addr + offset);	
	poll2 = inb(flash_addr + offset);	
	if((poll1 ^ poll2) & 0x40) // set sst flash datasheet Toggle Bit(DQ6)
		return 1;
	return 0;
}

#endif 
void mx_erase_sector(struct flash_device *dev, u32 offset)
{
	char* flash_addr = dev->vaddr;
	
	outb(flash_addr + 0x555, 0xaa);
	outb(flash_addr + 0x2aa, 0x55);
	outb(flash_addr + 0x555, 0x80);
	outb(flash_addr + 0x555, 0xaa);
	outb(flash_addr + 0x2aa, 0x55);
	outb(flash_addr + offset, 0x30);
}

void mx_erase_chip(struct flash_device *dev)
{
	char* flash_addr = dev->vaddr;
	
	outb(flash_addr + 0x555, 0xaa);
	outb(flash_addr + 0x2aa, 0x55);
	outb(flash_addr + 0x555, 0x80);
	outb(flash_addr + 0x555, 0xaa);
	outb(flash_addr + 0x2aa, 0x55);
	outb(flash_addr + 0x555, 0x10);
}

struct flash_ops mx_flash_ops = {
	.flash_erase_chip 	= mx_erase_chip,
	.flash_erase_sector = mx_erase_sector,
#if 0
	.flash_erase_busy	= sst_erase_busy,
	.flash_program_busy = sst_program_busy,
#endif
};
